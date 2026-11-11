#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) gedit 3.36.2-0ubuntu1
# arm64 plus gedit-common all as kemi-gedit (common bundled).
# Probe: aarch64 · 9 ELF (launcher + libgedit-3.36.so + 7 plugin
#   .so) · requiredGlibc 2.17 · no GLIBCXX · PASS vs 101 ≤2.31
#   launcher: libgedit-3.36.so + GIO/GObject + libtepl-4 + libc;
#     RUNPATH=/usr/lib/aarch64-linux-gnu/gedit
#   libgedit: GTK3 + GDK3 + GtkSourceView 4 + libtepl-4 +
#     libamtk-5 + libpeas/libpeas-gtk + Pango + ATK + Cairo +
#     GDK-Pixbuf + GIO/GObject/GLib + girepository + X11 +
#     pthread + libc
#   plugins also use libgspell-1.so.2 where relevant
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   python3.8, GTK3, GtkSourceView 4, typelibs, libtepl-4-0,
#   libamtk-5-0, libgspell-1-2, libpeas, gsettings-desktop-schemas,
#   iso-codes, python3-gi / python3-gi-cairo).
# gedit-common (>= 3.36, << 3.37) is bundled (official arch:all;
#   Depends: python3:any, dconf-gsettings-backend | gsettings-backend
#   — folded into this package). There is no separate gir1.2-gedit
#   typelib deb; typelib ships inside the official gedit package at
#   /usr/lib/aarch64-linux-gnu/gedit/girepository-1.0/Gedit-3.0.typelib
#   and stays there. Official Recommends (yelp, zenity) stay as
#   Recommends. Suggests gedit-plugins (different source) is not
#   bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed — not saved as a Packages.gz dump). Release pocket
#   still has older 3.36.1-1; this is the current official
#   focal-updates arm64 build. No librarian URL is recorded
#   this run.
# The official launcher ELF embeds compiled /usr prefixes and
#   RUNPATH=/usr/lib/aarch64-linux-gnu/gedit. Layout therefore
#   keeps the official ELF at /usr/bin/gedit and the private
#   library, typelib and plugin .so files at
#   /usr/lib/aarch64-linux-gnu/gedit. /opt/gedit/gedit is a
#   symlink to /usr/bin/gedit (HardInfo/Xpad/qpdfview/Pluma).
#   GI override stays at
#   /usr/lib/python3/dist-packages/gi/overrides/Gedit.py.
# Official desktop Icon=org.gnome.gedit (SVG shipped). Exec
#   lines are gedit %U / --new-window / --new-document (no
#   TryExec upstream). Official language-pack split: no .mo in
#   these debs. C help is real files; non-C help pages are
#   official symlinks into /usr/share/help-langpack/.
# Python 3 plugins and GI override have no PEP 585 annotations.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gedit
VER_UP=3.36.2
VER_DEB="${VER_UP}-0ubuntu1kemi1"
ARCH=arm64
PKG=kemi-gedit
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gedit-3.36.2-0ubuntu1-focal-unpack}"
UP_DEB="$DL/gedit_3.36.2-0ubuntu1_arm64.deb"
COM_DEB="$DL/gedit-common_3.36.2-0ubuntu1_all.deb"
EXPECT_SHA=b6671760cf1a489f58a9ce6f55ba7320b2330b559d63d6e2cf646598d50d28f6
EXPECT_BYTES=385740
COM_SHA=65ecc1153c0778b19fc2c1589bbd9433e1e3ca573b66d935026e55f3c4f659a9
COM_BYTES=94748
LIBDIR="usr/lib/aarch64-linux-gnu/gedit"
TYPELIB="$LIBDIR/girepository-1.0/Gedit-3.0.typelib"
OVERRIDE="usr/lib/python3/dist-packages/gi/overrides/Gedit.py"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB" && test -f "$COM_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$COM_DEB")" = "$COM_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$COM_SHA  $COM_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gedit"
test -f "$UNPACK/$LIBDIR/libgedit-3.36.so"
test -f "$UNPACK/$TYPELIB"
test -f "$UNPACK/$LIBDIR/plugins/libspell.so"
test -f "$UNPACK/$LIBDIR/plugins/libfilebrowser.so"
test -f "$UNPACK/$OVERRIDE"
test -f "$UNPACK/usr/share/applications/org.gnome.gedit.desktop"
test -f "$UNPACK/usr/share/man/man1/gedit.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gedit.gschema.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.gedit.svg"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.gedit.service"
test -f "$UNPACK/usr/share/metainfo/org.gnome.gedit.appdata.xml"
test -f "$UNPACK/usr/share/help/C/gedit/gedit-files-basic.page"
test -d "$UNPACK/usr/share/help/zh_CN/gedit"
# compiled /usr prefixes + RUNPATH — ELF must stay at /usr/bin
grep -qx '/usr/lib/aarch64-linux-gnu/gedit' < <(strings -n 8 "$UNPACK/usr/bin/gedit")
if command -v readelf >/dev/null 2>&1; then
  readelf -d "$UNPACK/usr/bin/gedit" | grep -q '\[/usr/lib/aarch64-linux-gnu/gedit\]'
