#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# system-config-printer 1.5.12-0ubuntu1.1
# Architecture: all as
# kemi-system-config-printer, bundling official
# same-source exact-version hard Depends
# system-config-printer-common
# (= 1.5.12-0ubuntu1.1) and
# python3-cupshelpers
# (= 1.5.12-0ubuntu1.1). Common also
# exact-version hard-Depends
# python3-cupshelpers at the same official
# updates version, already bundled.
# python3-cupshelpers has no further
# exact-version same-source Depends.
# Official same-source Recommends
# system-config-printer-udev stay
# Recommends and are not bundled
# (different-source avahi-utils also stay
# Recommends). Official Suggests
# gnome-software and (from common)
# python3-smbc stay Suggests. Transitional
# dummy system-config-printer-gnome is
# inspected and not packaged. Official
# python-cupshelpers (<= 1.5) Breaks/Replaces
# kept (old Python 2 name, not packaged).
# Newer than focal Release
# 1.5.12-0ubuntu1; not in focal-security or
# focal-backports. No Debian epoch, no tilde.
# Official user-facing launchers
# /usr/bin/system-config-printer,
# /usr/bin/system-config-printer-applet,
# /usr/bin/install-printerdriver and bundled
# /usr/bin/scp-dbus-service are bash wrappers
# (prefix=/usr, exec official Python under
# /usr/share/system-config-printer) and stay
# at official paths. /opt/system-config-printer/*
# are symlinks only. Also
# /usr/bin/kemi-system-config-printer →
# system-config-printer. Official D-Bus Exec
# /usr/bin/scp-dbus-service is already
# absolute and is kept. Official packages
# ship no .mo (Ubuntu language-pack split);
# none invented. Official desktop Icon is
# the theme name printer; official in-app
# 48×48 i-network-printer.png stays at the
# official path and is not used as the mall
# icon. A 128×128 evidence PNG rasterized
# from official Ubuntu 20.04
# humanity-icon-theme 0.6.15 devices/48/printer.svg
# via Chrome headless
# --default-background-color=00000000 lives at
# evidence/printer-128.png and is used only
# as the mall CREATE --icon; it is not
# shipped in the deb. The theme package is
# not bundled. Official GUI and common
# changelog.Debian.gz are symlinks into
# bundled python3-cupshelpers and are kept
# (they resolve after bundling); the real
# official changelog is also copied with
# cp -L into the kemi doc dir. Official
# desktop Name=Printers and GenericName=Printers
# are kept. Official appdata <name> is Print
# Settings (used as mall app_name). Official
# desktop Exec values are relative and are
# rewritten to absolute /usr/bin/...; TryExec
# is added. Official dh_python3
# postinst/prerm and python3 rtupdate hooks
# are retargeted to kemi-system-config-printer.
# Official common dpkg-maintscript-helper
# mv_conffile lines (historical package
# argument system-config-printer) and official
# conffiles are kept. Desktop-database hook
# is appended. Probe: Architecture all · 0
# unique packaged ELFs · vacuous PASS vs 101
# (None-safe; do not invent a max from null;
# probe_elf.py is not called with no --elf).
# Official SHA256 + size of the official debs
# matched official ports.ubuntu.com and Aliyun
# ubuntu-ports pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza
# (streamed; arch:all appears in the arm64
# index). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI mall
# version_name 1.5.12-0ubuntu1.1kemi1 is 22
# chars (under the mall version_name limit
# that rejected Remmina's 33-char string;
# 12–28 char siblings succeeded). No epoch,
# no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-system-config-printer
VER_UP=1.5.12-0ubuntu1.1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-system-config-printer
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/system-config-printer}"
UNPACK_COMMON="${UNPACK_COMMON:-$ROOT/unpack-official/system-config-printer-common}"
UNPACK_HELPERS="${UNPACK_HELPERS:-$ROOT/unpack-official/python3-cupshelpers}"
GUI_DEB="$DL/system-config-printer_1.5.12-0ubuntu1.1_all.deb"
COMMON_DEB="$DL/system-config-printer-common_1.5.12-0ubuntu1.1_all.deb"
HELPERS_DEB="$DL/python3-cupshelpers_1.5.12-0ubuntu1.1_all.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 22, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 74448
echo "33a4602eb29326df16955896a05db1ad16ad0a390e1999638cc033578b94ba36  $GUI_DEB" | sha256sum -c -
test -f "$COMMON_DEB" && test "$(stat -c%s "$COMMON_DEB")" = 107792
echo "09a0157852478bb8e6845c82114ad089932e327db1b1df32a97194cc154df352  $COMMON_DEB" | sha256sum -c -
test -f "$HELPERS_DEB" && test "$(stat -c%s "$HELPERS_DEB")" = 32488
echo "17cb8d760b1f465c15b584954697b713e9155d1de2241aba6a0c53820305a856  $HELPERS_DEB" | sha256sum -c -
for rel in \
  "$UNPACK_GUI/usr/bin/system-config-printer" \
  "$UNPACK_GUI/usr/bin/system-config-printer-applet" \
  "$UNPACK_GUI/usr/bin/install-printerdriver" \
  "$UNPACK_COMMON/usr/bin/scp-dbus-service"
