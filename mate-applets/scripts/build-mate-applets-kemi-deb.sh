#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-applets 1.24.0-1 Architecture: arm64
# as kemi-mate-applets. Official same-source
# mate-applets-common is an exact-version
# hard Depends (= 1.24.0-1) and is bundled.
# Newest official U20 pin: focal Release
# universe only; not in focal-updates,
# focal-security, or focal-backports.
# Official GUI stanza Source field is
# absent and was not defaulted; sibling
# stanza lists Source: mate-applets. No
# Debian epoch, no tilde. When bundling
# common, its dconf-gsettings-backend |
# gsettings-backend Depends is merged
# into kemi Depends. Official different-
# source Depends stay Depends. Official
# Recommends mate-media, mate-polkit,
# mate-system-monitor stay Recommends.
# Official Suggests: none. Official GUI
# Breaks/Replaces mate-netspeed (<< 1.13.0)
# and official common Breaks/Replaces
# mate-applets (<< 1.9.0), mate-netspeed
# (<< 1.13.0), mate-netspeed-common
# (<< 1.13.0) are kept. Official ELFs
# stay at official /usr paths.
# /opt/mate-applets/mate-cpufreq-selector
# is a symlink only. There is no official
# mate-applets command, so
# /usr/bin/kemi-mate-applets is not
# invented. This official U20 package has
# no /usr/share/applications/*.desktop;
# official registration is via 13
# .mate-panel-applet files and already-
# absolute D-Bus services (a real panel
# applet GUI suite). Official Names in
# those applet files are kept and are
# not mall app_name. Mall app_name is
# MATE Applets. Official common ships
# hicolor scalable SVG app icons
# (mate-cpu-frequency-applet,
# mate-eyes-applet, mate-netspeed-applet,
# mate-sticky-notes-applet) plus raster
# sizes and in-app artwork; those official
# icons are packed at official paths.
# There is no official 128 PNG. A 128×128
# evidence PNG rasterized from the official
# packaged mate-cpu-frequency-applet.svg
# (named by official CPU Frequency Scaling
# Monitor applet Icon) is used only as the
# mall CREATE --icon and is not packed.
# Official 128 .mo and official schemas
# live in bundled common and are packed;
# none of the .mo are invented. Official
# GUI changelog.Debian.gz is a real file;
# official kept and also cp -L into the
# kemi doc dir. Official common changelog
# is a different real file and is kept at
# the official path. Official Location
# and D-Bus Exec are already absolute and
# are kept. Official GUI and common have
# no maintainer scripts. Official GUI
# conffiles kept. gtk-update-icon-cache
# and glib-compile-schemas hooks are
# appended (no applications desktop, so
# no desktop-database; no bundled shared
# lib, so no ldconfig). Probe: 14 unique
# aarch64 ELFs, requiredGlibc 2.17, no
# GLIBCXX; PASS vs 101. Official SHA256
# + size matched ports.ubuntu.com and
# Aliyun ubuntu-ports (https) pool files
# and the Ubuntu 20.04 focal universe
# arm64 / all Packages stanzas. Official
# Homepage http://www.mate-desktop.org/
# is copied exactly. No librarian URL and
# no .buildinfo this run. KEMI mall
# version_name 1.24.0-1kemi1 is 13 chars.
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-applets
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-applets
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$ROOT/upstream/mate-applets_${VER_UP}_arm64.deb"
OFF_COMMON="$ROOT/upstream/mate-applets-common_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-cpufreq-selector" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -f "$UNPACK/common/usr/share/mate-panel/applets/org.mate.applets.CPUFreqApplet.mate-panel-applet" ]; then
  rm -rf "$UNPACK/common"; mkdir -p "$UNPACK/common"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/common/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
cp -a "$UNPACK/gui/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

