#!/usr/bin/env bash
# Build arm64 kemi-diskus .deb wrapping upstream aarch64-unknown-linux-gnu (MAX GLIBC 2.18).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.9.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-diskus
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/diskus-v0.9.0-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/sharkdp/diskus/releases/download/v${VER_UP}/diskus-v${VER_UP}-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=de8d7b4147911ed228fffeb49e4d19bc42c23a65eb4e3db98058ad9778a835cb
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/diskus-v${VER_UP}-aarch64-unknown-linux-gnu/diskus"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/diskus"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/sharkdp/diskus
License: MIT/Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-diskus
diskus $VER_UP — minimal, fast alternative to du -sh. Upstream aarch64-gnu MAX GLIBC 2.18.
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
Description: diskus fast du alternative (arm64)
 diskus $VER_UP — minimal fast alternative to du -sh.
 aarch64-gnu MAX GLIBC 2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
