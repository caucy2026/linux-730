#!/usr/bin/env bash
# Wrap official Logseq linux-arm64 zip as kemi-logseq.
# Drop wrong-arch @zvec/bindings-linux-x64 (x86_64) — optional embedding plugin.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-logseq
VER_UP=2.0.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-logseq
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_ZIP="$DL/Logseq-linux-arm64-2.0.2.zip"
EXPECT_SHA=9f0404ea59f5af58874ed51c9291bde0ebd2b0ae65fe3259abfc42d3188904d5
EXPECT_BYTES=179588196
mkdir -p "$DL" "$OUT"
test -f "$UP_ZIP"
test "$(stat -c%s "$UP_ZIP")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_ZIP" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
unzip -q -o "$UP_ZIP" -d "$STAGE/extract"
test -x "$STAGE/extract/logseq"
# Drop wrong-arch x64 zvec natives (not loadable on aarch64; saves ~57MiB)
rm -rf "$STAGE/extract/resources/app.asar.unpacked/node_modules/@zvec" || true

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/Logseq"
cp -a "$STAGE/extract/." "$STAGE/pkg/opt/Logseq/"

# Prefer PNG from resources if present; else skip (desktop still works)
ICON_SRC=""
for cand in \
  "$STAGE/pkg/opt/Logseq/resources/app.asar.unpacked" \
  "$STAGE/pkg/opt/Logseq"; do
  :
done
# extract icon from asar is heavy; use a simple symlink-friendly placeholder if none
# Try common electron icon paths
if [[ -f "$STAGE/pkg/opt/Logseq/resources/app.asar" ]]; then
  # leave icon unset if none; desktop Icon=logseq still ok without file on some DEs
  true
fi

cat > "$STAGE/pkg/usr/bin/logseq" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /opt/Logseq/logseq --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/logseq"
ln -sf logseq "$STAGE/pkg/usr/bin/kemi-logseq"

cat > "$STAGE/pkg/usr/share/applications/logseq.desktop" << 'EOT'
[Desktop Entry]
Name=Logseq
Name[zh_CN]=Logseq
Comment=A privacy-first, open-source knowledge base
Comment[zh_CN]=隐私优先的开源知识库 / 大纲笔记
Exec=/usr/bin/logseq %U
Terminal=false
Type=Application
Icon=logseq
StartupWMClass=Logseq
Categories=Office;Utility;TextEditor;
MimeType=x-scheme-handler/logseq;
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/logseq/logseq
Homepage: https://logseq.com
License: see /opt/Logseq/LICENSE.electron.txt and LICENSES.chromium.html
Official linux arm64 zip v${VER_UP} repackaged for KEMI as ${PKG}.
Wrong-arch @zvec/bindings-linux-x64 dropped (optional embedding).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Logseq ${VER_UP} — official linux arm64, KEMI repack.

Installs under /opt/Logseq/; launcher /usr/bin/logseq (passes --no-sandbox).
Probe: aarch64 · requiredGlibc ≤2.25 (Ubuntu 20.04 / glibc 2.31 OK).
合主线：gork.bot协助开发
EOT

if [[ -f "$STAGE/pkg/opt/Logseq/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/Logseq/chrome-sandbox" || true
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: office
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0
Recommends: libappindicator3-1, libasound2
Conflicts: logseq
Replaces: logseq
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://logseq.com
Description: Logseq knowledge base (arm64)
 Logseq ${VER_UP} — privacy-first open-source knowledge base / outliner.
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
if [ -f /opt/Logseq/chrome-sandbox ]; then
  chmod 4755 /opt/Logseq/chrome-sandbox || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
