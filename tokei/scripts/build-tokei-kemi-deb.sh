#!/usr/bin/env bash
# Build arm64 kemi-tokei .deb wrapping upstream aarch64-gnu binary (GLIBC≤2.18).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=12.1.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-tokei
DL="${DL:-$ROOT/dl}"
TGZ="$DL/tokei-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/XAMPPRocky/tokei/releases/download/v${VER_UP}/tokei-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=ef514fd12cfc3ee2d1725e5ecb866ee1123163004879ec285b22f3323389ebe2
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name tokei | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/tokei"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/XAMPPRocky/tokei
License: MIT / Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-tokei
tokei $VER_UP — count your code, quickly. Upstream aarch64-unknown-linux-gnu (GLIBC≤2.18).
Note: newer tags lack binary assets; this is last published aarch64 binary.
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
Depends: libc6 (>= 2.18)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: tokei code statistics (arm64)
 tokei $VER_UP — Count your code, quickly.
 aarch64 gnu (GLIBC≤2.18). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
