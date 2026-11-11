#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# update-manager 1:20.04.10.24 Architecture: all
# as kemi-update-manager, bundling official
# same-source exact-version hard Depends
# update-manager-core (= 1:20.04.10.24) and
# that package's official exact-version
# same-source hard Depends
# python3-update-manager (= 1:20.04.10.24).
# Newer than focal Release 1:20.04.9; not in
# focal-security or focal-backports. Debian
# epoch 1: is omitted from mall version_name
# and the deb filename, and kept in dpkg
# Version. Official different-source Depends
# stay Depends, unbundled. Official Recommends
# stay Recommends (software-properties-gtk,
# python3-launchpadlib, and bundled core's
# libpam-modules). Official Suggests stay
# Suggests (gir typelibs). Official
# python3-update-manager Suggests
# python3-launchpadlib is already a GUI
# Recommends and stays Recommends. Versioned
# Provides: update-manager, update-manager-core
# and python3-update-manager
# (= 1:20.04.10.24). Official user-facing
# launcher /usr/bin/update-manager is a Python
# 3 wrapper (not an ELF) and stays at the
# official path, as do bundled
# /usr/bin/hwe-support-status and
# /usr/bin/ubuntu-security-status.
# /opt/update-manager/* are symlinks only.
# Also /usr/bin/kemi-update-manager →
# update-manager. Official packages ship no
# .mo (Ubuntu language-pack split); invent
# none. Official package ships no app icon
# (desktop Icon is the theme name
# system-software-update). A 128×128 evidence
# PNG rasterized from official Ubuntu 20.04
# humanity-icon-theme 0.6.15
# system-software-update.svg via Chrome
# headless --default-background-color=00000000
# lives at evidence/system-software-update-128.png
# and is used only as the mall CREATE --icon;
# it is not shipped in the deb. The theme
# package is not bundled. Official help figure
# PNGs stay official and are not mall icons.
# Official GUI and core changelog.gz are
# symlinks into bundled
# python3-update-manager and are kept (they
# resolve after bundling); the real official
# changelog is also copied with cp -L into
# the kemi doc dir. Official desktop
# Name=Software Updater is kept; official
# GenericName=Software Updates stays in the
# desktop file and is not used as mall
# app_name. Official desktop Exec is already
# /usr/bin/update-manager and is kept;
# TryExec is added. Official dh_python3
# postinst/prerm are retargeted to
# kemi-update-manager (py3compile / py3clean /
# dpkg -L). Icon-cache is not required (no
# packaged app icon); desktop-database and
# glib-compile-schemas hooks are appended.
# Probe: Architecture all · 0 unique packaged
# ELFs · vacuous PASS vs 101 (None-safe;
# do not invent a max from null; probe_elf.py
# is not called with no --elf). Official
# SHA256 + size of all three official debs
# matched official ports.ubuntu.com and Aliyun
# ubuntu-ports pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza
# (streamed; arch:all appears in the arm64
# index). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI mall
# version_name 20.04.10.24kemi1 is 16 chars
# (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28
# char siblings succeeded). Epoch omitted
# from version_name; no tilde; no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-update-manager
VER_UP=20.04.10.24
VER_DEB="${VER_UP}kemi1"
VER_DPKG="1:${VER_DEB}"
ARCH=all
PKG=kemi-update-manager
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/update-manager}"
UNPACK_CORE="${UNPACK_CORE:-$ROOT/unpack-official/update-manager-core}"
UNPACK_PY="${UNPACK_PY:-$ROOT/unpack-official/python3-update-manager}"
GUI_DEB="$DL/update-manager_20.04.10.24_all.deb"
CORE_DEB="$DL/update-manager-core_20.04.10.24_all.deb"
PY_DEB="$DL/python3-update-manager_20.04.10.24_all.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 16, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
print("dpkg_version", "${VER_DPKG}")
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 552272
echo "2d9fd2358b5245ab0358b3d141460734a5c5dd9b8cf4ed771c6704a345cce78d  $GUI_DEB" | sha256sum -c -
test -f "$CORE_DEB" && test "$(stat -c%s "$CORE_DEB")" = 11588
echo "4340e6f153f5f4d4d1ff855faf28df631da20f7a0ca73d3c0e834a5aad589b1d  $CORE_DEB" | sha256sum -c -
test -f "$PY_DEB" && test "$(stat -c%s "$PY_DEB")" = 38520
echo "81241ac59c7fc26053a14abde997dde34029f0d8cbd8f62e8df77fe6623884b4  $PY_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/update-manager"
test -x "$UNPACK_CORE/usr/bin/hwe-support-status"
test -x "$UNPACK_CORE/usr/bin/ubuntu-security-status"
python3 - << PY
from pathlib import Path
for rel in [
    "$UNPACK_GUI/usr/bin/update-manager",
    "$UNPACK_CORE/usr/bin/hwe-support-status",
    "$UNPACK_CORE/usr/bin/ubuntu-security-status",
]:
    p = Path(rel)
    assert not p.is_symlink()
    first = p.read_bytes().splitlines()[0]
    assert b"python3" in first, first
    assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_python_wrappers_ok")
