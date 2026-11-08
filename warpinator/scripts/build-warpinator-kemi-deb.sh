#!/usr/bin/env bash
# Wrap Wasta/Linux Mint Warpinator 1.8.8 arm64 (focal) + xapp runtime as kemi-warpinator.
# gork.bot协助开发 · Verify ≠ compile · fills LocalSend LAN-share niche
set -euo pipefail
ROOT=/workspace/t140-20261108-next
VER_UP=1.8.8
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-warpinator
DL="$ROOT/src"
XAPP="$ROOT/src/xapp"
OUT="$ROOT/debs"
UP_DEB="$DL/warpinator_1.8.8_arm64.deb"
EXPECT_SHA=aedefb0dd7ae4e0f9f97f15fb06b63283c1150286f13ec61c6f43151adae53a8
EXPECT_BYTES=3925588
mkdir -p "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root" "$STAGE/pkg"

# Upstream warpinator
dpkg-deb -x "$UP_DEB" "$STAGE/root"
test -x "$STAGE/root/usr/bin/warpinator"
test -f "$STAGE/root/usr/libexec/warpinator/warpinator-launch.py"

# Bundle xapp runtime (not on stock Ubuntu 20.04)
for d in \
  "$XAPP/libxapp1_2.6.1_arm64.deb" \
  "$XAPP/gir1.2-xapp-1.0_2.6.1_arm64.deb" \
  "$XAPP/python3-xapp_3.0.3_all.deb" \
  "$XAPP/xapps-common_2.6.1_all.deb"
do
  test -f "$d"
  dpkg-deb -x "$d" "$STAGE/root"
done
test -e "$STAGE/root/usr/lib/aarch64-linux-gnu/libxapp.so.1"
test -f "$STAGE/root/usr/lib/aarch64-linux-gnu/girepository-1.0/XApp-1.0.typelib"

# Assemble package tree (copy selected trees)
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/libexec" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu" \
  "$STAGE/pkg/usr/lib/python3/dist-packages" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/etc/xdg/autostart" \
  "$STAGE/pkg/etc/X11/Xsession.d"

cp -a "$STAGE/root/usr/bin/warpinator" "$STAGE/pkg/usr/bin/warpinator"
cp -a "$STAGE/root/usr/bin/warpinator-send" "$STAGE/pkg/usr/bin/warpinator-send"
ln -sf warpinator "$STAGE/pkg/usr/bin/kemi-warpinator"
cp -a "$STAGE/root/usr/libexec/warpinator" "$STAGE/pkg/usr/libexec/"

# xapp runtime pieces Warpinator needs
cp -a "$STAGE/root/usr/lib/aarch64-linux-gnu/libxapp.so"* "$STAGE/pkg/usr/lib/aarch64-linux-gnu/"
mkdir -p "$STAGE/pkg/usr/lib/aarch64-linux-gnu/girepository-1.0" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/gtk-3.0/modules" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xapps" \
  "$STAGE/pkg/usr/libexec/xapps"
cp -a "$STAGE/root/usr/lib/aarch64-linux-gnu/girepository-1.0/XApp-1.0.typelib" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/girepository-1.0/"
cp -a "$STAGE/root/usr/lib/aarch64-linux-gnu/gtk-3.0/modules/libxapp-gtk3-module.so" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/gtk-3.0/modules/" 2>/dev/null || true
# xapp-sn-watcher binary if present
if [[ -x "$STAGE/root/usr/lib/aarch64-linux-gnu/xapps/xapp-sn-watcher" ]]; then
  cp -a "$STAGE/root/usr/lib/aarch64-linux-gnu/xapps/xapp-sn-watcher" "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xapps/"
elif [[ -x "$STAGE/root/usr/libexec/xapps/xapp-sn-watcher" ]]; then
  cp -a "$STAGE/root/usr/libexec/xapps/xapp-sn-watcher" "$STAGE/pkg/usr/libexec/xapps/"
