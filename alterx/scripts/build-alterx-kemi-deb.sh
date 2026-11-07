#!/usr/bin/env bash
# Build arm64 kemi-alterx .deb wrapping upstream alterx linux_arm64 (projectdiscovery/alterx).
# Binary command: alterx. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.1.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-alterx
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/alterx_${VER_UP}_linux_arm64.zip"
URL="https://github.com/projectdiscovery/alterx/releases/download/v${VER_UP}/alterx_${VER_UP}_linux_arm64.zip"
EXPECT_ZIP=14dfdaebfee0ecce559afacf62e9e15e9f8aa7dd8a2a659d9e0b3bc2dbb4419f
EXPECT_BIN=2f5089571b847dc1d507e1e992ee9f29b2b7a4c7eff57a288fd4c1777b0280db
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name alterx | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/alterx"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/projectdiscovery/alterx
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-alterx
alterx $VER_UP — fast and customizable subdomain wordlist generator.
Upstream linux-arm64 static binary under /usr/bin/alterx.
合主线：gork.bot协助开发
EOR
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOC
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: alterx subdomain wordlist CLI (arm64 static)
 alterx $VER_UP — Fast customizable subdomain wordlist generator.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
