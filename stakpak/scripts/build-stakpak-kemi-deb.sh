#!/usr/bin/env bash
# Wrap official stakpak linux-aarch64 static CLI. Verify ≠ compile.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.3.88
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-stakpak
DL="${DL:-$ROOT/dl}"
TAR="$DL/stakpak-linux-aarch64.tar.gz"
URL="https://github.com/stakpak/agent/releases/download/v${VER_UP}/stakpak-linux-aarch64.tar.gz"
EXPECT_SHA=8312b611b5a635ea7411555f082b0fb3b6d644f99007d2c6a1f30fc6c13e725d
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  if [[ -f /tmp/t161-inv/stakpak/stakpak-linux-aarch64.tar.gz ]]; then
    cp -a /tmp/t161-inv/stakpak/stakpak-linux-aarch64.tar.gz "$TAR"
  else
    curl -fsSL -o "$TAR" "$URL"
  fi
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN="$STAGE/extract/stakpak"
test -x "$BIN"
python3 - << PY
import subprocess,sys
p="$BIN"
ident=subprocess.check_output(["readelf","-h",p], text=True, errors="replace")
if "AArch64" not in ident:
    sys.exit("not aarch64")
interp=subprocess.check_output(["readelf","-l",p], text=True, errors="replace")
if "Requesting program interpreter" in interp:
    sys.exit("unexpected INTERP (want static)")
dyn=subprocess.run(["readelf","-d",p], capture_output=True, text=True)
if "NEEDED" in dyn.stdout or "Dynamic section" in dyn.stdout:
    # readelf says "There is no dynamic section" for static
    if "NEEDED" in dyn.stdout:
        sys.exit("unexpected NEEDED")
print("PROBE static aarch64 EXEC no INTERP no NEEDED")
PY
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/opt/stakpak" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/pkg/opt/stakpak/stakpak"
if [[ -f $ROOT/licenses-stakpak.txt ]]; then
  install -m 0644 "$ROOT/licenses-stakpak.txt" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-stakpak
Stakpak CLI $VER_UP official linux-aarch64 (static aarch64 EXEC).
Command: stakpak. User supplies credentials as documented upstream.
合主线：gork.bot协助开发
EOT
ln -s /opt/stakpak/stakpak "$STAGE/pkg/usr/bin/stakpak"
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Stakpak autonomous agent CLI (arm64)
 Official Stakpak $VER_UP Linux aarch64 CLI (static aarch64).
 Apache-2.0. User supplies credentials. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
