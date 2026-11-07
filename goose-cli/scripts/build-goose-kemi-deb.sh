#!/usr/bin/env bash
# Build arm64 kemi-goose .deb wrapping upstream static musl binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.57.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-goose
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/goose-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/aaif-goose/goose/releases/download/v${VER_UP}/goose-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=00a32522f0421ed72fc06f36bfc44c8e51cffefb4daf22a81bb84ccd29d1a1ce
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name goose | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/goose"
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-goose
Block/Goose terminal AI agent. Upstream $VER_UP static musl aarch64.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/aaif-goose/goose
License: see upstream repository LICENSE
Repackaged for KEMI Linux arm64 by gork.bot协助开发
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
Description: Goose AI agent CLI (arm64 musl)
 Block Goose $VER_UP — open-source AI agent CLI for developers.
 Static musl aarch64 binary; no Docker. User supplies LLM provider keys.
 gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
