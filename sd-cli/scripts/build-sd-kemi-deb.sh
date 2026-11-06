#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=1.1.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
UP="$ROOT/upstream"
mkdir -p "$UP" "$OUT"
TAR="$UP/sd-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/chmln/sd/releases/download/v${VER_UPSTREAM}/sd-v${VER_UPSTREAM}-aarch64-unknown-linux-musl.tar.gz"
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
BIN=$(find "$UP/extract" -type f -name sd -print -quit)
test -n "$BIN"
test -f "$BIN"
BIN_EXPECT=376d61e1f5e776a770ab832ec7be6d39a46cded8d0efdb119b458329295e7622
BIN_ACT=$(sha256sum "$BIN" | awk '{print $1}')
[[ "$BIN_EXPECT" == "$BIN_ACT" ]] || { echo "binary SHA mismatch $BIN_ACT != $BIN_EXPECT"; exit 1; }
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-sd
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/sd"
SRCROOT=$(dirname "$BIN")
if [[ -f "$SRCROOT/sd.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/sd.1" "$STAGE/usr/share/man/man1/sd.1"
elif [[ -f "$SRCROOT/gen/sd.1" ]]; then
  mkdir -p "$STAGE/usr/share/man/man1"
  install -m 0644 "$SRCROOT/gen/sd.1" "$STAGE/usr/share/man/man1/sd.1"
fi
for base in "$SRCROOT/completions" "$SRCROOT/autocomplete" "$SRCROOT/complete" "$SRCROOT/gen/completions"; do
  if [[ -f "$base/sd.bash" ]]; then
    mkdir -p "$STAGE/usr/share/bash-completion/completions"
    install -m 0644 "$base/sd.bash" "$STAGE/usr/share/bash-completion/completions/sd"
  fi
  if [[ -f "$base/sd.fish" ]]; then
    mkdir -p "$STAGE/usr/share/fish/vendor_completions.d"
    install -m 0644 "$base/sd.fish" "$STAGE/usr/share/fish/vendor_completions.d/sd.fish"
  fi
  if [[ -f "$base/_sd" ]]; then
    mkdir -p "$STAGE/usr/share/zsh/vendor-completions"
    install -m 0644 "$base/_sd" "$STAGE/usr/share/zsh/vendor-completions/_sd"
  fi
  if [[ -f "$base/sd.elv" ]]; then
    mkdir -p "$STAGE/usr/share/elvish/lib"
    install -m 0644 "$base/sd.elv" "$STAGE/usr/share/elvish/lib/sd.elv"
  fi
done
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: sd
Conflicts: sd
Replaces: sd
Description: sd find and replace for KEMI (arm64)
 Official chmln/sd ${VER_UPSTREAM} aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Installs /usr/bin/sd. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
echo "DEB=$DEB"
