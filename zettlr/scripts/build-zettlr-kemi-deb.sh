#!/usr/bin/env bash
# Wrap official Zettlr linux-arm64 deb as kemi-zettlr.
# Probe: aarch64 · requiredGlibc ≤2.25 · PASS vs 101 ≤2.31
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-zettlr
VER_UP=4.9.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-zettlr
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/Zettlr-4.9.0-arm64.deb"
EXPECT_SHA=809187ace4f0709f691b238ed9b1a97982ce6d4a330b5add22b111643c22e80a
EXPECT_BYTES=122299332
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
dpkg-deb -x "$UP_DEB" "$STAGE/extract"
test -x "$STAGE/extract/usr/lib/zettlr/Zettlr"

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/lib/zettlr"

cp -a "$STAGE/extract/usr/lib/zettlr/." "$STAGE/pkg/usr/lib/zettlr/"

# desktop + icon
if [[ -f "$STAGE/extract/usr/share/applications/zettlr.desktop" ]]; then
  cp -a "$STAGE/extract/usr/share/applications/zettlr.desktop" \
    "$STAGE/pkg/usr/share/applications/zettlr.desktop"
fi
if [[ -f "$STAGE/extract/usr/share/pixmaps/zettlr.png" ]]; then
  cp -a "$STAGE/extract/usr/share/pixmaps/zettlr.png" \
    "$STAGE/pkg/usr/share/pixmaps/zettlr.png"
elif [[ -f "$STAGE/extract/usr/share/icons/hicolor/256x256/apps/zettlr.png" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps"
  cp -a "$STAGE/extract/usr/share/icons/hicolor/256x256/apps/zettlr.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/zettlr.png"
fi
# copy any other pixmaps/icons if present
if [[ -d "$STAGE/extract/usr/share/icons" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/icons"
  cp -a "$STAGE/extract/usr/share/icons/." "$STAGE/pkg/usr/share/icons/" || true
fi

# Patch desktop Exec to wrapper
if [[ -f "$STAGE/pkg/usr/share/applications/zettlr.desktop" ]]; then
  sed -i 's|^Exec=.*|Exec=/usr/bin/zettlr %U|' "$STAGE/pkg/usr/share/applications/zettlr.desktop" || true
fi

cat > "$STAGE/pkg/usr/bin/zettlr" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /usr/lib/zettlr/Zettlr --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/zettlr"
ln -sf zettlr "$STAGE/pkg/usr/bin/kemi-zettlr"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/Zettlr/Zettlr
Homepage: https://www.zettlr.com
License: see /usr/lib/zettlr/LICENSE.electron.txt and LICENSES.chromium.html
Official linux arm64 deb v${VER_UP} repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Zettlr ${VER_UP} — official linux arm64, KEMI repack.

Installs under /usr/lib/zettlr/; launcher /usr/bin/zettlr (passes --no-sandbox).
Probe: aarch64 · requiredGlibc ≤2.25 (Ubuntu 20.04 / glibc 2.31 OK).
合主线：gork.bot协助开发
EOT

if [[ -f "$STAGE/pkg/usr/lib/zettlr/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/usr/lib/zettlr/chrome-sandbox" || true
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: editors
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2, libgbm1, libdrm2
Recommends: libappindicator3-1
Conflicts: zettlr
Replaces: zettlr
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.zettlr.com
Description: Zettlr markdown publication workbench (arm64)
 Zettlr ${VER_UP} — one-stop publication workbench / markdown editor.
 Official upstream arm64; glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
if [ -f /usr/lib/zettlr/chrome-sandbox ]; then
  chmod 4755 /usr/lib/zettlr/chrome-sandbox || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
