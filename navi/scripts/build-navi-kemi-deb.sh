#!/usr/bin/env bash
# Build arm64 kemi-navi .deb wrapping upstream aarch64 static binary
# (release asset named *-linux-gnu but fully static — no NEEDED/INTERP).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.24.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-navi
DL="${DL:-$ROOT/dl}"
TGZ="$DL/navi-v2.24.0-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/denisidoro/navi/releases/download/v${VER_UP}/navi-v2.24.0-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=de99e69906a0e06ffd30a329645e15f9e96a6b42c49eaac8baccac9bc314768a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name navi | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/navi"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/denisidoro/navi
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-navi
navi $VER_UP — interactive cheatsheet tool for the command-line.
Upstream aarch64 static binary (asset tagged linux-gnu; ELF static).
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
Description: navi interactive cheatsheet (arm64 static)
 navi $VER_UP — Interactive cheatsheet tool for the command-line.
 Static aarch64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
