#!/usr/bin/env bash
# Build arm64 codex-cli .deb wrapping upstream musl binary.
# Expects: $ROOT/upstream/codex (extracted binary) or CODEX_BIN env.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${CODEX_BIN:-$ROOT/upstream/codex}"
VER_UPSTREAM=0.166.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
PKG=codex-cli
test -x "$BIN" || { echo "missing binary: $BIN"; exit 1; }
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
install -m 0755 "$BIN" "$STAGE/usr/bin/codex"
cat > "$STAGE/usr/share/doc/$PKG/README.kemi.md" << EOT
# codex-cli
Upstream OpenAI Codex CLI ${VER_UPSTREAM} (aarch64-unknown-linux-musl), repackaged for KEMI.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: OpenAI Codex CLI (aarch64 linux musl upstream binary)
 Upstream rust-v${VER_UPSTREAM} codex-aarch64-unknown-linux-musl, repackaged for KEMI Linux store.
 Verified packaging for Ubuntu 20.04 aarch64 (101). gork.bot协助开发.
EOT
mkdir -p "$OUT"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
echo "DEB=$DEB"
