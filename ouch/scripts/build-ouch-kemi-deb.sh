#!/usr/bin/env bash
# Build arm64 kemi-ouch .deb wrapping upstream aarch64-unknown-linux-musl static binary.
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.8.3
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-ouch
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/ouch-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/ouch-org/ouch/releases/download/${VER_UP}/ouch-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=4619158de69e65e8d23147c3d8b46b116feb0259c8a1704df7d792394c2b5847
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/ouch-aarch64-unknown-linux-musl/ouch"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/ouch"
# man pages if present
for m in "$EXTRACT"/ouch-aarch64-unknown-linux-musl/man/*.1; do
  [[ -f "$m" ]] && install -m 0644 "$m" "$STAGE/pkg/usr/share/man/man1/"
done
# completions
COMP="$EXTRACT/ouch-aarch64-unknown-linux-musl/completions"
[[ -f "$COMP/ouch.bash" ]] && install -m 0644 "$COMP/ouch.bash" "$STAGE/pkg/usr/share/bash-completion/completions/ouch"
[[ -f "$COMP/_ouch" ]] && install -m 0644 "$COMP/_ouch" "$STAGE/pkg/usr/share/zsh/vendor-completions/_ouch"
[[ -f "$COMP/ouch.fish" ]] && install -m 0644 "$COMP/ouch.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/ouch.fish"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/ouch-org/ouch
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-ouch
ouch $VER_UP — Painless compression/decompression. Upstream aarch64-unknown-linux-musl static.
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
Description: ouch archive tool (arm64 musl static)
 ouch $VER_UP — Painless compression and decompression.
 Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