do
  test -x "$rel"
done
python3 - << PY
from pathlib import Path
magic = bytes([0x7F]) + b"ELF"
for rel in [
    "$UNPACK_GUI/usr/bin/system-config-printer",
    "$UNPACK_GUI/usr/bin/system-config-printer-applet",
    "$UNPACK_GUI/usr/bin/install-printerdriver",
    "$UNPACK_COMMON/usr/bin/scp-dbus-service",
]:
    p = Path(rel)
    assert not p.is_symlink()
    first = p.read_bytes().splitlines()[0]
    assert first.startswith(b"#!") and b"/bin/sh" in first, first
    body = p.read_text()
    assert "prefix=/usr" in body
    assert p.read_bytes()[:4] != magic
print("official_bash_wrappers_ok")
PY
test -f "$UNPACK_GUI/usr/share/applications/system-config-printer.desktop"
test -f "$UNPACK_GUI/usr/share/metainfo/system-config-printer.appdata.xml"
test ! -d "$UNPACK_GUI/usr/share/icons"
test -f "$UNPACK_GUI/usr/share/system-config-printer/icons/i-network-printer.png"
test -f "$UNPACK_HELPERS/usr/share/doc/python3-cupshelpers/changelog.Debian.gz"
test ! -L "$UNPACK_HELPERS/usr/share/doc/python3-cupshelpers/changelog.Debian.gz"
test -L "$UNPACK_GUI/usr/share/doc/system-config-printer/changelog.Debian.gz"
test -L "$UNPACK_COMMON/usr/share/doc/system-config-printer-common/changelog.Debian.gz"
test -f "$ROOT/evidence/printer-128.png"
test -f "$ROOT/evidence/printer.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/printer-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "ca6bf33bd8aa424d064c5a30d2e274b912930f314247fb19a3da4b92f7993d5f"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/printer.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "295cabc9042d09310f76790a54f5992014f452b0d105d6870ead408940d65196"
pix = Path("$UNPACK_GUI/usr/share/system-config-printer/icons/i-network-printer.png")
pdata = pix.read_bytes()
assert pdata[:8] == b"\x89PNG\r\n\x1a\n"
pw, ph = unpack(">II", pdata[16:24])
assert (pw, ph) == (48, 48), (pw, ph)
assert hashlib.sha256(pdata).hexdigest() == "c88cb75eaa5a5ca79a755487a08f8c0f9936ed16472396e83ac0fbf35f10226f"
mos = list(Path("$UNPACK_GUI").rglob("*.mo")) + list(Path("$UNPACK_COMMON").rglob("*.mo")) + list(Path("$UNPACK_HELPERS").rglob("*.mo"))
assert len(mos) == 0, len(mos)
print("official_no_mo")
appdata = Path("$UNPACK_GUI/usr/share/metainfo/system-config-printer.appdata.xml").read_text()
assert "<name>Print Settings</name>" in appdata
print("appdata_name_ok")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/system-config-printer"