mkdir -p "$STAGE/pkg/opt/mate-applets"
ln -s /usr/bin/mate-cpufreq-selector "$STAGE/pkg/opt/mate-applets/mate-cpufreq-selector"
test -x "$STAGE/pkg/usr/bin/mate-cpufreq-selector"
test -x "$STAGE/pkg/usr/lib/mate-applets/mate-cpufreq-applet"
test -L "$STAGE/pkg/opt/mate-applets/mate-cpufreq-selector"
if [ -e "$STAGE/pkg/usr/bin/kemi-mate-applets" ] || [ -e "$STAGE/pkg/usr/bin/mate-applets" ]; then
  echo "INVENTED_OR_UNEXPECTED_LAUNCHER" >&2
  exit 1
fi
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.stickynotes.gschema.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/mate-cpu-frequency-applet.svg"
test -f "$STAGE/pkg/etc/sound/events/mate-battstat_applet.soundlist"
APPLET_N=$(find "$STAGE/pkg/usr/share/mate-panel/applets" -name '*.mate-panel-applet' | wc -l)
test "$APPLET_N" -eq 13
# official package has no applications desktop; do not invent one
if find "$STAGE/pkg/usr/share/applications" -name '*.desktop' 2>/dev/null | grep -q .; then
  echo "UNEXPECTED_DESKTOP" >&2
  exit 1
fi

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 128

test -f "$STAGE/pkg/usr/share/doc/mate-applets/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-applets/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/mate-applets-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-applets-common/changelog.Debian.gz"

# official applet Names kept (no rewrite of Location, already absolute)
python3 - << 'PYAPP'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-applets/stage/pkg/usr/share/mate-panel/applets")
expected = {
    "org.mate.applets.AccessxStatusApplet.mate-panel-applet": "Name=Keyboard Accessibility Status",
    "org.mate.applets.BattstatApplet.mate-panel-applet": "Name=Battery Charge Monitor",
    "org.mate.applets.CPUFreqApplet.mate-panel-applet": "Name=CPU Frequency Scaling Monitor",
    "org.mate.applets.CharpickerApplet.mate-panel-applet": "Name=Character Palette",
    "org.mate.applets.CommandApplet.mate-panel-applet": "Name=Command",
    "org.mate.applets.DriveMountApplet.mate-panel-applet": "Name=Disk Mounter",
    "org.mate.applets.GeyesApplet.mate-panel-applet": "Name=Eyes",
    "org.mate.applets.MateWeatherApplet.mate-panel-applet": "Name=Weather Report",
    "org.mate.applets.MultiLoadApplet.mate-panel-applet": "Name=System Monitor",
    "org.mate.applets.NetspeedApplet.mate-panel-applet": "Name=Network Monitor",
    "org.mate.applets.StickyNotesApplet.mate-panel-applet": "Name=Sticky Notes",
    "org.mate.applets.TimerApplet.mate-panel-applet": "Name=Timer",
    "org.mate.applets.TrashApplet.mate-panel-applet": "Name=Trash",
}
files = sorted(p.name for p in root.glob("*.mate-panel-applet"))
assert files == sorted(expected), files
for name, needle in expected.items():
    t = (root / name).read_text()
    assert needle in t, (name, needle)
    assert r"\1" not in t
    assert "Location=/usr/lib/mate-applets/" in t
