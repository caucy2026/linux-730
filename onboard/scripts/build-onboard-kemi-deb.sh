#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) onboard 1.4.1-2ubuntu7 arm64
# plus onboard-common all (Depends) and onboard-data all
# (official Recommends; language models) as kemi-onboard
# (common + data bundled).
# Probe: aarch64 · 2 ELF (Python 3.8 extensions) · PASS vs 101 ≤2.31
#   osk.cpython-38-*.so: requiredGlibc 2.17 · no GLIBCXX ·
#     X11 + Xi + Xtst + Cairo + libcanberra + libdconf + GDK3 +
#     GLib/GObject + hunspell + udev + xkbfile + pthread + libc
#   lm.cpython-38-*.so: requiredGlibc 2.29 · GLIBCXX 3.4.21 ·
#     libstdc++ + libm + libgcc_s + pthread + libc
# Official Depends already match Ubuntu 20.04 (python3 >= 3.8~
#   << 3.9, gir1.2-gtk-3.0 / glib / gdkpixbuf / pango, iso-codes,
#   librsvg2-common, python3-cairo, python3-dbus, python3-gi-cairo,
#   dconf-gsettings-backend | gsettings-backend, libc6 >= 2.29,
#   libcairo2 >= 1.10.0, libcanberra0 >= 0.2, libdconf1 >= 0.14.0,
#   libgcc-s1 >= 3.0, libglib2.0-0 >= 2.31.8, libgtk-3-0 >= 3.9.10,
#   libhunspell-1.7-0, libstdc++6 >= 5.2, libudev1 >= 183,
#   libx11-6, libxi6 >= 2:1.2.99.4, libxkbfile1, libxtst6).
# onboard-common (= 1.4.1-2ubuntu7) is bundled (official arch:all,
#   Depends: python3; ships layouts / themes / locales / icons /
#   help / UI and INSTALL_DIR=/usr/share/onboard).
# onboard-data (= 1.4.1-2ubuntu7) is officially Recommends and is
#   bundled so word-suggestion language models
#   (/usr/share/onboard/models, 29 files; no zh_* model) work
#   without a second package. Official other Recommends
#   (gir1.2-appindicator3-0.1, gir1.2-atspi-2.0, xdg-utils) stay
#   as Recommends and are not bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed — not saved as a Packages.gz dump). There is no
#   newer focal-updates binary; this is the current official
#   focal Release arm64 build (no-change rebuild to drop
#   python3.7). No librarian URL is recorded this run.
# Official desktop Icon=onboard (hicolor / HighContrast /
#   ubuntu-mono icons shipped). Exec=onboard and
#   Exec=onboard-settings (no TryExec upstream). Official
#   autostart OnlyShowIn=Unity;MATE. Official D-Bus service
#   already Exec=/usr/bin/onboard.
# Locale path is /usr/share/locale (98 locales including
#   zh_CN / zh_HK / zh_TW, from onboard-common).
# C help is bundled; Python UI (.ui) and layouts/themes stay
#   at compiled /usr/share/onboard. Python modules and the two
#   cpython-38 extension ELFs stay on the standard
#   /usr/lib/python3/dist-packages/Onboard path (do not move
#   them under /opt — imports would break).
# Launchers live under /opt/onboard with /usr/bin symlinks.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-onboard
VER_UP=1.4.1
VER_DEB="${VER_UP}-2ubuntu7kemi1"
ARCH=arm64
PKG=kemi-onboard
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/onboard-1.4.1-2ubuntu7-focal-unpack}"
UP_DEB="$DL/onboard_1.4.1-2ubuntu7_arm64.deb"
COM_DEB="$DL/onboard-common_1.4.1-2ubuntu7_all.deb"
DATA_DEB="$DL/onboard-data_1.4.1-2ubuntu7_all.deb"
EXPECT_SHA=92f8945e2758e74deae7dfcbe796a08e56229d5d080b40edbd59d70f2f10eac4
EXPECT_BYTES=343944
COM_SHA=4572affbcc7c581010917dd12631d67257372dd4a0d194c551abd6780726ae7d
COM_BYTES=529504
DATA_SHA=001d2c3fef408fefc3ae22582372224b58c2ccfd60d38ea03e95a68ee5458ad1
DATA_BYTES=3803292
OSK_SO="usr/lib/python3/dist-packages/Onboard/osk.cpython-38-aarch64-linux-gnu.so"
LM_SO="usr/lib/python3/dist-packages/Onboard/pypredict/lm.cpython-38-aarch64-linux-gnu.so"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB" && test -f "$COM_DEB" && test -f "$DATA_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$COM_DEB")" = "$COM_BYTES"
test "$(stat -c%s "$DATA_DEB")" = "$DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$COM_SHA  $COM_DEB" | sha256sum -c -
echo "$DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/onboard"
test -x "$UNPACK/usr/bin/onboard-settings"
test -f "$UNPACK/$OSK_SO"
test -f "$UNPACK/$LM_SO"
test -f "$UNPACK/usr/share/applications/onboard.desktop"
test -f "$UNPACK/usr/share/applications/onboard-settings.desktop"
test -f "$UNPACK/etc/xdg/autostart/onboard-autostart.desktop"
test -f "$UNPACK/usr/share/man/man1/onboard.1.gz"
test -f "$UNPACK/usr/share/man/man1/onboard-settings.1.gz"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/onboard.svg"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.onboard.gschema.xml"
test -f "$UNPACK/usr/share/dbus-1/services/org.onboard.Onboard.service"
test -f "$UNPACK/usr/share/onboard/layouts/Small.onboard"
test -f "$UNPACK/usr/share/onboard/settings.ui"
test -f "$UNPACK/usr/share/onboard/models/en_US.lm"
test -f "$UNPACK/usr/share/help/C/onboard/index.page"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/onboard.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'onboard.mo' | wc -l)" = 98
test "$(find "$UNPACK/usr/share/onboard/models" -type f | wc -l)" = 29
grep -q '^Exec=/usr/bin/onboard$' "$UNPACK/usr/share/dbus-1/services/org.onboard.Onboard.service"
grep -q 'INSTALL_DIR                = "/usr/share/onboard"' \
  "$UNPACK/usr/lib/python3/dist-packages/Onboard/Config.py"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/etc/xdg/autostart" \
  "$STAGE/pkg/opt/onboard"

