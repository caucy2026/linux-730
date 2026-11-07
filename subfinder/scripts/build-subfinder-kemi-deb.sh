#!/usr/bin/env bash
# Build arm64 kemi-subfinder .deb wrapping upstream subfinder linux_arm64.
# Binary command: subfinder. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.17.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-subfinder
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/subfinder_${VER_UP}_linux_arm64.zip"
URL="https://github.com/projectdiscovery/subfinder/releases/download/v${VER_UP}/subfinder_${VER_UP}_linux_arm64.zip"
EXPECT_ZIP=24913d49dddc1d3a5e99a4a7580da5be980959b9415b96f52c4f7f4124392190
EXPECT_BIN=e6a8fb863f26315b8ab79a956d79847fd91970045979c374874e0755cabe7588
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name subfinder | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/subfinder"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/projectdiscovery/subfinder
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-subfinder
subfinder $VER_UP — subdomain discovery tool.
Upstream linux-arm64 static binary under /usr/bin/subfinder.
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
Description: subfinder subdomain discovery CLI (arm64 static)
 subfinder $VER_UP — Fast passive subdomain enumeration tool.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
