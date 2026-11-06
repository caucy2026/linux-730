#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=1.2.7
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/dust-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/bootandy/dust/releases/download/v${VER_UPSTREAM}/dust-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name dust -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=22b441d64b3c3368456ddd4cdb727faa055029c4a4dc43e7b848497558b31c00
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-dust
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/dust"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/dust.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/dust.1" "$STAGE/usr/share/man/man1/dust.1"
fi
if [[ -f "$SRCROOT/autocomplete/dust.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/autocomplete/dust.bash" "$STAGE/usr/share/bash-completion/completions/dust"
elif [[ -f "$SRCROOT/completions/dust.bash" ]]; then
  mkdir -p "$STAGE/usr/share/bash-completion/completions"
  install -m 0644 "$SRCROOT/completions/dust.bash" "$STAGE/usr/share/bash-completion/completions/dust"
fi
if [[ -f "$SRCROOT/autocomplete/dust.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/autocomplete/dust.fish" "$STAGE/usr/share/fish/vendor_completions.d/dust.fish"
elif [[ -f "$SRCROOT/completions/dust.fish" ]]; then
  mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
  install -m 0644 "$SRCROOT/completions/dust.fish" "$STAGE/usr/share/fish/vendor_completions.d/dust.fish"
fi
if [[ -f "$SRCROOT/autocomplete/_dust" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/autocomplete/_dust" "$STAGE/usr/share/zsh/vendor-completions/_dust"
elif [[ -f "$SRCROOT/completions/_dust" ]]; then
  mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
  install -m 0644 "$SRCROOT/completions/_dust" "$STAGE/usr/share/zsh/vendor-completions/_dust"
fi
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: dust
Conflicts: dust
Replaces: dust
Description: dust disk usage for KEMI (arm64)
 Official bootandy/dust ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/dust. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
