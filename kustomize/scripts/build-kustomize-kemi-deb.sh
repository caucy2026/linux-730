#!/usr/bin/env bash
# Build arm64 kemi-kustomize .deb wrapping upstream linux_arm64 static (kubernetes-sigs/kustomize).
# Binary command: kustomize. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=5.8.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-kustomize
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/kustomize_v${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${VER_UP}/kustomize_v${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=9867b76482cfc6d25b546abc1d2b5a32bd137505aba640649b4b378f64f6d68f
EXPECT_BIN=dd14c7e37e65cd2ec6dd07dfaf0bf02355113d9b925dfa47c1354134a6f8051b
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name kustomize | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/kustomize"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/kubernetes-sigs/kustomize
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-kustomize
kustomize $VER_UP — Customize Kubernetes YAML configurations.
Upstream linux_arm64 static binary under /usr/bin/kustomize.
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
Description: kustomize Kubernetes YAML customizer (arm64 static)
 kustomize $VER_UP — Customize Kubernetes YAML configurations.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
