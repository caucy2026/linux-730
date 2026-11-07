#!/usr/bin/env bash
# Build arm64 kemi-lazygit .deb wrapping upstream static linux_arm64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.66.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-lazygit
DL="${DL:-$ROOT/dl}"
TGZ="$DL/lazygit_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/jesseduffield/lazygit/releases/download/v${VER_UP}/lazygit_${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=79a3161eeb642f0473e23db6341f7baabd4a5933e921a9c1167c5d5c765c41a4
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name lazygit | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/lazygit"
if [[ -f "$STAGE/extract/LICENSE" ]]; then
  install -m 0644 "$STAGE/extract/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE.upstream"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOF
Upstream: https://github.com/jesseduffield/lazygit
License: MIT (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOF
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOF
# kemi-lazygit
lazygit $VER_UP — simple terminal UI for git commands. Upstream linux_arm64 static binary.
合主线：gork.bot协助开发
EOF
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: $PKG
Version: $VER_DEB
Section: vcs
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: lazygit terminal UI for git (arm64 static)
 lazygit $VER_UP — simple terminal UI for git commands.
 Static aarch64; no Docker. gork.bot协助开发.
EOF
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
