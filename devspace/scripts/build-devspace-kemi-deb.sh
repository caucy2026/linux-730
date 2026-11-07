#!/usr/bin/env bash
# Build arm64 kemi-devspace .deb wrapping upstream linux-arm64 static (devspace-sh/devspace).
# Binary command: devspace. 合主线：gork.bot协助开发
# Note: tilt v0.37.8 SKIP (GLIBC_2.34) → fallback this package for t252.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=6.3.21
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-devspace
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/devspace-linux-arm64"
URL="https://github.com/devspace-sh/devspace/releases/download/v${VER_UP}/devspace-linux-arm64"
EXPECT_BIN=8652285a22f079d4bfeda37a2f1089d56e64a34a76d32537dfb20a7cd6e69fcb
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -L -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/devspace"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/devspace-sh/devspace
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-devspace
devspace $VER_UP — Cloud-Native Development for Kubernetes.
Upstream linux-arm64 static binary under /usr/bin/devspace.
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
Description: devspace Kubernetes development CLI (arm64 static)
 devspace $VER_UP — Cloud-Native Development for Kubernetes.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
