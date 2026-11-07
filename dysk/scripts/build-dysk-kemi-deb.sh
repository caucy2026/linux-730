#!/usr/bin/env bash
# Build arm64 kemi-dysk .deb wrapping upstream aarch64-unknown-linux-musl (Canop/dysk).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=3.8.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-dysk
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/dysk-v${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/Canop/dysk/releases/download/v${VER_UP}/dysk-v${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=1017a880c83cd37d9794c1ab2b02937b21dce2bd0684965cf7e787c7b6593b31
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
SRC="$EXTRACT/dysk-v${VER_UP}-aarch64-unknown-linux-musl"
BIN_SRC="$SRC/dysk"
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/zsh/vendor-completions" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/dysk"
if [[ -f "$SRC/man/dysk.1" ]]; then
  install -m 0644 "$SRC/man/dysk.1" "$STAGE/pkg/usr/share/man/man1/"
fi
if [[ -f "$SRC/completion/dysk.bash" ]]; then
  install -m 0644 "$SRC/completion/dysk.bash" "$STAGE/pkg/usr/share/bash-completion/completions/dysk"
fi
if [[ -f "$SRC/completion/_dysk" ]]; then
  install -m 0644 "$SRC/completion/_dysk" "$STAGE/pkg/usr/share/zsh/vendor-completions/_dysk"
fi
if [[ -f "$SRC/completion/dysk.fish" ]]; then
  install -m 0644 "$SRC/completion/dysk.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/dysk.fish"
fi
for f in README.md CHANGELOG.md LICENSE; do
  if [[ -f "$SRC/$f" ]]; then
    install -m 0644 "$SRC/$f" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/Canop/dysk
License: MIT (see LICENSE)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-dysk
dysk $VER_UP — A linux utility to get information on filesystems.
Upstream aarch64-unknown-linux-musl static binary under /usr/bin/dysk.
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
Description: dysk filesystem info (arm64 musl)
 dysk $VER_UP — Get information on filesystems.
 aarch64-unknown-linux-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
