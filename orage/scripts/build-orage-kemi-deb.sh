#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) orage 4.12.1-7 arm64 + orage-data all
# as kemi-orage (data bundled).
# Probe: aarch64 · requiredGlibc 2.17 (4 ELF: orage, globaltime, tz_convert,
#   liborageclock.so) · no GLIBCXX ·
#   orage: GTK2 + GDK2 + Pango + X11 + libical/libicalss + libnotify + GdkPixbuf +
#          GObject/GLib + pthread + libc ·
#   globaltime: GTK2 + GDK2 + Pango + GObject/GLib + X11 + pthread + libc ·
#   tz_convert: libpopt + libc ·
#   plugin: libxfce4panel-1.0 + GTK2 + GDK2 + Pango + GObject + libxfce4util +
#           GLib + X11 + pthread + libc ·
#   PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 library set (libc6 >= 2.17,
#   libgdk-pixbuf2.0-0 >= 2.22.0, libglib2.0-0 >= 2.35.9, libgtk2.0-0 >= 2.16.0,
#   libical3 >= 3.0.0, libnotify4 >= 0.7.0, libpango-1.0-0 >= 1.14.0,
#   libpopt0 >= 1.14, libx11-6, libxfce4util7 >= 4.9.0).
# orage-data (= 4.12.1-7) is bundled (official arch:all, no runtime Depends).
# Official also Depends on xfce4-panel (>= 4.13) (<< 4.15). The calendar
# binaries do not link the panel; only liborageclock.so needs
# libxfce4panel-1.0.so.4 (GTK2), which is not published in focal arm64
# (Launchpad getPublishedBinaries total=0; package page 404). The plugin is
# still shipped on the standard XFCE path; xfce4-panel is Recommends only so
# a non-XFCE 101 image can install the standalone calendar.
# Launchpad: orage 4.12.1-7 in focal arm64, universe/Release, Published
#   2019-12-02 18:28:13 Asia/Shanghai (binarypub 134550228).
# arm64 binary was built in ubuntu focal PROPOSED (build 18188688) and
# copied to focal Release (HTML: Copied from ubuntu focal-proposed arm64).
# orage-data was built in ubuntu focal PROPOSED amd64 (build 18188687,
# arch:all) and published to focal arm64 Release (binarypub 134550222).
# Official desktops: xfcalendar.desktop Exec=orage %F Icon=xfcalendar;
#   globaltime.desktop Exec=globaltime Icon=orage_globaltime;
#   xfce-xfcalendar-settings.desktop Exec=orage -p Icon=xfcalendar
#   (hicolor icons shipped in orage-data).
# Sounds / HTML help stay at compiled /usr/share/orage paths.
# Locales / icons / desktop / man stay on standard /usr/share paths.
# Official orage-data does not ship /usr/share/orage/zoneinfo (globaltime
# may look for tz_convert.par there); system /usr/share/zoneinfo is used.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-orage
VER_UP=4.12.1
VER_DEB="${VER_UP}-7kemi1"
ARCH=arm64
PKG=kemi-orage
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/orage-4.12.1-7-focal-unpack}"
UP_DEB="$DL/orage_4.12.1-7_arm64.deb"
DATA_DEB="$DL/orage-data_4.12.1-7_all.deb"
EXPECT_SHA=9199c28d6d08d86fd812ded4679fddfa0f9a12652c59aa172f7b6f1ab100de1b
EXPECT_BYTES=166748
DATA_SHA=db322265d7b2e5d7b10a750e7c4e3d2bb45018224d9f0d3695cfd907cf2ae28f
DATA_BYTES=1320344
PLUGIN_SO="usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/liborageclock.so"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$DATA_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$DATA_DEB")" = "$DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/orage"
test -x "$UNPACK/usr/bin/globaltime"
test -x "$UNPACK/usr/bin/tz_convert"
test -f "$UNPACK/$PLUGIN_SO"
test -f "$UNPACK/usr/share/applications/xfcalendar.desktop"
test -f "$UNPACK/usr/share/applications/globaltime.desktop"
test -f "$UNPACK/usr/share/applications/xfce-xfcalendar-settings.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/xfcalendar.svg"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/xfcalendar.png"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/orage_globaltime.svg"
test -f "$UNPACK/usr/share/orage/sounds/Spo.wav"
test -f "$UNPACK/usr/share/orage/doc/C/orage.html"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/orage.mo"
test -f "$UNPACK/usr/share/man/man1/orage.1.gz"
test -f "$UNPACK/usr/share/xfce4/panel/plugins/xfce4-orageclock-plugin.desktop"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins" \
  "$STAGE/pkg/opt/orage"