PY
test -f "$UNPACK_GUI/usr/share/applications/update-manager.desktop"
test ! -d "$UNPACK_GUI/usr/share/icons"
test ! -L "$UNPACK_PY/usr/share/doc/python3-update-manager/changelog.gz"
test -f "$UNPACK_PY/usr/share/doc/python3-update-manager/changelog.gz"
test -L "$UNPACK_GUI/usr/share/doc/update-manager/changelog.gz"
test -L "$UNPACK_CORE/usr/share/doc/update-manager-core/changelog.gz"
test -f "$ROOT/evidence/system-software-update-128.png"
test -f "$ROOT/evidence/system-software-update.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/system-software-update-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "653115a22649c45e6397c4623b5eecf3ff4299080c51314527b0ce9d872e61e5"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/system-software-update.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "8e017caa7e9db658d2a8344a1ef69e8caec458106b8271344e61e50cdcb78410"
mos = list(Path("$UNPACK_GUI").rglob("*.mo")) + list(Path("$UNPACK_CORE").rglob("*.mo")) + list(Path("$UNPACK_PY").rglob("*.mo"))
assert mos == [], mos
print("official_mo_0_none_invented")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/update-manager"

cp -a "$UNPACK_PY/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_CORE/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
if [ -d "$UNPACK_CORE/var" ]; then
  mkdir -p "$STAGE/pkg/var"
  cp -a "$UNPACK_CORE/var/." "$STAGE/pkg/var/"
fi
chmod 0755 "$STAGE/pkg/usr/bin/update-manager" \
  "$STAGE/pkg/usr/bin/hwe-support-status" \
  "$STAGE/pkg/usr/bin/ubuntu-security-status"

# official changelog symlinks must resolve after bundling python3-update-manager
test -L "$STAGE/pkg/usr/share/doc/update-manager/changelog.gz"
test -e "$STAGE/pkg/usr/share/doc/update-manager/changelog.gz"
test -L "$STAGE/pkg/usr/share/doc/update-manager-core/changelog.gz"
test -e "$STAGE/pkg/usr/share/doc/update-manager-core/changelog.gz"
test -f "$STAGE/pkg/usr/share/doc/python3-update-manager/changelog.gz"
test ! -d "$STAGE/pkg/usr/share/icons"
# theme evidence must not be staged
if find "$STAGE/pkg" -name 'system-software-update-128.png' -o -name 'system-software-update.svg' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0

# 0-ELF vacuous probe: do not call probe_elf.py with no --elf
REPORT="$ROOT/probe/kemi-update-manager.json"
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
    "note": "0 unique packaged ELFs (official launchers are Python 3, Architecture: all); vacuous PASS vs 101. None-safe: no requiredGlibc/requiredGlibcxx values exist, so none are ranked as a max.",
    "n_elf": 0,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
files = report["files"]
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
if any(v is None for v in glibcs) or any(v is None for v in cxxs):
    raise SystemExit("PROBE_UNEXPECTED_NULL_IN_EMPTY")
if files:
    raise SystemExit("PROBE_UNEXPECTED_FILES")
if not report["configuredLimitsSatisfied"]:
    raise SystemExit("PROBE_FAIL")
