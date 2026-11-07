#!/usr/bin/env bash
# Build arm64 kemi-termshark .deb wrapping upstream linux_arm64 static (gcla/termshark).
# Binary command: termshark. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.4.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-termshark
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/termshark_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/gcla/termshark/releases/download/v${VER_UP}/termshark_${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=6dc3003a48291c463f057d0151727e0d21e295d804f082f3d35d72fd94d0a56e
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name termshark | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/termshark"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/gcla/termshark
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-termshark
termshark $VER_UP — a terminal UI for tshark, inspired by Wireshark.
Upstream linux_arm64 static binary (CGO_ENABLED=0) under /usr/bin/termshark.
Runtime note: typically expects tshark available on PATH.
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
Description: termshark terminal UI for tshark (arm64 static)
 termshark $VER_UP — terminal UI for tshark, inspired by Wireshark.
 linux_arm64 static (CGO_ENABLED=0). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
