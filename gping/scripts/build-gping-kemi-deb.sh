#!/usr/bin/env bash
# Build arm64 kemi-gping .deb wrapping upstream Linux-musl-arm64 (orf/gping).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.21.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gping
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/gping-Linux-musl-arm64.tar.gz"
URL="https://github.com/orf/gping/releases/download/gping-v${VER_UP}/gping-Linux-musl-arm64.tar.gz"
EXPECT_SHA=75e485e9ae081b4478b7c9fea0585a125dd7e640334cdbdec852af6238c3f1f1
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/gping"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" "$STAGE/pkg/usr/share/man/man1"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/gping"
if [[ -f "$EXTRACT/gping.1" ]]; then
  install -m 0644 "$EXTRACT/gping.1" "$STAGE/pkg/usr/share/man/man1/"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/orf/gping
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gping
gping $VER_UP — Ping, but with a graph.
Upstream Linux-musl-arm64 static binary under /usr/bin/gping.
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
Description: gping ping with graph (arm64 musl)
 gping $VER_UP — Ping, but with a graph.
 Linux-musl-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
