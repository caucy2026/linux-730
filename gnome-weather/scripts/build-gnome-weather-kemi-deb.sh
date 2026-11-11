#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) gnome-weather
# 3.36.1-1 Architecture: all as kemi-gnome-weather.
# The gnome-weather source ships only this one binary package
# in focal (no same-source -data/-common to bundle). Official
# control has no Recommends and no Suggests. System typelib /
# geoclue / gjs Depends stay Depends and are not bundled
# (different-source, not exact-version data). Versioned
# Provides: gnome-weather (= 3.36.1-1).
# Official /usr/bin/gnome-weather is a symlink to
# /usr/share/org.gnome.Weather/org.gnome.Weather, a GJS
# wrapper (#!/usr/bin/gjs, not an ELF). The BackgroundService
# helper is also a GJS script. Both hardcode prefix "/usr"
# and libdir "/usr/lib/gnome-weather" (that libdir is not
# shipped in the official tree; do not invent it). Official
# files stay on official paths; /opt/gnome-weather/* are
# symlinks. Official translations are 66 .mo including
# zh_CN / zh_TW / zh_HK. Official package has no
# /usr/share/help tree; do not invent one. Official icons
# are SVG only (org.gnome.Weather.svg and symbolic). Do not
# invent a PNG inside the package. A 128x128 PNG rasterized
# from the official SVG may be used only as the mall CREATE
# --icon and must live under evidence/ (GNOME Clocks /
# Calendar / Tweaks pattern). Official changelog is a real
# file. Official package has no maintainer scripts; hicolor
# + desktop-database hooks are added. Official D-Bus service
# Exec paths are already absolute under
# /usr/share/org.gnome.Weather/ and are kept. Official
# desktop Exec=gapplication launch org.gnome.Weather is
# rewritten to /usr/bin/gapplication (libglib2.0-bin, already
# a Depends; official lintian override documents this);
# Icon=org.gnome.Weather is kept; TryExec=/usr/bin/gnome-weather
# is added. DBusActivatable=true is kept.
# Probe: Architecture all · 0 packaged ELF · no
# requiredGlibc / requiredGlibcxx version-needs · GJS GTK3
# typelib GUI · vacuously within 101 ≤2.31 / ≤3.4.28
# (no ELF to exceed the baseline).
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed;
# arch:all listed in the arm64 index). No newer package in
# focal-updates (0 hits). No librarian URL and no .buildinfo
# is recorded this run (pool 404).
# KEMI version 3.36.1-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char string;
# gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars;
# gnome-tweaks 3.34.0-2ubuntu1kemi1 was 20 chars). No epoch,
# no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-weather
VER_UP=3.36.1-1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-gnome-weather
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/gnome-weather_3.36.1-1_all.deb"
EXPECT_SHA=dff7c84ef4689947972976aafba66ec2d36f817f85d4807d69e6e32f06f71464
EXPECT_BYTES=5160180
python3 - << PY
s="${VER_DEB}"
assert len(s) == 13, len(s)
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -L "$UNPACK/usr/bin/gnome-weather"
test "$(readlink "$UNPACK/usr/bin/gnome-weather")" = "../share/org.gnome.Weather/org.gnome.Weather"
test -x "$UNPACK/usr/share/org.gnome.Weather/org.gnome.Weather"
test "$(head -n 1 "$UNPACK/usr/share/org.gnome.Weather/org.gnome.Weather")" = "#!/usr/bin/gjs"
test "$(head -n 1 "$UNPACK/usr/share/org.gnome.Weather/org.gnome.Weather.BackgroundService")" = "#!/usr/bin/gjs"
python3 - << PY
from pathlib import Path
magic = bytes([0x7F]) + b"ELF"
root = Path("$UNPACK")
elfs=[]
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("OFFICIAL_HAS_ELF:" + ",".join(elfs))
print("official_no_elf")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Weather.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Weather.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Weather-symbolic.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.Weather.png"
test ! -d "$UNPACK/usr/share/icons/hicolor/48x48"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$UNPACK/usr/lib/gnome-weather"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 66
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/org.gnome.Weather.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/org.gnome.Weather.mo"
test ! -L "$UNPACK/usr/share/doc/gnome-weather/changelog.Debian.gz"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.Weather.service"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Weather.gschema.xml"
test ! -f "$UNPACK/DEBIAN/postinst"
test -f "$ROOT/evidence/org.gnome.Weather-128.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-weather"

