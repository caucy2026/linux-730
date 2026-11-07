#!/usr/bin/env bash
# Build arm64 kemi-ast-grep .deb wrapping upstream aarch64-unknown-linux-gnu (MAX GLIBC 2.18).
# Installs ast-grep + deprecated sg shim (same CLI). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.51.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-ast-grep
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/app-aarch64-unknown-linux-gnu.zip"
URL="https://github.com/ast-grep/ast-grep/releases/download/${VER_UP}/app-aarch64-unknown-linux-gnu.zip"
EXPECT_SHA=db02fae2d8eace5fc40c55242068882452dd03eab38a1d950d5fd981cf112926
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
AG=$(find "$EXTRACT" -type f -name ast-grep | head -1)
SG=$(find "$EXTRACT" -type f -name sg | head -1)
test -f "$AG"
chmod +x "$AG"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$AG" "$STAGE/pkg/usr/bin/ast-grep"
if [[ -f "$SG" ]]; then
  chmod +x "$SG"
  install -m 0755 "$SG" "$STAGE/pkg/usr/bin/sg"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ast-grep/ast-grep
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-ast-grep
ast-grep $VER_UP — A CLI tool for code structural search, lint and rewriting.
Upstream aarch64-unknown-linux-gnu (MAX GLIBC 2.18) under /usr/bin/ast-grep
(and deprecated /usr/bin/sg shim).
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
Description: ast-grep structural search (arm64)
 ast-grep $VER_UP — code structural search/lint/rewrite (sg alias).
 aarch64 gnu MAX GLIBC 2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
