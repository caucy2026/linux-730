#!/usr/bin/env bash
# Build arm64 kemi-age .deb wrapping upstream static linux-arm64 (FiloSottile/age).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.3.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-age
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/age-v1.3.2-linux-arm64.tar.gz"
URL="https://github.com/FiloSottile/age/releases/download/v${VER_UP}/age-v${VER_UP}-linux-arm64.tar.gz"
EXPECT_SHA=6b8dc4333c53a5a57c9e5834e3a48f92605d7154014cd07269ff3327db5d37f4
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
SRC="$EXTRACT/age"
test -x "$SRC/age" && test -x "$SRC/age-keygen"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
BINS=(age age-keygen age-inspect age-plugin-batchpass age-plugin-pq age-plugin-tag age-plugin-tagpq)
for b in "${BINS[@]}"; do
  test -x "$SRC/$b"
  install -m 0755 "$SRC/$b" "$STAGE/pkg/usr/bin/$b"
done
if [[ -f "$SRC/LICENSE" ]]; then
  install -m 0644 "$SRC/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/FiloSottile/age
License: BSD-3-Clause (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-age
age $VER_UP — simple, modern, secure file encryption.
Static linux-arm64 upstream binaries under /usr/bin/.
Bins: age, age-keygen, age-inspect, age-plugin-{batchpass,pq,tag,tagpq}.
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
Description: age file encryption (arm64 static)
 age $VER_UP — simple, modern, secure file encryption tool.
 Static linux-arm64. Includes age-keygen and plugins. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
