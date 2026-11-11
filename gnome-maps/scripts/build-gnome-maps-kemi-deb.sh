#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) gnome-maps
# 3.36.1-1ubuntu1 Architecture: arm64 as kemi-gnome-maps.
# Newer than focal Release 3.36.1-1 and still Ubuntu 20.04
# deps (libc6 >= 2.17). The gnome-maps source ships only this
# one binary package in focal (no same-source -data/-common
# to bundle). Official control has no Recommends and no
# Suggests. System typelib / geoclue / gjs / library Depends
# stay Depends and are not bundled (different-source, not
# exact-version data). Versioned Provides:
# gnome-maps (= 3.36.1-1ubuntu1).
# Official /usr/bin/gnome-maps is a symlink to
# /usr/share/gnome-maps/org.gnome.Maps, a GJS wrapper
# (#!/usr/bin/gjs). The wrapper hardcodes prefix "/usr" and
# libdir "/usr/lib/aarch64-linux-gnu". The unique packaged
# ELF is the private lib
# /usr/lib/aarch64-linux-gnu/gnome-maps/libgnome-maps.so.0.0.0
# (plus official soname symlinks) and a typelib beside it.
# Official files stay on official paths; /opt/gnome-maps/*
# are symlinks. Official package ships no .mo (Ubuntu
# language-pack split; desktop X-Ubuntu-Gettext-Domain=gnome-maps).
# Keep the official tree; do not invent or bundle language
# packs. Official package has no /usr/share/help tree; do
# not invent one. Official app icons are SVG only
# (org.gnome.Maps.svg, Devel, and symbolic). Official in-app
# UI PNGs under /usr/share/gnome-maps/icons are kept as the
# official tree and are not the app icon. Do not invent a
# PNG inside the package. A 128x128 PNG rasterized from the
# official app SVG may be used only as the mall CREATE --icon
# and must live under evidence/ (GNOME Clocks / Calendar /
# Weather / Tweaks pattern). Official changelog is a real
# file. Official package has no maintainer scripts; hicolor
# + desktop-database hooks are added. Official D-Bus service
# Exec is already absolute under /usr/share/gnome-maps/ and
# is kept. Official desktop Exec=gapplication launch
# org.gnome.Maps %U is rewritten to /usr/bin/gapplication
# (libglib2.0-bin, already a Depends; official lintian
# override documents this); Icon=org.gnome.Maps is kept;
# TryExec=/usr/bin/gnome-maps is added. DBusActivatable=true
# is kept.
# Probe: Architecture arm64 · 1 unique packaged ELF ·
# requiredGlibc 2.17 (1 versioned, 0 null) · no GLIBCXX
# (0 versioned, 1 null; null is not ranked as a max) ·
# GJS GTK3 typelib GUI + private aarch64 lib · within
# 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal-updates universe
# arm64 Packages stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no .buildinfo is recorded
# this run (pool 404).
# KEMI version 3.36.1-1ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-tweaks 3.34.0-2ubuntu1kemi1 was 20 chars).
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-maps
VER_UP=3.36.1-1ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-maps
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-maps_3.36.1-1ubuntu1_arm64.deb"
EXPECT_SHA=6f8e8577e9f8b82db87f11e5684a368dfba3272eaa242aacc387fe7792314707
EXPECT_BYTES=398268
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -L "$UNPACK/usr/bin/gnome-maps"
test "$(readlink "$UNPACK/usr/bin/gnome-maps")" = "../share/gnome-maps/org.gnome.Maps"
test -x "$UNPACK/usr/share/gnome-maps/org.gnome.Maps"
test "$(head -n 1 "$UNPACK/usr/share/gnome-maps/org.gnome.Maps")" = "#!/usr/bin/gjs"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/gnome-maps/libgnome-maps.so.0.0.0"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/gnome-maps/libgnome-maps.so.0"
test -f "$UNPACK/usr/share/applications/org.gnome.Maps.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Maps.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Maps-symbolic.svg"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Maps.Devel.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.Maps.png"
test ! -d "$UNPACK/usr/share/icons/hicolor/48x48"
test ! -d "$UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/gnome-maps/changelog.Debian.gz"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.Maps.service"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Maps.gschema.xml"
test ! -f "$UNPACK/DEBIAN/postinst"
test -f "$ROOT/evidence/org.gnome.Maps-128.png"
# official in-app UI PNGs exist and must stay official (not the app icon)
test -f "$UNPACK/usr/share/gnome-maps/icons/hicolor/24x24/apps/user-location.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-maps"