cp -a "$UNPACK_COMMON/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_COMMON/etc" "$STAGE/pkg/etc"
cp -a "$UNPACK_HELPERS/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_HELPERS/etc/." "$STAGE/pkg/etc/"
cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_GUI/etc/." "$STAGE/pkg/etc/"
chmod 0755 \
  "$STAGE/pkg/usr/bin/system-config-printer" \
  "$STAGE/pkg/usr/bin/system-config-printer-applet" \
  "$STAGE/pkg/usr/bin/install-printerdriver" \
  "$STAGE/pkg/usr/bin/scp-dbus-service"

# merge official conffiles
python3 - << PY
from pathlib import Path
paths = [
    Path("$UNPACK_GUI/DEBIAN/conffiles"),
    Path("$UNPACK_COMMON/DEBIAN/conffiles"),
    Path("$UNPACK_HELPERS/DEBIAN/conffiles"),
]
lines = []
seen = set()
for p in paths:
    for line in p.read_text().splitlines():
        if line and line not in seen:
            seen.add(line)
            lines.append(line)
Path("$STAGE/pkg/DEBIAN/conffiles").write_text("\n".join(lines) + "\n")
print("conffiles", lines)
PY

# official GUI/common changelog symlinks must resolve after bundling helpers
test -L "$STAGE/pkg/usr/share/doc/system-config-printer/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/system-config-printer/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/share/doc/system-config-printer-common/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/system-config-printer-common/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/python3-cupshelpers/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/system-config-printer/icons/i-network-printer.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'printer-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi

# retarget official python3 rtupdate hooks to the kemi package;
# replace the two official files with one covering the kemi package
rm -f \
  "$STAGE/pkg/usr/share/python3/runtime.d/system-config-printer.rtupdate" \
  "$STAGE/pkg/usr/share/python3/runtime.d/system-config-printer-common.rtupdate"
mkdir -p "$STAGE/pkg/usr/share/python3/runtime.d"
cat > "$STAGE/pkg/usr/share/python3/runtime.d/kemi-system-config-printer.rtupdate" << 'HOOK'
#! /bin/sh
set -e

if [ "$1" = rtupdate ]; then
	py3clean -p kemi-system-config-printer /usr/share/system-config-printer
	py3compile -p kemi-system-config-printer  /usr/share/system-config-printer
fi
HOOK
chmod 0755 "$STAGE/pkg/usr/share/python3/runtime.d/kemi-system-config-printer.rtupdate"
test ! -e "$STAGE/pkg/usr/share/python3/runtime.d/system-config-printer.rtupdate"
test ! -e "$STAGE/pkg/usr/share/python3/runtime.d/system-config-printer-common.rtupdate"
grep -q 'kemi-system-config-printer' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-system-config-printer.rtupdate"
! grep -q 'py3compile -p system-config-printer' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-system-config-printer.rtupdate"

# 0-ELF vacuous probe: do not call probe_elf.py with no --elf
REPORT="$ROOT/probe/kemi-system-config-printer.json"
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
    "note": "0 unique packaged ELFs (official launchers are bash wrappers around official Python, Architecture: all); vacuous PASS vs 101. None-safe: no requiredGlibc/requiredGlibcxx values exist, so none are ranked as a max.",
    "n_elf": 0,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
files = report["files"]
if files:
    raise SystemExit("PROBE_UNEXPECTED_FILES")
if not report["configuredLimitsSatisfied"]:
    raise SystemExit("PROBE_FAIL")
print("PROBE_PASS n_elf=0 vacuous Architecture:all official bash/Python launchers; None-safe (0 versioned, 0 null; no max invented) configuredLimitsSatisfied=true")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/system-config-printer/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_HELPERS/usr/share/doc/python3-cupshelpers/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "17fac627c2c8213fad2d4293a6a67967db11a137381b52aeab3d5a7790a4eab2"
print("changelog_upstream_ok")
PY

# rewrite official relative desktop Exec to absolute; add TryExec;
# keep official Name, GenericName, Icon, X-GNOME-FullName
export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/system-config-printer.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/system-config-printer.desktop"
export UNPACK_APPLET="$UNPACK_GUI/etc/xdg/autostart/print-applet.desktop"
export STAGE_APPLET="$STAGE/pkg/etc/xdg/autostart/print-applet.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path