else
  find "$STAGE/root" -name 'xapp-sn-watcher' -executable -print
  # copy wherever it is
  SN=$(find "$STAGE/root" -name 'xapp-sn-watcher' -type f | head -1)
  if [[ -n "$SN" ]]; then
    mkdir -p "$STAGE/pkg/$(dirname "${SN#$STAGE/root/}")"
    cp -a "$SN" "$STAGE/pkg/${SN#$STAGE/root/}"
  fi
fi

# python3-xapp
cp -a "$STAGE/root/usr/lib/python3/dist-packages/xapp" "$STAGE/pkg/usr/lib/python3/dist-packages/"
mkdir -p "$STAGE/pkg/usr/lib/python3/dist-packages/gi/overrides"
cp -a "$STAGE/root/usr/lib/python3/dist-packages/gi/overrides/XApp.py" \
  "$STAGE/pkg/usr/lib/python3/dist-packages/gi/overrides/"

# schemas / icons / locale / desktop / metainfo / dbus / autostart (best-effort)
[[ -d "$STAGE/root/usr/share/glib-2.0/schemas" ]] && \
  cp -a "$STAGE/root/usr/share/glib-2.0/schemas/." "$STAGE/pkg/usr/share/glib-2.0/schemas/"
[[ -d "$STAGE/root/usr/share/icons" ]] && \
  cp -a "$STAGE/root/usr/share/icons/." "$STAGE/pkg/usr/share/icons/"
[[ -d "$STAGE/root/usr/share/locale" ]] && \
  cp -a "$STAGE/root/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
[[ -d "$STAGE/root/usr/share/applications" ]] && \
  cp -a "$STAGE/root/usr/share/applications/." "$STAGE/pkg/usr/share/applications/"
[[ -d "$STAGE/root/usr/share/metainfo" ]] && \
  cp -a "$STAGE/root/usr/share/metainfo/." "$STAGE/pkg/usr/share/metainfo/"
[[ -d "$STAGE/root/usr/share/dbus-1/services" ]] && \
  cp -a "$STAGE/root/usr/share/dbus-1/services/." "$STAGE/pkg/usr/share/dbus-1/services/" || true
[[ -d "$STAGE/root/etc/xdg/autostart" ]] && \
  cp -a "$STAGE/root/etc/xdg/autostart/." "$STAGE/pkg/etc/xdg/autostart/" || true
[[ -d "$STAGE/root/etc/X11/Xsession.d" ]] && \
  cp -a "$STAGE/root/etc/X11/Xsession.d/." "$STAGE/pkg/etc/X11/Xsession.d/" || true

# Prefer zh name hint
if [[ -f "$STAGE/pkg/usr/share/applications/org.x.Warpinator.desktop" ]]; then
  grep -q 'Name\[zh_CN\]=' "$STAGE/pkg/usr/share/applications/org.x.Warpinator.desktop" || \
    sed -i '/^Name=/a Name[zh_CN]=Warpinator 局域网传文件' \
      "$STAGE/pkg/usr/share/applications/org.x.Warpinator.desktop" || true
fi

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Warpinator ${VER_UP} — LAN file sharing (Linux Mint / Wasta focal arm64) + bundled xapp runtime.

Installs /usr/bin/warpinator (+ /usr/bin/kemi-warpinator symlink).
Bundles libxapp1 / gir1.2-xapp / python3-xapp / xapps-common pieces so stock Ubuntu 20.04 works.
Probe: aarch64 · requiredGlibc ≤2.30 · PASS vs 101 baseline 2.31.
合主线：gork.bot协助开发
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/linuxmint/warpinator
License: GPL-3.0-or-later (see upstream)
xapp: https://github.com/linuxmint/xapp (GPL/LGPL)
Official wasta focal arm64 .deb v${VER_UP} + xapp 2.6.1/python3-xapp 3.0.3 repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: python3 (>= 3.8), python3 (<< 3.9), python3-gi, python3-gi-cairo, gir1.2-glib-2.0, gir1.2-gtk-3.0 (>= 3.20.0), python3-cryptography, python3-nacl, python3-netifaces, python3-netaddr, python3-qrcode, python3-setproctitle, python3-psutil, python3-ifaddr, python3-async-timeout, libgtk-3-0 (>= 3.21.5), libglib2.0-0 (>= 2.57.2), libcairo2, libcairo-gobject2, libgdk-pixbuf2.0-0, libpango-1.0-0, libx11-6, libgnomekbd8 (>= 3.6.0), libdbusmenu-gtk3-4 (>= 0.4.2), libc6 (>= 2.30), libstdc++6 (>= 5.2), dconf-gsettings-backend | gsettings-backend
Recommends: xdg-utils
Conflicts: warpinator, libxapp1, gir1.2-xapp-1.0, python3-xapp, xapps-common
Replaces: warpinator, libxapp1, gir1.2-xapp-1.0, python3-xapp, xapps-common
Provides: warpinator (= ${VER_UP})
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/linuxmint/warpinator
Description: Warpinator LAN file share (arm64)
 Warpinator ${VER_UP} — send/receive files on the local network.
 Wasta Ubuntu 20.04 arm64 build + bundled xapp runtime for stock focal.
 Fills LocalSend niche (LocalSend SKIP glibc 2.34). gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
