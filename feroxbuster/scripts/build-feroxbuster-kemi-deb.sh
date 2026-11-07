#!/usr/bin/env bash
# Build arm64 kemi-feroxbuster .deb wrapping upstream aarch64-linux (epi052/feroxbuster).
# Binary command: feroxbuster. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.13.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-feroxbuster
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/aarch64-linux-feroxbuster.zip"
URL="https://github.com/epi052/feroxbuster/releases/download/v${VER_UP}/aarch64-linux-feroxbuster.zip"
EXPECT_ZIP=1e5244e1f52e55a647b65e0c76ae7afe0b9983c1fbea30ed7c67e477175eb381
EXPECT_BIN=6db5d0b24b5345951be35ce4130efb12576d70c7a4a2dd0d1a1cc28374194200
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name feroxbuster | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
# gate GLIBC
if readelf -V "$BIN_SRC" 2>/dev/null | grep -E 'GLIBC_2\.(3[2-9]|[4-9][0-9])' >/dev/null; then
  echo 'FAIL: GLIBC > 2.31'; exit 1
fi
echo 'OK glibc≤2.31'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/feroxbuster"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/epi052/feroxbuster
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-feroxbuster
feroxbuster $VER_UP — fast recursive content discovery.
Upstream aarch64-linux binary under /usr/bin/feroxbuster (glibc≤2.18).
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
Depends: libc6, libgcc-s1
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: feroxbuster content discovery CLI (arm64)
 feroxbuster $VER_UP — A fast, simple, recursive content discovery tool.
 aarch64-linux glibc≤2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
