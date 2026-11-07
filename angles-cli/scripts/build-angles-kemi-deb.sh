#!/usr/bin/env bash
# Build arm64 kemi-angles .deb wrapping upstream static linux-arm64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.6.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-angles
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/angles-linux-arm64.tar.gz"
URL="https://github.com/angleschina/angles-cli/releases/download/v${VER_UP}/angles-linux-arm64.tar.gz"
EXPECT_SHA=d7337f01d39b00e13e781e345714cc2ace697a37183e64629efbc914f2af0183
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name 'angles*' | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/angles"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/angleschina/angles-cli
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-angles
Angles Code CLI terminal agentic coding tool. Upstream $VER_UP static aarch64.
合主线：gork.bot协助开发
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
Description: Angles AI coding agent CLI (arm64 static)
 Angles Code CLI $VER_UP — MIT agentic coding assistant.
 Static aarch64; no Docker. User supplies LLM keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
