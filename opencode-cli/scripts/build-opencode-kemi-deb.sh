#!/usr/bin/env bash
# Build arm64 opencode-cli .deb wrapping upstream linux-arm64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${OPENCODE_BIN:-$ROOT/upstream/opencode}"
VER_UPSTREAM=1.19.5
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
PKG=opencode-cli
test -x "$BIN" || { echo "missing binary: $BIN"; exit 1; }
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/opencode"
cat > "$STAGE/usr/share/doc/$PKG/README.kemi.md" << EOT
# opencode-cli
Upstream OpenCode CLI ${VER_UPSTREAM} (linux-arm64), repackaged for KEMI.
Debian package name opencode-cli to avoid colliding with desktop Package:opencode.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: OpenCode CLI (linux arm64 upstream)
 Upstream sst/opencode v${VER_UPSTREAM} linux-arm64 tar, repackaged for KEMI store.
 Debian package name opencode-cli to avoid colliding with desktop Package:opencode.
 gork.bot协助开发.
EOT
mkdir -p "$OUT"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
echo "DEB=$DEB"