# official trees (preserve the official /usr/bin symlink)
cp -a "$UNPACK/usr/bin/gnome-weather" "$STAGE/pkg/usr/bin/gnome-weather"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
test -L "$STAGE/pkg/usr/bin/gnome-weather"
test "$(readlink "$STAGE/pkg/usr/bin/gnome-weather")" = "../share/org.gnome.Weather/org.gnome.Weather"

# 0-ELF probe report (None-safe; do not invent a glibc max)
REPORT="$ROOT/probe/kemi-gnome-weather.json"
python3 - << PY
from pathlib import Path
import json
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs=[]
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
script = Path("$STAGE/pkg/usr/share/org.gnome.Weather/org.gnome.Weather")
if script.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_SCRIPT")
helper = Path("$STAGE/pkg/usr/share/org.gnome.Weather/org.gnome.Weather.BackgroundService")
if helper.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_HELPER")
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "official gnome-weather 3.36.1-1 is Architecture: all GJS / GTK3 typelib GUI; packaged tree contains 0 ELF files",
    "hostArchitecture": "x86_64",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "elfCount": 0,
    "glibcVersioned": 0,
    "glibcNull": 0,
    "glibcxxVersioned": 0,
    "glibcxxNull": 0,
    "maxVersionedGlibc": None,
    "maxVersionedGlibcxx": None,
    "wrapper": {
        "path": str(script),
        "shebang": script.read_text(encoding="utf-8").splitlines()[0],
        "bytes": script.stat().st_size,
        "usr_bin_symlink": "../share/org.gnome.Weather/org.gnome.Weather",
    },
    "helper": {
        "path": str(helper),
        "shebang": helper.read_text(encoding="utf-8").splitlines()[0],
        "bytes": helper.stat().st_size,
    },
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 gjs_wrapper glibc_versioned=0 glibc_null=0 noGLIBCXX configuredLimitsSatisfied=true (vacuous; no packaged ELF)")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 66
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/org.gnome.Weather.mo"
test ! -d "$STAGE/pkg/usr/share/help"
test ! -d "$STAGE/pkg/usr/lib/gnome-weather"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Weather.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps/org.gnome.Weather-symbolic.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.Weather.png"
if find "$STAGE/pkg" -name 'org.gnome.Weather-128.png' | grep -q .; then
  echo "PACKED_EVIDENCE_PNG" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-weather/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-weather/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.Weather.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Weather.desktop")
text = src.read_text(encoding="utf-8")
# official Exec=gapplication launch org.gnome.Weather (D-Bus activatable;
# command comes from Depends libglib2.0-bin). Make the command absolute.
text2 = re.sub(r"^Exec=gapplication launch org\.gnome\.Weather$",
               "Exec=/usr/bin/gapplication launch org.gnome.Weather",
               text, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gapplication launch org\.gnome\.Weather)$",
                   r"\1\nTryExec=/usr/bin/gnome-weather",
                   text2, count=1, flags=re.M)
