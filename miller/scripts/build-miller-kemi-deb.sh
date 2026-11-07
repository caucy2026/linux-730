#!/usr/bin/env bash
# Build arm64 kemi-miller .deb wrapping upstream linux-arm64 static Go binary (mlr).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=6.22.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-miller
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/miller-6.22.0-linux-arm64.tar.gz"
URL="https://github.com/johnkerl/miller/releases/download/v${VER_UP}/miller-${VER_UP}-linux-arm64.tar.gz"
EXPECT_SHA=86dbf9078cf4cd96fef7a8306b3786a441cdf7f8526324a233e38c37c4bfe742
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/miller-${VER_UP}-linux-arm64/mlr"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/mlr"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/johnkerl/miller
License: BSD-2-Clause / see upstream LICENSE.txt
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-miller
miller $VER_UP — like awk/sed/cut/join/sort for name-indexed data. Upstream linux-arm64 static Go (mlr).
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
Description: miller (mlr) data tool (arm64 static)
 miller $VER_UP — name-indexed data processing like awk/sed/cut.
 Static aarch64 Go (/usr/bin/mlr). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
