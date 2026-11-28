#!/usr/bin/env bash
# Build arm64 kemi-cc-switch-cli .deb wrapping official static musl CLI.
# Official gnu linux-arm64 needs GLIBC_2.39 — do not ship that artifact.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=5.11.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-cc-switch-cli
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/cc-switch-cli-linux-arm64-musl.tar.gz"
URL="https://github.com/SaladDay/cc-switch-cli/releases/download/v${VER_UP}/cc-switch-cli-linux-arm64-musl.tar.gz"
EXPECT_SHA=ea1ee67c4c9a72383a95f9ce1b97d13b9ea7d5f1e896e16aba2c1999b7c77fec
PROBE=""
for c in "$(dirname "$0")/../../scripts/probe_elf_abi.py" /workspace/t157-pack/scripts/probe_elf_abi.py; do
  [[ -f "$c" ]] && PROBE="$c" && break
done
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN="$STAGE/extract/cc-switch"
test -f "$BIN"
chmod +x "$BIN"
if [[ -n "$PROBE" ]]; then
  python3 "$PROBE" --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$BIN"
fi
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/opt/cc-switch-cli" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/pkg/opt/cc-switch-cli/cc-switch"
ln -s /opt/cc-switch-cli/cc-switch "$STAGE/pkg/usr/bin/cc-switch"
ln -s /opt/cc-switch-cli/cc-switch "$STAGE/pkg/usr/bin/cc-switch-cli"
if [[ -f "$ROOT/LICENSE.upstream" ]]; then
  install -m 0644 "$ROOT/LICENSE.upstream" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-cc-switch-cli
CC Switch CLI $VER_UP official linux-arm64 musl (static aarch64 EXEC).
Not the desktop app (farion1231/cc-switch, SKIP glibc 2.35+ / WebKitGTK 4.1).
Official gnu tarball needs GLIBC_2.39 and is not shipped.
合主线：gork.bot协助开发
EOT
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: CC Switch CLI (arm64 musl)
 Official SaladDay/cc-switch-cli $VER_UP Linux arm64 musl
 (static aarch64). Separate title from CC Switch desktop.
 MIT. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
