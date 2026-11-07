#!/usr/bin/env bash
# Build arm64 kemi-bandwhich .deb wrapping upstream musl static aarch64 binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.23.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-bandwhich
DL="${DL:-$ROOT/dl}"
TGZ="$DL/bandwhich-v0.23.1-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/imsnif/bandwhich/releases/download/v${VER_UP}/bandwhich-v0.23.1-aarch64-unknown-linux-musl.tar.gz"
EXPECT_SHA=6bbf084e5280a1a10833b8f466728ff428a7d637282c0487d6fcda0c4781357a
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ" ]]; then
  curl -fsSL -o "$TGZ" "$URL"
fi
echo "$EXPECT_SHA  $TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin"   "$STAGE/pkg/usr/share/doc/$PKG" "$STAGE/pkg/usr/share/man/man1"   "$STAGE/pkg/usr/share/bash-completion/completions"   "$STAGE/pkg/usr/share/zsh/vendor-completions"   "$STAGE/pkg/usr/share/fish/vendor_completions.d"
tar -xzf "$TGZ" -C "$STAGE/extract"
BIN=$(find "$STAGE/extract" -type f -name bandwhich | head -1)
test -x "$BIN"
install -m 0755 "$BIN" "$STAGE/pkg/usr/bin/bandwhich"
BASE=$(dirname "$BIN")
ASSETS="$BASE/assets"
if [[ -d "$ASSETS" ]]; then
  [[ -f "$ASSETS/bandwhich.1" ]] && install -m 0644 "$ASSETS/bandwhich.1" "$STAGE/pkg/usr/share/man/man1/bandwhich.1"
  [[ -f "$ASSETS/bandwhich.bash" ]] && install -m 0644 "$ASSETS/bandwhich.bash" "$STAGE/pkg/usr/share/bash-completion/completions/bandwhich"
  [[ -f "$ASSETS/_bandwhich" ]] && install -m 0644 "$ASSETS/_bandwhich" "$STAGE/pkg/usr/share/zsh/vendor-completions/_bandwhich"
  [[ -f "$ASSETS/bandwhich.fish" ]] && install -m 0644 "$ASSETS/bandwhich.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/bandwhich.fish"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/imsnif/bandwhich
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-bandwhich
bandwhich $VER_UP — terminal bandwidth utilization tool. Upstream aarch64-unknown-linux-musl static.
合主线：gork.bot协助开发
EOR
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOC
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: bandwhich bandwidth monitor (arm64 musl static)
 bandwhich $VER_UP — Terminal bandwidth utilization tool.
 Static aarch64 musl. May need CAP_NET_RAW on device. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
