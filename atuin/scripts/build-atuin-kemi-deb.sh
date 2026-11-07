#!/usr/bin/env bash
# Build arm64 kemi-atuin .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=18.24.5
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-atuin
DL="${DL:-$ROOT/dl}"
TGZ="$DL/atuin-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/atuinsh/atuin/releases/download/v${VER_UP}/atuin-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=b44b3f264652b847b2e524ec397aa498c13076ed75cf213239ed2b9a0de2f99d
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name atuin | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/atuin"
# optional docs from tarball
BASE=$(dirname "$BIN")
[[ -f "$BASE/LICENSE" ]] && install -m 0644 "$BASE/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream" || true
[[ -f "$BASE/README.md" ]] && install -m 0644 "$BASE/README.md" "$STAGE/pkg/usr/share/doc/$PKG/README.upstream.md" || true
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/atuinsh/atuin
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-atuin
atuin $VER_UP — magically better shell history. Upstream aarch64-unknown-linux-musl static.
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
Description: atuin shell history (arm64 musl static)
 atuin $VER_UP — Magically better shell history with sync.
 Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
