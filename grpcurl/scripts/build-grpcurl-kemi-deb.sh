#!/usr/bin/env bash
# Build arm64 kemi-grpcurl .deb wrapping upstream linux_arm64 static (fullstorydev/grpcurl).
# Binary command: grpcurl. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.9.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-grpcurl
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/grpcurl_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/fullstorydev/grpcurl/releases/download/v${VER_UP}/grpcurl_${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=ad66227d90631da5428b4a5ccf28d63846f0f15649d8b2367df044a59edbb617
EXPECT_BIN=76f633f7dbbf1e63661ab18311d7c1d4dec559937844e7b8f191d29ae742dc8f
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name grpcurl | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/grpcurl"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/fullstorydev/grpcurl
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-grpcurl
grpcurl $VER_UP — Like curl, but for gRPC.
Upstream linux_arm64 static binary under /usr/bin/grpcurl.
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
Description: grpcurl gRPC CLI (arm64 static)
 grpcurl $VER_UP — Like curl, but for gRPC.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
