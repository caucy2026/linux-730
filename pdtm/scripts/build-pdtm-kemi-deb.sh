#!/usr/bin/env bash
# Build arm64 kemi-pdtm .deb wrapping upstream pdtm linux_arm64 (glibc; no high GLIBC_ symbols).
# Binary command: pdtm. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.1.5
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-pdtm
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/pdtm_${VER_UP}_linux_arm64.zip"
URL="https://github.com/projectdiscovery/pdtm/releases/download/v${VER_UP}/pdtm_${VER_UP}_linux_arm64.zip"
EXPECT_ZIP=47d46a383c8ee68aee754fbfc82d074331105864f94431281aac5a418e6de1dd
EXPECT_BIN=949869f7c11dbe71d19b624dc2a9b0485406f436811c46aaf7a6595c49d36e6e
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -L -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_ZIP  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -q "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name pdtm | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
# expect dynamic glibc; reject ld-musl
if readelf -l "$BIN_SRC" 2>/dev/null | grep -q ld-musl; then
  echo 'FAIL: ld-musl unsuitable for 101'; exit 1
fi
echo 'OK glibc dynamic (no ld-musl)'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/pdtm"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/projectdiscovery/pdtm
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-pdtm
pdtm $VER_UP — ProjectDiscovery Tool Manager.
Upstream linux-arm64 glibc binary under /usr/bin/pdtm (probe PASS max-glibc 2.31).
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
Description: pdtm ProjectDiscovery tool manager (arm64)
 pdtm $VER_UP — Install/update ProjectDiscovery tools.
 linux-arm64 glibc. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
