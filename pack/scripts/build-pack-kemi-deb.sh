#!/usr/bin/env bash
# Build arm64 kemi-pack .deb wrapping upstream linux-arm64 static (buildpacks/pack).
# Binary command: pack. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.40.10
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-pack
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/pack-v${VER_UP}-linux-arm64.tgz"
URL="https://github.com/buildpacks/pack/releases/download/v${VER_UP}/pack-v${VER_UP}-linux-arm64.tgz"
EXPECT_TGZ=9a294abb0576fd95e19a009b3f9d5f5aa9fecdc2d7da7fa05e7e1e94f5085d77
EXPECT_BIN=afab278a97b3cee841eb64b660e06492599316712b2010d088432f6dd1e7083f
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name pack | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/pack"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/buildpacks/pack
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-pack
pack $VER_UP — CLI for Cloud Native Buildpacks.
Upstream linux-arm64 static binary under /usr/bin/pack.
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
Description: pack Cloud Native Buildpacks CLI (arm64 static)
 pack $VER_UP — Cloud Native Buildpacks CLI.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
