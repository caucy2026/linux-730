#!/usr/bin/env bash
# Build arm64 kemi-difftastic .deb wrapping upstream aarch64-gnu (Wilfred/difftastic).
# Binary installed as /usr/bin/difft. No aarch64 musl asset; gnu MAX GLIBC 2.18.
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.72.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-difftastic
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/difft-0.72.0-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/Wilfred/difftastic/releases/download/${VER_UP}/difft-${VER_UP}-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=0993a82a6708a24adc6c6b8de366924728ed08f537a5b488940082c8edc79353
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/difft"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/difft"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/Wilfred/difftastic
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-difftastic
difftastic $VER_UP — a structural diff that understands syntax (command: difft).
Upstream aarch64-gnu MAX GLIBC 2.18 under /usr/bin/difft.
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
Description: difftastic structural diff (arm64)
 difftastic $VER_UP — structural syntax-aware diff (command: difft).
 aarch64-gnu MAX GLIBC 2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
