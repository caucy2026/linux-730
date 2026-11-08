#!/usr/bin/env bash
# Wrap official Syncthing arm64.deb as kemi-syncthing.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-syncthing
VER_UP=2.1.7
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-syncthing
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/syncthing_2.1.7_arm64.deb"
EXPECT_SHA=1ce6836149febb1409ebe2a9876cb8cd5bba917d64029ed75afe72b780c691a9
EXPECT_BYTES=12901050
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root"
dpkg-deb -x "$UP_DEB" "$STAGE/root"
test -x "$STAGE/root/usr/bin/syncthing"

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man" \
  "$STAGE/pkg/usr/lib/systemd/user" \
  "$STAGE/pkg/lib/systemd/system" \
  "$STAGE/pkg/usr/lib/sysctl.d" \
  "$STAGE/pkg/etc/ufw/applications.d"

cp -a "$STAGE/root/usr/bin/syncthing" "$STAGE/pkg/usr/bin/syncthing"
ln -sf syncthing "$STAGE/pkg/usr/bin/kemi-syncthing"

# desktops / icons / man / systemd / sysctl / ufw (best-effort)
if [[ -d "$STAGE/root/usr/share/applications" ]]; then
  cp -a "$STAGE/root/usr/share/applications/." "$STAGE/pkg/usr/share/applications/"
fi
if [[ -d "$STAGE/root/usr/share/icons/hicolor" ]]; then
  cp -a "$STAGE/root/usr/share/icons/hicolor/." "$STAGE/pkg/usr/share/icons/hicolor/"
fi
if [[ -d "$STAGE/root/usr/share/man" ]]; then
  cp -a "$STAGE/root/usr/share/man/." "$STAGE/pkg/usr/share/man/"
fi
if [[ -d "$STAGE/root/usr/share/doc/syncthing" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
  cp -a "$STAGE/root/usr/share/doc/syncthing/." "$STAGE/pkg/usr/share/doc/$PKG/" || true
fi
if [[ -f "$STAGE/root/usr/lib/systemd/user/syncthing.service" ]]; then
  cp -a "$STAGE/root/usr/lib/systemd/user/syncthing.service" "$STAGE/pkg/usr/lib/systemd/user/"
fi
if [[ -f "$STAGE/root/lib/systemd/system/syncthing@.service" ]]; then
  cp -a "$STAGE/root/lib/systemd/system/syncthing@.service" "$STAGE/pkg/lib/systemd/system/"
fi
if [[ -f "$STAGE/root/usr/lib/sysctl.d/30-syncthing.conf" ]]; then
  cp -a "$STAGE/root/usr/lib/sysctl.d/30-syncthing.conf" "$STAGE/pkg/usr/lib/sysctl.d/"
fi
if [[ -f "$STAGE/root/etc/ufw/applications.d/syncthing" ]]; then
  cp -a "$STAGE/root/etc/ufw/applications.d/syncthing" "$STAGE/pkg/etc/ufw/applications.d/"
fi

# Prefer KEMI launcher name in desktop Exec still calls syncthing binary
sed -i 's/^Name=Start Syncthing$/Name=Start Syncthing\nName[zh_CN]=启动 Syncthing/' \
  "$STAGE/pkg/usr/share/applications/syncthing-start.desktop" 2>/dev/null || true

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Syncthing ${VER_UP} — official linux arm64, KEMI repack.

Installs /usr/bin/syncthing (+ /usr/bin/kemi-syncthing symlink).
Probe: aarch64 · static Go binary · glibc version-needs none (Ubuntu 20.04 OK).
合主线：gork.bot协助开发
EOT

cat >> "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT || true
Upstream: https://github.com/syncthing/syncthing
Homepage: https://syncthing.net/
License: MPL-2.0 (see LICENSE.txt in this doc dir)
Official linux arm64 .deb v${VER_UP} repackaged for KEMI as ${PKG}.
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
Depends: libc6, procps
Conflicts: syncthing
Replaces: syncthing
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://syncthing.net/
Description: Syncthing continuous file sync (arm64)
 Syncthing ${VER_UP} — open-source continuous file synchronization.
 Official upstream arm64; static binary OK on glibc 2.31 (Ubuntu 20.04).
 Fallthrough after LocalSend SKIP (glibc 2.34) / Joplin no linux arm64.
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
if command -v deb-systemd-invoke >/dev/null 2>&1; then
  systemctl daemon-reload 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
