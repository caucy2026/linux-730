#!/usr/bin/env bash
# Build arm64 kemi-lnav .deb wrapping upstream linux-musl-arm64 (tstack/lnav).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.14.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-lnav
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/lnav-0.14.1-linux-musl-arm64.zip"
URL="https://github.com/tstack/lnav/releases/download/v${VER_UP}/lnav-${VER_UP}-linux-musl-arm64.zip"
EXPECT_SHA=e605ac855af193b5c7201e2fd94372febec931c5721b50fdf828b3e5af90c677
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
SRC="$EXTRACT/lnav-${VER_UP}"
BIN_SRC="$SRC/lnav"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" "$STAGE/pkg/usr/share/man/man1"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/lnav"
if [[ -f "$SRC/lnav.1" ]]; then
  install -m 0644 "$SRC/lnav.1" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/README" ]]; then
  install -m 0644 "$SRC/README" "$STAGE/pkg/usr/share/doc/$PKG/README"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tstack/lnav
License: BSD-2-Clause (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-lnav
lnav $VER_UP — An advanced log file viewer for the small-scale.
Upstream linux-musl-arm64 static binary under /usr/bin/lnav.
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
Description: lnav log file viewer (arm64 musl)
 lnav $VER_UP — An advanced log file viewer for the small-scale.
 linux-musl-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
