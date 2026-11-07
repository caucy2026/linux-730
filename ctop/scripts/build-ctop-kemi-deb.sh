#!/usr/bin/env bash
# Build arm64 kemi-ctop .deb wrapping upstream linux-arm64 static (bcicen/ctop).
# Binary command: ctop. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.7.7
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-ctop
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/ctop-${VER_UP}-linux-arm64"
URL="https://github.com/bcicen/ctop/releases/download/v${VER_UP}/ctop-${VER_UP}-linux-arm64"
EXPECT_SHA=d8d91e0fea53a8c78fa81192f078272e5a92f0ea6c4f0e38ec7c944d76e6f02f
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/ctop"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/bcicen/ctop
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-ctop
ctop $VER_UP — Top-like interface for container metrics.
Upstream linux-arm64 static binary (CGO_ENABLED=0) under /usr/bin/ctop.
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
Description: ctop container metrics TUI (arm64 static)
 ctop $VER_UP — top-like interface for container metrics.
 linux-arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
