#!/usr/bin/env bash
# Build arm64 kemi-croc .deb wrapping upstream static Linux-ARM64 (schollz/croc).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=11.6.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-croc
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/croc_v11.6.4_Linux-ARM64.tar.gz"
URL="https://github.com/schollz/croc/releases/download/v${VER_UP}/croc_v${VER_UP}_Linux-ARM64.tar.gz"
EXPECT_SHA=e98ec8edd339fd0a272d7b37a0f0e464199efafac03a6dedee0f4dc71449fd53
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
test -x "$EXTRACT/croc"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$EXTRACT/croc" "$STAGE/pkg/usr/bin/croc"
if [[ -x "$EXTRACT/croc-update" ]]; then
  install -m 0755 "$EXTRACT/croc-update" "$STAGE/pkg/usr/bin/croc-update"
fi
if [[ -f "$EXTRACT/LICENSE" ]]; then
  install -m 0644 "$EXTRACT/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
if [[ -f "$EXTRACT/THIRD_PARTY_NOTICES.md" ]]; then
  install -m 0644 "$EXTRACT/THIRD_PARTY_NOTICES.md" "$STAGE/pkg/usr/share/doc/$PKG/THIRD_PARTY_NOTICES.md"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/schollz/croc
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-croc
croc $VER_UP — easily and securely send things from one computer to another.
Static Linux-ARM64 upstream binaries under /usr/bin/ (croc, croc-update).
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
Description: croc secure file transfer (arm64 static)
 croc $VER_UP — easily and securely send things from one computer to another.
 Static Linux-ARM64. Includes croc-update. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
