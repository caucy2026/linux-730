#!/usr/bin/env bash
# Build arm64 kemi-bottom .deb wrapping upstream musl static aarch64 btm.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.15.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-bottom
DL="${DL:-$ROOT/dl}"
TGZ="$DL/bottom_aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/ClementTsang/bottom/releases/download/${VER_UP}/bottom_aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=78e03e96d02e946be1f94066cd78f1adc3bb8c0db5f53fdf24d70a3ab351e05c
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" \
  "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name btm | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/btm"
# completions (best-effort)
if [[ -f "$STAGE/extract/completion/btm.bash" ]]; then
  install -m 0644 "$STAGE/extract/completion/btm.bash" "$STAGE/pkg/usr/share/bash-completion/completions/btm"
fi
if [[ -f "$STAGE/extract/completion/_btm" ]]; then
  install -m 0644 "$STAGE/extract/completion/_btm" "$STAGE/pkg/usr/share/zsh/vendor-completions/_btm"
fi
if [[ -f "$STAGE/extract/completion/btm.fish" ]]; then
  install -m 0644 "$STAGE/extract/completion/btm.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/btm.fish"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ClementTsang/bottom
License: MIT (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-bottom
bottom $VER_UP — cross-platform graphical process/system monitor (binary: btm).
Upstream aarch64-unknown-linux-musl static. 合主线：gork.bot协助开发
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
Description: bottom (btm) system monitor (arm64 musl static)
 bottom $VER_UP — yet another cross-platform graphical process/system monitor.
 Static aarch64 musl; binary /usr/bin/btm. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
