#!/usr/bin/env bash
# Build arm64 kemi-skate .deb wrapping upstream Linux_arm64 static (charmbracelet/skate).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.1.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-skate
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/skate_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/skate/releases/download/v${VER_UP}/skate_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=bb8b413929f4b17d87ec84920316151dbd14090331a7a8fa90958daa4c65a12c
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/skate_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/skate"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/skate"
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/skate
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-skate
skate $VER_UP — A personal key-value store.
Upstream Linux_arm64 static binary under /usr/bin/skate.
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
Description: skate personal key-value store (arm64 static)
 skate $VER_UP — A personal key-value store.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
