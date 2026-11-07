#!/usr/bin/env bash
# Build arm64 kemi-typos .deb wrapping upstream aarch64-unknown-linux-musl (crate-ci/typos).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.52.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-typos
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/typos-v${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/crate-ci/typos/releases/download/v${VER_UP}/typos-v${VER_UP}-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=63b7d4478d467a61fe47cdb3162f720c6797856e61a04f7e125d1cdc282488b8
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name typos | head -1)
test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/typos"
for f in README.md LICENSE-MIT LICENSE-APACHE; do
  src=$(find "$EXTRACT" -maxdepth 2 -type f -name "$f" | head -1 || true)
  if [[ -n "${src:-}" ]]; then
    install -m 0644 "$src" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/crate-ci/typos
License: MIT OR Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-typos
typos $VER_UP — Source code spell checker.
Upstream aarch64-unknown-linux-musl static binary under /usr/bin/typos.
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
Description: typos source spell checker (arm64 musl)
 typos $VER_UP — Source code spell checker.
 aarch64-unknown-linux-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