# Hardlink binaries so packing does not double disk use.
for b in orage globaltime tz_convert; do
  cp -al "$UNPACK/usr/bin/$b" "$STAGE/pkg/opt/orage/$b"
  chmod 0755 "$STAGE/pkg/opt/orage/$b"
  test -x "$STAGE/pkg/opt/orage/$b"
done

# Panel plugin stays on the standard XFCE search path (GTK2 plugin; lib
# libxfce4panel-1.0 is not in focal — shipped for completeness).
cp -al "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO" 2>/dev/null \
  || cp -a --remove-destination "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO"
chmod 0644 "$STAGE/pkg/$PLUGIN_SO"

# Probe all four staged ELFs before packing.
REPORT="$ROOT/probe/kemi-orage.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/opt/orage/orage" \
  --elf "$STAGE/pkg/opt/orage/globaltime" \
  --elf "$STAGE/pkg/opt/orage/tz_convert" \
  --elf "$STAGE/pkg/$PLUGIN_SO" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files=r.get("files") or []
if len(files) != 4:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
for f in files:
    if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_UNEXPECTED")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
by= {Path(f["path"]).name: set(f.get("neededLibraries") or []) for f in files}
for lib in ("libgtk-x11-2.0.so.0", "libgdk-x11-2.0.so.0", "libical.so.3",
            "libicalss.so.3", "libnotify.so.4", "libgdk_pixbuf-2.0.so.0",
            "libc.so.6"):
    if lib not in by["orage"]:
        raise SystemExit(f"PROBE_MISSING_ORAGE_{lib}")
for lib in ("libgtk-x11-2.0.so.0", "libX11.so.6", "libc.so.6"):
    if lib not in by["globaltime"]:
        raise SystemExit(f"PROBE_MISSING_GLOBALTIME_{lib}")
for lib in ("libpopt.so.0", "libc.so.6"):
    if lib not in by["tz_convert"]:
        raise SystemExit(f"PROBE_MISSING_TZ_{lib}")
for lib in ("libxfce4panel-1.0.so.4", "libgtk-x11-2.0.so.0", "libxfce4util.so.7"):
    if lib not in by["liborageclock.so"]:
        raise SystemExit(f"PROBE_MISSING_PLUGIN_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=4")
PY

# Locales, icons, help, sounds — keep standard /usr/share paths
# (compiled-in /usr/share/orage and /usr/share/locale).
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'orage.mo';
         find "$UNPACK/usr/share/icons/hicolor" -type f;
         find "$UNPACK/usr/share/orage" -type f)

cp -a --remove-destination "$UNPACK/usr/share/man/man1/orage.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/orage.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/globaltime.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/globaltime.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/tz_convert.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/tz_convert.1.gz"

cp -a --remove-destination \
  "$UNPACK/usr/share/xfce4/panel/plugins/xfce4-orageclock-plugin.desktop" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins/xfce4-orageclock-plugin.desktop"

