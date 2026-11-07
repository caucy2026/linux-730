#!/usr/bin/env bash
# Build arm64 kemi-kubie .deb wrapping upstream linux-arm64 static (kubie-org/kubie).
# Binary command: kubie. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.28.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-kubie
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/kubie-linux-arm64"
URL="https://github.com/kubie-org/kubie/releases/download/v${VER_UP}/kubie-linux-arm64"
EXPECT_SHA=04e85711d515d2a81998677d2cdfd6e3d8943dd050b6cd1a5d29ee837b47913e
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/kubie"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/kubie-org/kubie (formerly sbstp/kubie)
License: Zlib (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-kubie
kubie $VER_UP — a more powerful alternative to kubectx and kubens.
Upstream linux-arm64 static binary under /usr/bin/kubie.
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
Description: kubie Kubernetes context/namespace shell (arm64 static)
 kubie $VER_UP — more powerful alternative to kubectx and kubens.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
