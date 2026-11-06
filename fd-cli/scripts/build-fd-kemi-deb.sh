#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=10.5.1
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/fd-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/sharkdp/fd/releases/download/v${VER_UPSTREAM}/fd-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name fd -print -quit)
test -f "$BIN"
BIN_EXPECT=fee1f8195a2ff2fe894236cd7c045a26b91f47e5300bf31d7be050561b4e188f
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-fd
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/fd"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/fd.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/fd.1" "$STAGE/usr/share/man/man1/fd.1"
fi
if [[ -f "$SRCROOT/autocomplete/fd.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/autocomplete/fd.bash" "$STAGE/usr/share/bash-completion/completions/fd"
fi
if [[ -f "$SRCROOT/autocomplete/fd.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/autocomplete/fd.fish" "$STAGE/usr/share/fish/vendor_completions.d/fd.fish"
fi
if [[ -f "$SRCROOT/autocomplete/_fd" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/autocomplete/_fd" "$STAGE/usr/share/zsh/vendor-completions/_fd"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: fd
Conflicts: fd
Replaces: fd
Description: fd file finder for KEMI (arm64)
 Official sharkdp/fd ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/fd. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
