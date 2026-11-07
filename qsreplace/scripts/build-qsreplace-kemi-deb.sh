#!/usr/bin/env bash
# Build arm64 kemi-qsreplace .deb wrapping CGO_ENABLED=0 linux/arm64 qsreplace (tomnomnom/qsreplace@v0.0.3).
# No upstream linux_arm64 release asset; cross-built static. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.0.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-qsreplace
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/qsreplace"
EXPECT_BIN=a5a4e7c818151cc231f9d8c369d1131f72b2b17062a7bd1aa065b61230a1fbd7
SRC_DIR="$DL/qsreplace-src"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  if [[ ! -d "$SRC_DIR/.git" ]]; then
    git clone --depth 1 --branch v0.0.3 https://github.com/tomnomnom/qsreplace.git "$SRC_DIR"
  fi
  (cd "$SRC_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$BIN_SRC" .)
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/qsreplace"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tomnomnom/qsreplace
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-qsreplace
qsreplace $VER_UP — Accept URLs on stdin, replace query string values.
Cross-built linux-arm64 static (CGO_ENABLED=0) from tomnomnom/qsreplace@v0.0.3 (no upstream arm64 release).
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
Description: qsreplace query-string CLI (arm64 static)
 qsreplace $VER_UP — Replace URL query string values from stdin.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
