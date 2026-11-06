#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=0.20.1
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/delta-${VER_UPSTREAM}-aarch64-unknown-linux-gnu.tar.gz"
URL="https://github.com/dandavison/delta/releases/download/${VER_UPSTREAM}/delta-${VER_UPSTREAM}-aarch64-unknown-linux-gnu.tar.gz"
if [[ ! -f "$TAR" ]]; then
  curl -fL --retry 3 -o "$TAR" "$URL"
fi
if [[ -f "$ROOT/SHA256SUMS-upstream.txt" ]]; then
  EXPECT=$(awk '{print $1}' "$ROOT/SHA256SUMS-upstream.txt")
  ACT=$(sha256sum "$TAR" | awk '{print $1}')
  [[ "$EXPECT" == "$ACT" ]] || { echo "SHA mismatch $ACT != $EXPECT"; exit 1; }
fi
rm -rf "$UP/extract" && mkdir -p "$UP/extract"
tar -xzf "$TAR" -C "$UP/extract"
BIN=$(find "$UP/extract" -type f -name delta -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=eb5ba9f0ba70e60543d11dc20ad8979d3565f8307055338a638d954b2a4a7062
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-delta
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/delta"
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Depends: libc6
Provides: delta, git-delta
Conflicts: delta, git-delta
Replaces: delta, git-delta
Description: delta syntax-highlighting diff for KEMI (arm64)
 Official dandavison/delta ${VER_UPSTREAM} aarch64-unknown-linux-gnu, repackaged for KEMI Linux store.
 Installs /usr/bin/delta. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
