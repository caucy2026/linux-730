#!/usr/bin/env bash
# Build arm64 kemi-dasel .deb wrapping upstream linux_arm64 static (TomWright/dasel).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.11.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-dasel
DL="${DL:-$ROOT/dl}"
BIN_SRC_FILE="$DL/dasel_linux_arm64"
URL="https://github.com/TomWright/dasel/releases/download/v${VER_UP}/dasel_linux_arm64"
EXPECT_SHA=df33920a792cd8ee5573cec3632a710cd2178d7bc4fc3892c6be78f35e7cbcc6
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC_FILE" ]]; then
  curl -fsSL -o "$BIN_SRC_FILE" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC_FILE" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC_FILE" "$STAGE/pkg/usr/bin/dasel"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/TomWright/dasel
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-dasel
dasel $VER_UP — Select, put and delete data from JSON, TOML, YAML, XML and CSV.
Upstream linux_arm64 static binary under /usr/bin/dasel.
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
Description: dasel data selector (arm64 static)
 dasel $VER_UP — Query and update JSON/TOML/YAML/XML/CSV.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
