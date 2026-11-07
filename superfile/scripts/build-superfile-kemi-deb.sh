#!/usr/bin/env bash
# Build arm64 kemi-superfile .deb wrapping upstream linux arm64 static (yorukot/superfile).
# Binary command: spf. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.6.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-superfile
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/superfile-linux-v${VER_UP}-arm64.tar.gz"
URL="https://github.com/yorukot/superfile/releases/download/v${VER_UP}/superfile-linux-v${VER_UP}-arm64.tar.gz"
EXPECT_SHA=2e8150dab1a139e3a081bd74a9c775155e8d0241c34ae3f8d30817a3df1b8f06
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT" 2>/dev/null || tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name spf | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/spf"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/yorukot/superfile
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-superfile
superfile $VER_UP — Pretty fancy and modern terminal file manager (command: spf).
Upstream linux arm64 static binary under /usr/bin/spf.
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
Description: superfile terminal file manager (arm64 static)
 superfile $VER_UP — modern terminal file manager (command: spf).
 linux arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
