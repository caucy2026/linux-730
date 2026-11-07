#!/usr/bin/env bash
# Build arm64 kemi-melt .deb wrapping upstream Linux_arm64 static (charmbracelet/melt).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.6.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-melt
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/melt_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/melt/releases/download/v${VER_UP}/melt_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=12cdf4ee09b5fea8bba9388495912c19c784c844f407dddadb86e1d2b7b63acd
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/melt_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/melt"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/melt"
if [[ -f "$SRC/manpages/melt.1.gz" ]]; then
  install -m 0644 "$SRC/manpages/melt.1.gz" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completions/melt.bash" ]]; then
  install -m 0644 "$SRC/completions/melt.bash" "$STAGE/pkg/usr/share/bash-completion/completions/melt"
fi
if [[ -f "$SRC/completions/melt.zsh" ]]; then
  install -m 0644 "$SRC/completions/melt.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_melt"
fi
if [[ -f "$SRC/completions/melt.fish" ]]; then
  install -m 0644 "$SRC/completions/melt.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/melt.fish"
fi
for f in README.md LICENSE.md; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/melt
License: MIT (see LICENSE.md)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-melt
melt $VER_UP — Backup and restore Ed25519 SSH keys with seed phrases.
Upstream Linux_arm64 static binary under /usr/bin/melt.
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
Description: melt SSH key seed phrases (arm64 static)
 melt $VER_UP — Backup and restore Ed25519 SSH keys with seed phrases.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
