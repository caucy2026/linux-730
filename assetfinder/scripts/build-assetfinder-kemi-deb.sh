#!/usr/bin/env bash
# Build arm64 kemi-assetfinder .deb wrapping CGO_ENABLED=0 linux/arm64 assetfinder (tomnomnom/assetfinder@v0.1.1).
# No upstream linux_arm64 release asset; cross-built static. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.1.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-assetfinder
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/assetfinder"
EXPECT_BIN=9c94691ea9f7c4452c6ec819595ce1d9d9bb18e7c26da9f262ab2514c521abee
SRC_DIR="$DL/assetfinder-src"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  if [[ ! -d "$SRC_DIR/.git" ]]; then
    git clone --depth 1 --branch v0.1.1 https://github.com/tomnomnom/assetfinder.git "$SRC_DIR"
  fi
  if [[ ! -f "$SRC_DIR/go.mod" ]]; then
    (cd "$SRC_DIR" && go mod init github.com/tomnomnom/assetfinder)
  fi
  (cd "$SRC_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$BIN_SRC" .)
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/assetfinder"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tomnomnom/assetfinder
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-assetfinder
assetfinder $VER_UP — find domains and subdomains related to a given domain.
Cross-built linux-arm64 static (CGO_ENABLED=0) from tomnomnom/assetfinder@v0.1.1 (no upstream arm64 release).
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
Description: assetfinder subdomain discovery CLI (arm64 static)
 assetfinder $VER_UP — Find related domains and subdomains.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
