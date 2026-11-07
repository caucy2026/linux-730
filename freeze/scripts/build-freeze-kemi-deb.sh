#!/usr/bin/env bash
# Build arm64 kemi-freeze .deb wrapping upstream Linux_arm64 static (charmbracelet/freeze).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.2.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-freeze
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/freeze_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/freeze/releases/download/v${VER_UP}/freeze_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=ba1164c2e6d573af32df13ddc5868f7cdfc8b9992f26f53695787ca5f4274023
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/freeze_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/freeze"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/freeze"
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/freeze
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-freeze
freeze $VER_UP — Generate images of code and terminal output.
Upstream Linux_arm64 static binary under /usr/bin/freeze.
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
Description: freeze code/terminal screenshots (arm64 static)
 freeze $VER_UP — Generate images of code and terminal output.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
