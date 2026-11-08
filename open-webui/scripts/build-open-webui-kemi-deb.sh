#!/usr/bin/env bash
# Wrap official Open WebUI Desktop arm64.deb as kemi-open-webui.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108
VER_UP=0.1.4
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-open-webui
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/open-webui_arm64.deb"
EXPECT_SHA=efb0328b6cdf0b65b5bc792f752354a6dd88a30e4a0177187e9a77df94e684a5
EXPECT_BYTES=109787944
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root"
dpkg-deb -x "$UP_DEB" "$STAGE/root"
test -x "$STAGE/root/opt/Open WebUI/open-webui"
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt"
cp -a "$STAGE/root/opt/Open WebUI" "$STAGE/pkg/opt/"
if [[ -f "$STAGE/root/usr/share/icons/hicolor/512x512/apps/open-webui.png" ]]; then
  install -m 0644 "$STAGE/root/usr/share/icons/hicolor/512x512/apps/open-webui.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps/open-webui.png"
fi
cat > "$STAGE/pkg/usr/bin/open-webui" << 'EOT'
#!/bin/sh
exec "/opt/Open WebUI/open-webui" "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/open-webui"
ln -sf open-webui "$STAGE/pkg/usr/bin/kemi-open-webui"
cat > "$STAGE/pkg/usr/share/applications/open-webui.desktop" << 'EOT'
[Desktop Entry]
Name=Open WebUI
Comment=Open WebUI Desktop — local AI chat UI
Exec="/opt/Open WebUI/open-webui" %U
Terminal=false
Type=Application
Icon=open-webui
Categories=Network;Office;
StartupWMClass=Open WebUI
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/open-webui/desktop
License: AGPL-3.0 (see upstream)
Official arm64 .deb v${VER_UP} repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Open WebUI Desktop ${VER_UP} (official linux arm64).
Installs under /opt/Open WebUI/; launcher /usr/bin/open-webui.
User supplies model backends (Ollama / OpenAI-compatible / llama.cpp).
合主线：gork.bot协助开发
EOT
if [[ -f "$STAGE/pkg/opt/Open WebUI/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/Open WebUI/chrome-sandbox" || true
fi
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0
Recommends: libappindicator3-1
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://openwebui.com
Description: Open WebUI Desktop (arm64)
 Open WebUI Desktop ${VER_UP} — native AI chat UI for local/remote models.
 Official upstream arm64 build; glibc<=2.25 symbols (fits Ubuntu 20.04/2.31).
 AGPL-3.0. gork.bot协助开发.
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
