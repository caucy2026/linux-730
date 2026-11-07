#!/usr/bin/env bash
# Build arm64 kemi-fortio .deb wrapping upstream fortio-linux_arm64 (fortio/fortio).
# Binary command: fortio. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.76.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-fortio
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/fortio-linux_arm64-${VER_UP}.tgz"
URL="https://github.com/fortio/fortio/releases/download/v${VER_UP}/fortio-linux_arm64-${VER_UP}.tgz"
EXPECT_TGZ=5258719ab9b2515a53f2435d4eb59364b4ebcaf61166de06959ed44fc4b8440d
EXPECT_BIN=862527b12263fcf793dd5c8ede9ce3221bfd73f0865beb4be2f39b5681d01a49
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name fortio | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
MAN_SRC=$(find "$EXTRACT" -type f -name 'fortio.1' | head -1 || true)
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/fortio"
if [[ -n "${MAN_SRC:-}" && -f "$MAN_SRC" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/man/man1"
  install -m 0644 "$MAN_SRC" "$STAGE/pkg/usr/share/man/man1/fortio.1"
  gzip -9n "$STAGE/pkg/usr/share/man/man1/fortio.1" || true
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/fortio/fortio
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-fortio
fortio $VER_UP — load testing / fortio CLI.
Upstream linux-arm64 static binary under /usr/bin/fortio.
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
Description: fortio load testing CLI (arm64 static)
 fortio $VER_UP — HTTP/gRPC load testing and fortio echo server.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
