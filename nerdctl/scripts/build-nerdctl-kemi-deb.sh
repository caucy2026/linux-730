#!/usr/bin/env bash
# Build arm64 kemi-nerdctl .deb wrapping upstream linux-arm64 static (containerd/nerdctl).
# Binary command: nerdctl only (single-CLI; skip rootless helper scripts). 合主线：gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=2.4.2
VER_DEB="${VER_UP}-1kemi1"
OUT="${OUT:-$ROOT/debs}"
ARCH=arm64
PKG=kemi-nerdctl
DL="${DL:-$ROOT/dl}"
TGZ_SRC="$DL/nerdctl-${VER_UP}-linux-arm64.tar.gz"
URL="https://github.com/containerd/nerdctl/releases/download/v${VER_UP}/nerdctl-${VER_UP}-linux-arm64.tar.gz"
EXPECT_TGZ=6bb9cfe435be3745c079cde6c1fd14d6515a84de2b285993d1d3e2be2c4fa36a
EXPECT_BIN=1748965fbc6f6888e03088917d027b74d511ad46910bfaa925e0dddbd7200c8e
mkdir -p "$DL" "$OUT"
if [[ ! -f "$TGZ_SRC" ]]; then
  curl -fsSL -L -o "$TGZ_SRC" "$URL"
fi
echo "$EXPECT_TGZ  $TGZ_SRC" | sha256sum -c -
EXTRACT=$(mktemp -d)
STAGE=$(mktemp -d)
trap 'rm -rf "$EXTRACT" "$STAGE"' EXIT
tar -xzf "$TGZ_SRC" -C "$EXTRACT"
BIN_SRC=$(find "$EXTRACT" -type f -name nerdctl | head -1)
test -f "$BIN_SRC"
echo "$EXPECT_BIN  $BIN_SRC" | sha256sum -c -
chmod +x "$BIN_SRC"
mkdir -p "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/bin" "$STAGE/pkg/usr/share/doc/$PKG"
install -m 0755 "$BIN_SRC" "$STAGE/pkg/usr/bin/nerdctl"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOC
Upstream: https://github.com/containerd/nerdctl
License: Apache-2.0 (see upstream)
Repackaged for KEMI Linux arm64 by gork.bot协助开发
EOC
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOR
# kemi-nerdctl
nerdctl $VER_UP — Docker-compatible CLI for containerd.
Upstream linux-arm64 static binary under /usr/bin/nerdctl (single-CLI; rootless helpers not packaged).
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
Description: nerdctl containerd Docker-compatible CLI (arm64 static)
 nerdctl $VER_UP — Docker-compatible CLI for containerd.
 linux-arm64 static. gork.bot协助开发.
EOC
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
