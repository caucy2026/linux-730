#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=15.2.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/ripgrep-${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/BurntSushi/ripgrep/releases/download/${VER_UPSTREAM}/ripgrep-${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name rg -print -quit)
test -f "$BIN"
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-ripgrep
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/rg"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/doc/rg.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/doc/rg.1" "$STAGE/usr/share/man/man1/rg.1"
fi
if [[ -f "$SRCROOT/complete/rg.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/complete/rg.bash" "$STAGE/usr/share/bash-completion/completions/rg"
fi
if [[ -f "$SRCROOT/complete/rg.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/complete/rg.fish" "$STAGE/usr/share/fish/vendor_completions.d/rg.fish"
fi
if [[ -f "$SRCROOT/complete/_rg" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/complete/_rg" "$STAGE/usr/share/zsh/vendor-completions/_rg"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: ripgrep
Conflicts: ripgrep
Replaces: ripgrep
Description: ripgrep (rg) for KEMI (arm64)
 Official BurntSushi/ripgrep ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/rg. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
