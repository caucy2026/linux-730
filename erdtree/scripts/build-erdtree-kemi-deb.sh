#!/usr/bin/env bash
# Build arm64 kemi-erdtree .deb wrapping upstream aarch64-unknown-linux-musl static (erd).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.1.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-erdtree
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/erd-v3.1.2-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/solidiquis/erdtree/releases/download/v${VER_UP}/erd-v${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=5ad6d70a7ba9636f80a724e669e7ffe9daf2370f8a3f6095e33779e166ced4c2
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/erd"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/erd"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/solidiquis/erdtree
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-erdtree
erdtree $VER_UP — multi-threaded file-tree visualizer and disk usage analyzer (erd). Upstream aarch64 musl static.
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
Description: erdtree (erd) file-tree viewer (arm64 musl static)
 erdtree $VER_UP — multi-threaded file-tree / disk usage (erd).
 Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
