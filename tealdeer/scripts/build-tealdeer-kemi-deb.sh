#!/usr/bin/env bash
# Build arm64 kemi-tealdeer .deb wrapping upstream musl static aarch64 binary.
# Binary is installed as /usr/bin/tldr (upstream CLI name).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.9.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-tealdeer
DL="${DL:-$ROOT/dl}"
BIN_SRC="$DL/tealdeer-linux-aarch64-musl"
URL="https://github.com/tealdeer-rs/tealdeer/releases/download/v${VER_UP}/tealdeer-linux-aarch64-musl"
EXPECT_SHA=247746dd2d18f0135da79b849bb6b49e45262e2fe4318adfc3082dc6ce3ee968
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_SRC" ]]; then
  curl -fsSL -o "$BIN_SRC" "$URL"
fi
echo "$EXPECT_SHA  $BIN_SRC" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/tldr"
# optional completions from release (download if present next to build)
for kind in bash fish zsh; do
  COMP="$DL/completions_$kind"
  if [[ ! -f "$COMP" ]]; then
    curl -fsSL -o "$COMP" "https://github.com/tealdeer-rs/tealdeer/releases/download/v${VER_UP}/completions_${kind}" || true
  fi
done
if [[ -f "$DL/completions_bash" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/bash-completion/completions"
  install -m 0644 "$DL/completions_bash" "$STAGE/pkg/usr/share/bash-completion/completions/tldr"
fi
if [[ -f "$DL/completions_zsh" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/zsh/vendor-completions"
  install -m 0644 "$DL/completions_zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_tldr"
fi
if [[ -f "$DL/completions_fish" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/fish/vendor_completions.d"
  install -m 0644 "$DL/completions_fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/tldr.fish"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/tealdeer-rs/tealdeer
License: MIT / Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-tealdeer
tealdeer $VER_UP — fast tldr client. Upstream linux-aarch64-musl static.
CLI: /usr/bin/tldr
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
Description: tealdeer tldr client (arm64 musl static)
 tealdeer $VER_UP — A very fast implementation of tldr in Rust.
 Static aarch64 musl. Provides /usr/bin/tldr. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
