#!/usr/bin/env bash
# Build arm64 kemi-codewhale .deb wrapping official static Codewhale CLI/TUI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=0.10.4
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/../../debs}"
ARCH=arm64
PKG=kemi-codewhale
DL="${DL:-$ROOT/../../dl}"
TAR="$DL/codewhale-linux-arm64.tar.gz"
URL="https://github.com/codewhale-hq/Codewhale/releases/download/v${VER_UP}/codewhale-linux-arm64.tar.gz"
EXPECT_SHA=a711c0d430d44917d668ba980d107eee3f33faf26777c54ff8552b1e79769eec
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
SRC="$STAGE/extract/codewhale-linux-arm64"
BIN="$SRC/codewhale"
test -x "$BIN"
# official tarball also ships identical `codew` (same sha256); probe both then install once.
if [[ -n "$PROBE" ]]; then
  python3 "$PROBE" --max-glibc 2.31 --max-glibcxx 3.4.28 --expect-arch AArch64 "$SRC/codewhale" "$SRC/codew"
fi
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/opt/codewhale" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/pkg/opt/codewhale/codewhale"
if [[ -d "$SRC/codewhale-notices" ]]; then
  cp -a "$SRC/codewhale-notices" "$STAGE/pkg/opt/codewhale/codewhale-notices"
  if [[ -f "$SRC/codewhale-notices/LICENSE" ]]; then
    install -m 0644 "$SRC/codewhale-notices/LICENSE" "$STAGE/pkg/usr/share/doc/$PKG/copyright"
  fi
fi
ln -s /opt/codewhale/codewhale "$STAGE/pkg/usr/bin/codewhale"
ln -s /opt/codewhale/codewhale "$STAGE/pkg/usr/bin/codew"
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# kemi-codewhale
Codewhale $VER_UP official linux-arm64 (static aarch64 EXEC).
\`codew\` is an official alias of the same binary.
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
Description: Codewhale CLI/TUI coding agent (arm64)
 Official codewhale-hq/Codewhale $VER_UP Linux arm64 CLI/TUI
 (static aarch64; official \`codew\` alias). MIT.
 User supplies API keys. gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
