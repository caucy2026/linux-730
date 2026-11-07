#!/usr/bin/env bash
# Build arm64 kemi-pup .deb wrapping upstream linux_arm64 static (ericchiang/pup).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.4.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-pup
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/pup_v0.4.0_linux_arm64.zip"
URL="https://github.com/ericchiang/pup/releases/download/v${VER_UP}/pup_v${VER_UP}_linux_arm64.zip"
EXPECT_SHA=c09b669fa8240f4f869dee7d34ee3c7ea620a0280cee1ea7d559593bcdd062c9
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC="$EXTRACT/pup"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/pup"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ericchiang/pup
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-pup
pup $VER_UP — Parsing HTML at the command line.
Upstream linux_arm64 static binary under /usr/bin/pup.
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
Description: pup HTML CLI parser (arm64 static)
 pup $VER_UP — Parsing HTML at the command line.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
