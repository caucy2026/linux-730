#!/usr/bin/env bash
# Wrap official SiYuan linux-arm64.deb as kemi-siyuan.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-siyuan
VER_UP=3.8.9
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-siyuan
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/siyuan-3.8.9-linux-arm64.deb"
EXPECT_SHA=d3a2db8fa0fb6c593a7fb6bc6d03beb2d27c6e3aeac998fa67197c50d8ba4832
EXPECT_BYTES=215601004
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root"
dpkg-deb -x "$UP_DEB" "$STAGE/root"
test -x "$STAGE/root/opt/SiYuan/siyuan"
test -x "$STAGE/root/opt/SiYuan/resources/kernel/SiYuan-Kernel"

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt"
cp -a "$STAGE/root/opt/SiYuan" "$STAGE/pkg/opt/"
if [[ -d "$STAGE/root/usr/share/icons/hicolor" ]]; then
  cp -a "$STAGE/root/usr/share/icons/hicolor/." "$STAGE/pkg/usr/share/icons/hicolor/"
fi

cat > "$STAGE/pkg/usr/bin/siyuan" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /opt/SiYuan/siyuan --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/siyuan"
ln -sf siyuan "$STAGE/pkg/usr/bin/kemi-siyuan"
# optional kernel CLI symlink helper (docs suggest resources/kernel/SiYuan-Kernel)
ln -sf /opt/SiYuan/resources/kernel/SiYuan-Kernel "$STAGE/pkg/usr/bin/siyuan-kernel" || true

cat > "$STAGE/pkg/usr/share/applications/siyuan.desktop" << 'EOT'
[Desktop Entry]
Name=SiYuan
Name[zh_CN]=思源笔记
Comment=From thought to insight, with agents
Comment[zh_CN]=从思考到洞见，支持智能体
Exec=/usr/bin/siyuan %U
Terminal=false
Type=Application
Icon=siyuan
StartupWMClass=org.b3log.siyuan
Categories=Office;Utility;TextEditor;
MimeType=x-scheme-handler/siyuan;
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/siyuan-note/siyuan
Homepage: https://b3log.org/siyuan
License: see /opt/SiYuan/LICENSE and LICENSE.electron.txt
Official linux arm64 .deb v${VER_UP} repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
SiYuan (思源笔记) ${VER_UP} — official linux arm64, KEMI repack.

Installs under /opt/SiYuan/; launcher /usr/bin/siyuan (passes --no-sandbox).
Kernel binary: /opt/SiYuan/resources/kernel/SiYuan-Kernel (also /usr/bin/siyuan-kernel).

Probe: aarch64 · requiredGlibc ≤2.27 (Ubuntu 20.04 / glibc 2.31 OK).
合主线：gork.bot协助开发
EOT

if [[ -f "$STAGE/pkg/opt/SiYuan/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/SiYuan/chrome-sandbox" || true
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
Conflicts: siyuan
Replaces: siyuan
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://b3log.org/siyuan
Description: SiYuan / 思源笔记 (arm64)
 SiYuan ${VER_UP} — privacy-first personal knowledge management (Electron + Go kernel).
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
if [ -f /opt/SiYuan/chrome-sandbox ]; then
  chmod 4755 /opt/SiYuan/chrome-sandbox || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
