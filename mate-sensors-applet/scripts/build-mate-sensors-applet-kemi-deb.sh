#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-sensors-applet 1.24.0-1 Architecture:
# arm64 as kemi-mate-sensors-applet.
# Official same-source exact-version hard
# Depends libmate-sensors-applet-plugin0
# (= 1.24.0-1) and mate-sensors-applet-common
# (= 1.24.0-1) are bundled. Official
# libmate-sensors-applet-plugin-dev is
# inspected and not packaged. Newest
# official U20 pin: focal Release universe
# only; not in focal-updates,
# focal-security, or focal-backports.
# Official GUI stanza Source field is
# absent and was not defaulted; sibling
# stanzas list Source: mate-sensors-applet.
# No Debian epoch, no tilde. When bundling
# common, its dconf-gsettings-backend |
# gsettings-backend Depends is merged into
# kemi Depends. Official lib Depends are
# already covered by the GUI Depends.
# Official different-source Depends stay
# Depends. Official Recommends hddtemp stay
# Recommends. Official Suggests
# mate-sensors-applet-nvidia stay Suggests.
# Official common Breaks/Replaces
# mate-sensors-applet (<< 1.9.0) and
# official lib Breaks/Replaces
# libmatesensorsappletplugin are kept.
# Official ELFs stay at official /usr
# paths. /opt/mate-sensors-applet/mate-sensors-applet
# is a symlink only. There is no official
# /usr/bin/mate-sensors-applet command, so
# /usr/bin/kemi-mate-sensors-applet is not
# invented. This official U20 package has
# no /usr/share/applications/*.desktop;
# official registration is via one
# .mate-panel-applet file and an already-
# absolute D-Bus service (a real panel
# applet GUI). Official applet Name=
# Hardware Sensors Monitor is kept and is
# not mall app_name. Mall app_name is
# MATE Sensors Applet (the usual
# distinctive upstream title from the
# official Description). Official common
# ships a hicolor 48×48 app PNG
# (mate-sensors-applet.png); it is packed
# at the official path. There is no
# official 128 PNG or official app SVG. A
# 128×128 evidence PNG upscaled from that
# official 48 PNG is used only as the mall
# CREATE --icon and is not packed. Official
# 139 .mo and official schemas live in
# bundled common and are packed; none of
# the .mo are invented. Official GUI
# changelog.Debian.gz is a symlink into
# the bundled lib doc dir; official
# symlink is kept after it resolves, and
# also cp -L into the kemi doc dir.
# Official common changelog is a different
# real file and is kept at the official
# path. Official Location and D-Bus Exec
# are already absolute and are kept.
# Official GUI and common have no
# maintainer scripts. Official lib
# shlibs, symbols, and ldconfig triggers
# are kept. Official GUI lintian override
# is official packaging text and is
# packed. gtk-update-icon-cache,
# glib-compile-schemas, and ldconfig hooks
# are appended (bundled public shared lib;
# no applications desktop, so no
# desktop-database). Probe: 13 unique
# aarch64 ELFs, requiredGlibc 2.17, no
# GLIBCXX; PASS vs 101. Official SHA256 +
# size matched ports.ubuntu.com and Aliyun
# ubuntu-ports (https) pool files and the
# Ubuntu 20.04 focal universe arm64 / all
# Packages stanzas. Official Homepage
# http://www.mate-desktop.org/ is copied
# exactly. No librarian URL and no
# .buildinfo this run. KEMI mall
# version_name 1.24.0-1kemi1 is 13 chars.
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-sensors-applet
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-sensors-applet
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$ROOT/upstream/mate-sensors-applet_${VER_UP}_arm64.deb"
OFF_COMMON="$ROOT/upstream/mate-sensors-applet-common_${VER_UP}_all.deb"
OFF_LIB="$ROOT/upstream/libmate-sensors-applet-plugin0_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$UNPACK/lib" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/lib/mate-sensors-applet/mate-sensors-applet" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -f "$UNPACK/common/usr/share/icons/hicolor/48x48/apps/mate-sensors-applet.png" ]; then
  rm -rf "$UNPACK/common"; mkdir -p "$UNPACK/common"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
fi
if [ ! -f "$UNPACK/lib/usr/lib/aarch64-linux-gnu/libmate-sensors-applet-plugin.so.0.0.0" ]; then
  rm -rf "$UNPACK/lib"; mkdir -p "$UNPACK/lib"
  dpkg-deb -x "$OFF_LIB" "$UNPACK/lib"
  dpkg-deb -e "$OFF_LIB" "$UNPACK/lib/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/common/." "$STAGE/pkg/"
cp -a "$UNPACK/lib/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
# official lib packaging metadata
cp -a "$UNPACK/lib/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$UNPACK/lib/DEBIAN/symbols" "$STAGE/pkg/DEBIAN/symbols"
cp -a "$UNPACK/lib/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

mkdir -p "$STAGE/pkg/opt/mate-sensors-applet"
ln -s /usr/lib/mate-sensors-applet/mate-sensors-applet \
  "$STAGE/pkg/opt/mate-sensors-applet/mate-sensors-applet"
test -x "$STAGE/pkg/usr/lib/mate-sensors-applet/mate-sensors-applet"
test -L "$STAGE/pkg/opt/mate-sensors-applet/mate-sensors-applet"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmate-sensors-applet-plugin.so.0.0.0"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmate-sensors-applet-plugin.so.0"
if [ -e "$STAGE/pkg/usr/bin/kemi-mate-sensors-applet" ] || [ -e "$STAGE/pkg/usr/bin/mate-sensors-applet" ]; then
  echo "INVENTED_OR_UNEXPECTED_LAUNCHER" >&2
  exit 1