cp -a "$UNPACK/usr/bin/gnome-maps" "$STAGE/pkg/usr/bin/gnome-maps"
cp -a "$UNPACK/usr/lib" "$STAGE/pkg/usr/lib"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
test -L "$STAGE/pkg/usr/bin/gnome-maps"
test "$(readlink "$STAGE/pkg/usr/bin/gnome-maps")" = "../share/gnome-maps/org.gnome.Maps"

REPORT="$ROOT/probe/kemi-gnome-maps.json"
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
test "${#ELFS[@]}" = 1
PROBE_ARGS=(--target-arch arm64 --max-glibc 2.31 --report "$REPORT")
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 1:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
f = files[0]
if Path(f["path"]).name != "libgnome-maps.so.0.0.0":
    raise SystemExit(f"PROBE_NAME:{f['path']}")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{f.get('requiredGlibcxx')}")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or nulls or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
print("PROBE_PASS n_elf=1 unique libgnome-maps.so.0.0.0 aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Maps.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.Maps.png"
test -f "$STAGE/pkg/usr/share/gnome-maps/icons/hicolor/24x24/apps/user-location.png"
if find "$STAGE/pkg" -name 'org.gnome.Maps-128.png' | grep -q .; then
  echo "PACKED_EVIDENCE_PNG" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-maps/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-maps/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.Maps.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Maps.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gapplication launch org\.gnome\.Maps %U$",
               "Exec=/usr/bin/gapplication launch org.gnome.Maps %U",
               text, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gapplication launch org\.gnome\.Maps %U)$",
                   r"\1\nTryExec=/usr/bin/gnome-maps",
                   text2, count=1, flags=re.M)
if re.search(r"^Exec=gapplication(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gapplication launch org.gnome.Maps %U",
               "TryExec=/usr/bin/gnome-maps",
               "Icon=org.gnome.Maps",
               "Name=Maps",
               "DBusActivatable=true"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

t = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Maps.service").read_text(encoding="utf-8")
if "Exec=/usr/share/gnome-maps/org.gnome.Maps --gapplication-service" not in t:
    raise SystemExit("DBUS_CHANGED")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".gresource", ".typelib"}:
        continue
    try:
        txt = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in txt:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/gnome-maps "$STAGE/pkg/opt/gnome-maps/gnome-maps"
