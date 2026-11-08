#!/usr/bin/env bash
# Wrap official MarkText linux-arm64 deb as kemi-marktext.
# Drop native-keymap .node (GLIBC_2.34) — upstream index.js already try/catch → empty keymap.
# Drop darwin fontlist (wrong OS). gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-marktext
VER_UP=0.23.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-marktext
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/marktext-linux-arm64-0.23.0.deb"
EXPECT_SHA=7918e3843f9eb3a15e51abcb79340d3b31c3aad65e322a37997ca5dba52d15a1
EXPECT_BYTES=121073212
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
dpkg-deb -x "$UP_DEB" "$STAGE/extract"
test -x "$STAGE/extract/opt/MarkText/marktext"

# Drop GLIBC_2.34 natives (keyboard-layout only; graceful degrade)
rm -f \
  "$STAGE/extract/opt/MarkText/resources/app.asar.unpacked/node_modules/native-keymap/build/Release/keymapping.node" \
  "$STAGE/extract/opt/MarkText/resources/app.asar.unpacked/node_modules/native-keymap/bin/linux-arm64-146/native-keymap.node" \
  || true
# Drop wrong-OS helper
rm -rf "$STAGE/extract/opt/MarkText/resources/app.asar.unpacked/node_modules/font-list/libs/darwin" || true

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/mime/packages" \
  "$STAGE/pkg/opt/MarkText"

cp -a "$STAGE/extract/opt/MarkText/." "$STAGE/pkg/opt/MarkText/"
# reuse upstream desktop/icon/mime if present
if [[ -f "$STAGE/extract/usr/share/applications/marktext.desktop" ]]; then
  cp -a "$STAGE/extract/usr/share/applications/marktext.desktop" "$STAGE/pkg/usr/share/applications/marktext.desktop"
fi
if [[ -f "$STAGE/extract/usr/share/icons/hicolor/256x256/apps/marktext.png" ]]; then
  cp -a "$STAGE/extract/usr/share/icons/hicolor/256x256/apps/marktext.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/marktext.png"
fi
if [[ -f "$STAGE/extract/usr/share/mime/packages/marktext.xml" ]]; then
  cp -a "$STAGE/extract/usr/share/mime/packages/marktext.xml" \
    "$STAGE/pkg/usr/share/mime/packages/marktext.xml"
fi

# Patch desktop Exec to wrapper
if [[ -f "$STAGE/pkg/usr/share/applications/marktext.desktop" ]]; then
  sed -i 's|^Exec=.*|Exec=/usr/bin/marktext %U|' "$STAGE/pkg/usr/share/applications/marktext.desktop" || true
fi

cat > "$STAGE/pkg/usr/bin/marktext" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /opt/MarkText/marktext --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/marktext"
ln -sf marktext "$STAGE/pkg/usr/bin/kemi-marktext"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/marktext/marktext
Homepage: https://github.com/marktext/marktext
License: see /opt/MarkText/LICENSE.electron.txt and LICENSES.chromium.html
Official linux arm64 deb v${VER_UP} repackaged for KEMI as ${PKG}.
Dropped native-keymap .node (required GLIBC_2.34; keymap degrades gracefully).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
MarkText ${VER_UP} — official linux arm64, KEMI repack.

Installs under /opt/MarkText/; launcher /usr/bin/marktext (passes --no-sandbox).
Probe: aarch64 · requiredGlibc ≤2.25 after dropping native-keymap (Ubuntu 20.04 / glibc 2.31 OK).
合主线：gork.bot协助开发
EOT

if [[ -f "$STAGE/pkg/opt/MarkText/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/MarkText/chrome-sandbox" || true
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: editors
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2, libgbm1
Recommends: libappindicator3-1
Conflicts: marktext
Replaces: marktext
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/marktext/marktext
Description: MarkText markdown editor (arm64)
 MarkText ${VER_UP} — simple elegant open-source markdown editor.
 Official upstream arm64; glibc≤2.31 (Ubuntu 20.04) after native-keymap drop.
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
if [ -f /opt/MarkText/chrome-sandbox ]; then
  chmod 4755 /opt/MarkText/chrome-sandbox || true
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
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
