#!/usr/bin/env bash
# Build arm64 kemi-lsd .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.2.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-lsd
DL="${DL:-$ROOT/dl}"
TGZ="$DL/lsd-v1.2.0-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/lsd-rs/lsd/releases/download/v${VER_UP}/lsd-v1.2.0-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=642ecb1a763b9f790a99c83a1445c117a6813ed4edb5d498d4420423c6353eb8
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"   "$STAGE/pkg/DEBIAN"   "$STAGE/pkg/usr/bin"   "$STAGE/pkg/usr/share/doc/$PKG"   "$STAGE/pkg/usr/share/man/man1"   "$STAGE/pkg/usr/share/bash-completion/completions"   "$STAGE/pkg/usr/share/zsh/vendor-completions"   "$STAGE/pkg/usr/share/fish/vendor_completions.d"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name lsd | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/lsd"
BASE=$(dirname "$BIN")
[[ -f "$BASE/LICENSE" ]] && install -m 0644 "$BASE/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/LICENSE.upstream"
[[ -f "$BASE/lsd.1" ]] && install -m 0644 "$BASE/lsd.1" "$STAGE/pkg/usr/share/man/man1/lsd.1"
AC="$BASE/autocomplete"
if [[ -d "$AC" ]]; then
  [[ -f "$AC/lsd.bash-completion" ]] && install -m 0644 "$AC/lsd.bash-completion" "$STAGE/pkg/usr/share/bash-completion/completions/lsd"
  [[ -f "$AC/_lsd" ]] && install -m 0644 "$AC/_lsd" "$STAGE/pkg/usr/share/zsh/vendor-completions/_lsd"
  [[ -f "$AC/lsd.fish" ]] && install -m 0644 "$AC/lsd.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/lsd.fish"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/lsd-rs/lsd
License: Apache-2.0 (see upstream LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-lsd
lsd $VER_UP — next gen ls command. Upstream aarch64-unknown-linux-musl static.
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
Description: lsd next gen ls (arm64 musl static)
 lsd $VER_UP — the next gen ls command with lots of pretty colors and awesome icons.
 Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
