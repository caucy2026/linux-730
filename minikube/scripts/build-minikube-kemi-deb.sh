#!/usr/bin/env bash
# Build arm64 kemi-minikube .deb wrapping upstream linux-arm64 static (kubernetes/minikube).
# Binary command: minikube. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.39.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-minikube
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/minikube-linux-arm64.tar.gz"
URL="https://github.com/kubernetes/minikube/releases/download/v${VER_UP}/minikube-linux-arm64.tar.gz"
EXPECT_TGZ=2ce53fe7bb99b595739b076d19ad45da5e199c4b06d6fa508b171a566cc49ed7
EXPECT_BIN=202f331cb677761c5aec81c58472d16d65707358b9f66226210be3fe3275b1c3
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f \( -name 'minikube-linux-arm64' -o -name minikube \) | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/minikube"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/kubernetes/minikube
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-minikube
minikube $VER_UP — run Kubernetes locally.
Upstream linux-arm64 static binary (CGO_ENABLED=0) under /usr/bin/minikube.
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
Description: minikube local Kubernetes (arm64 static)
 minikube $VER_UP — run Kubernetes locally.
 linux-arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