# Upstream docs (from both official debs)
if [[ -f "$UNPACK/usr/share/doc/orage/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/orage/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/orage/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/orage/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/orage-data/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/orage-data/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream-data"
fi

# Desktop: keep upstream fields; point Exec at the KEMI launcher path.
# Official Icon=xfcalendar / orage_globaltime (hicolor shipped in orage-data).
sed -e 's|^Exec=orage %F$|Exec=/usr/bin/orage %F|' \
  "$UNPACK/usr/share/applications/xfcalendar.desktop" \
  > "$STAGE/pkg/usr/share/applications/xfcalendar.desktop"
grep -q '^Exec=/usr/bin/orage %F$' "$STAGE/pkg/usr/share/applications/xfcalendar.desktop"
grep -q '^Icon=xfcalendar' "$STAGE/pkg/usr/share/applications/xfcalendar.desktop"

sed -e 's|^Exec=globaltime$|Exec=/usr/bin/globaltime|' \
  "$UNPACK/usr/share/applications/globaltime.desktop" \
  > "$STAGE/pkg/usr/share/applications/globaltime.desktop"
grep -q '^Exec=/usr/bin/globaltime$' "$STAGE/pkg/usr/share/applications/globaltime.desktop"
grep -q '^Icon=orage_globaltime' "$STAGE/pkg/usr/share/applications/globaltime.desktop"

sed -e 's|^Exec=orage -p$|Exec=/usr/bin/orage -p|' \
  "$UNPACK/usr/share/applications/xfce-xfcalendar-settings.desktop" \
  > "$STAGE/pkg/usr/share/applications/xfce-xfcalendar-settings.desktop"
grep -q '^Exec=/usr/bin/orage -p$' "$STAGE/pkg/usr/share/applications/xfce-xfcalendar-settings.desktop"
grep -q '^Icon=xfcalendar' "$STAGE/pkg/usr/share/applications/xfce-xfcalendar-settings.desktop"

ln -sf /opt/orage/orage "$STAGE/pkg/usr/bin/orage"
ln -sf /opt/orage/globaltime "$STAGE/pkg/usr/bin/globaltime"
ln -sf /opt/orage/tz_convert "$STAGE/pkg/usr/bin/tz_convert"
ln -sf orage "$STAGE/pkg/usr/bin/kemi-orage"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.xfce.org/
Source: https://launchpad.net/ubuntu/+source/orage
Homepage: https://www.xfce.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (orage_4.12.1-7_arm64.deb)
plus official arch:all orage-data_4.12.1-7_all.deb, repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 orage_4.12.1-7_arm64.deb and
    orage-data_4.12.1-7_all.deb repackaged for KEMI as ${PKG}.
  * Layout /opt/orage + /usr/bin/orage, /usr/bin/globaltime,
    /usr/bin/tz_convert; locales, desktop, man, hicolor icons,
    HTML help and alarm sounds stay on standard /usr/share and
    /usr/share/orage paths. Official desktop Icon=xfcalendar /
    orage_globaltime (hicolor shipped in orage-data).
  * Panel plugin liborageclock.so stays on the standard XFCE path.
    Official Depends on xfce4-panel dropped to Recommends: the
    plugin needs libxfce4panel-1.0 (not in focal); the calendar
    binaries do not link the panel.
  * orage-data is bundled; Conflicts/Replaces orage and orage-data.
  * Depends kept for Ubuntu 20.04 (GTK2, GdkPixbuf, GLib, libical3,
    libnotify, Pango, libpopt, libX11, libxfce4util, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Orage ${VER_UP} — official Ubuntu 20.04 (focal) arm64 + orage-data, KEMI repack.

Installs under /opt/orage/; launchers /usr/bin/orage, /usr/bin/globaltime,
/usr/bin/tz_convert (symlinks into /opt/orage). Locales, desktop, man,
hicolor icons, HTML help and alarm sounds remain on standard /usr/share
and /usr/share/orage paths.
Official desktop Icon=xfcalendar / orage_globaltime (hicolor shipped in orage-data).
Panel plugin is shipped on the standard XFCE path; it links
libxfce4panel-1.0.so.4 which is not published in Ubuntu 20.04 focal.
The standalone calendar does not need xfce4-panel.
Probe: aarch64 · requiredGlibc 2.17 (4 ELF) · no GLIBCXX · GTK2 + libical +
libnotify + GdkPixbuf + Pango + X11 + (plugin) libxfce4panel-1.0 +
libxfce4util; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libgdk-pixbuf2.0-0 (>= 2.22.0), libc6 (>= 2.17), libglib2.0-0 (>= 2.35.9),
libgtk2.0-0 (>= 2.16.0), libical3 (>= 3.0.0), libnotify4 (>= 0.7.0),
libpango-1.0-0 (>= 1.14.0), libpopt0 (>= 1.14), libx11-6, libxfce4util7 (>= 4.9.0).
Official Launchpad publication: orage 4.12.1-7 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu focal PROPOSED (build 18188688) and copied
to focal Release. orage-data is arch:all from amd64 build 18188687.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: xfce
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.9), libgtk2.0-0 (>= 2.16.0), libical3 (>= 3.0.0), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.14.0), libpopt0 (>= 1.14), libx11-6, libxfce4util7 (>= 4.9.0)
Recommends: default-dbus-session-bus | dbus-session-bus, xfce4-panel (>= 4.13)
Suggests: sox
Conflicts: orage, orage-data
Replaces: orage, orage-data
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.xfce.org/
Description: Calendar for Xfce Desktop Environment (arm64)
 Orage ${VER_UP} — official Ubuntu 20.04 arm64 + data, KEMI repack.
 Lightweight GTK2 desktop calendar with iCal storage and reminders.
 glibc≤2.31 (Ubuntu 20.04).
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
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
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-orage-control.txt"
