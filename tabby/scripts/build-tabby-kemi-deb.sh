#!/usr/bin/env bash
# Wrap official Tabby linux arm64.deb as kemi-tabby.
# Patch node-pty arm64 natives that require GLIBC_2.34 → use prebuilds/linux-arm64 (2.28).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-tabby
VER_UP=1.0.238
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-tabby
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/tabby-1.0.238-linux-arm64.deb"
EXPECT_SHA=a79e381455b8e1d9f4e253aa342323e2eb4d33ea204e7ec2d51dcd9dc7a137d0
EXPECT_BYTES=125550188
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root"
dpkg-deb -x "$UP_DEB" "$STAGE/root"
test -x "$STAGE/root/opt/Tabby/tabby"

# --- glibc≤2.31 patch: replace 2.34 node-pty with prebuild 2.28 ---
NPT="$STAGE/root/opt/Tabby/resources/app.asar.unpacked/node_modules/node-pty"
GOOD="$NPT/prebuilds/linux-arm64/pty.node"
test -f "$GOOD"
install -m 0755 "$GOOD" "$NPT/build/Release/pty.node"
install -m 0755 "$GOOD" "$NPT/bin/linux-arm64-148/node-pty.node"

# Drop non-linux-arm64 native blobs (size + avoid accidental load of wrong ABI)
find "$STAGE/root/opt/Tabby/resources/app.asar.unpacked" -type d \( \
  -name 'darwin-*' -o -name 'win32-*' -o -name 'android-*' \
  -o -name 'linux-x64' -o -name 'linux-arm' -o -name 'linux-armv*' \
  -o -name 'linux-ia32' -o -name 'linux-arm-gnueabihf' \
\) -prune -exec rm -rf {} + 2>/dev/null || true
# russh / fontmanager cross-arch .node files sitting flat
find "$STAGE/root/opt/Tabby/resources/app.asar.unpacked" -type f \( \
  -name '*.darwin-*.node' -o -name '*.win32-*.node' -o -name '*.linux-x64-*.node' \
  -o -name '*.linux-arm-*.node' -o -name 'russh.linux-arm-gnueabihf.node' \
  -o -name 'russh.linux-x64-gnu.node' \
\) -delete 2>/dev/null || true

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt"
cp -a "$STAGE/root/opt/Tabby" "$STAGE/pkg/opt/"
# icons
if [[ -d "$STAGE/root/usr/share/icons/hicolor" ]]; then
  cp -a "$STAGE/root/usr/share/icons/hicolor/." "$STAGE/pkg/usr/share/icons/hicolor/"
fi
cat > "$STAGE/pkg/usr/bin/tabby" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /opt/Tabby/tabby --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/tabby"
ln -sf tabby "$STAGE/pkg/usr/bin/kemi-tabby"
cat > "$STAGE/pkg/usr/share/applications/tabby.desktop" << 'EOT'
[Desktop Entry]
Name=Tabby
Comment=A terminal for a modern age
Exec=/usr/bin/tabby %U
Terminal=false
Type=Application
Icon=tabby
Categories=System;TerminalEmulator;
StartupWMClass=tabby
MimeType=x-scheme-handler/ssh;x-scheme-handler/telnet;x-scheme-handler/tabby;
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/Eugeny/tabby
License: see upstream /opt/Tabby/LICENSE.electron.txt and app license
Official linux arm64 .deb v${VER_UP} repackaged for KEMI as ${PKG}.
node-pty arm64 natives patched to prebuilds/linux-arm64 (GLIBC≤2.28) for Ubuntu 20.04/2.31.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Tabby ${VER_UP} (official linux arm64, KEMI repack).

Installs under /opt/Tabby/; launcher /usr/bin/tabby (passes --no-sandbox).
PTY native uses prebuilds/linux-arm64 (glibc 2.28) instead of Release build (2.34).

合主线：gork.bot协助开发
EOT
if [[ -f "$STAGE/pkg/opt/Tabby/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/Tabby/chrome-sandbox" || true
fi
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2
Recommends: gnome-keyring, libappindicator3-1
Conflicts: tabby-terminal
Replaces: tabby-terminal
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://tabby.sh
Description: Tabby terminal (arm64)
 Tabby ${VER_UP} — modern terminal / SSH / serial client (Electron).
 Official upstream arm64; node-pty patched for glibc≤2.31 (Ubuntu 20.04).
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
# chrome-sandbox setuid if present
if [ -f /opt/Tabby/chrome-sandbox ]; then
  chmod 4755 /opt/Tabby/chrome-sandbox || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
