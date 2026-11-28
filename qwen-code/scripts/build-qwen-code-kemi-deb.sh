#!/usr/bin/env bash
# Build arm64 kemi-qwen-code .deb wrapping official Qwen Code linux-arm64 tarball.
# Strips foreign-arch vendor binaries and optional audio-capture.node (GLIBC_2.34).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.28.7
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-qwen-code
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/qwen-code-linux-arm64.tar.gz"
URL="https://github.com/QwenLM/qwen-code/releases/download/v${VER_UP}/qwen-code-linux-arm64.tar.gz"
EXPECT_SHA=88490953e9d1b93544fadb97486510cddfff9231cbc90387a6d449550e120e48
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
SRC="$STAGE/extract/qwen-code"
test -x "$SRC/bin/qwen"
test -x "$SRC/node/bin/node"
# drop non-linux-arm64 vendor ELFs
rm -rf \
  "$SRC/lib/vendor/ripgrep/x64-linux" \
  "$SRC/lib/vendor/ripgrep/x64-darwin" \
  "$SRC/lib/vendor/ripgrep/arm64-darwin" \
  "$SRC/lib/vendor/ripgrep/x64-win32" \
  "$SRC/lib/vendor/landlock-run/x64-linux"
# optionalDependency audio-capture native needs GLIBC_2.34; remove prebuild only
rm -f "$SRC/lib/node_modules/@qwen-code/audio-capture/prebuilds/linux-arm64/@qwen-code+audio-capture.node"
rmdir "$SRC/lib/node_modules/@qwen-code/audio-capture/prebuilds/linux-arm64" 2>/dev/null || true
if [[ -n "$PROBE" ]]; then
  python3 "$PROBE" --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$SRC"
fi
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/opt" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$SRC" "$STAGE/pkg/opt/qwen-code"
ln -s /opt/qwen-code/bin/qwen "$STAGE/pkg/usr/bin/qwen"
if [[ -f "$SRC/LICENSE" ]]; then
  install -m 0644 "$SRC/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-qwen-code
Qwen Code $VER_UP official linux-arm64 (bundled Node, glibc <= 2.28 after strip).
Removed foreign-arch ripgrep/landlock vendors and optional audio-capture.node
(GLIBC_2.34; voice capture unavailable on Ubuntu 20.04).
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
Depends: libc6 (>= 2.28)
Description: Qwen Code CLI coding agent (arm64)
 Official QwenLM/qwen-code $VER_UP Linux arm64 CLI (bundled Node).
 Foreign-arch vendor binaries stripped. Optional audio-capture native
 omitted (needs glibc 2.34). Apache-2.0. User supplies API keys.
 gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
