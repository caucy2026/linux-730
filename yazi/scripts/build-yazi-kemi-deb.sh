#!/usr/bin/env bash
# Build arm64 kemi-yazi .deb wrapping upstream musl static aarch64 binaries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=26.9.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-yazi
DL="${DL:-$ROOT/dl}"
ZIP="$DL/yazi-aarch64-unknown-linux-musl.zip"
URL="https://github.com/sxyazi/yazi/releases/download/v${VER_UP}/yazi-aarch64-unknown-linux-musl.zip"
EXPECT_SHA=dd569daecaae914185f295634109295ccd25c1b42b02eb89a74f651970024f2e
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP" ]]; then
  curl -fsSL -o "$ZIP" "$URL"
fi
echo "$EXPECT_SHA  $ZIP" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" \
  "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
unzip -q -o "$ZIP" -d "$STAGE/extract"
YAZI=$(find "$STAGE/extract" -type f -name yazi | head -1)
YA=$(find "$STAGE/extract" -type f -name ya | head -1)
test -x "$YAZI" && test -x "$YA"
install -m 0755 "$YAZI" "$STAGE/pkg/usr/bin/yazi"
install -m 0755 "$YA" "$STAGE/pkg/usr/bin/ya"
# completions
BASE=$(dirname "$YAZI")
COMP="$BASE/completions"
[[ -d "$COMP" ]] || COMP=$(find "$STAGE/extract" -type d -name completions | head -1)
if [[ -n "${COMP:-}" ]]; then
  [[ -f "$COMP/yazi.bash" ]] && install -m 0644 "$COMP/yazi.bash" "$STAGE/pkg/usr/share/bash-completion/completions/yazi"
  [[ -f "$COMP/ya.bash" ]] && install -m 0644 "$COMP/ya.bash" "$STAGE/pkg/usr/share/bash-completion/completions/ya"
  [[ -f "$COMP/_yazi" ]] && install -m 0644 "$COMP/_yazi" "$STAGE/pkg/usr/share/zsh/vendor-completions/_yazi"
  [[ -f "$COMP/_ya" ]] && install -m 0644 "$COMP/_ya" "$STAGE/pkg/usr/share/zsh/vendor-completions/_ya"
  [[ -f "$COMP/yazi.fish" ]] && install -m 0644 "$COMP/yazi.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/yazi.fish"
  [[ -f "$COMP/ya.fish" ]] && install -m 0644 "$COMP/ya.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/ya.fish"
fi
LIC=$(find "$STAGE/extract" -type f -name LICENSE | head -1 || true)
if [[ -n "${LIC:-}" ]]; then
  install -m 0644 "$LIC" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE.upstream"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/sxyazi/yazi
License: MIT (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-yazi
yazi $VER_UP — blazing fast terminal file manager (yazi + ya). Upstream aarch64-unknown-linux-musl static.
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
Description: yazi terminal file manager (arm64 musl static)
 yazi $VER_UP — blazing fast terminal file manager written in Rust.
 Ships /usr/bin/yazi and /usr/bin/ya. Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
