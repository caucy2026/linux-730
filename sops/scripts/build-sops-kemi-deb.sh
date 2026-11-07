#!/usr/bin/env bash
# Build arm64 kemi-sops .deb wrapping upstream static linux.arm64 (getsops/sops).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.13.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-sops
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/sops-v${VER_UP}.linux.arm64"
URL="https://github.com/getsops/sops/releases/download/v${VER_UP}/sops-v${VER_UP}.linux.arm64"
EXPECT_SHA=53b0abacd38ef1b12a66d6c100956691b9cefce018d91f81e73ddf7438b94d77
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
test -f "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/sops"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/getsops/sops
License: MPL-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-sops
sops $VER_UP — Simple and flexible tool for managing secrets.
Static linux.arm64 upstream binary under /usr/bin/sops.
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
Description: sops secrets manager (arm64 static)
 sops $VER_UP — Simple and flexible tool for managing secrets.
 Static linux.arm64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
