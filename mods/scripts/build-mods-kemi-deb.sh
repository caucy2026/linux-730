#!/usr/bin/env bash
# Build arm64 kemi-mods .deb wrapping upstream Linux_arm64 static (charmbracelet/mods).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.8.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-mods
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/mods_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/mods/releases/download/v${VER_UP}/mods_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=448d205e27e1ec0cb4e185275ff826e93b16182d35977652db01e4d475b1b671
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/mods_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/mods"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/mods"
if [[ -f "$SRC/manpages/mods.1.gz" ]]; then
  install -m 0644 "$SRC/manpages/mods.1.gz" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completions/mods.bash" ]]; then
  install -m 0644 "$SRC/completions/mods.bash" "$STAGE/pkg/usr/share/bash-completion/completions/mods"
fi
if [[ -f "$SRC/completions/mods.zsh" ]]; then
  install -m 0644 "$SRC/completions/mods.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_mods"
fi
if [[ -f "$SRC/completions/mods.fish" ]]; then
  install -m 0644 "$SRC/completions/mods.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/mods.fish"
fi
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/mods
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-mods
mods $VER_UP — AI on the command line.
Upstream Linux_arm64 static binary under /usr/bin/mods.
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
Description: mods AI on the command line (arm64 static)
 mods $VER_UP — AI on the command line.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
