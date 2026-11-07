#!/usr/bin/env bash
# Build arm64 kemi-httprobe .deb wrapping CGO_ENABLED=0 linux/arm64 httprobe (tomnomnom/httprobe@v0.2).
# No upstream linux_arm64 release asset; cross-built static. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.2.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-httprobe
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/httprobe"
EXPECT_BIN=12f0400d636f1961d1f56cf0ff7559562b0268dd2ab502b0415a082c32672bad
SRC_DIR="$DL/httprobe-src"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  if [[ ! -d "$SRC_DIR/.git" ]]; then
    git clone --depth 1 --branch v0.2 https://github.com/tomnomnom/httprobe.git "$SRC_DIR"
  fi
  (cd "$SRC_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags='-s -w' -o "$BIN_SRC" .)
fi
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/httprobe"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tomnomnom/httprobe
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-httprobe
httprobe $VER_UP — take a list of domains and probe for working HTTP/HTTPS servers.
Cross-built linux-arm64 static (CGO_ENABLED=0) from tomnomnom/httprobe@v0.2 (no upstream arm64 release).
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
Description: httprobe HTTP probe CLI (arm64 static)
 httprobe $VER_UP — Probe domains for working HTTP/HTTPS.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
