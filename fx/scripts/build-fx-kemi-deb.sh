#!/usr/bin/env bash
# Build arm64 kemi-fx .deb wrapping upstream Linux arm64 static binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=40.0.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-fx
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/fx_linux_arm64"
URL="https://github.com/antonmedv/fx/releases/download/${VER_UP}/fx_linux_arm64"
EXPECT_SHA=90377fbdbe3a01f791032a289986867ff1f8fe20ce94b45f20ecb399f7b69411
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/fx"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/antonmedv/fx
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-fx
fx $VER_UP — Terminal JSON viewer / processor. Upstream fx_linux_arm64 static.
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
Description: fx JSON terminal tool (arm64 static)
 fx $VER_UP — Terminal JSON viewer / processor.
 Static aarch64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
