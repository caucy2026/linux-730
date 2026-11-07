#!/usr/bin/env bash
# Build arm64 kemi-qsv .deb wrapping upstream aarch64-unknown-linux-musl (dathere/qsv).
# Single CLI: install only `qsv` (omit qsvlite). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=28.0.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-qsv
DL="${DL:-$ROOT/dl}"
ZIP_SRC="$DL/qsv-${VER_UP}-aarch64-unknown-linux-musl.zip"
URL="https://github.com/dathere/qsv/releases/download/${VER_UP}/qsv-${VER_UP}-aarch64-unknown-linux-musl.zip"
EXPECT_SHA=aec242f62d2679a6a63d9835aee898aa99fc7f0f99e77c9922a7e866c03bd951
mkdir -p "$DL" "$OUT"
if [[ ! -f "$ZIP_SRC" ]]; then
  curl -fsSL -o "$ZIP_SRC" "$URL"
fi
echo "$EXPECT_SHA  $ZIP_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
unzip -qo "$ZIP_SRC" -d "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name qsv | head -1)
test -n "$BIN_SRC" && test -f "$BIN_SRC"
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/qsv"
for f in README LICENSE-MIT COPYING THIRD_PARTY_NOTICES.md; do
  src=$(find "$EXTRACT" -maxdepth 2 -type f -name "$f" | head -1 || true)
  if [[ -n "${src:-}" ]]; then
    install -m 0644 "$src" "$STAGE/pkg/usr/share/doc/$PKG/"
  fi
done
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/dathere/qsv
License: MIT / Unlicense (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-qsv
qsv $VER_UP — high-performance CSV data-wrangling CLI.
Upstream aarch64-unknown-linux-musl static binary under /usr/bin/qsv
(qsvlite intentionally omitted — single-CLI package).
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
Description: qsv CSV Swiss-army knife (arm64 musl)
 qsv $VER_UP — high-performance CSV data-wrangling toolkit CLI.
 aarch64-unknown-linux-musl static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
