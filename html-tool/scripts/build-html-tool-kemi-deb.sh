#!/usr/bin/env bash
# Build arm64 kemi-html-tool .deb wrapping CGO_ENABLED=0 linux/arm64 html-tool
# from tomnomnom/hacks/html-tool (untagged; version from path commit date).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.0.20220725
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-html-tool
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/html-tool"
EXPECT_BIN=ae6aed9fd82225e585faa33c50fc97e63e55cf6b8cb18c81809ceedc0ee8a1ad
HACKS_SRC="$DL/hacks-src"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  if [[ ! -d "$HACKS_SRC/.git" ]]; then
    git clone --depth 1 https://github.com/tomnomnom/hacks.git "$HACKS_SRC"
  fi
  (cd "$HACKS_SRC/html-tool" && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$BIN_SRC" .)
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/html-tool"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tomnomnom/hacks/tree/master/html-tool
License: see upstream
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-html-tool
html-tool $VER_UP — extract tags/attribs/comments from HTML URLs or files on stdin.
Cross-built linux-arm64 static (CGO_ENABLED=0) from tomnomnom/hacks/html-tool@6fd7870 (2022-07-25).
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
Description: html-tool HTML extract CLI (arm64 static)
 html-tool $VER_UP — Extract tags/attribs/comments from HTML.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