print("PROBE_PASS n_elf=0 vacuous Architecture:all Python official launchers; None-safe (0 versioned, 0 null; no max invented) configuredLimitsSatisfied=true")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/update-manager/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_PY/usr/share/doc/python3-update-manager/changelog.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "a9553fe4a57305a12e056ce96ec599efa1c5dd407c676761e3282df4ffd773ac"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/update-manager.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/update-manager.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Software Updater\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^GenericName=Software Updates\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERICNAME")
if not re.search(r"^Exec=/usr/bin/update-manager\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
# official Exec is already absolute; keep it and add TryExec
text = re.sub(
    r"^Exec=/usr/bin/update-manager.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/update-manager",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/update-manager" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/update-manager" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/update-manager"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/update-manager":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_kept_absolute_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-update-manager/scripts/build-update-manager-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/update-manager\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/update-manager" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/update-manager "$STAGE/pkg/opt/update-manager/update-manager"
ln -sf /usr/bin/hwe-support-status "$STAGE/pkg/opt/update-manager/hwe-support-status"
ln -sf /usr/bin/ubuntu-security-status "$STAGE/pkg/opt/update-manager/ubuntu-security-status"
ln -sf update-manager "$STAGE/pkg/usr/bin/kemi-update-manager"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg"}:
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
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        bad.append(("bin", str(p)))
        continue
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

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-update-manager (${VER_DPKG}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    update-manager 1:20.04.10.24 all, KEMI mall
    linuxpkg repack. Bundles official
    same-source exact-version
    update-manager-core (= 1:20.04.10.24) and
    python3-update-manager (= 1:20.04.10.24).
    Official different-source Depends stay
    Depends. Official Recommends stay
    Recommends. Official Suggests stay
    Suggests. Versioned Provides for the three
    official packages (= 1:20.04.10.24).
    Official /usr/bin/update-manager stays at
    the official path; /opt/update-manager/*
    are symlinks. Also
    /usr/bin/kemi-update-manager →
    update-manager. Official desktop
    Name=Software Updater kept; official
    GenericName=Software Updates kept in the
    desktop file; already-absolute Exec kept;
    TryExec added. Official GUI/core changelog
    symlinks into bundled python3-update-manager
    are kept and resolve; the real official
    changelog was also copied with cp -L.
    Official package ships no app icon; a
    128×128 evidence PNG rasterized from
    official Ubuntu 20.04 humanity-icon-theme
    0.6.15 is used only as mall CREATE --icon
    and is not packed. Theme package is not
    bundled. Official package ships no .mo;
    none invented. Official dh_python3 hooks
    retargeted to kemi-update-manager;
    desktop-database and glib-compile-schemas
    hooks appended. Epoch omitted from mall
    version_name and the deb filename, kept in
    dpkg Version.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Software Updater — official Ubuntu 20.04
(focal-updates main) update-manager
1:20.04.10.24 Architecture: all, KEMI repack.
Official user-facing launcher
/usr/bin/update-manager is a Python 3 wrapper
and stays under /usr. /opt/update-manager/*
are symlinks. Bundles official same-source
exact-version update-manager-core and
python3-update-manager (= 1:20.04.10.24).
Official different-source Depends stay Depends
and are not bundled. Official Recommends stay
Recommends. Official Suggests stay Suggests.
Official packages ship no .mo (keep official;
do not invent language packs). Official
package ships no app icon (theme name
system-software-update); a 128×128 evidence
PNG rasterized from official Ubuntu 20.04
humanity-icon-theme 0.6.15 is used only as
mall CREATE --icon and is not packed. Theme
package is not bundled. Official help PNGs
stay official. Official desktop Name=Software
Updater is kept; mall app_name is Software
Updater (official desktop Name, appdata
<name>, and README title). Official
GenericName=Software Updates stays in the
desktop file. Probe: 0 unique ELF
(Architecture: all, official launchers are
Python); vacuous PASS vs Ubuntu 20.04 /
glibc 2.31; None-safe (no max invented from
null). Official publication: Ubuntu 20.04
focal-updates main update-manager
1:20.04.10.24 (all), newer than focal Release
1:20.04.9. Official SHA256 + size of all
three official debs matched ports.ubuntu.com
and Aliyun ubuntu-ports pool files and the
focal-updates main Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DPKG
Section: gnome
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: python3:any (>= 3.2~), dconf-gsettings-backend | gsettings-backend, libgtk3-perl, python3-aptdaemon.gtk3widgets (>= 1.1.1+bzr982-0ubuntu13) | synaptic, policykit-1, python3-dbus, python3-gi (>= 3.8), python3-yaml, gir1.2-gtk-3.0, gir1.2-snapd-1, ubuntu-release-upgrader-gtk, update-notifier, gnome-shell | policykit-1-gnome | polkit-kde-agent-1 | lxpolkit | lxqt-policykit | mate-polkit | polkit-1-auth-agent, python3-distro-info, distro-info-data, lsb-release, ubuntu-release-upgrader-core (>= 1:18.04.9), ubuntu-advantage-tools (>= 30~), python3-apt (>= 0.8.5~), python3-distupgrade
Recommends: software-properties-gtk (>= 0.71.2), python3-launchpadlib, libpam-modules (>= 1.0.1-9ubuntu3)
Suggests: gir1.2-dbusmenu-glib-0.4, gir1.2-unity-5.0
Breaks: update-notifier (<< 3.177), computer-janitor (<= 1.11-0ubuntu1), python3-distupgrade (<< 1:16.10.10)
Replaces: update-manager, update-manager-core, python3-update-manager
Conflicts: update-manager, update-manager-core, python3-update-manager
Provides: update-manager (= 1:20.04.10.24), update-manager-core (= 1:20.04.10.24), python3-update-manager (= 1:20.04.10.24)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: GNOME application that manages apt updates
 Software Updater ${VER_UP} — official Ubuntu
 20.04 all, KEMI repack of update-manager.
 Bundles official update-manager-core and
 python3-update-manager.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Official dh_python3 hooks retargeted to the kemi package name,
# then desktop/gschema hooks appended. Quoted heredocs so $1 is
# not expanded under set -u.
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi package name):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-update-manager -V 3.2-
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-update-manager -V 3.2- || true
fi

# End automatically added section

if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
HOOK
cat > "$STAGE/pkg/DEBIAN/prerm" << 'HOOK'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi package name):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-update-manager 
else
	dpkg -L kemi-update-manager | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi

# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"
grep -q 'py3compile -p kemi-update-manager' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-update-manager' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'dpkg -L kemi-update-manager' "$STAGE/pkg/DEBIAN/prerm"
! grep -q 'py3compile -p update-manager' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p python3-update-manager' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'dpkg -L update-manager' "$STAGE/pkg/DEBIAN/prerm"
! grep -q 'dpkg -L python3-update-manager' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
# assert filename has no epoch
echo "$DEB" | grep -q 'kemi-update-manager_20.04.10.24kemi1_all.deb'
echo "$DEB" | grep -qv ':'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'Version: 1:20.04.10.24kemi1' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'Provides: update-manager (= 1:20.04.10.24)' "$ROOT/evidence/kemi-update-manager-control.txt"
# dpkg-deb -I prints one Provides line with all names
grep -q 'update-manager-core (= 1:20.04.10.24)' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'python3-update-manager (= 1:20.04.10.24)' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'ubuntu-advantage-tools (>= 30~)' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'python3-apt (>= 0.8.5~)' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'Recommends: software-properties-gtk' "$ROOT/evidence/kemi-update-manager-control.txt"
grep -q 'Suggests: gir1.2-dbusmenu-glib-0.4' "$ROOT/evidence/kemi-update-manager-control.txt"
! grep -q 'Depends:.*update-manager-core' "$ROOT/evidence/kemi-update-manager-control.txt"
! grep -q 'Depends:.*python3-update-manager' "$ROOT/evidence/kemi-update-manager-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
import re
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/update-manager.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Software Updater" not in desk:
    raise SystemExit("BUILT_NAME")
if "GenericName=Software Updates" not in desk:
    raise SystemExit("BUILT_GENERICNAME")
if "Exec=/usr/bin/update-manager" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/update-manager" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=update-manager\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/update-manager"
python3 - << PY
from pathlib import Path
p = Path("$CHECK/usr/bin/update-manager")
assert not p.is_symlink()
assert b"python3" in p.read_bytes().splitlines()[0]
assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("built_launcher_is_python")
PY
test -L "$CHECK/usr/bin/kemi-update-manager"
test "$(readlink "$CHECK/usr/bin/kemi-update-manager")" = "update-manager"
test -L "$CHECK/opt/update-manager/update-manager"
test "$(readlink "$CHECK/opt/update-manager/update-manager")" = "/usr/bin/update-manager"
test -x "$CHECK/usr/bin/hwe-support-status"
test -x "$CHECK/usr/bin/ubuntu-security-status"
test -f "$CHECK/usr/lib/python3/dist-packages/UpdateManager/__init__.py"
test -f "$CHECK/usr/lib/python3/dist-packages/UpdateManager/UpdateManager.py"
test -d "$CHECK/var/lib/update-manager"
test -d "$CHECK/var/lib/update-notifier"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test ! -d "$CHECK/usr/share/icons"
if find "$CHECK" -name 'system-software-update-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
test -L "$CHECK/usr/share/doc/update-manager/changelog.gz"
test -e "$CHECK/usr/share/doc/update-manager/changelog.gz"
test -f "$CHECK/usr/share/doc/python3-update-manager/changelog.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
