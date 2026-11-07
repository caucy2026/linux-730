#!/usr/bin/env bash
# Build arm64 kemi-pop .deb wrapping upstream Linux_arm64 static (charmbracelet/pop).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.5.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-pop
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/pop_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/pop/releases/download/v${VER_UP}/pop_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=79a4785d48548974a225ad44f160de447e627ba9291e973341c5fcb9fd96e0f5
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/pop_${VER_UP}_Linux_arm64"
BIN_SRC="$SRC/pop"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/pop"
if [[ -f "$SRC/manpages/pop.1.gz" ]]; then
  install -m 0644 "$SRC/manpages/pop.1.gz" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completions/pop.bash" ]]; then
  install -m 0644 "$SRC/completions/pop.bash" "$STAGE/pkg/usr/share/bash-completion/completions/pop"
fi
if [[ -f "$SRC/completions/pop.zsh" ]]; then
  install -m 0644 "$SRC/completions/pop.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_pop"
fi
if [[ -f "$SRC/completions/pop.fish" ]]; then
  install -m 0644 "$SRC/completions/pop.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/pop.fish"
fi
for f in README.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/pop
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-pop
pop $VER_UP — Send emails from your terminal.
Upstream Linux_arm64 static binary under /usr/bin/pop.
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
Description: pop send email from terminal (arm64 static)
 pop $VER_UP — Send emails from your terminal.
 Linux_arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