# Python extensions stay on the standard dist-packages path.
# Hardlink trees so packing does not double disk use.
mkdir -p "$STAGE/pkg/usr/lib/python3/dist-packages"
cp -al "$UNPACK/usr/lib/python3/dist-packages/Onboard" \
  "$STAGE/pkg/usr/lib/python3/dist-packages/Onboard"
cp -al "$UNPACK/usr/lib/python3/dist-packages/onboard-1.4.1.egg-info" \
  "$STAGE/pkg/usr/lib/python3/dist-packages/onboard-1.4.1.egg-info"
chmod 0755 "$STAGE/pkg/$OSK_SO" "$STAGE/pkg/$LM_SO"

# Launchers under /opt/onboard (Python shebang scripts).
cp -al "$UNPACK/usr/bin/onboard" "$STAGE/pkg/opt/onboard/onboard"
cp -al "$UNPACK/usr/bin/onboard-settings" "$STAGE/pkg/opt/onboard/onboard-settings"
chmod 0755 "$STAGE/pkg/opt/onboard/onboard" "$STAGE/pkg/opt/onboard/onboard-settings"

# Probe the staged ELFs before packing.
REPORT="$ROOT/probe/kemi-onboard.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/$OSK_SO" \
  --elf "$STAGE/pkg/$LM_SO" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 2:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by={}
for f in r["files"]:
    by[Path(f["path"]).name]=f
