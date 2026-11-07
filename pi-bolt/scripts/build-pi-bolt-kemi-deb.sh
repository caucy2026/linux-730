#!/usr/bin/env bash
# Build arm64 kemi-pi-bolt .deb wrapping upstream AOT linux-arm64 tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.1.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-pi-bolt
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/pi-bolt-linux-arm64.tar.xz"
URL="https://github.com/opensec-git/Pi-Bolt/releases/download/bolt-v${VER_UP}/pi-bolt-linux-arm64.tar.xz"
EXPECT_SHA=b4c37c4a6364334f1ec1f3eb53997c59dabe2aa95809803382b8244b35e6201a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/opt/kemi-pi-bolt" \
  "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xJf "$TAR" -C "$STAGE/extract"
SRC=$(find "$STAGE/extract" -maxdepth 2 -type f -name pi | head -1)
SRC_DIR=$(dirname "$SRC")
cp -a "$SRC_DIR/." "$STAGE/pkg/opt/kemi-pi-bolt/"
chmod 0755 "$STAGE/pkg/opt/kemi-pi-bolt/pi"
cat > "$STAGE/pkg/usr/bin/pi-bolt" << 'EOT'
#!/bin/sh
exec /opt/kemi-pi-bolt/pi "$@"
EOT
cat > "$STAGE/pkg/usr/bin/pi" << 'EOT'
#!/bin/sh
exec /opt/kemi-pi-bolt/pi "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/pi-bolt" "$STAGE/pkg/usr/bin/pi"
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-pi-bolt
Pi-Bolt $VER_UP AOT linux arm64. gork.bot协助开发
EOT
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: pi-bolt
Conflicts: pi-bolt
Replaces: pi-bolt
Description: Pi-Bolt AI coding agent (arm64 AOT)
 Pi-Bolt $VER_UP — AOT-compiled Pi coding agent for linux arm64.
 No Docker/Node. MIT. User supplies LLM keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
