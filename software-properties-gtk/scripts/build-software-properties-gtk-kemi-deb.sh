#!/bin/bash
# Wrap official Ubuntu 20.04 (focal-updates
# main) software-properties-gtk 0.99.9.12
# Architecture: all as
# kemi-software-properties-gtk. Newer than
# focal Release 0.98.9 and newer than
# focal-security 0.98.9.2. Not present in
# focal-backports. Official same-source
# python3-software-properties 0.99.9.12 is
# bundled: the GUI hard Depends is
# python3-software-properties (= 0.99.9.12),
# an exact-version hard Depends. Official
# same-source software-properties-common is
# only an unversioned hard Depends of the
# GUI; multiple official focal versions
# exist, so it stays Depends and is not
# bundled (it was inspected: D-Bus backend,
# add-apt-repository, polkit). Official
# same-source software-properties-qt was
# inspected and is not packaged (different
# frontend, not a Depends of the GTK GUI).
# Different-source Depends stay Depends.
# Official Recommends
# gnome-keyring, gnome-session-bin |
# xfce4-session | mate-session-manager stay
# Recommends. Official Recommends of the
# bundled python package
# (unattended-upgrades) are merged into
# kemi Recommends. Official control has no
# Suggests. Versioned Provides:
# software-properties-gtk (= 0.99.9.12),
# python3-software-properties (= 0.99.9.12).
# No Debian epoch, no tilde. Official
# /usr/bin/software-properties-gtk is a
# Python 3 wrapper (not an ELF) and stays
# at the official path. Official files stay
# on official paths; /opt/software-properties-gtk/*
# are symlinks only. Also
# /usr/bin/kemi-software-properties-gtk →
# software-properties-gtk. Official packages
# ship no .mo (Ubuntu language-pack split);
# do not invent language packs. Official
# icons include 16/24/48/64 PNG plus
# scalable SVG (no official 256×256 PNG).
# A 128×128 PNG rasterized from the official
# scalable SVG is used only as the mall
# CREATE --icon and is not packed. Official
# in-app SVGs stay official. Official
# desktop Name=Software & Updates is kept;
# official GenericName=Software & Updates
# is kept and is not used as a distinct mall
# name; mall app_name is Software & Updates
# (the usual user-facing title in the
# official desktop, appdata <name> and
# appdata description; the README project
# title "Software Properties" is reported
# and is not used as mall app_name). Official
# Additional Drivers and Livepatch helper
# desktops keep their official Names. Official
# desktop Exec=software-properties-gtk is
# rewritten to /usr/bin/software-properties-gtk;
# already-absolute helper Exec paths are kept;
# TryExec is added. Official GUI changelog.gz
# is a symlink into the bundled python doc
# dir and is kept if it resolves after
# bundling; the real official changelog is
# also copied with cp -L into the kemi doc
# dir. Official dh_python3 postinst/prerm
# are kept and retargeted to the kemi package
# name. Icon-cache, desktop-database,
# update-mime-database and
# glib-compile-schemas hooks are appended.
# Probe: Architecture all · 0 unique packaged
# ELFs · vacuous PASS vs 101 (None-safe;
# do not invent a max from null; probe_elf.py
# is not called with no --elf). Official
# SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal-updates main arm64 Packages
# stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 0.99.9.12kemi1 is 14 chars
# (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28
# char siblings succeeded, including Vinagre
# 28). No epoch, no tilde, no shortening
# applied unless the mall later rejects 14.
# gork.bot协助开发 · Verify ≠ compile

