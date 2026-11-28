#!/usr/bin/env bash
# Build arm64 kemi-oh-my-pi .deb wrapping official gnu omp-linux-arm64.
# Official musl build is dynamic (/lib/ld-musl-aarch64.so.1 + libstdc++), not 101-runnable.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=19.2.1
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-oh-my-pi
DL="${DL:-$ROOT/../../dl}"
BIN_DL="$DL/omp-linux-arm64"
URL="https://github.com/can1357/oh-my-pi/releases/download/v${VER_UP}/omp-linux-arm64"
EXPECT_SHA=92d4cce4b14814f6b838aa86dcec6359f0cb089cbcc300e8463cbb5326991fe0
PROBE=""
for c in "$(dirname "$0")/../../scripts/probe_elf_abi.py" /workspace/t157-pack/scripts/probe_elf_abi.py; do
  [[ -f "$c" ]] && PROBE="$c" && break
done
mkdir -p "$DL" "$OUT"
if [[ ! -f "$BIN_DL" ]]; then
  curl -fsSL -o "$BIN_DL" "$URL"
fi
echo "$EXPECT_SHA  $BIN_DL" | sha256sum -c -
chmod +x "$BIN_DL"
if [[ -n "$PROBE" ]]; then
  python3 "$PROBE" --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$BIN_DL"
fi
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/opt/oh-my-pi" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_DL" "$STAGE/pkg/opt/oh-my-pi/omp"
ln -s /opt/oh-my-pi/omp "$STAGE/pkg/usr/bin/omp"
ln -s /opt/oh-my-pi/omp "$STAGE/pkg/usr/bin/oh-my-pi"
if [[ -f "$ROOT/LICENSE.upstream" ]]; then
  install -m 0644 "$ROOT/LICENSE.upstream" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-oh-my-pi
oh-my-pi $VER_UP official linux-arm64 gnu (MAX_GLIBC 2.17).
Not the musl build (dynamic ld-musl + libstdc++). Not pi-bolt / badlogic Pi.
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
Depends: libc6 (>= 2.17)
Description: oh-my-pi coding agent (arm64)
 Official can1357/oh-my-pi $VER_UP Linux arm64 gnu binary (glibc 2.17).
 Distinct from shipped pi-bolt (badlogic/pi-mono). MIT.
 User supplies API keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