osk=by.get("osk.cpython-38-aarch64-linux-gnu.so")
lm=by.get("lm.cpython-38-aarch64-linux-gnu.so")
if not osk or not lm:
    raise SystemExit("PROBE_UNEXPECTED_NAMES")
if osk.get("requiredGlibc") != "2.17" or osk.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_OSK")
if osk.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_OSK_GLIBCXX")
if lm.get("requiredGlibc") != "2.29" or lm.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_LM")
if lm.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_UNEXPECTED_LM_GLIBCXX")
needed_osk=set(osk.get("neededLibraries") or [])
for lib in ("libX11.so.6", "libXi.so.6", "libXtst.so.6", "libcairo.so.2",
            "libcanberra.so.0", "libdconf.so.1", "libgdk-3.so.0",
            "libglib-2.0.so.0", "libgobject-2.0.so.0", "libhunspell-1.7.so.0",
            "libudev.so.1", "libxkbfile.so.1", "libc.so.6"):
    if lib not in needed_osk:
        raise SystemExit(f"PROBE_MISSING_OSK_{lib}")
needed_lm=set(lm.get("neededLibraries") or [])
for lib in ("libstdc++.so.6", "libm.so.6", "libgcc_s.so.1", "libc.so.6"):
    if lib not in needed_lm:
        raise SystemExit(f"PROBE_MISSING_LM_{lib}")
print("PROBE_PASS osk glibc=2.17 no-GLIBCXX; lm glibc=2.29 GLIBCXX=3.4.21; arch=aarch64 n_elf=2")
PY

# Share data stays on compiled /usr/share paths.
cp -a "$UNPACK/usr/share/onboard" "$STAGE/pkg/usr/share/onboard"
cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
if [[ -d "$UNPACK/usr/share/sounds" ]]; then
  cp -a "$UNPACK/usr/share/sounds" "$STAGE/pkg/usr/share/sounds"
fi
cp -a --remove-destination "$UNPACK/usr/share/man/man1/onboard.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/onboard.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/onboard-settings.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/onboard-settings.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.onboard.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.onboard.gschema.xml"
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/org.onboard.Onboard.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.onboard.Onboard.service"
test -f "$STAGE/pkg/usr/share/onboard/layouts/Small.onboard"
test -f "$STAGE/pkg/usr/share/onboard/models/en_US.lm"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/onboard.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'onboard.mo' | wc -l)" = 98
test "$(find "$STAGE/pkg/usr/share/onboard/models" -type f | wc -l)" = 29
grep -q '^Exec=/usr/bin/onboard$' "$STAGE/pkg/usr/share/dbus-1/services/org.onboard.Onboard.service"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/onboard/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/onboard/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/onboard/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/onboard/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi

# Desktop + autostart: point Exec/TryExec at the KEMI launcher path.
# Official Icon=onboard. No TryExec upstream.
sed -e 's|^Exec=onboard$|Exec=/usr/bin/onboard|' \
    -e 's|^TryExec=onboard$|TryExec=/usr/bin/onboard|' \
  "$UNPACK/usr/share/applications/onboard.desktop" \
  > "$STAGE/pkg/usr/share/applications/onboard.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/onboard.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/onboard$/a TryExec=/usr/bin/onboard' \
    "$STAGE/pkg/usr/share/applications/onboard.desktop"
fi
sed -e 's|^Exec=onboard-settings$|Exec=/usr/bin/onboard-settings|' \
    -e 's|^TryExec=onboard-settings$|TryExec=/usr/bin/onboard-settings|' \
  "$UNPACK/usr/share/applications/onboard-settings.desktop" \
  > "$STAGE/pkg/usr/share/applications/onboard-settings.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/onboard-settings.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/onboard-settings$/a TryExec=/usr/bin/onboard-settings' \
    "$STAGE/pkg/usr/share/applications/onboard-settings.desktop"
