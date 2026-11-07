#!/usr/bin/env bash
# Build arm64 kemi-hexyl .deb wrapping upstream aarch64-unknown-linux-gnu (MAX GLIBC 2.17).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.17.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-hexyl
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/hexyl-v0.17.0-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/sharkdp/hexyl/releases/download/v${VER_UP}/hexyl-v${VER_UP}-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=70b97648935f98801fd3c3e4758ff4e92afcf7e75316ff65d4e4f5d2e321b658
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/hexyl-v${VER_UP}-aarch64-unknown-linux-gnu/hexyl"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/hexyl"
# man if present
if [[ -f "$EXTRACT/hexyl-v${VER_UP}-aarch64-unknown-linux-gnu/hexyl.1" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/man/man1"
  install -m 0644 "$EXTRACT/hexyl-v${VER_UP}-aarch64-unknown-linux-gnu/hexyl.1" "$STAGE/pkg/usr/share/man/man1/"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/sharkdp/hexyl
License: MIT/Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-hexyl
hexyl $VER_UP — command-line hex viewer. Upstream aarch64-gnu MAX GLIBC 2.17.
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
Description: hexyl hex viewer (arm64)
 hexyl $VER_UP — colorful command-line hex viewer.
 aarch64-gnu MAX GLIBC 2.17. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
