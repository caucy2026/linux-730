#!/usr/bin/env bash
# Build arm64 kemi-goreleaser .deb wrapping upstream goreleaser_Linux_arm64.
# Binary command: goreleaser. 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.20.0
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-goreleaser
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/goreleaser_Linux_arm64.tar.gz"
URL="https://github.com/goreleaser/goreleaser/releases/download/v${VER_UP}/goreleaser_Linux_arm64.tar.gz"
EXPECT_TGZ=2dada0a6bbcd10f3a05228d98e77d25fb362efb9e5bab6362cf37e64c8a26cb9
EXPECT_BIN=fbb2d4282826697bda31aacebddd6e6c3de5c939df16c06d9c7ce08d0d5bb525
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name goreleaser | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
readelf -d "$BIN_SRC" 2>/dev/null | grep -q NEEDED && { echo 'FAIL: dynamic'; exit 1; } || echo 'OK static NO_NEEDED'
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/goreleaser"
# optional completions + man
if [[ -f "$EXTRACT/completions/goreleaser.bash" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/bash-completion/completions"
  install -m 0644 "$EXTRACT/completions/goreleaser.bash" "$STAGE/pkg/usr/share/bash-completion/completions/goreleaser"
fi
if [[ -f "$EXTRACT/completions/goreleaser.zsh" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/zsh/vendor-completions"
  install -m 0644 "$EXTRACT/completions/goreleaser.zsh" "$STAGE/pkg/usr/share/zsh/vendor-completions/_goreleaser"
fi
if [[ -f "$EXTRACT/completions/goreleaser.fish" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/fish/vendor_completions.d"
  install -m 0644 "$EXTRACT/completions/goreleaser.fish" "$STAGE/pkg/usr/share/fish/vendor_completions.d/goreleaser.fish"
fi
if [[ -f "$EXTRACT/manpages/goreleaser.1.gz" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/man/man1"
  install -m 0644 "$EXTRACT/manpages/goreleaser.1.gz" "$STAGE/pkg/usr/share/man/man1/goreleaser.1.gz"
fi
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/goreleaser/goreleaser
License: MIT (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-goreleaser
goreleaser $VER_UP — release automation for Go (and more).
Upstream linux-arm64 static binary under /usr/bin/goreleaser.
合主线：gork.bot协助开发
EOR
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOC
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: goreleaser release automation CLI (arm64 static)
 goreleaser $VER_UP — Deliver Go binaries as fast and easily as possible.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