fi
sed -e 's|^Exec=onboard |Exec=/usr/bin/onboard |' \
    -e 's|^Exec=onboard$|Exec=/usr/bin/onboard|' \
  "$UNPACK/etc/xdg/autostart/onboard-autostart.desktop" \
  > "$STAGE/pkg/etc/xdg/autostart/onboard-autostart.desktop"
grep -q '^Exec=/usr/bin/onboard$' "$STAGE/pkg/usr/share/applications/onboard.desktop"
grep -q '^TryExec=/usr/bin/onboard$' "$STAGE/pkg/usr/share/applications/onboard.desktop"
grep -q '^Icon=onboard$' "$STAGE/pkg/usr/share/applications/onboard.desktop"
grep -q '^Exec=/usr/bin/onboard-settings$' "$STAGE/pkg/usr/share/applications/onboard-settings.desktop"
grep -q '^TryExec=/usr/bin/onboard-settings$' "$STAGE/pkg/usr/share/applications/onboard-settings.desktop"
grep -q '^Exec=/usr/bin/onboard --not-show-in=GNOME,GNOME-Classic:GNOME --startup-delay=3.0$' \
  "$STAGE/pkg/etc/xdg/autostart/onboard-autostart.desktop"
if grep -ER '^Exec=onboard( |$)' "$STAGE/pkg/usr/share/applications" "$STAGE/pkg/etc/xdg/autostart"; then
  echo "LEFTOVER_RELATIVE_EXEC" >&2
  exit 1
fi

ln -sf /opt/onboard/onboard "$STAGE/pkg/usr/bin/onboard"
ln -sf /opt/onboard/onboard-settings "$STAGE/pkg/usr/bin/onboard-settings"
ln -sf onboard "$STAGE/pkg/usr/bin/kemi-onboard"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://launchpad.net/onboard
Source: https://launchpad.net/ubuntu/+source/onboard
Homepage: https://launchpad.net/onboard
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(onboard_1.4.1-2ubuntu7_arm64.deb) plus official arch:all
onboard-common_1.4.1-2ubuntu7_all.deb and
onboard-data_1.4.1-2ubuntu7_all.deb
repackaged for KEMI as ${PKG} (common + data bundled).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 onboard_1.4.1-2ubuntu7_arm64.deb
    (focal universe) plus official onboard-common and
    onboard-data of the same version, repackaged for KEMI as
    ${PKG} (common + data bundled).
  * Layout /opt/onboard + /usr/bin/onboard and
    /usr/bin/onboard-settings; Python 3.8 modules and the two
    extension ELFs stay on
    /usr/lib/python3/dist-packages/Onboard. Layouts, themes,
    UI, models, locales, desktop, man, icons, GSettings schema,
    D-Bus service, C help and autostart stay on standard
    /usr/share and /etc/xdg paths. Official desktop
    Icon=onboard. INSTALL_DIR remains /usr/share/onboard.
  * 98 locales including zh_CN / zh_HK / zh_TW are bundled from
    onboard-common. 29 official language models from
    onboard-data are bundled (word suggestion; no zh_* model
    in this official set). Official D-Bus service already
    Exec=/usr/bin/onboard. Official autostart remains
    OnlyShowIn=Unity;MATE.
  * Conflicts/Replaces onboard, onboard-common, onboard-data.
  * Depends kept for Ubuntu 20.04 (Python 3.8, GTK3 + typelibs,
    cairo, hunspell, dconf, libcanberra, X11/Xi/Xtst/xkbfile,
    udev, libstdc++6, libc6 >= 2.29, gsettings backend).
    Recommends: gir1.2-appindicator3-0.1, gir1.2-atspi-2.0,
    xdg-utils. Suggests: mousetweaks (>= 3.3.90).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:50:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Onboard ${VER_UP}-2ubuntu7 — official Ubuntu 20.04 (focal)
arm64, KEMI repack (onboard-common + onboard-data bundled).

