#!/usr/bin/env bash
# Build arm64 kemi-stern .deb wrapping upstream linux_arm64 static (stern/stern).
# Binary command: stern. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.35.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-stern
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/stern_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/stern/stern/releases/download/v${VER_UP}/stern_${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=b12f5e2ee0d01f6f21e0759cced0be2d8df9cd4e93e6a3cf11393170ae0f43cf
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name stern | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/stern"
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/stern/stern
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-stern
stern $VER_UP — multi pod and container log tailing for Kubernetes.
Upstream linux_arm64 static binary (CGO_ENABLED=0) under /usr/bin/stern.
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
Description: stern multi-pod Kubernetes log tail (arm64 static)
 stern $VER_UP — multi pod and container log tailing for Kubernetes.
 linux_arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
