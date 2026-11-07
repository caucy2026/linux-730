#!/usr/bin/env bash
# Build arm64 kemi-gitui .deb wrapping upstream linux-aarch64 (gitui-org/gitui).
# No musl asset; gnu MAX GLIBC 2.28 ≤ 2.31.
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.28.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gitui
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/gitui-linux-aarch64.tar.gz"
URL="https://github.com/gitui-org/gitui/releases/download/v${VER_UP}/gitui-linux-aarch64.tar.gz"
EXPECT_SHA=2a640da05b73e9152a7bf92bfd7c23acd9d60438f4f2cabb62357014a5fd7c28
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/gitui"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/gitui"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/gitui-org/gitui
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gitui
gitui $VER_UP — Blazing fast terminal-ui for git written in rust.
Upstream linux-aarch64 (gnu MAX GLIBC 2.28) under /usr/bin/gitui.
合主线：gork.bot协助开发
EOR
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOC
Package: $PKG
Version: $VER_DEB
Section: vcs
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: gitui terminal git UI (arm64)
 gitui $VER_UP — Blazing fast terminal-ui for git.
 linux-aarch64 gnu MAX GLIBC 2.28. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
