#!/usr/bin/env bash
# Build arm64 kemi-ov .deb wrapping upstream linux_arm64 static (noborus/ov).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.55.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-ov
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/ov_${VER_UP}_linux_arm64.zip"
URL="https://github.com/noborus/ov/releases/download/v${VER_UP}/ov_${VER_UP}_linux_arm64.zip"
EXPECT_SHA=0e5912383ae65af84be274f26fc920d0f493b237d1256123c1d1384a2e5e542f
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name ov | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/ov"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/ov"
for f in README.md LICENSE ov.yaml ov-less.yaml; do
  src=$(find "$EXTRACT" -maxdepth 2 -type f -name "$f" | head -1 || true)
  if [[ -n "${src:-}" ]]; then
    if [[ "$f" == *.yaml ]]; then
      install -m 0644 "$src" "$STAGE/pkg/usr/share/ov/"
    else
      install -m 0644 "$src" "$STAGE/pkg/usr/share/doc/$PKG/"
    fi
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/noborus/ov
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-ov
ov $VER_UP — Feature-rich terminal pager.
Upstream linux_arm64 static binary under /usr/bin/ov.
Sample configs in /usr/share/ov/.
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
Description: ov feature-rich terminal pager (arm64 static)
 ov $VER_UP — Feature-rich terminal pager.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
