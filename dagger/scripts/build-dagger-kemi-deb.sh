#!/usr/bin/env bash
# Build arm64 kemi-dagger .deb wrapping upstream linux_arm64 static (dagger/dagger).
# Binary command: dagger. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.21.11
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-dagger
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/dagger_v${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/dagger/dagger/releases/download/v${VER_UP}/dagger_v${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=7a19fc16ce58d8aa80e273629a38a3cf3e49951df8928b38a908805c9a08cc50
EXPECT_BIN=19fc0866b7fa6e3e711dcf5e642a65c2094d49a4f0dc3e8b85acc7057bbd5c44
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name dagger | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/dagger"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/dagger/dagger
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-dagger
dagger $VER_UP — Portable DevKit for CI/CD pipelines.
Upstream linux_arm64 static binary under /usr/bin/dagger.
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
Description: dagger CI/CD portable DevKit CLI (arm64 static)
 dagger $VER_UP — Portable DevKit for CI/CD pipelines.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
