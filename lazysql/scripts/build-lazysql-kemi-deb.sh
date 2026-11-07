#!/usr/bin/env bash
# Build arm64 kemi-lazysql .deb wrapping upstream Linux_arm64 static (jorgerojas26/lazysql).
# Binary command: lazysql. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.7.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-lazysql
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/lazysql_Linux_arm64.tar.gz"
URL="https://github.com/jorgerojas26/lazysql/releases/download/v${VER_UP}/lazysql_Linux_arm64.tar.gz"
EXPECT_SHA=2157e58f107bd9c250ad4d106e31d3f3484cfd93280b1c59f25a2dd0965e9128
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name lazysql | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/lazysql"
if [[ -f "$EXTRACT/LICENSE.txt" ]]; then
  install -m 0644 "$EXTRACT/LICENSE.txt" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE.txt"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/jorgerojas26/lazysql
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-lazysql
lazysql $VER_UP — a cross-platform TUI database management tool.
Upstream Linux_arm64 static binary (CGO_ENABLED=0) under /usr/bin/lazysql.
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
Description: lazysql database TUI (arm64 static)
 lazysql $VER_UP — cross-platform TUI database management tool.
 Linux_arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
