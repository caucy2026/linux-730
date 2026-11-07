#!/usr/bin/env bash
# Build arm64 kemi-wishlist .deb wrapping upstream Linux_arm64 static (charmbracelet/wishlist).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.15.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-wishlist
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/wishlist_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/wishlist/releases/download/v${VER_UP}/wishlist_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=8098b23e4e2464cf9507c58da572a9de396114c7bc9cda4eda7e3316d57754b9
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/wishlist_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/wishlist"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/wishlist"
[[ -f "$SRC/manpages/wishlist.1.gz" ]] && install -m 0644 "$SRC/manpages/wishlist.1.gz" "$STAGE/pkg/usr/share/man/man1/"
[[ -f "$SRC/completions/wishlist.bash" ]] && install -m 0644 "$SRC/completions/wishlist.bash" "$STAGE/pkg/usr/share/bash-completion/completions/wishlist"
[[ -f "$SRC/completions/wishlist.zsh" ]] && install -m 0644 "$SRC/completions/wishlist.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_wishlist"
[[ -f "$SRC/completions/wishlist.fish" ]] && install -m 0644 "$SRC/completions/wishlist.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/wishlist.fish"
for f in README.md LICENSE; do
  [[ -f "$SRC/$f" ]] && install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/wishlist
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-wishlist
wishlist $VER_UP — A SSH directory / SSH menu for your terminal.
Upstream Linux_arm64 static binary under /usr/bin/wishlist.
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
Description: wishlist SSH directory (arm64 static)
 wishlist $VER_UP — A SSH directory for your terminal.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
