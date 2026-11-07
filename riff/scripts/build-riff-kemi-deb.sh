#!/usr/bin/env bash
# Build arm64 kemi-riff .deb wrapping upstream aarch64-linux static (walles/riff).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.7.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-riff
DL="${DL:-$ROOT/dl}"
BIN_SRC_FILE="$DL/riff-3.7.0-aarch64-linux"
URL="https://github.com/walles/riff/releases/download/${VER_UP}/riff-${VER_UP}-aarch64-linux"
EXPECT_SHA=1acbe244b18a4d60b7ef5aafb5f8c538548817ab528c52bccabf27737e3698df
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC_FILE" ]]; then
  curl -fsSL -o "$BIN_SRC_FILE" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC_FILE" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC_FILE" "$STAGE/pkg/usr/bin/riff"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/walles/riff
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-riff
riff $VER_UP — A diff filter highlighting which line parts have changed.
Upstream aarch64-linux static binary under /usr/bin/riff.
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
Description: riff diff highlighter (arm64 static)
 riff $VER_UP — A diff filter highlighting changed line parts.
 aarch64-linux static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