set -euo pipefail
ROOT=/workspace/t142-20261112-software-properties-gtk
VER_UP=0.99.9.12
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-software-properties-gtk
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/software-properties-gtk_0.99.9.12_all}"
PYPKG="${PYPKG:-$ROOT/unpack-official/python3-software-properties_0.99.9.12_all}"
UP_DEB="$DL/software-properties-gtk_0.99.9.12_all.deb"
PY_DEB="$DL/python3-software-properties_0.99.9.12_all.deb"
EXPECT_SHA=7f306186ff48e58b5c6bfc14ad643426c1c8f5a53fb1ec0050a07a0ad9f743bb
EXPECT_BYTES=69052
PY_SHA=caa2084d07f6e25b73b9ac75b52d96f91124b02d7e3ffc8f311f1fafcc4d3af5
PY_BYTES=21676
python3 - << PY
s="${VER_DEB}"
assert len(s) == 14, len(s)
assert ":" not in s, s
assert "~" not in s, s
assert s == "0.99.9.12kemi1"
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$PY_DEB"
test "$(stat -c%s "$PY_DEB")" = "$PY_BYTES"
echo "$PY_SHA  $PY_DEB" | sha256sum -c -
test -f "$UNPACK/usr/bin/software-properties-gtk"
test ! -L "$UNPACK/usr/bin/software-properties-gtk"
python3 - << PY
from pathlib import Path
launcher = Path("$UNPACK/usr/bin/software-properties-gtk")
head = launcher.read_bytes()[:80]
assert head.startswith(b"#!/usr/bin/python3"), head[:40]
assert launcher.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_launcher_is_python_not_elf")
PY
test -f "$UNPACK/usr/share/applications/software-properties-gtk.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/software-properties.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/software-properties.png"
test -f "$PYPKG/usr/share/doc/python3-software-properties/changelog.gz"
test ! -L "$PYPKG/usr/share/doc/python3-software-properties/changelog.gz"
test -L "$UNPACK/usr/share/doc/software-properties-gtk/changelog.gz"
test ! -e "$UNPACK/usr/share/doc/software-properties-gtk/changelog.gz"
test -f "$ROOT/evidence/software-properties-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib, re
ev = Path("$ROOT/evidence/software-properties-128.png")
data = ev.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128)
assert hashlib.sha256(data).hexdigest() == "9a3c448c643c9a8ae9bb23547f399d7f878cc69bf6c8d8637d3707be2ed612da"
assert ev.stat().st_size == 13215
svg = Path("$UNPACK/usr/share/icons/hicolor/scalable/apps/software-properties.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "d92f2c558c9d497c8878f1c4fb0dc4136caa4ee13b4773933ff9b0e0c27180e1"
assert svg.stat().st_size == 20746
assert list(Path("$UNPACK").rglob("*.mo")) == []
assert list(Path("$PYPKG").rglob("*.mo")) == []
desk = Path("$UNPACK/usr/share/applications/software-properties-gtk.desktop").read_text()
assert re.search(r"^Name=Software & Updates\s*$", desk, flags=re.M)
assert re.search(r"^GenericName=Software & Updates\s*$", desk, flags=re.M)
assert re.search(r"^Icon=software-properties\s*$", desk, flags=re.M)
chg = Path("$PYPKG/usr/share/doc/python3-software-properties/changelog.gz")
assert hashlib.sha256(chg.read_bytes()).hexdigest() == "7dbf269e31176664d39ff4247ef058d6c46a72a86b649584ff445718453f3e30"
assert chg.stat().st_size == 1145
print("official_icons_desktop_changelog_ok")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/software-properties-gtk"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
cp -a "$PYPKG/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/software-properties-gtk"

# Official GUI changelog symlink into bundled python doc must resolve
test -L "$STAGE/pkg/usr/share/doc/software-properties-gtk/changelog.gz"
test -e "$STAGE/pkg/usr/share/doc/software-properties-gtk/changelog.gz"
test -f "$STAGE/pkg/usr/share/doc/python3-software-properties/changelog.gz"
# do not pack unbundled common
test ! -e "$STAGE/pkg/usr/bin/add-apt-repository"
test ! -d "$STAGE/pkg/usr/share/doc/software-properties-common"
test ! -e "$STAGE/pkg/etc/dbus-1/system.d/com.ubuntu.SoftwareProperties.conf"

# 0-ELF vacuous probe: do not call probe_elf.py with no --elf
REPORT="$ROOT/probe/kemi-software-properties-gtk.json"
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
test "${#ELFS[@]}" = 0
python3 - << PY
import json
from pathlib import Path
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "note": "0 unique packaged ELFs (official launcher is Python 3, Architecture: all); vacuous PASS vs 101. None-safe: no requiredGlibc/requiredGlibcxx values exist, so none are ranked as a max.",
    "n_elf": 0,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
# None-safe assertion: do not invent a max from an empty/null set
files = report["files"]
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
if any(v is None for v in glibcs) or any(v is None for v in cxxs):
    # none should exist in this 0-ELF report
    raise SystemExit("PROBE_UNEXPECTED_NULL_IN_EMPTY")
if files:
    raise SystemExit("PROBE_UNEXPECTED_FILES")
if not report["configuredLimitsSatisfied"]:
    raise SystemExit("PROBE_FAIL")
print("PROBE_PASS n_elf=0 vacuous Architecture:all Python official launcher; None-safe (0 versioned, 0 null; no max invented) configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/software-properties.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/64x64/apps/software-properties.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/software-properties.png"
if find "$STAGE/pkg" -name 'software-properties-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/com.ubuntu.SoftwareProperties.gschema.xml"
test -f "$STAGE/pkg/usr/share/mime/packages/apt.xml"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/software-properties-gtk/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
# official symlink is kept because it now resolves; also copy real changelog
cp --remove-destination -L \
  "$PYPKG/usr/share/doc/python3-software-properties/changelog.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
from pathlib import Path
import hashlib
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "7dbf269e31176664d39ff4247ef058d6c46a72a86b649584ff445718453f3e30"
print("kemi_changelog_from_python_ok")
# official symlink still present and resolves to same bytes
link = Path("$STAGE/pkg/usr/share/doc/software-properties-gtk/changelog.gz")
assert link.is_symlink()
assert link.exists()
assert link.read_bytes() == p.read_bytes()
print("official_gui_changelog_symlink_resolves")
PY

export STAGE_APPS="$STAGE/pkg/usr/share/applications"
python3 - << 'PY'
import os, re
from pathlib import Path
src_dir = Path("/workspace/t142-20261112-software-properties-gtk/unpack-official/software-properties-gtk_0.99.9.12_all/usr/share/applications")
out_dir = Path(os.environ["STAGE_APPS"])

def rewrite(name, expect_name=None, relative_exec=None, already_absolute=None):
    text = (src_dir / name).read_text()
    if expect_name and not re.search(r"^Name=" + re.escape(expect_name) + r"\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_NAME:" + name)
    if re.search(r"^TryExec=", text, flags=re.M):
        raise SystemExit("DESKTOP_TRYEXEC_ALREADY:" + name)
    out = []
    inserted = False
    for line in text.splitlines(True):
        if line.startswith("Exec="):
            rest = line[len("Exec="):]
            if already_absolute:
                if not rest.startswith("/usr/bin/software-properties-gtk"):
                    raise SystemExit("DESKTOP_ABS_UNEXPECTED:" + name + ":" + line)
                out.append(line)
            else:
                if not rest.startswith("software-properties-gtk"):
                    raise SystemExit("DESKTOP_REL_UNEXPECTED:" + name + ":" + line)
                line = "Exec=/usr/bin/" + rest
                out.append(line)
            if not inserted:
                out.append("TryExec=/usr/bin/software-properties-gtk\n")
                inserted = True
        else:
            out.append(line)
    text = "".join(out)
    if not re.search(r"^Exec=/usr/bin/software-properties-gtk(?:\s|$)", text, flags=re.M):
        raise SystemExit("DESKTOP_REWRITE_FAIL:" + name)
    if text.count("TryExec=/usr/bin/software-properties-gtk") != 1:
        raise SystemExit("DESKTOP_TRYEXEC_COUNT:" + name)
    if r"\1" in text:
        raise SystemExit("DESKTOP_LITERAL_GROUP:" + name)
    for line in text.splitlines():
        if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/software-properties-gtk"):
            raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + name + ":" + line)
        if line.startswith("TryExec=") and line != "TryExec=/usr/bin/software-properties-gtk":
            raise SystemExit("DESKTOP_BAD_TRYEXEC:" + name + ":" + line)
    (out_dir / name).write_text(text)
    print("desktop_rewritten", name)

rewrite("software-properties-gtk.desktop", expect_name="Software & Updates", already_absolute=False)
rewrite("software-properties-drivers.desktop", expect_name="Additional Drivers", already_absolute=True)
rewrite("software-properties-livepatch.desktop", expect_name="Livepatch", already_absolute=True)
# main desktop still has GenericName
text = (out_dir / "software-properties-gtk.desktop").read_text()
if not re.search(r"^GenericName=Software & Updates\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERIC_LOST")
if not re.search(r"^Icon=software-properties\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ICON")
print("all_desktops_ok")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-software-properties-gtk/scripts/build-software-properties-gtk-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/software-properties-gtk\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/software-properties-gtk "$STAGE/pkg/opt/software-properties-gtk/software-properties-gtk"
ln -sf software-properties-gtk "$STAGE/pkg/usr/bin/kemi-software-properties-gtk"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".xpm", ".woff", ".svg"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        bad.append(("elf", str(p)))
        continue
    text = raw.decode("utf-8", "replace")
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "x86_64" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-software-properties-gtk (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    software-properties-gtk 0.99.9.12 all,
    KEMI mall linuxpkg repack. Newer than
    focal Release 0.98.9 and focal-security
    0.98.9.2. Official same-source
    python3-software-properties 0.99.9.12
    bundled (exact-version hard Depends).
    Official same-source
    software-properties-common stays Depends
    (unversioned; multiple focal versions).
    Different-source Depends stay Depends.
    Official Recommends stay Recommends;
    bundled python Recommends
    unattended-upgrades merged. No Suggests.
    Versioned Provides:
    software-properties-gtk /
    python3-software-properties
    (= 0.99.9.12). No Debian epoch, no
    tilde. Official Python launcher stays at
    the official path; /opt/software-properties-gtk/*
    are symlinks. Also
    /usr/bin/kemi-software-properties-gtk →
    software-properties-gtk. Official
    desktop Name=Software & Updates kept;
    mall app_name is Software & Updates;
    Exec rewritten to
    /usr/bin/software-properties-gtk;
    TryExec added. Official changelog
    symlink into bundled python doc is kept
    (resolves); real official changelog also
    copied with cp -L. Official icons are
    SVG plus small PNGs (no 256); a 128
    evidence PNG is CREATE-only and is not
    packed. Official packages ship no .mo;
    none invented. Official dh_python3 hooks
    retargeted to the kemi package name.
    Icon-cache, desktop-database,
    mime-database and glib-compile-schemas
    hooks appended. gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 03:34:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Software & Updates — official Ubuntu 20.04
(focal-updates main) software-properties-gtk
0.99.9.12 Architecture: all, KEMI repack.
Official /usr/bin/software-properties-gtk is
a Python 3 wrapper and stays under /usr.
/opt/software-properties-gtk/* are symlinks.
Official same-source python3-software-properties
0.99.9.12 is bundled (exact-version hard
Depends). Official software-properties-common
stays Depends. Different-source Depends stay
Depends. Official Recommends stay Recommends.
Official packages ship no .mo. Official icons
include small PNGs and a scalable SVG; a 128
evidence PNG is used only as mall CREATE --icon
and is not packed. Official desktop
Name=Software & Updates; mall app_name is
Software & Updates. No Debian epoch, no tilde.
Probe: 0 unique ELF (Architecture: all, official
launcher is Python); vacuous PASS vs Ubuntu
20.04 / glibc 2.31; None-safe (no max invented
from null). Official publication: Ubuntu 20.04
focal-updates main software-properties-gtk
0.99.9.12 (all). Official SHA256 + size matched
ports.ubuntu.com pool files and the Packages
stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: ubuntu-advantage-desktop-daemon, ubuntu-advantage-tools (>= 27.11~), gir1.2-gtk-3.0, libgtk3-perl, python3, python3-dateutil, python3-distro-info, python3-gi, python3-requests-unixsocket, software-properties-common, ubuntu-drivers-common (>= 1:0.2.75), dconf-gsettings-backend | gsettings-backend, python3:any, gpg, iso-codes, lsb-release, python3-apt (>= 0.6.20ubuntu16)
Recommends: gnome-keyring, gnome-session-bin | xfce4-session | mate-session-manager, unattended-upgrades
Replaces: software-properties-gtk, python3-software-properties
Conflicts: software-properties-gtk, python3-software-properties
Provides: software-properties-gtk (= 0.99.9.12), python3-software-properties (= 0.99.9.12)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: manage the repositories that you install software from (gtk)
 Software & Updates ${VER_UP} — official Ubuntu
 20.04 all, KEMI repack. Bundles official
 python3-software-properties.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Official dh_python3 hooks retargeted to the kemi package name,
# then icon/desktop/mime/gschema hooks appended.
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi package name):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-software-properties-gtk 
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-software-properties-gtk  || true
fi

# End automatically added section

if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
	if command -v update-icon-caches >/dev/null 2>&1; then
		update-icon-caches /usr/share/icons/hicolor || true
	elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q /usr/share/icons/hicolor || true
	fi
	if command -v update-mime-database >/dev/null 2>&1; then
		update-mime-database /usr/share/mime >/dev/null 2>&1 || true
	fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
HOOK
cat > "$STAGE/pkg/DEBIAN/prerm" << 'HOOK'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi package name):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-software-properties-gtk 
else
	dpkg -L kemi-software-properties-gtk | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi

# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"
grep -q 'py3compile -p kemi-software-properties-gtk' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-software-properties-gtk' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'dpkg -L kemi-software-properties-gtk' "$STAGE/pkg/DEBIAN/prerm"
! grep -q 'py3compile -p software-properties-gtk' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p python3-software-properties' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'dpkg -L software-properties-gtk' "$STAGE/pkg/DEBIAN/prerm"
! grep -q 'dpkg -L python3-software-properties' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-mime-database' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'Version: 0.99.9.12kemi1' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'python3-software-properties (= 0.99.9.12)' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'software-properties-gtk (= 0.99.9.12)' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'software-properties-common' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'ubuntu-advantage-tools (>= 27.11~)' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'python3-apt (>= 0.6.20ubuntu16)' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'Recommends: gnome-keyring' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
grep -q 'unattended-upgrades' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-software-properties-gtk-control.txt"
# bundled python must not remain a Depends
! grep -q 'python3-software-properties' <(grep -E '^ Depends:' "$ROOT/evidence/kemi-software-properties-gtk-control.txt")
python3 - << PY
from pathlib import Path
text = Path("$ROOT/evidence/kemi-software-properties-gtk-control.txt").read_text()
assert "Provides:" in text
assert "software-properties-gtk (= 0.99.9.12)" in text
assert "python3-software-properties (= 0.99.9.12)" in text
print("provides_ok")
PY

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
desk = Path("$CHECK/usr/share/applications/software-properties-gtk.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if not re.search(r"^Name=Software & Updates\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_NAME")
if not re.search(r"^Exec=/usr/bin/software-properties-gtk\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/software-properties-gtk" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=software-properties-gtk\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
drivers = Path("$CHECK/usr/share/applications/software-properties-drivers.desktop").read_text()
if r"\1" in drivers:
    raise SystemExit("BUILT_DRIVERS_GROUP")
if not re.search(r"^Name=Additional Drivers\s*$", drivers, flags=re.M):
    raise SystemExit("BUILT_DRIVERS_NAME")
if not re.search(r"^Exec=/usr/bin/software-properties-gtk --open-tab=4\s*$", drivers, flags=re.M):
    raise SystemExit("BUILT_DRIVERS_EXEC")
live = Path("$CHECK/usr/share/applications/software-properties-livepatch.desktop").read_text()
if not re.search(r"^Name=Livepatch\s*$", live, flags=re.M):
    raise SystemExit("BUILT_LIVE_NAME")
if not re.search(r"^Exec=/usr/bin/software-properties-gtk --open-tab=6\s*$", live, flags=re.M):
    raise SystemExit("BUILT_LIVE_EXEC")
print("built_desktops_ok")
# launcher is python, not ELF
head = Path("$CHECK/usr/bin/software-properties-gtk").read_bytes()[:80]
assert head.startswith(b"#!/usr/bin/python3")
assert Path("$CHECK/usr/bin/software-properties-gtk").read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("built_launcher_python_ok")
PY
test -x "$CHECK/usr/bin/software-properties-gtk"
test -L "$CHECK/usr/bin/kemi-software-properties-gtk"
test "$(readlink "$CHECK/usr/bin/kemi-software-properties-gtk")" = "software-properties-gtk"
test -L "$CHECK/opt/software-properties-gtk/software-properties-gtk"
test "$(readlink "$CHECK/opt/software-properties-gtk/software-properties-gtk")" = "/usr/bin/software-properties-gtk"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/software-properties.svg"
test -f "$CHECK/usr/share/icons/hicolor/64x64/apps/software-properties.png"
test ! -f "$CHECK/usr/share/icons/hicolor/256x256/apps/software-properties.png"
if find "$CHECK" -name 'software-properties-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test -L "$CHECK/usr/share/doc/software-properties-gtk/changelog.gz"
test -e "$CHECK/usr/share/doc/software-properties-gtk/changelog.gz"
test -f "$CHECK/usr/share/doc/python3-software-properties/changelog.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test ! -e "$CHECK/usr/bin/add-apt-repository"
test -d "$CHECK/usr/lib/python3/dist-packages/softwareproperties/gtk"
test -f "$CHECK/usr/lib/python3/dist-packages/softwareproperties/SoftwareProperties.py"
# hash the published deb by explicit path, never find|head
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
