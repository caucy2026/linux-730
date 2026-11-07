#!/usr/bin/env bash
# Build arm64 kemi-gau .deb wrapping upstream gau linux_arm64 (lc/gau).
# Binary command: gau. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.2.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gau
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/gau_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/lc/gau/releases/download/v${VER_UP}/gau_${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=c194992df360d3a24e021c6dc5a5a0576cfd769be1d19cccb29adc1d3759637d
EXPECT_BIN=b6c7880b094696b322bb8df1857ad60c5e2109ce721362542921dfc8a8706838
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name gau | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/gau"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/lc/gau
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gau
gau $VER_UP — fetch known URLs from AlienVault OTX / Wayback / Common Crawl / URLScan.
Upstream linux-arm64 static binary under /usr/bin/gau.
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
Description: gau URL fetcher CLI (arm64 static)
 gau $VER_UP — Get All URLs from multiple sources.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