def rewrite(src, dest, expect_name=None, expect_generic=None, expect_exec_cmd=None, expect_icon=None):
    text = Path(src).read_text()
    if expect_name and not re.search(rf"^Name={re.escape(expect_name)}\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_NAME:" + src)
    if expect_generic is not None:
        if expect_generic and not re.search(rf"^GenericName={re.escape(expect_generic)}\s*$", text, flags=re.M):
            raise SystemExit("DESKTOP_GENERICNAME:" + src)
    if expect_icon and not re.search(rf"^Icon={re.escape(expect_icon)}\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_ICON:" + src)
    m = re.search(r"^Exec=(\S+)", text, flags=re.M)
    if not m:
        raise SystemExit("DESKTOP_NO_EXEC:" + src)
    exec_val = m.group(1)
    if exec_val.startswith("/"):
        abs_exec = exec_val
    else:
        if "/" in exec_val:
            raise SystemExit("DESKTOP_RELATIVE_PATH:" + exec_val)
        abs_exec = "/usr/bin/" + exec_val
    if expect_exec_cmd and not abs_exec.endswith("/" + expect_exec_cmd):
        raise SystemExit("DESKTOP_EXEC_CMD:" + abs_exec)
    # replace only the Exec path token, keep any args
    def _sub_exec(mo):
        rest = mo.group(0)[len("Exec=" + exec_val):]
        return "Exec=" + abs_exec + rest
    text = re.sub(r"^Exec=" + re.escape(exec_val) + r".*$", _sub_exec, text, count=1, flags=re.M)
    if re.search(r"^TryExec=", text, flags=re.M):
        text = re.sub(r"^TryExec=.*$", "TryExec=" + abs_exec, text, count=1, flags=re.M)
    else:
        text = re.sub(
            r"^Exec=" + re.escape(abs_exec) + r".*$",
            lambda mo: mo.group(0) + "\nTryExec=" + abs_exec,
            text,
            count=1,
            flags=re.M,
        )
    if r"\1" in text:
        raise SystemExit("DESKTOP_LITERAL_GROUP:" + src)
    if f"Exec={abs_exec}" not in text or f"TryExec={abs_exec}" not in text:
        raise SystemExit("DESKTOP_REWRITE_FAIL:" + src)
    Path(dest).write_text(text)
    print("desktop_rewritten", dest, abs_exec)

rewrite(
    os.environ["UNPACK_DESKTOP"],
    os.environ["STAGE_DESKTOP"],
    expect_name="Printers",
    expect_generic="Printers",
    expect_exec_cmd="system-config-printer",
    expect_icon="printer",
)
rewrite(
    os.environ["UNPACK_APPLET"],
    os.environ["STAGE_APPLET"],
    expect_name="Print Queue Applet",
    expect_generic="",
    expect_exec_cmd="system-config-printer-applet",
    expect_icon="printer",
)
print("desktops_ok")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-system-config-printer/scripts/build-system-config-printer-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/system-config-printer\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/system-config-printer "$STAGE/pkg/opt/system-config-printer/system-config-printer"
ln -sf /usr/bin/system-config-printer-applet "$STAGE/pkg/opt/system-config-printer/system-config-printer-applet"
ln -sf /usr/bin/install-printerdriver "$STAGE/pkg/opt/system-config-printer/install-printerdriver"
ln -sf /usr/bin/scp-dbus-service "$STAGE/pkg/opt/system-config-printer/scp-dbus-service"
ln -sf system-config-printer "$STAGE/pkg/usr/bin/kemi-system-config-printer"

