#!/usr/bin/env bash
# Build arm64 kemi-pastel .deb wrapping upstream aarch64-unknown-linux-gnu (MAX GLIBC 2.18).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.12.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-pastel
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/pastel-v0.12.0-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/sharkdp/pastel/releases/download/v${VER_UP}/pastel-v${VER_UP}-aarch64-unknown-linux-gnu.tar.gz"
EXPECT_SHA=f437e19974399ab7ae99fa52b76a2cdfad4fafafde3b48243100d371894935ba
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TAR_SRC" -C "$EXTRACT"
BIN_SRC="$EXTRACT/pastel-v${VER_UP}-aarch64-unknown-linux-gnu/pastel"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/pastel"
# man pages
MAN_DIR="$EXTRACT/pastel-v${VER_UP}-aarch64-unknown-linux-gnu/man"
if [[ -d "$MAN_DIR" ]]; then
  for m in "$MAN_DIR"/*.1; do
    [[ -f "$m" ]] && install -m 0644 "$m" "$STAGE/pkg/usr/share/man/man1/"
  done
fi
# autocomplete
AC="$EXTRACT/pastel-v${VER_UP}-aarch64-unknown-linux-gnu/autocomplete"
if [[ -f "$AC/pastel.bash" ]]; then
  install -m 0644 "$AC/pastel.bash" "$STAGE/pkg/usr/share/bash-completion/completions/pastel"
fi
if [[ -f "$AC/_pastel" ]]; then
  install -m 0644 "$AC/_pastel" "$STAGE/pkg/usr/share/zsh/vendor-completions/_pastel"
fi
if [[ -f "$AC/pastel.fish" ]]; then
  install -m 0644 "$AC/pastel.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/pastel.fish"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/sharkdp/pastel
License: MIT/Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-pastel
pastel $VER_UP — a command-line tool to generate, analyze, convert and manipulate colors.
Upstream aarch64-gnu MAX GLIBC 2.18.
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
Description: pastel color CLI (arm64)
 pastel $VER_UP — generate, analyze, convert and manipulate colors.
 aarch64-gnu MAX GLIBC 2.18. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
