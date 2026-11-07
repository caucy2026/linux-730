#!/usr/bin/env bash
# Build arm64 kemi-crush .deb wrapping upstream static binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.100.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-crush
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/crush_${VER_UP}_Linux_arm64.tar.gz"
URL="https://github.com/charmbracelet/crush/releases/download/v${VER_UP}/crush_${VER_UP}_Linux_arm64.tar.gz"
EXPECT_SHA=095e3ab19710508e9ae41919e5f179f69bac390aeb7c06a14ef999c78dde705a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name crush | head -1)
test -x "$BIN"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" "$STAGE/pkg/etc/bash_completion.d" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d" "$STAGE/pkg/usr/share/zsh/site-functions"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/crush"
EXDIR=$(dirname "$BIN")
[[ -f "$EXDIR/manpages/crush.1.gz" ]] && install -m 0644 "$EXDIR/manpages/crush.1.gz" "$STAGE/pkg/usr/share/man/man1/crush.1.gz"
[[ -f "$EXDIR/completions/crush.bash" ]] && install -m 0644 "$EXDIR/completions/crush.bash" "$STAGE/pkg/etc/bash_completion.d/crush"
[[ -f "$EXDIR/completions/crush.fish" ]] && install -m 0644 "$EXDIR/completions/crush.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/crush.fish"
[[ -f "$EXDIR/completions/crush.zsh" ]] && install -m 0644 "$EXDIR/completions/crush.zsh" "$STAGE/pkg/usr/share/zsh/site-functions/_crush"
[[ -f "$EXDIR/LICENSE.md" ]] && cp "$EXDIR/LICENSE.md" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-crush
Charm Crush terminal AI coding agent. Upstream $VER_UP static arm64.
合主线：gork.bot协助开发
EOT
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Crush terminal AI coding agent (arm64)
 Charm Crush $VER_UP — terminal-based AI assistant for developers.
 Static aarch64 binary; no Docker. User supplies LLM API keys.
 FSL-1.1-MIT. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
