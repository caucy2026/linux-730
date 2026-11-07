#!/usr/bin/env bash
# Build arm64 kemi-argocd .deb wrapping upstream linux-arm64 static (argoproj/argo-cd).
# Binary command: argocd. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.6.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-argocd
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/argocd-linux-arm64"
URL="https://github.com/argoproj/argo-cd/releases/download/v${VER_UP}/argocd-linux-arm64"
EXPECT_BIN=6636e9183de7dba666b673a417986e7ff54dbadd948b2f9f6c83bcf7d33ebb94
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -L -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/argocd"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/argoproj/argo-cd
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-argocd
argocd $VER_UP — Declarative GitOps continuous delivery for Kubernetes.
Upstream linux-arm64 static binary under /usr/bin/argocd.
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
Description: argocd GitOps CLI for Kubernetes (arm64 static)
 argocd $VER_UP — Declarative GitOps continuous delivery.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
