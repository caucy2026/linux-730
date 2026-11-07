#!/usr/bin/env bash
# Build arm64 kemi-helmfile .deb wrapping upstream linux_arm64 static (helmfile/helmfile).
# Binary command: helmfile. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.8.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-helmfile
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/helmfile_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/helmfile/helmfile/releases/download/v${VER_UP}/helmfile_${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=e035c0338e31e0a8054ae798280532d32edcfbb7d6c4993e3b2efa2dc40647ce
EXPECT_BIN=b3aa06cfe772b59b658aed6be68fc0d2b3d6a0a04dd6c97c996e9990601b83a2
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name helmfile | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/helmfile"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/helmfile/helmfile
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-helmfile
helmfile $VER_UP — Deploy Kubernetes Helm Charts declaratively.
Upstream linux_arm64 static binary under /usr/bin/helmfile.
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
Description: helmfile declarative Helm deployments (arm64 static)
 helmfile $VER_UP — Deploy Kubernetes Helm Charts.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
