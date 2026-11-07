#!/usr/bin/env bash
# Build arm64 kemi-oha .deb wrapping upstream linux-arm64 static (hatoo/oha).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.16.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-oha
DL="${DL:-$ROOT/dl}"
BIN_SRC_FILE="$DL/oha-linux-arm64"
URL="https://github.com/hatoo/oha/releases/download/v${VER_UP}/oha-linux-arm64"
EXPECT_SHA=99a790eb8c3e0feaca974bd6b32f0f8d4426a0c5b289f39e833e5b2c7529cd39
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC_FILE" ]]; then
  curl -fsSL -o "$BIN_SRC_FILE" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC_FILE" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC_FILE" "$STAGE/pkg/usr/bin/oha"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/hatoo/oha
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-oha
oha $VER_UP — HTTP load generator, inspired by rakyll/hey with tui animation.
Upstream linux-arm64 static binary under /usr/bin/oha.
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
Description: oha HTTP load generator (arm64 static)
 oha $VER_UP — HTTP load generator with TUI animation.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