# official D-Bus Exec already absolute
grep -qx 'Exec=/usr/bin/scp-dbus-service' "$STAGE/pkg/usr/share/dbus-1/services/org.fedoraproject.Config.Printing.service"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    # Flag leftover multiarch typelib/library paths only
    # (x86_64-linux-gnu). Official source may mention
    # the x86_64 architecture string (cupshelpers/openprinting.py)
    # and must stay.
    if b"x86_64-linux-gnu" not in raw:
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
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-system-config-printer (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    system-config-printer 1.5.12-0ubuntu1.1
    all, KEMI mall linuxpkg repack. Bundles
    official same-source exact-version
    system-config-printer-common and
    python3-cupshelpers
    (= 1.5.12-0ubuntu1.1). Official
    different-source Depends stay Depends.
    Official Recommends stay Recommends
    (including system-config-printer-udev).
    Official Suggests stay Suggests.
    Transitional dummy
    system-config-printer-gnome inspected,
    not packaged. Official launchers stay
    at official paths; /opt/system-config-printer/*
    are symlinks. Also
    /usr/bin/kemi-system-config-printer →
    system-config-printer. Official desktop
    Name=Printers and GenericName=Printers
    kept; relative Exec rewritten absolute;
    TryExec added. Official GUI/common
    changelog symlinks into bundled
    python3-cupshelpers are kept and
    resolve; the real official changelog was
    also copied with cp -L. Official package
    ships no app icon (theme name printer);
    official in-app 48×48 PNG stays official.
    A 128×128 evidence PNG rasterized from
    official Ubuntu 20.04 humanity-icon-theme
    0.6.15 is used only as mall CREATE --icon
    and is not packed. Theme package is not
    bundled. Official packages ship no .mo;
    none invented. Official dh_python3 and
    rtupdate hooks retargeted to
    kemi-system-config-printer; official
    common maintainer scripts and conffiles
    kept; desktop-database hook appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Print Settings — official Ubuntu 20.04
(focal-updates main) system-config-printer
1.5.12-0ubuntu1.1 Architecture: all, KEMI
repack. Official user-facing launchers are
bash wrappers (prefix=/usr) around official
Python under /usr/share/system-config-printer
and stay under /usr.
/opt/system-config-printer/* are symlinks.
Bundles official same-source exact-version
system-config-printer-common and
python3-cupshelpers (= 1.5.12-0ubuntu1.1).
Official different-source Depends stay
Depends. Official Recommends
(system-config-printer-udev, avahi-utils,
and from common cups-pk-helper and
gir1.2-secret-1) stay Recommends. Official
Suggests (gnome-software, and from common
python3-smbc) stay Suggests. Transitional
dummy system-config-printer-gnome inspected,
not packaged. Official packages ship no .mo
(Ubuntu language-pack split); none invented.
Official package ships no app icon (theme
name printer); official in-app 48×48 PNG
stays official. A 128×128 evidence PNG
rasterized from official Ubuntu 20.04
humanity-icon-theme 0.6.15 is used only as
mall CREATE --icon and is not packed. Theme
package is not bundled. Official desktop
Name=Printers and GenericName=Printers are
kept; mall app_name is Print Settings
(official appdata <name>). Official desktop
Name is generic; official GenericName is the
same as Name and is not used as mall
app_name. Probe: 0 unique ELF (Architecture:
all, official launchers are bash/Python);
vacuous PASS vs Ubuntu 20.04 / glibc 2.31;
None-safe (no max invented from null).
Official publication: Ubuntu 20.04
focal-updates main system-config-printer
1.5.12-0ubuntu1.1 (all), newer than focal
Release 1.5.12-0ubuntu1. Official SHA256 +
size of the official debs matched
ports.ubuntu.com and Aliyun ubuntu-ports
pool files and the focal-updates main
Packages stanza. No librarian URL this run.
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
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-notify-0.7, gir1.2-packagekitglib-1.0, gir1.2-pango-1.0, gir1.2-polkit-1.0, python3-cups (>= 1.9.60), python3-dbus, python3-gi, python3:any, python3-cairo, python3-requests
Recommends: system-config-printer-udev, avahi-utils, cups-pk-helper, gir1.2-secret-1
Suggests: gnome-software (>= 3.16.5-2), python3-smbc
Conflicts: system-config-printer, system-config-printer-common, python3-cupshelpers
Replaces: system-config-printer, system-config-printer-common, python3-cupshelpers, system-config-printer-gnome (<< 1.5.7+20160812-0ubuntu3~), python-cupshelpers (<= 1.5)
Breaks: system-config-printer-gnome (<< 1.5.7+20160812-0ubuntu3~), python-cupshelpers (<= 1.5)
Provides: system-config-printer (= 1.5.12-0ubuntu1.1), system-config-printer-common (= 1.5.12-0ubuntu1.1), python3-cupshelpers (= 1.5.12-0ubuntu1.1)
Homepage: https://github.com/zdohnal/system-config-printer
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: graphical interface to configure the printing system
 Print Settings ${VER_UP} — official Ubuntu
 20.04 all, KEMI repack of
 system-config-printer. Bundles official
 system-config-printer-common and
 python3-cupshelpers.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Merge official maintainer scripts: keep official
# dpkg-maintscript-helper mv_conffile lines
# (historical package argument
# system-config-printer is official and kept).
# Retarget dh_python3 hooks to the kemi package
# name. One py3compile covers the whole kemi
# package (share + dist-packages). Desktop-
# database hook appended before exit if any.
export STAGE_DEBIAN="$STAGE/pkg/DEBIAN"
export COMMON_DEBIAN="$UNPACK_COMMON/DEBIAN"
python3 - << 'PY'
import os
from pathlib import Path
dst = Path(os.environ["STAGE_DEBIAN"])
common = Path(os.environ["COMMON_DEBIAN"])

def write_exec(path: Path, text: str):
    path.write_text(text if text.endswith("\n") else text + "\n")
    path.chmod(0o755)

# postinst: python compile + official common maintscript + desktop hook
write_exec(dst / "postinst", """#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi package):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-system-config-printer
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-system-config-printer || true
fi

# End automatically added section
# Automatically added by dh_installdeb/12.10ubuntu1
dpkg-maintscript-helper mv_conffile /etc/dbus-1/system.d/newprinternotification.conf /etc/dbus-1/system.d/com.redhat.NewPrinterNotification.conf 1.4.1-3\\~ system-config-printer -- "$@"
dpkg-maintscript-helper mv_conffile /etc/dbus-1/system.d/printerdriversinstaller.conf /etc/dbus-1/system.d/com.redhat.PrinterDriversInstaller.conf 1.4.1-3\\~ system-config-printer -- "$@"
# End automatically added section

# kemi hooks
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
""")

write_exec(dst / "prerm", """#!/bin/sh
set -e
# Automatically added by dh_installdeb/12.10ubuntu1
dpkg-maintscript-helper mv_conffile /etc/dbus-1/system.d/newprinternotification.conf /etc/dbus-1/system.d/com.redhat.NewPrinterNotification.conf 1.4.1-3\\~ system-config-printer -- "$@"
dpkg-maintscript-helper mv_conffile /etc/dbus-1/system.d/printerdriversinstaller.conf /etc/dbus-1/system.d/com.redhat.PrinterDriversInstaller.conf 1.4.1-3\\~ system-config-printer -- "$@"
# End automatically added section

# Automatically added by dh_python3 (retargeted to kemi package):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-system-config-printer
else
	dpkg -L kemi-system-config-printer | perl -ne 's,/([^/]*)\\.py$,/__pycache__/\\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi

# End automatically added section
""")

# official common preinst/postrm are only the maintscript helper
for name in ("preinst", "postrm"):
    write_exec(dst / name, (common / name).read_text())

post = (dst / "postinst").read_text()
prerm = (dst / "prerm").read_text()
assert "py3compile -p kemi-system-config-printer" in post
assert "py3clean -p kemi-system-config-printer" in prerm
assert "dpkg -L kemi-system-config-printer" in prerm
assert "py3compile -p system-config-printer" not in post
assert "py3compile -p system-config-printer-common" not in post
assert "py3compile -p python3-cupshelpers" not in post
assert "dpkg -L system-config-printer" not in prerm or "dpkg -L system-config-printer-" in prerm
# the official historical package argument in mv_conffile must stay
assert "1.4.1-3\\~ system-config-printer --" in post or "1.4.1-3~ system-config-printer --" in post
assert "update-desktop-database" in post
print("hooks_written")
PY
grep -q 'py3compile -p kemi-system-config-printer' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-system-config-printer' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg-maintscript-helper' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'system-config-printer --' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p system-config-printer ' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p python3-cupshelpers' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_ok"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-system-config-printer_1.5.12-0ubuntu1.1kemi1_all.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'Version: 1.5.12-0ubuntu1.1kemi1' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'system-config-printer (= 1.5.12-0ubuntu1.1)' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'system-config-printer-common (= 1.5.12-0ubuntu1.1)' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'python3-cupshelpers (= 1.5.12-0ubuntu1.1)' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'python3-cups (>= 1.9.60)' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'Recommends: system-config-printer-udev' "$ROOT/evidence/kemi-system-config-printer-control.txt"
grep -q 'Suggests: gnome-software' "$ROOT/evidence/kemi-system-config-printer-control.txt"
! grep -q 'Depends:.*system-config-printer-common' "$ROOT/evidence/kemi-system-config-printer-control.txt"
! grep -q 'Depends:.*python3-cupshelpers' "$ROOT/evidence/kemi-system-config-printer-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/system-config-printer.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Printers" in desk
assert "GenericName=Printers" in desk
assert "X-GNOME-FullName=Printers" in desk
assert "Exec=/usr/bin/system-config-printer" in desk
assert "TryExec=/usr/bin/system-config-printer" in desk
assert "Icon=printer" in desk
assert "Exec=system-config-printer\n" not in desk.replace("Exec=/usr/bin/system-config-printer", "")
applet = Path("$CHECK/etc/xdg/autostart/print-applet.desktop").read_text()
if r"\\1" in applet or r"\1" in applet:
    raise SystemExit("BUILT_APPLET_LITERAL_GROUP")
assert "Name=Print Queue Applet" in applet
assert "Exec=/usr/bin/system-config-printer-applet" in applet
assert "TryExec=/usr/bin/system-config-printer-applet" in applet
assert "Icon=printer" in applet
print("built_desktops_ok")
PY
for b in system-config-printer system-config-printer-applet install-printerdriver scp-dbus-service; do
  test -x "$CHECK/usr/bin/$b"
  test ! -L "$CHECK/usr/bin/$b"
done
python3 - << PY
from pathlib import Path
magic = bytes([0x7F]) + b"ELF"
for name in ["system-config-printer", "system-config-printer-applet", "install-printerdriver", "scp-dbus-service"]:
    p = Path("$CHECK/usr/bin") / name
    assert not p.is_symlink()
    first = p.read_bytes().splitlines()[0]
    assert b"/bin/sh" in first, first
    assert "prefix=/usr" in p.read_text()
    assert p.read_bytes()[:4] != magic
print("built_launchers_are_bash")
PY
test -L "$CHECK/usr/bin/kemi-system-config-printer"
test "$(readlink "$CHECK/usr/bin/kemi-system-config-printer")" = "system-config-printer"
test -L "$CHECK/opt/system-config-printer/system-config-printer"
test "$(readlink "$CHECK/opt/system-config-printer/system-config-printer")" = "/usr/bin/system-config-printer"
test -f "$CHECK/usr/share/system-config-printer/system-config-printer.py"
test -f "$CHECK/usr/lib/python3/dist-packages/cupshelpers/__init__.py"
test -f "$CHECK/usr/share/system-config-printer/icons/i-network-printer.png"
test -f "$CHECK/usr/share/metainfo/system-config-printer.appdata.xml"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test -f "$CHECK/usr/share/python3/runtime.d/kemi-system-config-printer.rtupdate"
test ! -e "$CHECK/usr/share/python3/runtime.d/system-config-printer.rtupdate"
test ! -e "$CHECK/usr/share/python3/runtime.d/system-config-printer-common.rtupdate"
if find "$CHECK" -name 'printer-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
test -L "$CHECK/usr/share/doc/system-config-printer/changelog.Debian.gz"
test -e "$CHECK/usr/share/doc/system-config-printer/changelog.Debian.gz"
test -L "$CHECK/usr/share/doc/system-config-printer-common/changelog.Debian.gz"
test -e "$CHECK/usr/share/doc/system-config-printer-common/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/python3-cupshelpers/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$CHECK/etc/xdg/autostart/print-applet.desktop"
test -f "$CHECK/etc/cupshelpers/preferreddrivers.xml"
test -f "$CHECK/etc/dbus-1/system.d/com.redhat.NewPrinterNotification.conf"
grep -qx 'Exec=/usr/bin/scp-dbus-service' "$CHECK/usr/share/dbus-1/services/org.fedoraproject.Config.Printing.service"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
