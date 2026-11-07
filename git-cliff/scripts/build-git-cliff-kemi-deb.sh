#!/usr/bin/env bash
# Build arm64 kemi-git-cliff .deb wrapping upstream aarch64-unknown-linux-musl (orhun/git-cliff).
# Single CLI: install only git-cliff (omit mangen/completions helper bins). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.14.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-git-cliff
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/git-cliff-${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/orhun/git-cliff/releases/download/v${VER_UP}/git-cliff-${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=4be21b21ec9699af4d330b224aeba8a41d41d8f5b351ca2da8a9ea2bdc36380f
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/git-cliff-${VER_UP}"
BIN_SRC="$SRC/git-cliff"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/git-cliff"
[[ -f "$SRC/man/git-cliff.1" ]] && install -m 0644 "$SRC/man/git-cliff.1" "$STAGE/pkg/usr/share/man/man1/"
[[ -f "$SRC/completions/git-cliff.bash" ]] && install -m 0644 "$SRC/completions/git-cliff.bash" "$STAGE/pkg/usr/share/bash-completion/completions/git-cliff"
[[ -f "$SRC/completions/_git-cliff" ]] && install -m 0644 "$SRC/completions/_git-cliff" "$STAGE/pkg/usr/share/zsh/vendor-completions/_git-cliff"
[[ -f "$SRC/completions/git-cliff.fish" ]] && install -m 0644 "$SRC/completions/git-cliff.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/git-cliff.fish"
for f in README.md CHANGELOG.md LICENSE-MIT LICENSE-APACHE; do
  [[ -f "$SRC/$f" ]] && install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/orhun/git-cliff
License: MIT OR Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-git-cliff
git-cliff $VER_UP — A highly customizable Changelog Generator.
Upstream aarch64-unknown-linux-musl static under /usr/bin/git-cliff
(helper bins git-cliff-mangen / git-cliff-completions omitted — single-CLI).
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
Description: git-cliff changelog generator (arm64 musl)
 git-cliff $VER_UP — highly customizable changelog generator.
 aarch64-unknown-linux-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