fi
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.sensors-applet.gschema.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/mate-sensors-applet.png"
test -f "$STAGE/pkg/usr/share/mate-panel/applets/org.mate.applets.SensorsApplet.mate-panel-applet"
test -f "$STAGE/pkg/usr/share/lintian/overrides/mate-sensors-applet"
if find "$STAGE/pkg/usr/share/applications" -name '*.desktop' 2>/dev/null | grep -q .; then
  echo "UNEXPECTED_DESKTOP" >&2
  exit 1
fi

# official GUI changelog symlink into bundled lib must resolve
test -L "$STAGE/pkg/usr/share/doc/mate-sensors-applet/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/mate-sensors-applet/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libmate-sensors-applet-plugin0/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libmate-sensors-applet-plugin0/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/mate-sensors-applet-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-sensors-applet-common/changelog.Debian.gz"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 139

python3 - << 'PYAPP'
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-sensors-applet/stage/pkg/usr/share/mate-panel/applets/org.mate.applets.SensorsApplet.mate-panel-applet")
t = p.read_text()
assert "Name=Hardware Sensors Monitor" in t
assert "Icon=mate-sensors-applet" in t
assert "Location=/usr/lib/mate-sensors-applet/mate-sensors-applet" in t
assert r"\1" not in t
svc = Path("/workspace/t142-20261112-mate-sensors-applet/stage/pkg/usr/share/dbus-1/services/org.mate.panel.applet.SensorsAppletFactory.service").read_text()
assert "Exec=/usr/lib/mate-sensors-applet/mate-sensors-applet" in svc
print("applet_and_dbus_ok")
PYAPP

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-sensors-applet/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-sensors-applet/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-sensors-applet (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-sensors-applet 1.24.0-1 arm64,
    KEMI mall linuxpkg repack, bundling
    official same-source exact-version
    libmate-sensors-applet-plugin0 and
    mate-sensors-applet-common (= 1.24.0-1).
    Official ELF stays under /usr.
    Official applet Name=Hardware Sensors
    Monitor kept; mall app_name=MATE
    Sensors Applet.
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
if command -v ldconfig >/dev/null 2>&1; then
	ldconfig
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
	if command -v ldconfig >/dev/null 2>&1; then
		ldconfig
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"
grep -q '\[ "$1" = "remove" \]' "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'mate-sensors-applet-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.9), libgtk-3-0 (>= 3.21.4), libmate-panel-applet-4-1 (>= 1.18), libnotify4 (>= 0.7.0), libsensors5 (>= 1:3.5.0), dconf-gsettings-backend | gsettings-backend
Recommends: hddtemp
Suggests: mate-sensors-applet-nvidia
Provides: mate-sensors-applet (= ${VER_UP}), mate-sensors-applet-common (= ${VER_UP}), libmate-sensors-applet-plugin0 (= ${VER_UP})
Conflicts: mate-sensors-applet, mate-sensors-applet-common, libmate-sensors-applet-plugin0
Replaces: mate-sensors-applet, mate-sensors-applet-common, libmate-sensors-applet-plugin0, mate-sensors-applet (<< 1.9.0), libmatesensorsappletplugin
Breaks: mate-sensors-applet (<< 1.9.0), libmatesensorsappletplugin
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Display readings from hardware sensors in your MATE panel
 MATE Sensors Applet 1.24.0-1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-sensors-applet, bundling official
 mate-sensors-applet-common and
 libmate-sensors-applet-plugin0. Official
 ELF stays under /usr. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

grep -q '^Homepage: http://www.mate-desktop.org/$' "$STAGE/pkg/DEBIAN/control"
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"
grep -q 'dconf-gsettings-backend | gsettings-backend' "$STAGE/pkg/DEBIAN/control"
grep -q 'libsensors5 (>= 1:3.5.0)' "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-sensors-applet/stage/pkg")
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
p = Path("/workspace/t142-20261112-mate-sensors-applet/debs/kemi-mate-sensors-applet_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-sensors-applet/upstream/mate-sensors-applet_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-sensors-applet-control.txt"

python3 - "$OUT" << 'PYLIST'
import subprocess, sys
out = subprocess.check_output(["dpkg-deb", "-c", sys.argv[1]], text=True)
bad = [ln for ln in out.splitlines() if any(s in ln for s in (
    "mate-sensors-applet-128", "humanity-icon-theme", "libmate-sensors-applet-plugin-dev"))]
if bad:
    raise SystemExit("PACKED_BAD:" + repr(bad))
if any("usr/bin/kemi-mate-sensors-applet" in ln for ln in out.splitlines()):
    raise SystemExit("INVENTED_LAUNCHER_PACKED")
if any("usr/share/applications/" in ln and ln.endswith(".desktop") for ln in out.splitlines()):
    raise SystemExit("INVENTED_DESKTOP_PACKED")
assert any("usr/share/icons/hicolor/48x48/apps/mate-sensors-applet.png" in ln for ln in out.splitlines())
assert any("usr/share/mate-panel/applets/org.mate.applets.SensorsApplet.mate-panel-applet" in ln for ln in out.splitlines())
assert any("libmate-sensors-applet-plugin.so.0.0.0" in ln for ln in out.splitlines())
print("evidence_not_packed_official_icon_lib_and_applet_kept")
PYLIST

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-sensors-applet/stage/pkg")
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
test "${#ELFS[@]}" -eq 13
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-sensors-applet.json"
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
assert gv == 13 and gn == 0
assert cmax is None
assert cv == 0 and cn == 13
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
