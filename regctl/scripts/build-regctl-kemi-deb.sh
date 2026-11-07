#!/usr/bin/env bash
# Build arm64 kemi-regctl .deb wrapping upstream linux-arm64 static (regclient/regclient).
# Binary command: regctl only (single-CLI; not regbot/regsync). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.11.7
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-regctl
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/regctl-linux-arm64"
URL="https://github.com/regclient/regclient/releases/download/v${VER_UP}/regctl-linux-arm64"
EXPECT_BIN=9f349bab5c407ac04f3dabf99c7c7a6b0f9e9723c23f2775380e804d02c6dbb9
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -L -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/regctl"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/regclient/regclient
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-regctl
regctl $VER_UP — Docker and OCI registry client.
Upstream linux-arm64 static binary under /usr/bin/regctl (single-CLI; regbot/regsync not packaged).
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
Description: regctl OCI registry client (arm64 static)
 regctl $VER_UP — Docker and OCI registry client.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
