#!/usr/bin/env bash
# Build arm64 kemi-gojq .deb wrapping upstream linux_arm64 static (itchyny/gojq).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.12.20
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gojq
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/gojq_v${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/itchyny/gojq/releases/download/v${VER_UP}/gojq_v${VER_UP}_linux_arm64.tar.gz"
EXPECT_SHA=14384db99511f57f0dcb35c7b825f8afd5407f9c203631aad4dd163af1856c35
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/gojq_v${VER_UP}_linux_arm64"
BIN_SRC="$SRC/gojq"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/gojq"
if [[ -f "$SRC/_gojq" ]]; then
  install -m 0644 "$SRC/_gojq" "$STAGE/pkg/usr/share/zsh/vendor-completions/_gojq"
fi
for f in README.md CHANGELOG.md LICENSE CREDITS; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/itchyny/gojq
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gojq
gojq $VER_UP — Pure Go implementation of jq.
Upstream linux_arm64 static binary under /usr/bin/gojq.
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
Description: gojq pure-Go jq (arm64 static)
 gojq $VER_UP — Pure Go implementation of jq.
 linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
