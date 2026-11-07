#!/usr/bin/env bash
# Build arm64 kemi-gum .deb wrapping upstream Linux arm64 static binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.0.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-gum
DL="${DL:-$ROOT/dl}"
TGZ="$DL/gum_2.0.2_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/gum/releases/download/v${VER_UP}/gum_2.0.2_Linux_arm64.tar.gz"
EXPECT_SHA=8ebf8b54ec1e8c81f2bb58b59ff9b70998186a4d11375f0cf357b80e0ccfa1d5
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG" "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name gum | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/gum"
BASE=$(dirname "$BIN")
[[ -f "$BASE/LICENSE" ]] && install -m 0644 "$BASE/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream" || true
[[ -f "$BASE/manpages/gum.1.gz" ]] && install -m 0644 "$BASE/manpages/gum.1.gz" "$STAGE/pkg/usr/share/man/man1/gum.1.gz"
[[ -f "$BASE/completions/gum.bash" ]] && install -m 0644 "$BASE/completions/gum.bash" "$STAGE/pkg/usr/share/bash-completion/completions/gum"
[[ -f "$BASE/completions/gum.zsh" ]] && install -m 0644 "$BASE/completions/gum.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_gum"
[[ -f "$BASE/completions/gum.fish" ]] && install -m 0644 "$BASE/completions/gum.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/gum.fish"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/gum
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-gum
gum $VER_UP — A tool for glamorous shell scripts. Upstream Linux_arm64 static Go binary.
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
Description: gum glamorous shell scripts (arm64 static)
 gum $VER_UP — A tool for glamorous shell scripts.
 Static aarch64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
