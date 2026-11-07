#!/usr/bin/env bash
# Build arm64 kemi-katana .deb wrapping upstream katana linux_arm64 (projectdiscovery/katana).
# Binary command: katana. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.8.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-katana
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/katana_${VER_UP}_linux_arm64.zip"
URL="https://github.com/projectdiscovery/katana/releases/download/v${VER_UP}/katana_${VER_UP}_linux_arm64.zip"
EXPECT_ZIP=80e269210727a855511ffac8dfb01297b2344742acec71a35e8ba4a67a90f0f2
EXPECT_BIN=d1cad5684a2561ede5d79844cbe5fc18ab783742c215df7c53a89baddd5800c7
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name katana | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/katana"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/projectdiscovery/katana
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-katana
katana $VER_UP — next-generation crawling / spidering framework.
Upstream linux-arm64 static binary under /usr/bin/katana.
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
Description: katana web crawler CLI (arm64 static)
 katana $VER_UP — A next-generation crawling and spidering framework.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
