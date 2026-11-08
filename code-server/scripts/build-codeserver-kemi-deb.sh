#!/usr/bin/env bash
# Wrap official code-server linux-arm64 tarball as kemi-code-server.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-codeserver
VER_UP=4.145.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-code-server
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_TGZ="$DL/code-server-${VER_UP}-linux-arm64.tar.gz"
EXPECT_SHA=e867a34416e2da4a83496b09580001893e7a4e5bb58a0624c4fcd22819e7d53d
EXPECT_BYTES=233639045
mkdir -p "$DL" "$OUT"
test -f "$UP_TGZ"
test "$(stat -c%s "$UP_TGZ")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_TGZ" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
tar -xzf "$UP_TGZ" -C "$STAGE/extract"
SRC="$STAGE/extract/code-server-${VER_UP}-linux-arm64"
test -x "$SRC/bin/code-server"
test -x "$SRC/lib/node"

# Drop cross-arch / unused natives to shrink (keep linux-arm64 only)
find "$SRC" -type d \( \
  -name 'linux-x64' -o -name 'linux-ia32' -o -name 'linux-arm' \
  -o -name 'darwin-*' -o -name 'win32-*' -o -name 'android-*' \
\) -prune -exec rm -rf {} + 2>/dev/null || true
find "$SRC" -type f \( \
  -name '*.linux-x64*' -o -name '*.darwin-*' -o -name '*.win32-*' \
  -o -name 'win32-app-container-tokens*.node' \
\) -delete 2>/dev/null || true

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps"

# Official-ish layout: /usr/lib/code-server
cp -a "$SRC" "$STAGE/pkg/usr/lib/code-server"

# Launcher (absolute path so symlinks work)
cat > "$STAGE/pkg/usr/bin/code-server" << 'EOT'
#!/bin/sh
set -eu
ROOT=/usr/lib/code-server
exec "$ROOT/lib/node" "$ROOT" "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/code-server"
ln -sf code-server "$STAGE/pkg/usr/bin/kemi-code-server"

# Prefer bundled SVG icon if present
ICON_SRC=$(find "$STAGE/pkg/usr/lib/code-server" -path '*/media/code-icon.svg' 2>/dev/null | head -1 || true)
if [[ -n "${ICON_SRC:-}" && -f "$ICON_SRC" ]]; then
  cp -a "$ICON_SRC" "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/code-server.svg"
fi

cat > "$STAGE/pkg/usr/share/applications/code-server.desktop" << 'EOT'
[Desktop Entry]
Name=code-server
Comment=VS Code in the browser
Exec=/usr/bin/code-server %U
Terminal=true
Type=Application
Icon=code-server
Categories=Development;IDE;
StartupWMClass=code-server
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/coder/code-server
License: MIT (see upstream LICENSE) + VS Code product notices in ThirdPartyNotices.txt
Official linux arm64 tarball v${VER_UP} repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
code-server ${VER_UP} (official linux arm64, KEMI repack).

Installs under /usr/lib/code-server/; launcher /usr/bin/code-server.
Cross-arch natives (linux-x64 / win32 / darwin) stripped.

Usage: code-server --bind-addr 127.0.0.1:8080
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
Depends: libc6 (>= 2.28)
Conflicts: code-server
Replaces: code-server
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/coder/code-server
Description: code-server (arm64)
 VS Code in the browser — code-server ${VER_UP}.
 Official upstream linux arm64 tarball; glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
