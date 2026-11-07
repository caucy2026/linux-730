#!/usr/bin/env bash
# Build arm64 kemi-kubeseal .deb wrapping upstream linux-arm64 static (bitnami/sealed-secrets).
# Binary command: kubeseal. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.41.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-kubeseal
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/kubeseal-${VER_UP}-linux-arm64.tar.gz"
URL="https://github.com/bitnami/sealed-secrets/releases/download/v${VER_UP}/kubeseal-${VER_UP}-linux-arm64.tar.gz"
EXPECT_SHA=8a73c0b252f6c0e8752a7a749da51f55a6e99dc5603e3bd29ed3c00ff9e82db2
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name kubeseal | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/kubeseal"
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/bitnami/sealed-secrets (kubeseal CLI)
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-kubeseal
kubeseal $VER_UP — client-side utility for Sealed Secrets.
Upstream linux-arm64 static binary (CGO_ENABLED=0) under /usr/bin/kubeseal.
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
Description: kubeseal Sealed Secrets CLI (arm64 static)
 kubeseal $VER_UP — client-side utility for Sealed Secrets.
 linux-arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
