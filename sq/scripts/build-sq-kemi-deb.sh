#!/usr/bin/env bash
# Build arm64 kemi-sq .deb wrapping upstream linux-arm64 static (neilotoole/sq).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.55.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-sq
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/sq-${VER_UP}-linux-arm64.tar.gz"
URL="https://github.com/neilotoole/sq/releases/download/v${VER_UP}/sq-${VER_UP}-linux-arm64.tar.gz"
EXPECT_SHA=3a99e6b1ac6f2802ce620de453259b5fc9946f52c4b8ae13e93e0c9f2722dfcc
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name sq | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/sq"
MAN=$(find "$EXTRACT" -type f -name 'sq.1.gz' | head -1 || true)
[[ -n "${MAN:-}" ]] && install -m 0644 "$MAN" "$STAGE/pkg/usr/share/man/man1/"
BASHC=$(find "$EXTRACT" -type f -path '*/completions/sq.bash' | head -1 || true)
[[ -n "${BASHC:-}" ]] && install -m 0644 "$BASHC" "$STAGE/pkg/usr/share/bash-completion/completions/sq"
ZSHC=$(find "$EXTRACT" -type f -path '*/completions/sq.zsh' | head -1 || true)
[[ -n "${ZSHC:-}" ]] && install -m 0644 "$ZSHC" "$STAGE/pkg/usr/share/zsh/vendor-completions/_sq"
FISHC=$(find "$EXTRACT" -type f -path '*/completions/sq.fish' | head -1 || true)
[[ -n "${FISHC:-}" ]] && install -m 0644 "$FISHC" "$STAGE/pkg/usr/share/fish/vendor_completions.d/sq.fish"
for f in README.md CHANGELOG.md LICENSE; do
  src=$(find "$EXTRACT" -maxdepth 1 -type f -name "$f" | head -1 || true)
  [[ -n "${src:-}" ]] && install -m 0644 "$src" "$STAGE/pkg/usr/share/doc/$PKG/"
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/neilotoole/sq
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-sq
sq $VER_UP — Swiss-army knife for data (neilotoole/sq).
Upstream linux-arm64 static binary under /usr/bin/sq.
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
Description: sq data Swiss-army knife (arm64 static)
 sq $VER_UP — Swiss-army knife for data (neilotoole/sq).
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
