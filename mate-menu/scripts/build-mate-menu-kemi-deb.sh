#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-menu 20.04.3-0ubuntu1 Architecture:
# all as kemi-mate-menu. This is a real
# official Python/GTK MATE panel-applet
# GUI. Official registration is via
# org.mate.panel.MateMenuApplet.mate-panel-applet
# and an already-absolute D-Bus service.
# This official U20 package has no
# /usr/share/applications/*.desktop; no
# desktop file is invented. Official
# applet Name=Advanced MATE Menu is kept
# and is not mall app_name. Mall app_name
# is MATE Menu (the usual distinctive
# upstream title). Official appdata has
# none. Newest official U20 pin: focal
# Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza
# Source field is absent and was not
# defaulted (index hits from source
# mate-menus are a different library
# source and were not copied onto kemi).
# Official Homepage
# https://github.com/ubuntu-mate/mate-menu/
# is copied exactly. No Debian epoch, no
# tilde. No exact-version same-source
# hard Depends exist to bundle. Official
# gir1.2-matemenu-2.0 (>= 1.22) is a
# different-source range and stays
# Depends. Official alternatives
# mozo | menulibre stay Depends and are
# not bundled. Official mate-menus /
# libmate-menu2 / gir / -dev packages
# (source mate-menus) are inspected and
# not packaged. Official Suggests
# software-center, synaptic stay
# Suggests. Official Recommends: none.
# Official Replaces matemenu is kept.
# Architecture: all is kept; arm64 is
# not invented. Official Python stays at
# official /usr paths. Official
# /usr/bin/mate-menu exists, so
# /opt/mate-menu/mate-menu and
# /usr/bin/kemi-mate-menu are symlinks
# only. Official Location and D-Bus Exec
# are already absolute and are kept.
# Official 163 .mo and five schemas are
# packed; none of the .mo are invented.
# Official package ships no app icon
# (applet Icon=start-here is a theme
# name); in-app search-engine PNGs are
# packed at official paths and are not
# used as the mall icon. A 128 evidence
# PNG from official U20
# humanity-icon-theme 0.6.15
# places/64/start-here.svg is used only
# as CREATE --icon and is not packed;
# the theme is not bundled. Official
# changelog and copyright are real
# files and are kept. Official
# maintainer scripts are kept and
# package-name hooks are retargeted to
# kemi-mate-menu. Official
# glib-compile-schemas is kept. No
# desktop-database (no applications
# desktop). No gtk-update-icon-cache (no
# official hicolor icons). No ldconfig.
# Vacuous 0-ELF probe PASS.
# version_name 20.04.3-0ubuntu1kemi1 is
# 21 chars. No epoch, no tilde, no
# shortening needed. gork.bot协助开发
# · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-menu
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-menu
VER_UP=20.04.3-0ubuntu1
VER_NAME=20.04.3-0ubuntu1kemi1
VER_DEB=20.04.3-0ubuntu1kemi1
ARCH=all
OFF_GUI="$ROOT/debs/ports-mate-menu_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "20.04.3-0ubuntu1kemi1"
assert len(s) == 21, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

# official maintainer scripts kept, package-name hooks retargeted
cp -a "$UNPACK/gui/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/gui/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
python3 - << 'PYRET'
from pathlib import Path
files = [
    Path("/workspace/t142-20261112-mate-menu/stage/pkg/DEBIAN/postinst"),
    Path("/workspace/t142-20261112-mate-menu/stage/pkg/DEBIAN/prerm"),
    Path("/workspace/t142-20261112-mate-menu/stage/pkg/usr/share/python3/runtime.d/mate-menu.rtupdate"),
]
for p in files:
    t = p.read_text()
    t = t.replace("py3compile -p mate-menu", "py3compile -p kemi-mate-menu")
    t = t.replace("pypy3compile -p mate-menu", "pypy3compile -p kemi-mate-menu")
    t = t.replace("py3clean -p mate-menu", "py3clean -p kemi-mate-menu")
    t = t.replace("dpkg -L mate-menu", "dpkg -L kemi-mate-menu")
    p.write_text(t)
print("scripts_retargeted")
PYRET

