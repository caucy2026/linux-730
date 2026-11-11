#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) simple-scan
# 3.36.3-0ubuntu0.20.04.0 arm64 deb as kemi-simple-scan.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX ·
#   GLib/GIO/GObject + GTK3 + GDK3 + Cairo + GDK-Pixbuf +
#   libgusb + SANE + colord + PackageKit + libwebp/libwebpmux +
#   zlib + libc · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libcairo2 >= 1.4.10, libcolord2 >= 0.1.10,
#   libgdk-pixbuf2.0-0 >= 2.22.0, libglib2.0-0 >= 2.43.92,
#   libgtk-3-0 >= 3.21.5, libgusb2 >= 0.2.2,
#   libpackagekit-glib2-18 >= 0.9.4, libsane >= 1.0.24,
#   libwebp6 >= 0.5.1, libwebpmux3 >= 0.6.1-2, zlib1g >= 1:1.1.4,
#   default-dbus-session-bus | dbus-session-bus, xdg-utils,
#   dconf-gsettings-backend | gsettings-backend).
# Official C help is shipped in this deb (help:simple-scan);
#   non-C help entries are official symlinks into
#   /usr/share/help-langpack (including zh_TW; this deb has no
#   zh_CN help dir), not bundled. Recommends: yelp.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   file and the Ubuntu 20.04 focal-updates main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed — not saved as a Packages.gz dump). Launchpad
#   HTML/API were retried this run but Launchpad returned 503.
# The focal Release pocket still has 3.36.0-0ubuntu1 (same
#   Depends); this package is the current official focal-updates
#   arm64 build (LP: #1883819).
# Official desktop Icon=org.gnome.SimpleScan (hicolor SVG
#   shipped). Exec=simple-scan (no TryExec upstream).
# UI is compiled-in as a GResource
#   (/org/gnome/SimpleScan/*.ui).
# Locale path compiled in as /usr/share/locale (this deb ships
#   no .mo; translations may come from language packs; desktop
#   has X-Ubuntu-Gettext-Domain=simple-scan).
# Help / schemas / icons / metainfo / man stay on standard
#   /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-simple-scan
VER_UP=3.36.3
VER_DEB="${VER_UP}-0ubuntu0.20.04.0kemi1"
ARCH=arm64
PKG=kemi-simple-scan
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/simple-scan-3.36.3-0ubuntu0.20.04.0-focal-unpack}"
UP_DEB="$DL/simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb"
EXPECT_SHA=9444d1407873a810ebbc9c09e0ca5606e10b63e952c50e1be3eaece94c1af4bc
EXPECT_BYTES=170116
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/simple-scan"
test -f "$UNPACK/usr/share/applications/simple-scan.desktop"
test -f "$UNPACK/usr/share/man/man1/simple-scan.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.SimpleScan.gschema.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.SimpleScan.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.SimpleScan-symbolic.svg"
test -f "$UNPACK/usr/share/metainfo/simple-scan.appdata.xml"
test -f "$UNPACK/usr/share/help/C/simple-scan/index.page"
test -f "$UNPACK/usr/share/help/C/simple-scan/figures/icon.svg"
test -L "$UNPACK/usr/share/help/zh_TW/simple-scan/index.page"
test ! -e "$UNPACK/usr/share/help/zh_CN"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/simple-scan"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/simple-scan" "$STAGE/pkg/opt/simple-scan/simple-scan"
chmod 0755 "$STAGE/pkg/opt/simple-scan/simple-scan"
test -x "$STAGE/pkg/opt/simple-scan/simple-scan"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-simple-scan.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/simple-scan/simple-scan" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
            "libgtk-3.so.0", "libgdk-3.so.0", "libcairo.so.2",
            "libgdk_pixbuf-2.0.so.0", "libgusb.so.2", "libsane.so.1",
            "libcolord.so.2", "libpackagekit-glib2.so.18",
            "libwebp.so.6", "libwebpmux.so.3", "libz.so.1", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Help / icons — keep standard /usr/share paths; preserve official
# help-langpack symlinks (do not follow).
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
test -f "$STAGE/pkg/usr/share/help/C/simple-scan/index.page"
test -L "$STAGE/pkg/usr/share/help/zh_TW/simple-scan/index.page"
test ! -e "$STAGE/pkg/usr/share/help/zh_CN"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/simple-scan.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/simple-scan.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.SimpleScan.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.SimpleScan.gschema.xml"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/simple-scan.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/simple-scan.appdata.xml"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/simple-scan/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/simple-scan/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/simple-scan/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/simple-scan/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi

