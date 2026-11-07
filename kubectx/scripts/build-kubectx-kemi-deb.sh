#!/usr/bin/env bash
# Build arm64 kemi-kubectx .deb wrapping upstream linux_arm64 static (ahmetb/kubectx).
# Single-CLI: install only kubectx (kubens packaged separately). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.11.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-kubectx
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/kubectx_v${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/ahmetb/kubectx/releases/download/v${VER_UP}/kubectx_v${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=1dac2072216689e773325cb7587b858ea7415706ebcf04e23bf80e7e70555340
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name kubectx | head -1)
test -f "$BIN_SRC"
! find "$EXTRACT" -name kubens | grep -q .
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/kubectx"
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ahmetb/kubectx
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
Single-CLI: kubectx only (kubens packaged separately).
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-kubectx
kubectx $VER_UP — faster way to switch between clusters in kubectl.
Upstream linux_arm64 static binary (CGO_ENABLED=0) under /usr/bin/kubectx.
Single-CLI package (kubens not included).
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
Description: kubectx Kubernetes context switcher (arm64 static)
 kubectx $VER_UP — faster way to switch between clusters in kubectl.
 linux_arm64 static (CGO_ENABLED=0). Single-CLI (no kubens). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
