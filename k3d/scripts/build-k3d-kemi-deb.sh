#!/usr/bin/env bash
# Build arm64 kemi-k3d .deb wrapping upstream linux-arm64 static (k3d-io/k3d).
# Binary command: k3d. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=5.9.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-k3d
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/k3d-linux-arm64"
URL="https://github.com/k3d-io/k3d/releases/download/v${VER_UP}/k3d-linux-arm64"
EXPECT_SHA=03cde5cf23e6e8e67de5a039ecf26e5b85aca82fba3e5d13dadf904cd218a250
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/k3d"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/k3d-io/k3d
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-k3d
k3d $VER_UP — little helper to run k3s in Docker.
Upstream linux-arm64 static binary (CGO_ENABLED=0) under /usr/bin/k3d.
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
Description: k3d run k3s in Docker (arm64 static)
 k3d $VER_UP — little helper to run k3s in Docker.
 linux-arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
