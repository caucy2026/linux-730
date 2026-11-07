#!/usr/bin/env bash
# Build arm64 kemi-sad .deb wrapping upstream aarch64-musl (ms-jpq/sad).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.4.33
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-sad
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/sad-v0.4.33-aarch64-unknown-linux-musl.zip"
URL="https://github.com/ms-jpq/sad/releases/download/v${VER_UP}/aarch64-unknown-linux-musl.zip"
EXPECT_SHA=81546b7fa93a8b5928fc2b780ccb84e51cdc463d9a635cc835b9dab2d3ad5e46
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC="$EXTRACT/sad"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/sad"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ms-jpq/sad
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-sad
sad $VER_UP — Search And Replace CLI tool (interactive, space-diff preview).
Upstream aarch64-musl static binary under /usr/bin/sad.
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
Description: sad search-and-replace (arm64 musl)
 sad $VER_UP — Search And Replace CLI with interactive preview.
 aarch64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
