#!/usr/bin/env bash
# Build arm64 kemi-mise .deb wrapping upstream linux-arm64-musl (jdx/mise).
# Single CLI: /usr/bin/mise (+ man + fish activate). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2026.11.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-mise
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/mise-v${VER_UP}-linux-arm64-musl.tar.gz"
URL="https://github.com/jdx/mise/releases/download/v${VER_UP}/mise-v${VER_UP}-linux-arm64-musl.tar.gz"
EXPECT_SHA=975fcaac68ddf1a667ceceab30168989d3645f6894b39b40a7b0e6de94096101
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/mise"
BIN_SRC="$SRC/bin/mise"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/fish/vendor_conf.d" \
  "$STAGE/pkg/usr/lib/mise"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/mise"
# helper archive used by mise (not a second CLI)
if [[ -f "$SRC/bin/mise.d" ]]; then
  install -m 0644 "$SRC/bin/mise.d" "$STAGE/pkg/usr/lib/mise/mise.d"
fi
if [[ -f "$SRC/man/man1/mise.1" ]]; then
  install -m 0644 "$SRC/man/man1/mise.1" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/share/fish/vendor_conf.d/mise-activate.fish" ]]; then
  install -m 0644 "$SRC/share/fish/vendor_conf.d/mise-activate.fish" "$STAGE/pkg/usr/share/fish/vendor_conf.d/"
fi
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/jdx/mise
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-mise
mise $VER_UP — The front-end to your dev env (polyglot tool version manager).
Upstream linux-arm64-musl static binary under /usr/bin/mise.
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
Description: mise polyglot version manager (arm64 musl)
 mise $VER_UP — The front-end to your dev env.
 linux-arm64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
