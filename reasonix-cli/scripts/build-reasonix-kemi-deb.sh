#!/usr/bin/env bash
# Build arm64 kemi-reasonix .deb wrapping official static Reasonix CLI + Studio dist.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.61.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-reasonix
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/reasonix-linux-arm64.tar.gz"
URL="https://github.com/esengine/DeepSeek-Reasonix/releases/download/v${VER_UP}/reasonix-linux-arm64.tar.gz"
EXPECT_SHA=08ce828507427f3f0e475e2b0bf5e71944e30e49b197fc8bd2ab8dc25983f174
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TAR" ]]; then
  curl -fsSL -o "$TAR" "$URL"
fi
echo "$EXPECT_SHA  $TAR" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$TAR" -C "$STAGE/extract"
BIN="$STAGE/extract/reasonix"
test -x "$BIN"
# ABI: official static aarch64 EXEC (no PT_INTERP / no glibc NEEDED).
if command -v python3 >/dev/null && [[ -f "$(dirname "$0")/../../scripts/probe_elf_abi.py" ]]; then
  python3 "$(dirname "$0")/../../scripts/probe_elf_abi.py" --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$BIN"
elif command -v python3 >/dev/null && [[ -f /workspace/t157-pack/scripts/probe_elf_abi.py ]]; then
  python3 /workspace/t157-pack/scripts/probe_elf_abi.py --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$BIN"
fi
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/opt/reasonix" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/pkg/opt/reasonix/reasonix"
if [[ -d "$STAGE/extract/frontend-next" ]]; then
  cp -a "$STAGE/extract/frontend-next" "$STAGE/pkg/opt/reasonix/frontend-next"
fi
ln -s /opt/reasonix/reasonix "$STAGE/pkg/usr/bin/reasonix"
if [[ -f "$ROOT/LICENSE.upstream" ]]; then
  install -m 0644 "$ROOT/LICENSE.upstream" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
elif [[ -f /tmp/reasonix-LICENSE ]]; then
  install -m 0644 /tmp/reasonix-LICENSE "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-reasonix
Reasonix CLI $VER_UP official linux-arm64 (static aarch64).
Studio dist is at /opt/reasonix/frontend-next/dist for:
  reasonix serve --page /opt/reasonix/frontend-next/dist
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
Description: Reasonix CLI coding agent (arm64)
 Official DeepSeek-Reasonix $VER_UP Linux arm64 CLI (static aarch64).
 Includes Studio frontend-next dist for \`reasonix serve --page\`.
 MIT. User supplies LLM API keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
