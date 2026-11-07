#!/usr/bin/env bash
# Build arm64 kemi-hrdr .deb wrapping upstream static musl binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.18.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-hrdr
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/hrdr-v0.18.0-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/kryptic-sh/hrdr/releases/download/v${VER_UP}/hrdr-v0.18.0-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=63c4c1d45ea003a81a25b5a847dfc98c7cfed2421ee8fe546656d7d944d13f9d
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name hrdr | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/hrdr"
if [[ -f "$STAGE/extract/LICENSE" ]]; then
  install -m 0644 "$STAGE/extract/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
else
  cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/kryptic-sh/hrdr
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOT
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-hrdr
hrdr (Herder) terminal agentic coding harness. Upstream $VER_UP static musl aarch64.
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
Description: hrdr AI coding agent CLI (arm64 musl)
 hrdr (Herder) $VER_UP — open-source agentic coding harness for
 OpenAI-compatible models. Static musl aarch64; no Docker.
 User supplies LLM provider keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