print("applet_files_ok", len(expected))
PYAPP

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-applets/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-applets/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-applets (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-applets 1.24.0-1 arm64, KEMI mall
    linuxpkg repack, bundling official
    same-source exact-version
    mate-applets-common (= 1.24.0-1).
    Official ELF stays under /usr.
    Official applet Names kept; mall
    app_name=MATE Applets.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
# End automatically added section
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
	fi
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q '\[ "$1" = "remove" \]' "$STAGE/pkg/DEBIAN/postrm"
if grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"; then
  echo "UNEXPECTED_LDCONFIG" >&2
  exit 1
fi
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'mate-cpu-frequency-applet-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: gsettings-desktop-schemas, gvfs, mate-panel, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libcpufreq0 (>= 001), libdbus-glib-1-2 (>= 0.88), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libgtksourceview-3.0-1 (>= 2.91.4), libgtop-2.0-11 (>= 2.22.3), libgucharmap-2-90-7 (>= 1:3.0.0), libiw30 (>= 30~pre1), libmate-panel-applet-4-1 (>= 1.18), libmateweather1 (>= 1.18), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libpolkit-gobject-1-0 (>= 0.99), libupower-glib3 (>= 0.99.0), libwnck-3-0 (>= 2.91.6), libx11-6, libxml2 (>= 2.7.4), dconf-gsettings-backend | gsettings-backend
Recommends: mate-media, mate-polkit, mate-system-monitor
Provides: mate-applets (= ${VER_UP}), mate-applets-common (= ${VER_UP})
Conflicts: mate-applets, mate-applets-common
Replaces: mate-applets, mate-applets-common, mate-netspeed (<< 1.13.0), mate-applets (<< 1.9.0), mate-netspeed-common (<< 1.13.0)
Breaks: mate-netspeed (<< 1.13.0), mate-applets (<< 1.9.0), mate-netspeed-common (<< 1.13.0)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Various applets for the MATE panel
 MATE Applets 1.24.0-1 — official Ubuntu
 20.04 arm64, KEMI repack of mate-applets,
 bundling official mate-applets-common.
 Official ELF stays under /usr. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

grep -q '^Homepage: http://www.mate-desktop.org/$' "$STAGE/pkg/DEBIAN/control"
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"
grep -q 'dconf-gsettings-backend | gsettings-backend' "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-applets/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif"}:
        continue
    if "lintian/overrides" in str(p.as_posix()):
        continue
    if p.name in {"control", "copyright"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-applets/debs/kemi-mate-applets_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-applets/upstream/mate-applets_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-applets-control.txt"

python3 - "$OUT" << 'PYLIST'
import subprocess, sys
out = subprocess.check_output(["dpkg-deb", "-c", sys.argv[1]], text=True)
bad = [ln for ln in out.splitlines() if any(s in ln for s in (
    "mate-cpu-frequency-applet-128", "humanity-icon-theme"))]
if bad:
    raise SystemExit("PACKED_BAD:" + repr(bad))
if any("usr/bin/kemi-mate-applets" in ln for ln in out.splitlines()):
    raise SystemExit("INVENTED_LAUNCHER_PACKED")
if any("usr/share/applications/" in ln and ln.endswith(".desktop") for ln in out.splitlines()):
    raise SystemExit("INVENTED_DESKTOP_PACKED")
assert any("usr/share/icons/hicolor/scalable/apps/mate-cpu-frequency-applet.svg" in ln for ln in out.splitlines())
assert any("usr/share/mate-panel/applets/org.mate.applets.CPUFreqApplet.mate-panel-applet" in ln for ln in out.splitlines())
print("evidence_not_packed_official_icons_and_applets_kept")
PYLIST

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-applets/stage/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PYELF
)
echo "ELF_COUNT ${#ELFS[@]}"
test "${#ELFS[@]}" -eq 14
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-applets.json"
rm -f "$REPORT"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT" >/dev/null
N_ELF=${#ELFS[@]}
export N_ELF REPORT
python3 - << 'PYPROBE'
import json, os
from pathlib import Path
report = Path(os.environ["REPORT"])
n = int(os.environ["N_ELF"])
d = json.loads(report.read_text())
files = d.get("files") or []
assert len(files) == n, (len(files), n)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
gver = [v for v in glibcs if v is not None]
def verkey(s):
    return tuple(int(x) for x in s.split("."))
gmax = max(gver, key=verkey) if gver else None
cver = [v for v in cxxs if v is not None]
cmax = max(cver, key=verkey) if cver else None
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=%s requiredGlibc=%s (%s versioned, %s null); requiredGlibcxx=%s (%s versioned, %s null, nulls not ranked as a max); configuredLimitsSatisfied=true" % (n, gmax, gv, gn, cmax, cv, cn))
if cmax is not None:
    assert verkey(cmax) <= (3, 4, 28), cmax
if gmax is not None:
    assert verkey(gmax) <= (2, 31), gmax
assert gmax == "2.17"
assert gv == 14 and gn == 0
assert cmax is None
assert cv == 0 and cn == 14
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
