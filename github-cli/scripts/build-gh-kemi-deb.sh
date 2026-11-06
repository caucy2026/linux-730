#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=2.103.3
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/gh_${VER_UPSTREAM}_linux_arm64.tar.gz"
URL="https://github.com/cli/cli/releases/download/v${VER_UPSTREAM}/gh_${VER_UPSTREAM}_linux_arm64.tar.gz"
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
BIN=$(find "$UP/extract" -path '*/bin/gh' -type f | head -1)
test -f "$BIN"
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-gh
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/gh"
MANROOT=$(dirname "$(dirname "$BIN")")/share
if [[ -d "$MANROOT" ]]; then mkdir -p "$STAGE/usr/share"; cp -a "$MANROOT"/* "$STAGE/usr/share/" || true; fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: gh
Conflicts: gh
Replaces: gh
Description: GitHub CLI (gh) for KEMI (arm64)
 Official GitHub CLI ${VER_UPSTREAM} linux_arm64, repackaged for KEMI Linux store.
 Installs /usr/bin/gh. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
