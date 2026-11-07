#!/usr/bin/env bash
# Build arm64 kemi-dive .deb wrapping upstream static linux_arm64 (wagoodman/dive).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.13.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-dive
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/dive_0.13.1_linux_arm64.tar.gz"
URL="https://github.com/wagoodman/dive/releases/download/v${VER_UP}/dive_${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=2fcd2cf20f634ccdb41efac44048b204bfc867c115641f37a7420693ed480a18
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/dive"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/dive"
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/wagoodman/dive
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-dive
dive $VER_UP — explore a docker image, layer contents, and discover ways to shrink.
Static linux_arm64 upstream binary under /usr/bin/dive.
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
Description: dive docker image explorer (arm64 static)
 dive $VER_UP — explore docker image layers and shrink opportunities.
 Static linux_arm64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
