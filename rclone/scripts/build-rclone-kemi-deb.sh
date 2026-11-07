#!/usr/bin/env bash
# Build arm64 kemi-rclone .deb wrapping upstream static linux-arm64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.76.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-rclone
DL="${DL:-$ROOT/../../dl}"
ZIP="$DL/rclone-v${VER_UP}-linux-arm64.zip"
URL="https://github.com/rclone/rclone/releases/download/v${VER_UP}/rclone-v${VER_UP}-linux-arm64.zip"
EXPECT_SHA=ee169016675e23a69d77240565133ff7dbc9b33d16fa8f7053d4af39f1eaeb78
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP" ]]; then
  curl -fsSL -o "$ZIP" "$URL"
fi
echo "$EXPECT_SHA  $ZIP" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/man/man1" "$STAGE/pkg/usr/share/doc/$PKG"
unzip -qo "$ZIP" -d "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name rclone | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/rclone"
MAN=$(find "$STAGE/extract" -type f -name 'rclone.1' | head -1 || true)
if [[ -n "${MAN:-}" ]]; then
  install -m 0644 "$MAN" "$STAGE/pkg/usr/share/man/man1/rclone.1"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOF
Upstream: https://github.com/rclone/rclone
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOF
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOF
# kemi-rclone
rclone $VER_UP — rsync for cloud storage. Upstream linux-arm64 static binary.
合主线：gork.bot协助开发
EOF
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: rclone cloud storage sync CLI (arm64 static)
 rclone $VER_UP — sync files to/from cloud storage providers.
 Static aarch64; no Docker. gork.bot协助开发.
EOF
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
