#!/usr/bin/env bash
# Build arm64 kemi-just .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.59.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-just
DL="${DL:-$ROOT/dl}"
TGZ="$DL/just-${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/casey/just/releases/download/${VER_UP}/just-${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=23871b1702bfd550fb5f901778fd4290ecf2ee034a45a889fbe96d89b188086d
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
BIN=$(find "$STAGE/extract" -type f -name just | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/just"
BASE=$(dirname "$BIN")
# tarball often has man/completions at top level or next to binary
for f in "$BASE/just.1" "$STAGE/extract/just.1"; do
  [[ -f "$f" ]] && install -m 0644 "$f" "$STAGE/pkg/usr/share/man/man1/just.1" && break || true
done
for f in "$BASE/completions/just.bash" "$STAGE/extract/completions/just.bash" "$BASE/just.bash"; do
  [[ -f "$f" ]] && install -m 0644 "$f" "$STAGE/pkg/usr/share/bash-completion/completions/just" && break || true
done
for f in "$BASE/completions/just.zsh" "$STAGE/extract/completions/just.zsh" "$BASE/just.zsh"; do
  [[ -f "$f" ]] && install -m 0644 "$f" "$STAGE/pkg/usr/share/zsh/vendor-completions/_just" && break || true
done
for f in "$BASE/completions/just.fish" "$STAGE/extract/completions/just.fish" "$BASE/just.fish"; do
  [[ -f "$f" ]] && install -m 0644 "$f" "$STAGE/pkg/usr/share/fish/vendor_completions.d/just.fish" && break || true
done
[[ -f "$BASE/LICENSE" ]] && install -m 0644 "$BASE/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream" || true
[[ -f "$STAGE/extract/LICENSE" ]] && install -m 0644 "$STAGE/extract/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream" || true
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/casey/just
License: CC0-1.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-just
just $VER_UP — Just a command runner. Upstream aarch64-unknown-linux-musl static.
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
Description: just command runner (arm64 musl static)
 just $VER_UP — Just a command runner.
 Static aarch64 musl. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
