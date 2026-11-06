#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=0.74.5
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/fzf-${VER_UPSTREAM}-linux_arm64.tar.gz"
URL="https://github.com/junegunn/fzf/releases/download/v${VER_UPSTREAM}/fzf-${VER_UPSTREAM}-linux_arm64.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name fzf -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=886c80fa9a66b8687d1b072b8a956b8a4eb3311f03e4bea6a9cae39bf402a519
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-fzf
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/fzf"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/fzf.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/fzf.1" "$STAGE/usr/share/man/man1/fzf.1"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: fzf
Conflicts: fzf
Replaces: fzf
Description: fzf fuzzy finder for KEMI (arm64)
 Official junegunn/fzf ${VER_UPSTREAM} linux arm64, repackaged for KEMI Linux store.
 Installs /usr/bin/fzf. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
