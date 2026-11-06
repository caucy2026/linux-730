#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=0.10.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/zoxide-${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/ajeetdsouza/zoxide/releases/download/v${VER_UPSTREAM}/zoxide-${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name zoxide -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=1864ef686a652b9db90901c72dbb8bd3da45d98738d12f94b4f85729448f2dde
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-zoxide
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/zoxide"
SRCROOT=$(dirname "$BIN")
if [[ -d "$SRCROOT/man/man1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  find "$SRCROOT/man/man1" -type f -name '*.1' -exec install -m 0644 {} "$STAGE/usr/share/man/man1/" \;
fi
if [[ -f "$SRCROOT/completions/zoxide.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/completions/zoxide.bash" "$STAGE/usr/share/bash-completion/completions/zoxide"
fi
if [[ -f "$SRCROOT/completions/zoxide.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/completions/zoxide.fish" "$STAGE/usr/share/fish/vendor_completions.d/zoxide.fish"
fi
if [[ -f "$SRCROOT/completions/_zoxide" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/completions/_zoxide" "$STAGE/usr/share/zsh/vendor-completions/_zoxide"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: zoxide
Conflicts: zoxide
Replaces: zoxide
Description: zoxide smarter cd for KEMI (arm64)
 Official ajeetdsouza/zoxide ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/zoxide. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
