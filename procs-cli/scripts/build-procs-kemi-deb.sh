#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=0.14.12
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
ZIP="$UP/procs-v${VER_UPSTREAM}-aarch64-linux.zip"
URL="https://github.com/dalance/procs/releases/download/v${VER_UPSTREAM}/procs-v${VER_UPSTREAM}-aarch64-linux.zip"
if [[ ! -f "$ZIP" ]]; then
  curl -fL --retry 3 -o "$ZIP" "$URL"
fi
if [[ -f "$ROOT/SHA256SUMS-upstream.txt" ]]; then
  EXPECT=$(awk '{print $1}' "$ROOT/SHA256SUMS-upstream.txt")
  ACT=$(sha256sum "$ZIP" | awk '{print $1}')
  [[ "$EXPECT" == "$ACT" ]] || { echo "SHA mismatch $ACT != $EXPECT"; exit 1; }
fi
rm -rf "$UP/extract" && mkdir -p "$UP/extract"
unzip -q -o "$ZIP" -d "$UP/extract"
BIN=$(find "$UP/extract" -type f -name procs -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=bd09e92e5ff1cf32d9695997c4841e3c4e2a2c565f8584a1cc15d998b531fa4c
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-procs
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/procs"
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: procs
Conflicts: procs
Replaces: procs
Description: procs process viewer for KEMI (arm64)
 Official dalance/procs ${VER_UPSTREAM} aarch64-linux (musl static), repackaged for KEMI Linux store.
 Installs /usr/bin/procs. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
