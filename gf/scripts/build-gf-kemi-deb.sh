#!/usr/bin/env bash
# Build arm64 kemi-gf .deb wrapping CGO_ENABLED=0 linux/arm64 gf (tomnomnom/gf@master).
# Untagged; version from commit date. Patterns not bundled (single CLI). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.0.20200618
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gf
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/gf"
EXPECT_BIN=e72d5cd4d01a645370dcde43b1e628767333aa6602b7d77b416e2e716ae0c370
SRC_DIR="$DL/gf-src"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  if [[ ! -d "$SRC_DIR/.git" ]]; then
    git clone --depth 1 https://github.com/tomnomnom/gf.git "$SRC_DIR"
  fi
  if [[ ! -f "$SRC_DIR/go.mod" ]]; then
    (cd "$SRC_DIR" && go mod init github.com/tomnomnom/gf)
  fi
  (cd "$SRC_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$BIN_SRC" .)
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/gf"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tomnomnom/gf
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gf
gf $VER_UP — wrapper around grep for common patterns (tomnomnom/gf).
Cross-built linux-arm64 static (CGO_ENABLED=0) from master tip dcd4c361 (2020-06-18; untagged).
Patterns: not bundled; copy upstream examples/ into ~/.gf as needed.
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
Description: gf grep-pattern wrapper CLI (arm64 static)
 gf $VER_UP — Grep wrapper with named patterns.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
