#!/usr/bin/env bash
# Wrap official Kilo Code linux-arm64 (gnu) CLI. Verify ≠ compile.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=7.8.40
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-kilo-code
DL="${DL:-$ROOT/dl}"
TAR="$DL/kilo-linux-arm64.tar.gz"
URL="https://github.com/Kilo-Org/kilocode/releases/download/v${VER_UP}/kilo-linux-arm64.tar.gz"
EXPECT_SHA=3e7b140cd446c09b1f48589085d7b4b975889e37255eb4d71ebf80b506f54661
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  # reuse already-verified copy if present
  if [[ -f /tmp/t160-inv/kilo/kilo-linux-arm64.tar.gz ]]; then
    cp -a /tmp/t160-inv/kilo/kilo-linux-arm64.tar.gz "$TAR"
  else
    curl -fsSL -o "$TAR" "$URL"
  fi
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN="$STAGE/extract/kilo"
test -x "$BIN"
# ABI probe of every ELF
python3 - << PY
import os,subprocess,re,sys
from pathlib import Path
root=Path("$STAGE/extract")
ELFMAG=b"\\x7fELF"
def keyv(s): return [int(x) for x in s.split(".")]
elfs=[]
for p in root.rglob("*"):
    if p.is_file():
        try:
            if p.open("rb").read(4)==ELFMAG:
                elfs.append(p)
        except Exception:
            pass
allg=[]; machines=set()
for p in elfs:
    ident=subprocess.check_output(["readelf","-h",str(p)], text=True, errors="replace")
    machine=next((l.split(":",1)[1].strip() for l in ident.splitlines() if "Machine:" in l),"?")
    machines.add(machine)
    if machine != "AArch64":
        sys.exit(f"foreign arch {machine} {p}")
    interp=subprocess.check_output(["readelf","-l",str(p)], text=True, errors="replace")
    if "ld-musl-" in interp:
        sys.exit(f"dynamic musl {p}")
    ver=subprocess.run(["readelf","-V",str(p)], capture_output=True, text=True)
    glibc=sorted(set(re.findall(r"GLIBC_([0-9.]+)", ver.stdout)), key=keyv)
    cxx=sorted(set(re.findall(r"GLIBCXX_([0-9.]+)", ver.stdout)), key=keyv)
    allg.extend(glibc)
    if glibc and keyv(glibc[-1])>[2,31]:
        sys.exit(f"GLIBC {glibc[-1]} {p}")
    if cxx and keyv(cxx[-1])>[3,4,28]:
        sys.exit(f"GLIBCXX {cxx[-1]} {p}")
print("ELF_COUNT", len(elfs), "MACHINES", machines, "MAX_GLIBC", max(allg, key=keyv) if allg else "none")
PY
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/opt/kilo-code" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
# official tree as-is
cp -a "$STAGE/extract/." "$STAGE/pkg/opt/kilo-code/"
chmod 0755 "$STAGE/pkg/opt/kilo-code/kilo"
[[ -x "$STAGE/pkg/opt/kilo-code/bwrap" ]] && chmod 0755 "$STAGE/pkg/opt/kilo-code/bwrap"
[[ -x "$STAGE/pkg/opt/kilo-code/kilo-sandbox-seccomp" ]] && chmod 0755 "$STAGE/pkg/opt/kilo-code/kilo-sandbox-seccomp"
ln -s /opt/kilo-code/kilo "$STAGE/pkg/usr/bin/kilo"
ln -s /opt/kilo-code/kilo "$STAGE/pkg/usr/bin/kilo-code"
if [[ -f "$ROOT/licenses-kilo.txt" ]]; then
  install -m 0644 "$ROOT/licenses-kilo.txt" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-kilo-code
Kilo Code CLI $VER_UP official linux-arm64 (gnu, MAX_GLIBC 2.17).
The official musl tarball is dynamic (ld-musl-aarch64.so.1) and is not used.
Command: kilo (also kilo-code). User supplies model/API credentials.
合主线：gork.bot协助开发
EOT
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Depends: libc6 (>= 2.17)
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Kilo Code CLI coding agent (arm64)
 Official Kilo Code $VER_UP Linux arm64 CLI (gnu, glibc 2.17).
 MIT. User supplies model credentials. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