mkdir -p "$STAGE/pkg/opt/mate-menu"
ln -s /usr/bin/mate-menu "$STAGE/pkg/opt/mate-menu/mate-menu"
ln -s mate-menu "$STAGE/pkg/usr/bin/kemi-mate-menu"
test -x "$STAGE/pkg/usr/bin/mate-menu"
test -L "$STAGE/pkg/opt/mate-menu/mate-menu"
test -L "$STAGE/pkg/usr/bin/kemi-mate-menu"
test -f "$STAGE/pkg/usr/lib/mate-menu/mate-menu.py"
test -f "$STAGE/pkg/usr/share/mate-panel/applets/org.mate.panel.MateMenuApplet.mate-panel-applet"
test -f "$STAGE/pkg/usr/share/dbus-1/services/org.mate.panel.applet.MateMenuAppletFactory.service"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.mate-menu.gschema.xml"
test -f "$STAGE/pkg/usr/share/doc/mate-menu/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-menu/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/mate-menu/copyright"
python3 - << 'PYNODESK'
from pathlib import Path
app = Path("/workspace/t142-20261112-mate-menu/stage/pkg/usr/share/applications")
if app.exists() and any(app.rglob("*.desktop")):
    raise SystemExit("UNEXPECTED_DESKTOP")
print("no_applications_desktop")
PYNODESK
# theme / evidence must not be packed
if find "$STAGE/pkg" \( -name 'mate-menu-128.png' -o -name 'humanity-icon-theme*' -o -name 'humanity-start-here*' -o -path '*/icons/Humanity/*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi
# different-source mate-menus library must not be packed
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmate-menu.so.2"
test ! -d "$STAGE/pkg/usr/share/doc/mate-menus"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 163

python3 - << 'PYAPP'
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-menu/stage/pkg/usr/share/mate-panel/applets/org.mate.panel.MateMenuApplet.mate-panel-applet")
t = p.read_text()
assert "Name=Advanced MATE Menu" in t
assert "Icon=start-here" in t
assert "Location=/usr/lib/mate-menu/mate-menu.py" in t
assert r"\1" not in t
svc = Path("/workspace/t142-20261112-mate-menu/stage/pkg/usr/share/dbus-1/services/org.mate.panel.applet.MateMenuAppletFactory.service").read_text()
assert "Exec=/usr/lib/mate-menu/mate-menu.py" in svc
assert r"\1" not in svc
print("applet_and_dbus_ok")
PYAPP

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/mate-menu/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/mate-menu/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-menu (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-menu 20.04.3-0ubuntu1
    Architecture: all, KEMI mall linuxpkg
    repack. No exact-version same-source
    hard Depends to bundle. Official
    files stay under /usr. Official
    applet Name=Advanced MATE Menu kept;
    mall app_name=MATE Menu.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# official postinst already compiles schemas; no extra ldconfig / icon-cache / desktop-database
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"
python3 - << 'PYHOOK'
from pathlib import Path
post = Path("/workspace/t142-20261112-mate-menu/stage/pkg/DEBIAN/postinst").read_text()
prerm = Path("/workspace/t142-20261112-mate-menu/stage/pkg/DEBIAN/prerm").read_text()
rt = Path("/workspace/t142-20261112-mate-menu/stage/pkg/usr/share/python3/runtime.d/mate-menu.rtupdate").read_text()
assert "glib-compile-schemas /usr/share/glib-2.0/schemas" in post
assert "py3compile -p kemi-mate-menu" in post
assert "py3compile -p mate-menu" not in post
assert "pypy3compile -p kemi-mate-menu" in post
assert "py3compile -p kemi-mate-menu /usr/lib/mate-menu" in post
assert "ldconfig" not in post
assert "update-desktop-database" not in post
assert "py3clean -p kemi-mate-menu" in prerm
assert "dpkg -L kemi-mate-menu" in prerm
assert "dpkg -L mate-menu" not in prerm
assert "py3clean -p kemi-mate-menu /usr/lib/mate-menu" in rt
assert "py3compile -p kemi-mate-menu  /usr/lib/mate-menu" in rt
assert "py3compile -p mate-menu" not in rt
print("hooks_ok")
PYHOOK

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: python3-configobj, python3-pkg-resources, python3:any, dconf-gsettings-backend | gsettings-backend, gir1.2-matedesktop-2.0 (>= 1.20), gir1.2-matemenu-2.0 (>= 1.22), gir1.2-matepanelapplet-4.0 (>= 1.22), gir1.2-gtk-3.0, mozo | menulibre, python3 (>= 3.3), python3-gi-cairo, python3-setproctitle, python3-xdg, python3-xlib, xdg-utils, libglib2.0-bin
Suggests: software-center, synaptic
Provides: mate-menu (= ${VER_UP})
Conflicts: mate-menu
Replaces: mate-menu, matemenu
Homepage: https://github.com/ubuntu-mate/mate-menu/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Advanced MATE menu
 MATE Menu 20.04.3-0ubuntu1 — official
 Ubuntu 20.04 Architecture: all, KEMI
 repack of mate-menu. No exact-version
 same-source hard Depends were bundled.
 Official files stay under /usr.
 gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-mate-menu/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: https://github.com/ubuntu-mate/mate-menu/\n" in c
assert "Version: 20.04.3-0ubuntu1kemi1\n" in c
assert "Architecture: all\n" in c
assert "Source:" not in c
assert "Depends: python3-configobj, python3-pkg-resources, python3:any, dconf-gsettings-backend | gsettings-backend, gir1.2-matedesktop-2.0 (>= 1.20), gir1.2-matemenu-2.0 (>= 1.22), gir1.2-matepanelapplet-4.0 (>= 1.22), gir1.2-gtk-3.0, mozo | menulibre, python3 (>= 3.3), python3-gi-cairo, python3-setproctitle, python3-xdg, python3-xlib, xdg-utils, libglib2.0-bin\n" in c
assert "Suggests: software-center, synaptic\n" in c
assert "Replaces: mate-menu, matemenu\n" in c
print("control_ok")
PYCTL

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-menu/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".glade"}:
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
import hashlib, subprocess
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-menu/debs/kemi-mate-menu_20.04.3-0ubuntu1kemi1_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/bin/mate-menu" in ln and ln.startswith("-rwxr-xr-x") for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-mate-menu" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./opt/mate-menu/mate-menu" in ln for ln in out.splitlines())
assert any("./usr/share/mate-panel/applets/org.mate.panel.MateMenuApplet.mate-panel-applet" in ln for ln in out.splitlines())
assert any("./usr/lib/mate-menu/mate-menu.py" in ln for ln in out.splitlines())
assert not any("usr/share/applications/" in ln and ln.endswith(".desktop") for ln in out.splitlines())
assert not any("mate-menu-128.png" in ln for ln in out.splitlines())
assert not any("humanity-icon-theme" in ln or "Humanity/places" in ln for ln in out.splitlines())
assert not any("libmate-menu.so" in ln for ln in out.splitlines())
print("deb_contents_ok")
PYHASH

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-menu-control.txt"

python3 - << 'PYELF'
import json, shutil, subprocess
from pathlib import Path
deb = Path("/workspace/t142-20261112-mate-menu/debs/kemi-mate-menu_20.04.3-0ubuntu1kemi1_all.deb")
td = Path("/tmp/t142-mate-menu-probe-unpack")
if td.exists():
    shutil.rmtree(td)
td.mkdir()
subprocess.check_call(["dpkg-deb", "-x", str(deb), str(td)])
elfs = []
for p in td.rglob("*"):
    if p.is_file() and not p.is_symlink():
        if p.read_bytes()[:4] == b"\x7fELF":
            elfs.append(str(p))
print("ELF_COUNT", len(elfs))
assert len(elfs) == 0, elfs
report = Path("/workspace/t142-20261112-mate-menu/probe/kemi-mate-menu.json")
report.parent.mkdir(parents=True, exist_ok=True)
d = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "vacuous 0-ELF PASS: official Architecture: all Python/GTK panel-applet GUI; no packaged ELF; probe_elf.py not invoked with zero --elf",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "n_elf": 0,
    "requiredGlibc": None,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx": None,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
report.write_text(json.dumps(d, indent=2) + "\n")
print("PROBE_PASS n_elf=0 requiredGlibc=None (0 versioned, 0 null); requiredGlibcxx=None (0 versioned, 0 null, nulls not ranked as a max); configuredLimitsSatisfied=true; vacuous=yes")
PYELF

echo "BUILD_OK $OUT"
