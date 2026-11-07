#!/usr/bin/env bash
# Build arm64 kemi-soft-serve .deb wrapping upstream Linux_arm64 static (charmbracelet/soft-serve).
# Binary name: soft. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.12.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-soft-serve
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/soft-serve_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/soft-serve/releases/download/v${VER_UP}/soft-serve_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=9f70fbd02577abcad05c9bf2c91cf22f6026f92da6ae0f834dcead65271153eb
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/soft-serve_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/soft"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/soft"
[[ -f "$SRC/manpages/soft-serve.1.gz" ]] && install -m 0644 "$SRC/manpages/soft-serve.1.gz" "$STAGE/pkg/usr/share/man/man1/"
[[ -f "$SRC/completions/soft-serve.bash" ]] && install -m 0644 "$SRC/completions/soft-serve.bash" "$STAGE/pkg/usr/share/bash-completion/completions/soft"
[[ -f "$SRC/completions/soft-serve.zsh" ]] && install -m 0644 "$SRC/completions/soft-serve.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_soft"
[[ -f "$SRC/completions/soft-serve.fish" ]] && install -m 0644 "$SRC/completions/soft-serve.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/soft.fish"
for f in README.md LICENSE; do
  [[ -f "$SRC/$f" ]] && install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/soft-serve
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-soft-serve
soft-serve $VER_UP — The tasty, self-hostable Git server for the command line (binary: soft).
Upstream Linux_arm64 static under /usr/bin/soft.
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
Description: soft-serve self-hostable Git server (arm64 static)
 soft-serve $VER_UP — self-hostable Git server (command: soft).
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
