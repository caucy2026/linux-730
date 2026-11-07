#!/usr/bin/env bash
# Build arm64 kemi-watchexec .deb wrapping upstream aarch64-musl (watchexec/watchexec).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.8.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-watchexec
DL="${DL:-$ROOT/dl}"
TAR_SRC="$DL/watchexec-2.8.0-aarch64-unknown-linux-musl.tar.xz"
URL="https://github.com/watchexec/watchexec/releases/download/v${VER_UP}/watchexec-${VER_UP}-aarch64-unknown-linux-musl.tar.xz"
EXPECT_SHA=3961878b21e3c1729279322f4007dd5bbf0032110fbcb5e7b983946a9ceb3bf6
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR_SRC" ]]; then
  curl -fsSL -o "$TAR_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TAR_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xJf "$TAR_SRC" -C "$EXTRACT"
SRC="$EXTRACT/watchexec-${VER_UP}-aarch64-unknown-linux-musl"
BIN_SRC="$SRC/watchexec"
test -x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/watchexec"
if [[ -f "$SRC/watchexec.1" ]]; then
  install -m 0644 "$SRC/watchexec.1" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completions/bash" ]]; then
  install -m 0644 "$SRC/completions/bash" "$STAGE/pkg/usr/share/bash-completion/completions/watchexec"
fi
if [[ -f "$SRC/completions/zsh" ]]; then
  install -m 0644 "$SRC/completions/zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_watchexec"
fi
if [[ -f "$SRC/completions/fish" ]]; then
  install -m 0644 "$SRC/completions/fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/watchexec.fish"
fi
if [[ -f "$SRC/LICENSE" ]]; then
  install -m 0644 "$SRC/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/watchexec/watchexec
License: Apache-2.0 (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-watchexec
watchexec $VER_UP — Executes commands in response to file modifications.
Upstream aarch64-musl static binary under /usr/bin/watchexec.
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
Description: watchexec file watcher (arm64 musl)
 watchexec $VER_UP — Executes commands in response to file modifications.
 aarch64-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
