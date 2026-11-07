#!/usr/bin/env bash
# Build arm64 kemi-trippy .deb wrapping upstream aarch64-musl (fujiapple852/trippy).
# Binary installed as /usr/bin/trip.
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.13.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-trippy
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/trippy-0.13.0-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/fujiapple852/trippy/releases/download/${VER_UP}/trippy-${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=73af939aa94e9e0f07cac2b3c8177e02a6b1c3be88299d85988e02be81ae7004
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/trippy-${VER_UP}-aarch64-unknown-linux-musl/trip"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/trip"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/fujiapple852/trippy
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-trippy
trippy $VER_UP — A network diagnostic tool (command: trip).
Upstream aarch64-musl static binary under /usr/bin/trip.
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
Description: trippy network diagnostic (arm64 musl)
 trippy $VER_UP — A network diagnostic tool (command: trip).
 aarch64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
