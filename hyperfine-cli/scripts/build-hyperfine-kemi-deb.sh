#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=2.0.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/hyperfine-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/sharkdp/hyperfine/releases/download/v${VER_UPSTREAM}/hyperfine-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name hyperfine -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=1817d2374db766607bf18992a031638c92b31d53d3cc2328a9a3451b8d12391a
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-hyperfine
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/hyperfine"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/hyperfine.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/hyperfine.1" "$STAGE/usr/share/man/man1/hyperfine.1"
fi
if [[ -f "$SRCROOT/autocomplete/hyperfine.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/autocomplete/hyperfine.bash" "$STAGE/usr/share/bash-completion/completions/hyperfine"
fi
if [[ -f "$SRCROOT/autocomplete/hyperfine.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/autocomplete/hyperfine.fish" "$STAGE/usr/share/fish/vendor_completions.d/hyperfine.fish"
fi
if [[ -f "$SRCROOT/autocomplete/_hyperfine" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/autocomplete/_hyperfine" "$STAGE/usr/share/zsh/vendor-completions/_hyperfine"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: hyperfine
Conflicts: hyperfine
Replaces: hyperfine
Description: hyperfine command-line benchmarking for KEMI (arm64)
 Official sharkdp/hyperfine ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/hyperfine. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