# Desktop: keep upstream fields; point Exec/TryExec at the KEMI launcher path.
# Official Icon=org.gnome.SimpleScan (hicolor SVG shipped). No TryExec upstream.
sed -e 's|^Exec=simple-scan$|Exec=/usr/bin/simple-scan|' \
    -e 's|^TryExec=simple-scan$|TryExec=/usr/bin/simple-scan|' \
  "$UNPACK/usr/share/applications/simple-scan.desktop" \
  > "$STAGE/pkg/usr/share/applications/simple-scan.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/simple-scan.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/simple-scan$/a TryExec=/usr/bin/simple-scan' \
    "$STAGE/pkg/usr/share/applications/simple-scan.desktop"
fi
grep -q '^Exec=/usr/bin/simple-scan$' "$STAGE/pkg/usr/share/applications/simple-scan.desktop"
grep -q '^TryExec=/usr/bin/simple-scan$' "$STAGE/pkg/usr/share/applications/simple-scan.desktop"
grep -q '^Icon=org.gnome.SimpleScan$' "$STAGE/pkg/usr/share/applications/simple-scan.desktop"

ln -sf /opt/simple-scan/simple-scan "$STAGE/pkg/usr/bin/simple-scan"
ln -sf simple-scan "$STAGE/pkg/usr/bin/kemi-simple-scan"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gitlab.gnome.org/GNOME/simple-scan
Source: https://launchpad.net/ubuntu/+source/simple-scan
Homepage: https://gitlab.gnome.org/GNOME/simple-scan
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb)
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04
    simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb (focal-updates)
    repackaged for KEMI as ${PKG}.
  * Layout /opt/simple-scan + /usr/bin/simple-scan; desktop, man,
    hicolor icons, GSettings schema, metainfo and help stay on
    standard /usr/share paths. Official desktop
    Icon=org.gnome.SimpleScan (hicolor SVG shipped). UI
    compiled-in as a GResource.
  * Official C help is bundled; non-C help entries remain official
    symlinks into /usr/share/help-langpack (not shipped in this
    deb; zh_TW is a langpack symlink, no zh_CN help dir). This
    official deb ships no locale .mo.
  * Conflicts/Replaces simple-scan.
  * Depends kept for Ubuntu 20.04 (GTK3, GLib, Cairo, GDK-Pixbuf,
    SANE, colord, PackageKit, libgusb, libwebp, libc6 >= 2.17,
    gsettings backend, dbus session bus, xdg-utils).
    Recommends: yelp.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Simple Scan ${VER_UP}-0ubuntu0.20.04.0 — official Ubuntu 20.04
(focal-updates) arm64, KEMI repack.

Installs under /opt/simple-scan/; launcher /usr/bin/simple-scan
(symlink into /opt/simple-scan).
Desktop, man, hicolor icons, GSettings schema, metainfo and help
remain on standard /usr/share paths.
Official desktop Icon=org.gnome.SimpleScan (hicolor SVG shipped).
UI is compiled-in as a GResource (/org/gnome/SimpleScan/*.ui).
This official deb ships no locale .mo (compiled locale path is
/usr/share/locale).
C help is bundled; other language help entries are official
symlinks into /usr/share/help-langpack (zh_TW only among zh_*;
no zh_CN help dir in this deb).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX ·
GLib/GIO/GObject + GTK3 + GDK3 + Cairo + GDK-Pixbuf + libgusb +
SANE + colord + PackageKit + libwebp; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: default-dbus-session-bus | dbus-session-bus, xdg-utils,
dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17),
libcairo2 (>= 1.4.10), libcolord2 (>= 0.1.10),
libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.92),
libgtk-3-0 (>= 3.21.5), libgusb2 (>= 0.2.2),
libpackagekit-glib2-18 (>= 0.9.4), libsane (>= 1.0.24),
libwebp6 (>= 0.5.1), libwebpmux3 (>= 0.6.1-2), zlib1g (>= 1:1.1.4).
Recommends: yelp.
Official publication: Ubuntu 20.04 focal-updates main arm64
simple-scan 3.36.3-0ubuntu0.20.04.0 (current official U20 package;
Release pocket still has 3.36.0-0ubuntu1 with the same Depends).
Official SHA256 + size matched ports.ubuntu.com pool file and
focal-updates main arm64 Packages stanzas.
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
Depends: default-dbus-session-bus | dbus-session-bus, xdg-utils, dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.4.10), libcolord2 (>= 0.1.10), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.92), libgtk-3-0 (>= 3.21.5), libgusb2 (>= 0.2.2), libpackagekit-glib2-18 (>= 0.9.4), libsane (>= 1.0.24), libwebp6 (>= 0.5.1), libwebpmux3 (>= 0.6.1-2), zlib1g (>= 1:1.1.4)
Recommends: yelp
Conflicts: simple-scan
Replaces: simple-scan
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gitlab.gnome.org/GNOME/simple-scan
Description: Simple Scanning Utility (arm64)
 Simple Scan ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 document scanner (SANE frontend).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-simple-scan-control.txt"