if re.search(r"^Exec=gapplication(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gapplication launch org.gnome.Weather",
               "TryExec=/usr/bin/gnome-weather",
               "Icon=org.gnome.Weather",
               "Name=Weather",
               "DBusActivatable=true"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

# official D-Bus Exec already absolute — keep
for rel, needle in (
    ("usr/share/dbus-1/services/org.gnome.Weather.service",
     "Exec=/usr/share/org.gnome.Weather/org.gnome.Weather --gapplication-service"),
    ("usr/share/dbus-1/services/org.gnome.Weather.BackgroundService.service",
     "Exec=/usr/share/org.gnome.Weather/org.gnome.Weather.BackgroundService"),
):
    t = Path("$STAGE/pkg", rel).read_text(encoding="utf-8")
    if needle not in t:
        raise SystemExit("DBUS_CHANGED:" + rel)

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".gresource"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in t:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/gnome-weather "$STAGE/pkg/opt/gnome-weather/gnome-weather"
ln -sf gnome-weather "$STAGE/pkg/usr/bin/kemi-gnome-weather"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Weather
Source: https://launchpad.net/ubuntu/+source/gnome-weather
Homepage: https://wiki.gnome.org/Apps/Weather
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: all deb v${VER_UP}
(gnome-weather_3.36.1-1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-weather_3.36.1-1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. No same-source data
    package in focal. Official control has no Recommends
    and no Suggests. Versioned Provides:
    gnome-weather (= 3.36.1-1).
  * Official /usr/bin/gnome-weather is a symlink to a GJS
    wrapper (no packaged ELF). Data stays under
    /usr/share/org.gnome.Weather (compiled /usr prefix).
    /opt/gnome-weather/* are symlinks. Also
    /usr/bin/kemi-gnome-weather.
  * Desktop, official 66 .mo (including zh_CN), official
    SVG icons, official gsettings schema, D-Bus services
    and GNOME Shell search provider stay on standard
    paths. Official desktop Exec=gapplication rewritten
    to /usr/bin/gapplication; Icon=org.gnome.Weather.
    Official D-Bus Exec already absolute and kept.
    Official icons are SVG only; no PNG is invented
    inside the package. Official package has no
    /usr/share/help.
  * Official package has no maintainer scripts. Official
    changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Weather ${VER_UP} — official Ubuntu 20.04
(focal) universe Architecture: all, KEMI repack.

Official /usr/bin/gnome-weather is a symlink to a
GJS wrapper (no packaged ELF). /opt/gnome-weather/*
are symlinks. Desktop, official 66 .mo (including
zh_CN), official SVG icons, official schema, D-Bus
services and search provider remain on standard
paths. Official control has no Recommends and no
Suggests. Probe: 0 ELF · no requiredGlibc /
requiredGlibcxx version-needs; GJS GTK3 typelib
GUI; vacuously within Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04 focal universe
gnome-weather 3.36.1-1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com
pool files and focal universe arm64 Packages
stanza. No librarian URL this run.
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
Depends: geoclue-2.0 (>= 2.3.1), gir1.2-gdkpixbuf-2.0, gir1.2-geoclue-2.0 (>= 2.3.1), gir1.2-geocodeglib-1.0, gir1.2-glib-2.0 (>= 1.35.9), gir1.2-gnomedesktop-3.0, gir1.2-gtk-3.0 (>= 3.11.4), gir1.2-gweather-3.0 (>= 3.17.2), gjs (>= 1.49.4), libglib2.0-bin (>= 2.40), dconf-gsettings-backend | gsettings-backend
Replaces: gnome-weather
Conflicts: gnome-weather
Provides: gnome-weather (= 3.36.1-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Weather
Description: access current conditions and forecasts
 GNOME Weather ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Current conditions and forecasts for a city
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-weather-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
if "org.gnome.Weather-128.png" in out or "128x128/apps/org.gnome.Weather.png" in out:
    raise SystemExit("PACKED_RASTER_OR_INVENTED_PNG")
need = [
    "./usr/bin/gnome-weather",
    "./usr/bin/kemi-gnome-weather",
    "./opt/gnome-weather/gnome-weather",
    "./usr/share/org.gnome.Weather/org.gnome.Weather",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Weather.svg",
    "./usr/share/locale/zh_CN/LC_MESSAGES/org.gnome.Weather.mo",
    "./usr/share/dbus-1/services/org.gnome.Weather.service",
    "./usr/share/glib-2.0/schemas/org.gnome.Weather.gschema.xml",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
# official bin must remain a symlink, not a copied regular file
# dpkg-deb -c shows '->' for symlinks
if not any("usr/bin/gnome-weather" in line and "->" in line for line in out.splitlines()):
    raise SystemExit("BIN_NOT_SYMLINK")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
