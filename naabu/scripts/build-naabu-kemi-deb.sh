#!/usr/bin/env bash
# Build arm64 kemi-naabu .deb wrapping upstream naabu linux_arm64 (gnu).
# Note: musl zip needs /lib/ld-musl-aarch64.so.1 — unsuitable for glibc 101.
# Binary command: naabu. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.7.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-naabu
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/naabu_${VER_UP}_linux_arm64.zip"
URL="https://github.com/projectdiscovery/naabu/releases/download/v${VER_UP}/naabu_${VER_UP}_linux_arm64.zip"
EXPECT_ZIP=e88af9bbfd777e2ffab6f84696747ba74de98fafeda882c078d158a610dbd86e
EXPECT_BIN=4069be13f4170bd4dffe855a01d5e8977b2a70e05b71b6c45e519a4c1e8dfe2a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name naabu | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
# gate: no GLIBC > 2.31 version-needs
if readelf -V "$BIN_SRC" 2>/dev/null | grep -E 'GLIBC_2\.(3[2-9]|[4-9][0-9])' >/dev/null; then
  echo 'FAIL: GLIBC > 2.31'; exit 1
fi
echo 'OK glibc baseline (no high version-needs)'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/naabu"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/projectdiscovery/naabu
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-naabu
naabu $VER_UP — port scanning tool (projectdiscovery).
Upstream linux-arm64 (gnu) binary under /usr/bin/naabu.
(musl asset skipped: needs ld-musl on glibc 101.)
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
Depends: libc6
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: naabu port scanner CLI (arm64)
 naabu $VER_UP — A fast port scanner written in go.
 linux-arm64 gnu (glibc≤2.31). gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