ln -sf gnome-maps "$STAGE/pkg/usr/bin/kemi-gnome-maps"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Maps
Source: https://launchpad.net/ubuntu/+source/gnome-maps
Homepage: https://wiki.gnome.org/Apps/Maps
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) Architecture: arm64 deb v${VER_UP}
(gnome-maps_3.36.1-1ubuntu1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-maps_3.36.1-1ubuntu1_arm64.deb
    (focal-updates universe; newer than focal Release
    3.36.1-1, still Ubuntu 20.04 deps) repackaged for
    KEMI as ${PKG}. No same-source data package in focal.
    Official control has no Recommends and no Suggests.
    Versioned Provides: gnome-maps (= 3.36.1-1ubuntu1).
  * Official /usr/bin/gnome-maps is a symlink to a GJS
    wrapper. Unique packaged ELF is private
    libgnome-maps.so.0.0.0. Data stays under
    /usr/share/gnome-maps (compiled /usr prefix).
    /opt/gnome-maps/* are symlinks. Also
    /usr/bin/kemi-gnome-maps.
  * Desktop, official SVG app icons, official in-app UI
    icons, official gsettings schema and D-Bus service
    stay on standard paths. Official package ships no
    .mo and no /usr/share/help (language-pack split).
    Official desktop Exec=gapplication rewritten to
    /usr/bin/gapplication; Icon=org.gnome.Maps.
    Official D-Bus Exec already absolute and kept.
    Official app icons are SVG only; no PNG is invented
    inside the package.
  * Official package has no maintainer scripts. Official
    changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Maps ${VER_UP} — official Ubuntu 20.04
(focal-updates) universe Architecture: arm64,
KEMI repack.

Official /usr/bin/gnome-maps is a symlink to a
GJS wrapper. Unique packaged ELF is private
libgnome-maps.so.0.0.0 (glibc 2.17, no GLIBCXX).
/opt/gnome-maps/* are symlinks. Desktop, official
SVG app icons, official schema and D-Bus service
remain on standard paths. Official package ships
no .mo (language-pack split) and no /usr/share/help.
Official control has no Recommends and no Suggests.
Probe: 1 unique ELF · requiredGlibc 2.17 (1
versioned, 0 null) · no requiredGlibcxx (0
versioned, 1 null; null not ranked as a max);
GJS GTK3 typelib GUI; within Ubuntu 20.04 /
glibc 2.31.
Official publication: Ubuntu 20.04 focal-updates
universe gnome-maps 3.36.1-1ubuntu1
(Architecture: arm64). Official SHA256 + size
matched ports.ubuntu.com pool files and
focal-updates universe arm64 Packages stanza.
No librarian URL this run.
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
Depends: geoclue-2.0 (>= 2.0), gir1.2-champlain-0.12 (>= 0.12.14), gir1.2-clutter-1.0, gir1.2-cogl-1.0, gir1.2-gdkpixbuf-2.0, gir1.2-geoclue-2.0, gir1.2-geocodeglib-1.0 (>= 3.15.2), gir1.2-gfbgraph-0.2, gir1.2-glib-2.0 (>= 1.41), gir1.2-goa-1.0, gir1.2-gtk-3.0 (>= 3.22.0), gir1.2-gtkchamplain-0.12 (>= 0.12.14), gir1.2-gtkclutter-1.0, gir1.2-gweather-3.0, gir1.2-rest-0.7 (>= 0.7.90), gir1.2-secret-1, gir1.2-soup-2.4, gir1.2-webkit2-4.0, gjs (>= 1.50.0), libglib2.0-bin (>= 2.40.0-3), dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libchamplain-0.12-0 (>= 0.12.14), libfolks25 (>= 0.10.0), libgee-0.8-2 (>= 0.16.0), libgeocode-glib0 (>= 3.16.2), libglib2.0-0 (>= 2.44.0), librest-0.7-0 (>= 0.7), libxml2 (>= 2.7.4)
Replaces: gnome-maps
Conflicts: gnome-maps
Provides: gnome-maps (= 3.36.1-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Maps
Description: map application for GNOME
 GNOME Maps ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 View maps, search places, and show location
 (GTK3, GJS typelib GUI).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v update-icon-caches >/dev/null 2>&1; then
		update-icon-caches /usr/share/icons/hicolor || true
	elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q /usr/share/icons/hicolor || true
	fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-icon-caches >/dev/null 2>&1; then
	update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-maps-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
if "org.gnome.Maps-128.png" in out or "128x128/apps/org.gnome.Maps.png" in out:
    raise SystemExit("PACKED_RASTER_OR_INVENTED_PNG")
need = [
    "./usr/bin/gnome-maps",
    "./usr/bin/kemi-gnome-maps",
    "./opt/gnome-maps/gnome-maps",
    "./usr/share/gnome-maps/org.gnome.Maps",
    "./usr/lib/aarch64-linux-gnu/gnome-maps/libgnome-maps.so.0.0.0",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Maps.svg",
    "./usr/share/dbus-1/services/org.gnome.Maps.service",
    "./usr/share/glib-2.0/schemas/org.gnome.Maps.gschema.xml",
    "./usr/share/gnome-maps/icons/hicolor/24x24/apps/user-location.png",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if not any("usr/bin/gnome-maps" in line and "->" in line for line in out.splitlines()):
    raise SystemExit("BIN_NOT_SYMLINK")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
