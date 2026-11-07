#!/usr/bin/env bash
# Build arm64 kemi-eza .deb wrapping upstream aarch64 gnu (no_libgit) binary.
# Note: no official aarch64 musl; gnu needs max GLIBC_2.18 (fits device 2.31).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.23.5
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-eza
DL="${DL:-$ROOT/dl}"
TGZ="$DL/eza_aarch64-unknown-linux-gnu_no_libgit.tar.gz"
URL="https://github.com/eza-community/eza/releases/download/v${VER_UP}/eza_aarch64-unknown-linux-gnu_no_libgit.tar.gz"
EXPECT_SHA=1c01b578b5bd3f23b7de5a4b41936cde20fb16ff16a03e63266317ac1eb821e0
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name eza | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/eza"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/eza-community/eza
License: MIT (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-eza
eza $VER_UP — modern ls replacement. Upstream aarch64-unknown-linux-gnu_no_libgit (max GLIBC_2.18; no aarch64 musl release).
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
Depends: libc6 (>= 2.18), libgcc-s1 | libgcc1
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: eza modern ls (arm64 gnu, no_libgit)
 eza $VER_UP — a modern replacement for ls.
 aarch64 gnu no_libgit; max GLIBC_2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
