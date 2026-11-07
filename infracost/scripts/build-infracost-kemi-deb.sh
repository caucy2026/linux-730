#!/usr/bin/env bash
# Build arm64 kemi-infracost .deb wrapping upstream linux-arm64 static (infracost/infracost).
# Binary command: infracost. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.10.47
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-infracost
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/infracost-linux-arm64.tar.gz"
URL="https://github.com/infracost/infracost/releases/download/v${VER_UP}/infracost-linux-arm64.tar.gz"
EXPECT_TGZ=1db33dddcac989f39687fa9bf00ed9d8cce4268450578848e5bf6287ad8a7b44
EXPECT_BIN=10f4bda15d5586c6bd21c957c27de31ce10155b0d8b06592aa27b9c8820e2489
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f \( -name 'infracost-linux-arm64' -o -name infracost \) | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/infracost"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/infracost/infracost
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-infracost
infracost $VER_UP — Cloud cost estimates for Terraform/OpenTofu.
Upstream linux-arm64 static binary under /usr/bin/infracost.
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
Description: infracost cloud cost estimate CLI (arm64 static)
 infracost $VER_UP — Cost estimates for Terraform/OpenTofu.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
