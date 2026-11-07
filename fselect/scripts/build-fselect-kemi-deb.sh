#!/usr/bin/env bash
# Build arm64 kemi-fselect .deb wrapping upstream aarch64-linux-musl (jhspetersson/fselect).
# 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.10.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-fselect
DL="${DL:-$ROOT/dl}"
GZ_SRC="$DL/fselect-aarch64-linux-musl.gz"
URL="https://github.com/jhspetersson/fselect/releases/download/${VER_UP}/fselect-aarch64-linux-musl.gz"
EXPECT_SHA=8719132405679e609fc548d2746f53de3e8c20220a8c453f00a91256dda31eb6
mkdir -p "$DL" "$OUT"
if [[ ! -f "$GZ_SRC" ]]; then
  curl -fsSL -o "$GZ_SRC" "$URL"
fi
echo "$EXPECT_SHA  $GZ_SRC" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
gunzip -c "$GZ_SRC" > "$STAGE/pkg/usr/bin/fselect"
chmod 0755 "$STAGE/pkg/usr/bin/fselect"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/jhspetersson/fselect
License: MIT/Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-fselect
fselect $VER_UP — Find files with SQL-like queries.
Upstream aarch64-linux-musl static binary under /usr/bin/fselect.
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
Description: fselect SQL-like file finder (arm64 musl)
 fselect $VER_UP — Find files with SQL-like queries.
 aarch64-linux-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
