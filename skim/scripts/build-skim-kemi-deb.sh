#!/usr/bin/env bash
# Build arm64 kemi-skim .deb wrapping upstream aarch64-musl (skim-rs/skim).
# Binary installed as /usr/bin/sk.
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=5.9.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-skim
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/skim-aarch64-unknown-linux-musl.tar.xz"
URL="https://github.com/skim-rs/skim/releases/download/v${VER_UP}/skim-aarch64-unknown-linux-musl.tar.xz"
EXPECT_SHA=651fa4314223e3c32478f32cab22cf046943c6852caa220c73f211f785bc257a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xJf "$TAR_SRC" -C "$EXTRACT"
SRC="$EXTRACT/skim-aarch64-unknown-linux-musl"
BIN_SRC="$SRC/sk"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/skim" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/sk"
if [[ -f "$SRC/man/man1/sk.1" ]]; then
  install -m 0644 "$SRC/man/man1/sk.1" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/man/man1/sk-tmux.1" ]]; then
  install -m 0644 "$SRC/man/man1/sk-tmux.1" "$STAGE/pkg/usr/share/man/man1/"
fi
# shell helpers (key-bindings + completions) under /usr/share/skim + completion dirs
if [[ -d "$SRC/shell" ]]; then
  for f in key-bindings.bash key-bindings.zsh key-bindings.fish completion.bash completion.zsh completion.fish completion.nu LICENSE README.md version.txt; do
    [[ -f "$SRC/shell/$f" ]] && install -m 0644 "$SRC/shell/$f" "$STAGE/pkg/usr/share/skim/"
  done
  [[ -f "$SRC/shell/completion.bash" ]] && install -m 0644 "$SRC/shell/completion.bash" "$STAGE/pkg/usr/share/bash-completion/completions/sk"
  [[ -f "$SRC/shell/completion.zsh" ]] && install -m 0644 "$SRC/shell/completion.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_sk"
  [[ -f "$SRC/shell/completion.fish" ]] && install -m 0644 "$SRC/shell/completion.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/sk.fish"
fi
if [[ -f "$SRC/LICENSE" ]]; then
  install -m 0644 "$SRC/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/skim-rs/skim
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-skim
skim $VER_UP — Fuzzy Finder in rust!
Binary: /usr/bin/sk (aarch64-musl static).
Shell helpers: /usr/share/skim/
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
Description: skim fuzzy finder (arm64 musl)
 skim $VER_UP — Fuzzy Finder in rust (command: sk).
 aarch64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
