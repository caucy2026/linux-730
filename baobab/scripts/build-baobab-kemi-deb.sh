#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) baobab 3.34.0-1 arm64 deb as kemi-baobab.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX ·
#   GLib/GIO/GObject + GTK3 + GDK3 + Pango + Cairo + libm + libc ·
#   PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libcairo2 >= 1.2.4, libglib2.0-0 >= 2.43.92, libgtk-3-0 >= 3.19.12,
#   libpango-1.0-0 >= 1.14.0, dconf-gsettings-backend | gsettings-backend).
# Official Recommends: yelp (C help is shipped in this deb; non-C help
#   entries are official symlinks into /usr/share/help-langpack, not bundled).
# Launchpad: baobab 3.34.0-1 in focal arm64, main/Release, Published
#   2019-10-18 17:15:30 Asia/Shanghai (binarypub 131884253).
# arm64 binary was built in ubuntu eoan PROPOSED (build 17770047) and
# published to focal Release (Launchpad HTML: "arm64 build of baobab
# 3.34.0-1 in ubuntu eoan PROPOSED produced these files").
# Official desktop Icon=org.gnome.baobab (hicolor SVG shipped).
# Exec=baobab; DBusActivatable with
#   /usr/share/dbus-1/services/org.gnome.baobab.service
#   Exec=/usr/bin/baobab --gapplication-service.
# UI is compiled-in as a GResource (/org/gnome/baobab/ui/*.ui,
#   resource:///org/gnome/baobab/baobab.css).
# Locale path compiled in as /usr/share/locale (this deb ships no .mo;
# translations may come from language packs; desktop has
# X-Ubuntu-Gettext-Domain=baobab).
# Help / schemas / icons / metainfo / man / dbus stay on standard
# /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-baobab
VER_UP=3.34.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-baobab
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/baobab-3.34.0-1-focal-unpack}"
UP_DEB="$DL/baobab_3.34.0-1_arm64.deb"
EXPECT_SHA=e7756a722943f221c8d65a42a27702fa58b476909abb3e074cc2a0d293411034
EXPECT_BYTES=91248
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/baobab"
test -f "$UNPACK/usr/share/applications/org.gnome.baobab.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.baobab.service"
test -f "$UNPACK/usr/share/man/man1/baobab.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.baobab.gschema.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.baobab.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.baobab-symbolic.svg"
test -f "$UNPACK/usr/share/metainfo/org.gnome.baobab.appdata.xml"
test -f "$UNPACK/usr/share/help/C/baobab/index.page"
test -f "$UNPACK/usr/share/help/C/baobab/media/hicolor_apps_48x48_baobab.png"
test -L "$UNPACK/usr/share/help/zh_CN/baobab/index.page"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/baobab"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/baobab" "$STAGE/pkg/opt/baobab/baobab"
chmod 0755 "$STAGE/pkg/opt/baobab/baobab"
test -x "$STAGE/pkg/opt/baobab/baobab"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-baobab.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/baobab/baobab" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libglib-2.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libgtk-3.so.0", "libgdk-3.so.0", "libpango-1.0.so.0",
            "libcairo.so.2", "libm.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Help / icons — keep standard /usr/share paths; preserve official
# help-langpack symlinks (do not follow).
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
test -f "$STAGE/pkg/usr/share/help/C/baobab/index.page"
test -L "$STAGE/pkg/usr/share/help/zh_CN/baobab/index.page"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/baobab.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/baobab.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.baobab.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.baobab.gschema.xml"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.gnome.baobab.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.gnome.baobab.appdata.xml"
# Official D-Bus service already points at /usr/bin/baobab.
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/org.gnome.baobab.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.baobab.service"
grep -q '^Exec=/usr/bin/baobab --gapplication-service$' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.baobab.service"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/baobab/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/baobab/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/baobab/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/baobab/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/baobab/NEWS.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/baobab/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi

# Desktop: keep upstream fields; point Exec/TryExec at the KEMI launcher path.
# Official Icon=org.gnome.baobab (hicolor SVG shipped).
sed -e 's|^Exec=baobab$|Exec=/usr/bin/baobab|' \
    -e 's|^TryExec=baobab$|TryExec=/usr/bin/baobab|' \
  "$UNPACK/usr/share/applications/org.gnome.baobab.desktop" \
  > "$STAGE/pkg/usr/share/applications/org.gnome.baobab.desktop"
grep -q '^Exec=/usr/bin/baobab$' "$STAGE/pkg/usr/share/applications/org.gnome.baobab.desktop"
grep -q '^TryExec=/usr/bin/baobab$' "$STAGE/pkg/usr/share/applications/org.gnome.baobab.desktop"
grep -q '^Icon=org.gnome.baobab$' "$STAGE/pkg/usr/share/applications/org.gnome.baobab.desktop"

ln -sf /opt/baobab/baobab "$STAGE/pkg/usr/bin/baobab"
ln -sf baobab "$STAGE/pkg/usr/bin/kemi-baobab"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Baobab
Source: https://launchpad.net/ubuntu/+source/baobab
Homepage: https://wiki.gnome.org/Apps/Baobab
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (baobab_3.34.0-1_arm64.deb)
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 baobab_3.34.0-1_arm64.deb repackaged for KEMI
    as ${PKG}.
  * Layout /opt/baobab + /usr/bin/baobab; desktop, man, hicolor icons,
    GSettings schema, metainfo, D-Bus service and help stay on standard
    /usr/share paths. Official desktop Icon=org.gnome.baobab (hicolor
    SVG shipped). UI compiled-in as a GResource.
  * Official C help is bundled; non-C help entries remain official
    symlinks into /usr/share/help-langpack (not shipped in this deb).
    This official deb ships no locale .mo.
  * Conflicts/Replaces baobab.
  * Depends kept for Ubuntu 20.04 (GTK3, GLib, Cairo, Pango, libc6 >= 2.17,
    gsettings backend). Recommends: yelp.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:45:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Baobab ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/baobab/; launcher /usr/bin/baobab (symlink into /opt/baobab).
Desktop, man, hicolor icons, GSettings schema, metainfo, D-Bus service and
help remain on standard /usr/share paths.
Official desktop Icon=org.gnome.baobab (hicolor SVG shipped).
UI is compiled-in as a GResource (/org/gnome/baobab/ui, baobab.css).
This official deb ships no locale .mo (compiled locale path is /usr/share/locale).
C help is bundled; other language help entries are official symlinks into
/usr/share/help-langpack.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GLib/GIO/GObject +
GTK3 + GDK3 + Pango + Cairo; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.43.92),
libgtk-3-0 (>= 3.19.12), libpango-1.0-0 (>= 1.14.0),
dconf-gsettings-backend | gsettings-backend. Recommends: yelp.
Official Launchpad publication: baobab 3.34.0-1 in focal arm64 (main, Release).
The arm64 binary was built in ubuntu eoan PROPOSED (build 17770047) and
published to focal Release.
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.43.92), libgtk-3-0 (>= 3.19.12), libpango-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend
Recommends: yelp
Conflicts: baobab
Replaces: baobab
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Baobab
Description: GNOME disk usage analyzer (arm64)
 Baobab ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 disk usage analyzer with a treemap view.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-baobab-control.txt"
