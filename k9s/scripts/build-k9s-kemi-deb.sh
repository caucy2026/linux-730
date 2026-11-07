#!/usr/bin/env bash
# Build arm64 kemi-k9s .deb wrapping upstream Linux_arm64 static (derailed/k9s).
# Binary command: k9s. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.51.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-k9s
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/k9s_Linux_arm64.tar.gz"
URL="https://github.com/derailed/k9s/releases/download/v${VER_UP}/k9s_Linux_arm64.tar.gz"
EXPECT_SHA=3ee05c82e5f9198928a4e86133608ba6a2c10a2244d6a7789e820f78319d640c
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name k9s | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/k9s"
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/derailed/k9s
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-k9s
k9s $VER_UP — Kubernetes CLI to manage your clusters in style.
Upstream Linux_arm64 static binary (CGO_ENABLED=0) under /usr/bin/k9s.
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
Description: k9s Kubernetes TUI (arm64 static)
 k9s $VER_UP — Kubernetes CLI to manage your clusters in style.
 Linux_arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
