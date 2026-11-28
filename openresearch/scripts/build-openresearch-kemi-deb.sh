#!/usr/bin/env bash
# Wrap official OpenResearch musl CLI (static aarch64). Verify ≠ compile.
# Do not ship the Linux desktop AppImage (upstream documents glibc 2.35+).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.2.30
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-openresearch
DL="${DL:-$ROOT/dl}"
TAR="$DL/openresearch-cli-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/alphaXiv/OpenResearch/releases/download/v${VER_UP}/openresearch-cli-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=e07b12714029b58d05a0d20c1d3c73a68a4035ee7a6dc89f75c2eeaeddbf75d8
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  if [[ -f /tmp/t160-inv/orx/openresearch-cli-aarch64-unknown-linux-musl.tar.gz ]]; then
    cp -a /tmp/t160-inv/orx/openresearch-cli-aarch64-unknown-linux-musl.tar.gz "$TAR"
  else
    curl -fsSL -o "$TAR" "$URL"
  fi
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
# tarball root is openresearch-cli-aarch64-unknown-linux-musl/
BIN="$STAGE/extract/openresearch-cli-aarch64-unknown-linux-musl/orx"
test -x "$BIN"
python3 - << PY
import subprocess,re,sys
p="$BIN"
ident=subprocess.check_output(["readelf","-h",p], text=True, errors="replace")
if "AArch64" not in ident:
    sys.exit("not aarch64")
interp=subprocess.check_output(["readelf","-l",p], text=True, errors="replace")
if "Requesting program interpreter" in interp:
    sys.exit("unexpected INTERP (want static)")
dyn=subprocess.run(["readelf","-d",p], capture_output=True, text=True)
if "NEEDED" in dyn.stdout:
    sys.exit("unexpected NEEDED")
ver=subprocess.run(["readelf","-V",p], capture_output=True, text=True)
if re.search(r"GLIBC_([0-9.]+)", ver.stdout):
    sys.exit("unexpected GLIBC")
print("PROBE static aarch64 EXEC no INTERP no NEEDED")
PY
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/opt/openresearch" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/pkg/opt/openresearch/orx"
if [[ -f $STAGE/extract/openresearch-cli-aarch64-unknown-linux-musl/LICENSE ]]; then
  install -m 0644 "$STAGE/extract/openresearch-cli-aarch64-unknown-linux-musl/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
elif [[ -f $ROOT/licenses-openresearch.txt ]]; then
  install -m 0644 "$ROOT/licenses-openresearch.txt" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
if [[ -f $STAGE/extract/openresearch-cli-aarch64-unknown-linux-musl/README.md ]]; then
  install -m 0644 "$STAGE/extract/openresearch-cli-aarch64-unknown-linux-musl/README.md" "$STAGE/pkg/usr/share/doc/$PKG/README.upstream.md"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-openresearch
OpenResearch CLI $VER_UP official aarch64-unknown-linux-musl (static aarch64 EXEC).
The Linux desktop AppImage is not included (upstream: glibc 2.35+).
Commands: orx, openresearch. User supplies credentials as documented upstream.
合主线：gork.bot协助开发
EOT
ln -s /opt/openresearch/orx "$STAGE/pkg/usr/bin/orx"
ln -s /opt/openresearch/orx "$STAGE/pkg/usr/bin/openresearch"
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: OpenResearch CLI research agent (arm64)
 Official OpenResearch $VER_UP linux musl CLI (static aarch64).
 MIT. User supplies credentials. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
