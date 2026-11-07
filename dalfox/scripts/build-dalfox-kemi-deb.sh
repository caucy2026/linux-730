#!/usr/bin/env bash
# Build arm64 kemi-dalfox .deb wrapping upstream linux-aarch64-musl (hahwul/dalfox).
# Binary command: dalfox. Fully static musl (no interpreter). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.2.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-dalfox
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/dalfox-v${VER_UP}-linux-aarch64-musl.tar.gz"
URL="https://github.com/hahwul/dalfox/releases/download/v${VER_UP}/dalfox-v${VER_UP}-linux-aarch64-musl.tar.gz"
EXPECT_TGZ=fd56b0b7da2d06868cd73b504f41d21314629feffcd5bdc97718db1c9dd2fa70
EXPECT_BIN=33827ec8456b145dea4299f219e8a08005b7b04c86085fdbaf5a6b82c87cfe0b
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name dalfox | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
# reject dynamic musl interpreter
if readelf -l "$BIN_SRC" 2>/dev/null | grep -q 'ld-musl'; then
  echo 'FAIL: needs ld-musl interpreter'; exit 1
fi
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/dalfox"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/hahwul/dalfox
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-dalfox
dalfox $VER_UP — XSS scanning / parameter analysis toolkit.
Upstream linux-aarch64-musl static binary under /usr/bin/dalfox.
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
Description: dalfox XSS scanner CLI (arm64 musl static)
 dalfox $VER_UP — Powerful open-source XSS scanner.
 linux-aarch64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
