#!/usr/bin/env bash
# Build arm64 kemi-zellij .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.45.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-zellij
DL="${DL:-$ROOT/dl}"
TGZ="$DL/zellij-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/zellij-org/zellij/releases/download/v${VER_UP}/zellij-aarch64-unknown-linux-musl.tar.gz"
EXPECT_TAR_SHA=05f0802afadd53f8db9514e7cae53c9ae8432fed1b35b8294aa816ee3044a16b
EXPECT_BIN_SHA=2a2c0621e6f3b11ecbb05d66939a48000a2508604620aa20727a5fd61c49f451
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_TAR_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name zellij | head -1)
test -x "$BIN"
echo "$EXPECT_BIN_SHA  $BIN" | sha256sum -c -
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/zellij"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/zellij-org/zellij
License: MIT (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-zellij
zellij $VER_UP — terminal workspace / multiplexer. Upstream aarch64-unknown-linux-musl static.
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
Description: zellij terminal workspace (arm64 musl static)
 zellij $VER_UP — a terminal workspace with batteries included.
 Static aarch64 musl; no Docker. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
