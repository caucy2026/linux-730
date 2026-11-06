#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=1.8.2
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
BIN_UP="$UP/jq-linux-arm64"
URL="https://github.com/jqlang/jq/releases/download/jq-${VER_UPSTREAM}/jq-linux-arm64"
if [[ ! -f "$BIN_UP" ]]; then
  curl -fL --retry 3 -o "$BIN_UP" "$URL"
fi
if [[ -f "$ROOT/SHA256SUMS-upstream.txt" ]]; then
  EXPECT=$(awk '{print $1}' "$ROOT/SHA256SUMS-upstream.txt")
  ACT=$(sha256sum "$BIN_UP" | awk '{print $1}')
  [[ "$EXPECT" == "$ACT" ]] || { echo "SHA mismatch $ACT != $EXPECT"; exit 1; }
fi
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-jq
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN_UP" "$STAGE/usr/bin/jq"
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: jq
Conflicts: jq
Replaces: jq
Description: jq JSON processor for KEMI (arm64)
 Official jqlang/jq ${VER_UPSTREAM} linux arm64, repackaged for KEMI Linux store.
 Installs /usr/bin/jq. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