fi

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/python3/runtime.d" \
  "$STAGE/pkg/opt/gedit"

# Official ELF stays at /usr/bin/gedit (compiled /usr prefixes + RUNPATH).
cp -al "$UNPACK/usr/bin/gedit" "$STAGE/pkg/usr/bin/gedit"
chmod 0755 "$STAGE/pkg/usr/bin/gedit"

# Private lib, typelib and plugins stay on compiled /usr/lib path.
mkdir -p "$STAGE/pkg/usr/lib/aarch64-linux-gnu"
cp -al "$UNPACK/$LIBDIR" "$STAGE/pkg/$LIBDIR"
test -f "$STAGE/pkg/$LIBDIR/libgedit-3.36.so"
test -f "$STAGE/pkg/$TYPELIB"
test -f "$STAGE/pkg/$LIBDIR/plugins/libspell.so"

# GI override must stay on dist-packages (do not relocate).
mkdir -p "$STAGE/pkg/usr/lib/python3/dist-packages/gi/overrides"
cp -al "$UNPACK/$OVERRIDE" "$STAGE/pkg/$OVERRIDE"
test -f "$STAGE/pkg/$OVERRIDE"

# Probe staged ELFs before packing.
REPORT="$ROOT/probe/kemi-gedit.json"
rm -f "$REPORT"
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PY
)
test "${#ELFS[@]}" = 9
PROBE_ARGS=()
for e in "${ELFS[@]}"; do PROBE_ARGS+=(--elf "$e"); done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 9:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in r["files"]}
for need in ("gedit", "libgedit-3.36.so", "libspell.so", "libfilebrowser.so"):
    if need not in by:
        raise SystemExit(f"PROBE_MISSING_{need}")