Launchers install under /opt/onboard/; /usr/bin/onboard and
/usr/bin/onboard-settings are symlinks into /opt/onboard.
Python 3.8 modules and the two cpython-38 extension ELFs stay
on /usr/lib/python3/dist-packages/Onboard (do not relocate).
Layouts, themes, UI, language models, locales, desktop, man,
icons, GSettings schema, D-Bus service, C help and autostart
remain on standard /usr/share and /etc/xdg paths.
Official desktop Icon=onboard. INSTALL_DIR is compiled as
/usr/share/onboard. 98 locales including zh_CN / zh_HK / zh_TW
are bundled. 29 official language models are bundled for word
suggestion (no zh_* model in this official set).
Probe: aarch64 · 2 ELF · osk requiredGlibc 2.17 (no GLIBCXX) ·
lm requiredGlibc 2.29 + GLIBCXX 3.4.21 · Ubuntu 20.04 /
glibc 2.31 OK. The extensions are built for CPython 3.8
(official python3 >= 3.8~ << 3.9).
Runtime: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gtk-3.0,
gir1.2-pango-1.0 (>= 1.29.3), iso-codes, librsvg2-common,
python3-cairo, python3-dbus, python3-gi-cairo,
dconf-gsettings-backend | gsettings-backend,
python3 (<< 3.9), python3 (>= 3.8~), python3:any,
libc6 (>= 2.29), libcairo2 (>= 1.10.0), libcanberra0 (>= 0.2),
libdconf1 (>= 0.14.0), libgcc-s1 (>= 3.0),
libglib2.0-0 (>= 2.31.8), libgtk-3-0 (>= 3.9.10),
libhunspell-1.7-0, libstdc++6 (>= 5.2), libudev1 (>= 183),
libx11-6, libxi6 (>= 2:1.2.99.4), libxkbfile1, libxtst6.
Recommends: gir1.2-appindicator3-0.1, gir1.2-atspi-2.0,
xdg-utils. Suggests: mousetweaks (>= 3.3.90).
Official publication: Ubuntu 20.04 focal universe arm64
onboard 1.4.1-2ubuntu7 (current official U20 package; no
newer focal-updates binary). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64 Packages
stanzas.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: gnome
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-pango-1.0 (>= 1.29.3), iso-codes, librsvg2-common, python3-cairo, python3-dbus, python3-gi-cairo, dconf-gsettings-backend | gsettings-backend, python3 (<< 3.9), python3 (>= 3.8~), python3:any, libc6 (>= 2.29), libcairo2 (>= 1.10.0), libcanberra0 (>= 0.2), libdconf1 (>= 0.14.0), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.31.8), libgtk-3-0 (>= 3.9.10), libhunspell-1.7-0, libstdc++6 (>= 5.2), libudev1 (>= 183), libx11-6, libxi6 (>= 2:1.2.99.4), libxkbfile1, libxtst6
Recommends: gir1.2-appindicator3-0.1, gir1.2-atspi-2.0, xdg-utils
Suggests: mousetweaks (>= 3.3.90)
Conflicts: onboard, onboard-common, onboard-data
Replaces: onboard, onboard-common, onboard-data
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://launchpad.net/onboard
Description: Simple On-screen Keyboard (arm64)
 Onboard ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Flexible on-screen keyboard (common + language models bundled).
 glibc≤2.31 (Ubuntu 20.04, Python 3.8).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/conffiles" << 'EOT'
/etc/xdg/autostart/onboard-autostart.desktop
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v py3compile >/dev/null 2>&1; then
  py3compile /usr/lib/python3/dist-packages/Onboard >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/HighContrast /usr/share/icons/ubuntu-mono-dark /usr/share/icons/ubuntu-mono-light 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
if command -v py3clean >/dev/null 2>&1; then
  py3clean /usr/lib/python3/dist-packages/Onboard >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
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
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/HighContrast /usr/share/icons/ubuntu-mono-dark /usr/share/icons/ubuntu-mono-light 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-onboard-control.txt"
