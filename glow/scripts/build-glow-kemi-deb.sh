#!/usr/bin/env bash
# Build arm64 kemi-glow .deb wrapping upstream Linux arm64 static binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.0.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-glow
DL="${DL:-$ROOT/dl}"
TGZ="$DL/glow_3.0.0_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/glow/releases/download/v${VER_UP}/glow_3.0.0_Linux_arm64.tar.gz"
EXPECT_SHA=810c39f4691feb75e675a5f5f54b9fa091354e7599d9cf9c9fc9b97e47a99759
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
BIN=$(find "$STAGE/extract" -type f -name glow | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/glow"
BASE=$(dirname "$BIN")
[[ -f "$BASE/LICENSE" ]] && install -m 0644 "$BASE/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream" || true
[[ -f "$BASE/manpages/glow.1.gz" ]] && install -m 0644 "$BASE/manpages/glow.1.gz" "$STAGE/pkg/usr/share/man/man1/glow.1.gz"
[[ -f "$BASE/completions/glow.bash" ]] && install -m 0644 "$BASE/completions/glow.bash" "$STAGE/pkg/usr/share/bash-completion/completions/glow"
[[ -f "$BASE/completions/glow.zsh" ]] && install -m 0644 "$BASE/completions/glow.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_glow"
[[ -f "$BASE/completions/glow.fish" ]] && install -m 0644 "$BASE/completions/glow.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/glow.fish"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/charmbracelet/glow
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-glow
glow $VER_UP — Render markdown on the CLI. Upstream Linux_arm64 static Go binary.
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
Description: glow markdown terminal viewer (arm64 static)
 glow $VER_UP — Render markdown on the CLI, with pizzazz!
 Static aarch64. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
