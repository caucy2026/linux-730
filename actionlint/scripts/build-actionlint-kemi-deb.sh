#!/usr/bin/env bash
# Build arm64 kemi-actionlint .deb wrapping upstream actionlint linux_arm64.
# Binary command: actionlint. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.7.12
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-actionlint
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/actionlint_${VER_UP}_linux_arm64.tar.gz"
URL="https://github.com/rhysd/actionlint/releases/download/v${VER_UP}/actionlint_${VER_UP}_linux_arm64.tar.gz"
EXPECT_TGZ=325e971b6ba9bfa504672e29be93c24981eeb1c07576d730e9f7c8805afff0c6
EXPECT_BIN=ac0323433c2853ec3fb978c611430c5b3dc5d43c58d1a1ec031b00ab572beb60
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name actionlint | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/actionlint"
MAN_SRC=$(find "$EXTRACT" -type f -name 'actionlint.1' | head -1 || true)
if [[ -n "${MAN_SRC:-}" && -f "$MAN_SRC" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/man/man1"
  install -m 0644 "$MAN_SRC" "$STAGE/pkg/usr/share/man/man1/actionlint.1"
  gzip -9n "$STAGE/pkg/usr/share/man/man1/actionlint.1" || true
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/rhysd/actionlint
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-actionlint
actionlint $VER_UP — static checker for GitHub Actions workflow files.
Upstream linux-arm64 static binary under /usr/bin/actionlint.
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
Description: actionlint GitHub Actions linter (arm64 static)
 actionlint $VER_UP — static checker for GitHub Actions workflow files.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