for name, f in by.items():
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["libgedit-3.36.so"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libgtksourceview-4.so.0",
            "libtepl-4.so.0", "libamtk-5.so.0", "libpeas-1.0.so.0",
            "libpeas-gtk-1.0.so.0", "libpango-1.0.so.0", "libatk-1.0.so.0",
            "libcairo.so.2", "libgdk_pixbuf-2.0.so.0", "libgio-2.0.so.0",
            "libgobject-2.0.so.0", "libglib-2.0.so.0",
            "libgirepository-1.0.so.1", "libX11.so.6", "libpthread.so.0",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
ln = set(by["gedit"].get("neededLibraries") or [])
if "libgedit-3.36.so" not in ln:
    raise SystemExit("PROBE_LAUNCHER_MISSING_LIBGEDIT")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=9")
PY

# Data, help, schemas, icons, man, metainfo, dbus stay on /usr/share.
cp -a "$UNPACK/usr/share/gedit" "$STAGE/pkg/usr/share/gedit"
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
cp -a "$UNPACK/usr/share/glib-2.0/schemas/." "$STAGE/pkg/usr/share/glib-2.0/schemas/"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/gedit.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gedit.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.gnome.gedit.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.gnome.gedit.appdata.xml"
mkdir -p "$STAGE/pkg/usr/share/dbus-1/services"
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/org.gnome.gedit.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.gedit.service"
grep -q '^Exec=/usr/bin/gedit --gapplication-service$' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.gedit.service"
test -f "$STAGE/pkg/usr/share/help/C/gedit/gedit-files-basic.page"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.gedit.svg"
test -d "$STAGE/pkg/usr/share/gedit/plugins"

# Official changelog/copyright may be regular files; dereference anyway.
if [[ -f "$UNPACK/usr/share/doc/gedit/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gedit/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/gedit/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gedit/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
if [[ -f "$UNPACK/usr/share/doc/gedit/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gedit/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi

# Desktop: keep official Icon=org.gnome.gedit; point all Exec/TryExec.
python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.gedit.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.gedit.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gedit\b", "Exec=/usr/bin/gedit", text, flags=re.M)
text2 = re.sub(r"^TryExec=gedit$", "TryExec=/usr/bin/gedit", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = text2.replace(
        "Exec=/usr/bin/gedit %U",
        "Exec=/usr/bin/gedit %U\nTryExec=/usr/bin/gedit",
        1,
    )
if re.search(r"^Exec=gedit(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/gedit %U" not in text2:
    raise SystemExit("MISSING_MAIN_EXEC")
if "Exec=/usr/bin/gedit --new-window" not in text2:
    raise SystemExit("MISSING_NEW_WINDOW_EXEC")
if "Exec=/usr/bin/gedit --new-document" not in text2:
    raise SystemExit("MISSING_NEW_DOCUMENT_EXEC")
if "TryExec=/usr/bin/gedit" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if "Icon=org.gnome.gedit" not in text2.splitlines() and not re.search(r"^Icon=org\.gnome\.gedit$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten")
PY
grep -q '^Icon=org.gnome.gedit$' "$STAGE/pkg/usr/share/applications/org.gnome.gedit.desktop"

# Path-based rtupdate (do not use Debian package name gedit).
cat > "$STAGE/pkg/usr/share/python3/runtime.d/kemi-gedit.rtupdate" << 'EOT'
#! /bin/sh
set -e
if [ "$1" = rtupdate ]; then
	if command -v py3clean >/dev/null 2>&1; then
		py3clean /usr/lib/aarch64-linux-gnu/gedit/plugins >/dev/null 2>&1 || true
		py3clean /usr/lib/python3/dist-packages/gi/overrides/Gedit.py >/dev/null 2>&1 || true
	fi
	if command -v py3compile >/dev/null 2>&1; then
		py3compile -V 3.8 /usr/lib/aarch64-linux-gnu/gedit/plugins >/dev/null 2>&1 || true
		py3compile /usr/lib/python3/dist-packages/gi/overrides/Gedit.py >/dev/null 2>&1 || true
	fi
fi
EOT
chmod 0755 "$STAGE/pkg/usr/share/python3/runtime.d/kemi-gedit.rtupdate"

# /opt is a layout marker only — symlink to the official ELF path.
ln -sf /usr/bin/gedit "$STAGE/pkg/opt/gedit/gedit"
ln -sf gedit "$STAGE/pkg/usr/bin/kemi-gedit"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Gedit
Source: https://launchpad.net/ubuntu/+source/gedit
Homepage: https://wiki.gnome.org/Apps/Gedit
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(gedit_3.36.2-0ubuntu1_arm64.deb) plus official arch:all
gedit-common_3.36.2-0ubuntu1_all.deb
repackaged for KEMI as ${PKG} (common bundled).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gedit_3.36.2-0ubuntu1_arm64.deb
    (focal-updates main) plus official gedit-common of the
    same version, repackaged for KEMI as ${PKG} (common bundled).
  * Official ELF stays at /usr/bin/gedit because the launcher
    embeds compiled /usr prefixes and RUNPATH
    /usr/lib/aarch64-linux-gnu/gedit. Private libgedit-3.36.so,
    typelib and plugin .so files stay on that path.
    /opt/gedit/gedit is a symlink to /usr/bin/gedit.
    GI override stays at
    /usr/lib/python3/dist-packages/gi/overrides/Gedit.py.
  * Desktop, D-Bus service, man, GSettings schemas, metainfo,
    icons, plugin data and help stay on standard /usr/share
    paths. Official desktop Icon=org.gnome.gedit (SVG shipped).
  * Official language-pack split: these debs ship no .mo files.
    C help is real; non-C help pages are official symlinks into
    /usr/share/help-langpack/.
  * Conflicts/Replaces gedit, gedit-common.
  * Depends kept for Ubuntu 20.04 (GTK3, GtkSourceView 4,
    libtepl-4, libamtk-5, libgspell, libpeas, typelibs,
    python3.8, python3-gi, gsettings-desktop-schemas, iso-codes,
    gsettings backend, libc6 >= 2.17).
    Recommends: yelp, zenity.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:10:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gedit ${VER_UP}-0ubuntu1 — official Ubuntu 20.04 (focal-updates)
arm64, KEMI repack (gedit-common bundled).

The official ELF stays at /usr/bin/gedit (compiled /usr prefixes
and RUNPATH /usr/lib/aarch64-linux-gnu/gedit). /opt/gedit/gedit
is a symlink to /usr/bin/gedit. Private libgedit-3.36.so, typelib
Gedit-3.0.typelib and plugin .so files stay under
/usr/lib/aarch64-linux-gnu/gedit. GI override stays at
/usr/lib/python3/dist-packages/gi/overrides/Gedit.py.
Desktop, D-Bus, man, GSettings schemas, metainfo, icons, plugin
data and help remain on standard /usr/share paths.
Official desktop Icon=org.gnome.gedit (SVG shipped).
Official language-pack split: no .mo in these debs. C help is
real; zh_CN / zh_HK / zh_TW help pages are official langpack
symlinks.
Probe: aarch64 · 9 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + GtkSourceView 4 + libtepl/libamtk; Ubuntu 20.04 / glibc
2.31 OK.
Runtime: typelibs gir1.2-glib-2.0 / gtk-3.0 / gtksource-4 /
pango-1.0 / peas-1.0, gsettings-desktop-schemas, iso-codes,
python3-gi, python3-gi-cairo, python3.8, gsettings backend,
libamtk-5-0 (>= 5.0.0), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17),
libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.25.2),
libgirepository-1.0-1 (>= 0.9.3), libglib2.0-0 (>= 2.51.0),
libgspell-1-2 (>= 1.8.2), libgtk-3-0 (>= 3.21.5),
libgtksourceview-4-0 (>= 3.18.0), libpango-1.0-0 (>= 1.14.0),
libpeas-1.0-0 (>= 1.14.1), libtepl-4-0 (>= 4.4), libx11-6.
Recommends: yelp, zenity.
Official publication: Ubuntu 20.04 focal-updates main arm64
gedit 3.36.2-0ubuntu1 (current official U20 package; newer than
Release 3.36.1-1). Official SHA256 + size matched
ports.ubuntu.com pool files and focal-updates main arm64
Packages stanzas.
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
Depends: gir1.2-glib-2.0, gir1.2-gtk-3.0 (>= 3.21.3), gir1.2-gtksource-4, gir1.2-pango-1.0, gir1.2-peas-1.0, gsettings-desktop-schemas, iso-codes, python3-gi (>= 3.0), python3-gi-cairo (>= 3.0), python3:any, python3.8, dconf-gsettings-backend | gsettings-backend, libamtk-5-0 (>= 5.0.0), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.25.2), libgirepository-1.0-1 (>= 0.9.3), libglib2.0-0 (>= 2.51.0), libgspell-1-2 (>= 1.8.2), libgtk-3-0 (>= 3.21.5), libgtksourceview-4-0 (>= 3.18.0), libpango-1.0-0 (>= 1.14.0), libpeas-1.0-0 (>= 1.14.1), libtepl-4-0 (>= 4.4), libx11-6
Recommends: yelp, zenity
Conflicts: gedit, gedit-common
Replaces: gedit, gedit-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Gedit
Description: official text editor of the GNOME desktop (arm64)
 Gedit ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Tabbed GTK3 text editor with syntax highlighting and plugins
 (common bundled).
 glibc≤2.31 (Ubuntu 20.04, Python 3.8).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
case "$1" in
    configure)
        update-alternatives \
            --install \
                /usr/bin/gnome-text-editor \
                gnome-text-editor \
                /usr/bin/gedit \
                50 \
            --slave \
                /usr/share/man/man1/gnome-text-editor.1.gz \
                gnome-text-editor.1.gz \
                /usr/share/man/man1/gedit.1.gz \
            || true
    ;;
esac
if command -v py3compile >/dev/null 2>&1; then
  py3compile -V 3.8 /usr/lib/aarch64-linux-gnu/gedit/plugins >/dev/null 2>&1 || true
  py3compile /usr/lib/python3/dist-packages/gi/overrides/Gedit.py >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = remove ]; then
  update-alternatives --remove gnome-text-editor /usr/bin/gedit || true
fi
if command -v py3clean >/dev/null 2>&1; then
  py3clean /usr/lib/aarch64-linux-gnu/gedit/plugins >/dev/null 2>&1 || true
  py3clean /usr/lib/python3/dist-packages/gi/overrides/Gedit.py >/dev/null 2>&1 || true
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
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gedit-control.txt"
