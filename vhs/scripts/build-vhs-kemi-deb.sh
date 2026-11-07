#!/usr/bin/env bash
# Build arm64 kemi-vhs .deb wrapping upstream Linux_arm64 static (charmbracelet/vhs).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.12.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-vhs
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/vhs_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/vhs/releases/download/v${VER_UP}/vhs_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=0b27029809fcc2ca2c381cceb854cbe03479a0f229b963e9bc3a2f2c36ffd3e7
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/vhs_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/vhs"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/vhs"
if [[ -f "$SRC/manpages/vhs.1.gz" ]]; then
  install -m 0644 "$SRC/manpages/vhs.1.gz" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completions/vhs.bash" ]]; then
  install -m 0644 "$SRC/completions/vhs.bash" "$STAGE/pkg/usr/share/bash-completion/completions/vhs"
fi
if [[ -f "$SRC/completions/vhs.zsh" ]]; then
  install -m 0644 "$SRC/completions/vhs.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_vhs"
fi
if [[ -f "$SRC/completions/vhs.fish" ]]; then
  install -m 0644 "$SRC/completions/vhs.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/vhs.fish"
fi
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/vhs
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-vhs
vhs $VER_UP — Write terminal GIFs as code for documentation and demos.
Upstream Linux_arm64 static binary under /usr/bin/vhs.
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
Description: vhs terminal GIF as code (arm64 static)
 vhs $VER_UP — Write terminal GIFs as code.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
