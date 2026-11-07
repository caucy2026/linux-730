#!/usr/bin/env bash
# Build arm64 kemi-starship .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.27.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-starship
DL="${DL:-$ROOT/dl}"
TGZ="$DL/starship-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/starship/starship/releases/download/v${VER_UP}/starship-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=341f5cbf24699fa0b27ec88965ad25f862ea09e15d35a543fd6ffdff1d2aa00d
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name starship | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/starship"
# optional: LICENSE if present in tarball (often not)
if [[ -f "$STAGE/extract/LICENSE" ]]; then
  install -m 0644 "$STAGE/extract/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE.upstream"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/starship/starship
License: ISC (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-starship
starship $VER_UP — cross-shell prompt. Upstream aarch64-unknown-linux-musl static binary.
合主线：gork.bot协助开发
EOR
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOC
Package: $PKG
Version: $VER_DEB
Section: shells
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: starship cross-shell prompt (arm64 musl static)
 starship $VER_UP — minimal, blazing-fast, and infinitely customizable prompt.
 Static aarch64 musl; no Docker. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
