#!/usr/bin/env bash
# Build arm64 kemi-terragrunt .deb wrapping upstream linux_arm64 static (gruntwork-io/terragrunt).
# Binary command: terragrunt. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.2.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-terragrunt
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/terragrunt_linux_arm64"
URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${VER_UP}/terragrunt_linux_arm64"
EXPECT_BIN=01c0768aab01e0c183209ba7edce9d2ebc8f8a7690763bb52f1b8900aec224bc
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -L -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/terragrunt"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/gruntwork-io/terragrunt
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-terragrunt
terragrunt $VER_UP — Thin wrapper for OpenTofu/Terraform that provides extra tools.
Upstream linux_arm64 static binary under /usr/bin/terragrunt.
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
Description: terragrunt OpenTofu/Terraform wrapper (arm64 static)
 terragrunt $VER_UP — Extra tools for OpenTofu/Terraform.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
