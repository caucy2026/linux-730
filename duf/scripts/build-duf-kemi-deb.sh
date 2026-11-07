#!/usr/bin/env bash
# Build arm64 kemi-duf .deb wrapping upstream static linux_arm64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.9.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-duf
DL="${DL:-$ROOT/dl}"
TGZ="$DL/duf_0.9.1_linux_arm64.tar.gz"
URL="https://github.com/muesli/duf/releases/download/v${VER_UP}/duf_0.9.1_linux_arm64.tar.gz"
EXPECT_SHA=22ea0ad29f6610bf443aa351e600de97e47a9b380ef58316606a84bb8f595216
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin"   "$STAGE/pkg/usr/share/doc/$PKG" "$STAGE/pkg/usr/share/man/man1"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name duf | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/duf"
MAN=$(find "$STAGE/extract" -type f -name 'duf.1' | head -1 || true)
[[ -n "${MAN:-}" ]] && install -m 0644 "$MAN" "$STAGE/pkg/usr/share/man/man1/duf.1"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/muesli/duf
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-duf
duf $VER_UP — Disk Usage/Free Utility. Upstream linux_arm64 static Go binary.
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
Description: duf disk usage/free utility (arm64 static)
 duf $VER_UP — Disk Usage/Free Utility (better df).
 Static aarch64 Go; no Docker. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
