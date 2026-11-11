#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal main) gnome-screenshot
# 3.36.0-1ubuntu1 arm64 as kemi-gnome-screenshot.
# No newer package in focal-updates, focal-security, or
# focal-backports. The gnome-screenshot source ships only
# this one binary package in focal (no same-source
# -data/-common to bundle). Official libc / cairo /
# canberra / gdk-pixbuf / glib / GTK / X11 / Xext /
# dconf-gsettings-backend|gsettings-backend Depends stay
# Depends, unbundled. Official control has no Recommends
# and no Suggests. Versioned Provides: gnome-screenshot
# (= 3.36.0-1ubuntu1). No Debian epoch, no tilde. Official
# /usr/bin/gnome-screenshot is a real aarch64 ELF and
# stays at the official path. /opt/gnome-screenshot/* and
# /usr/bin/kemi-gnome-screenshot are symlinks only.
# Official package ships no .mo and no Yelp help (Ubuntu
# language-pack split; keep official tree; do not invent
# language packs). Official app icons are SVG only
# (hicolor scalable org.gnome.Screenshot.svg and
# symbolic). There is no official 256×256 PNG. A 128×128
# evidence PNG rasterized from the official scalable SVG
# via Chrome headless --default-background-color=00000000
# lives at evidence/gnome-screenshot-128.png and is used
# only as the mall CREATE --icon; it is not shipped in
# the deb. Official changelog.Debian.gz and NEWS.gz are
# real files and are copied with cp -L. Official desktop
# Exec=gnome-screenshot (including action Exec lines) is
# rewritten to /usr/bin/gnome-screenshot; TryExec is
# added; Icon=org.gnome.Screenshot; official Name=
# Screenshot is kept (mall app_name is GNOME Screenshot).
# Official D-Bus Exec is already absolute and is kept.
# Official DBusActivatable=true is kept. Official gschema
# and GConf convert files stay official. Official package
# has no maintainer scripts; icon-cache, desktop-database
# and glib-compile-schemas hooks are added. Probe: arm64
# · 1 unique packaged ELF · requiredGlibc 2.29 (1
# versioned, 0 null; do not invent a max from null) · no
# GLIBCXX (0 versioned, 1 null; null is not ranked as a
# max) · no RUNPATH · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04
# focal main arm64 Packages stanza (Aliyun ubuntu-ports
# mirror, streamed). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI version
# 3.36.0-1ubuntu1kemi1 is 20 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-screenshot
VER_UP=3.36.0-1ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-screenshot
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-kemi}"
UP_DEB="$DL/gnome-screenshot_3.36.0-1ubuntu1_arm64.deb"
EXPECT_SHA=a164503a0d9474c2fdfe32385afb5e806661b2bc509660bfe56149180fc72d19
EXPECT_BYTES=52044
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

rm -rf "$UNPACK"
mkdir -p "$UNPACK"
dpkg-deb -x "$UP_DEB" "$UNPACK"
dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"

test -x "$UNPACK/usr/bin/gnome-screenshot"
python3 - << PY
from pathlib import Path
p = Path("$UNPACK") / "usr/bin/gnome-screenshot"
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
print("official_elf_present", p.stat().st_size)
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Screenshot.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Screenshot.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Screenshot.png"
test ! -L "$UNPACK/usr/share/doc/gnome-screenshot/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-screenshot/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-screenshot/NEWS.gz"
test -f "$UNPACK/usr/share/doc/gnome-screenshot/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -f "$ROOT/evidence/gnome-screenshot-128.png"
python3 - << PY
import struct
from pathlib import Path
p = Path("$ROOT/evidence/gnome-screenshot-128.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (128, 128), (w, h)
print("evidence_128_for_create", w, h, p.stat().st_size)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-screenshot"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-screenshot"

# official package has no maintainer scripts

REPORT="$ROOT/probe/kemi-gnome-screenshot.json"
export STAGE_PKG="$STAGE/pkg"
export REPORT
python3 - << 'END_GNOME_SCREENSHOT_PROBE'
import json, os, subprocess, sys
from pathlib import Path
root = Path(os.environ["STAGE_PKG"])
magic = bytes([0x7F]) + b"ELF"
elfs = []
seen = set()
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            rp = str(p.resolve())
            if rp not in seen:
                seen.add(rp)
                elfs.append(str(p))
if len(elfs) != 1:
    raise SystemExit("ELF_COUNT:" + ",".join(elfs))
if not str(Path(elfs[0])).endswith("/usr/bin/gnome-screenshot"):
    raise SystemExit("UNEXPECTED_ELF:" + elfs[0])
cmd = [
    sys.executable,
    "/workspace/t142-20261112-gnome-screenshot/scripts/probe_elf.py",
    "--target-arch", "arm64",
    "--max-glibc", "2.31",
    "--report", os.environ["REPORT"],
    "--elf", elfs[0],
]
subprocess.check_call(cmd)
rep = json.loads(Path(os.environ["REPORT"]).read_text())
files = rep.get("files") or []
if len(files) != 1:
    raise SystemExit("PROBE_FILE_COUNT")
f = files[0]
glibc = f.get("requiredGlibc")
glibcxx = f.get("requiredGlibcxx")
glibc_versioned = 1 if glibc not in (None, "", []) else 0
glibc_null = 1 if glibc in (None, "", []) else 0
glibcxx_versioned = 1 if glibcxx not in (None, "", []) else 0
glibcxx_null = 1 if glibcxx in (None, "", []) else 0
# None-safe: do not rank a null requiredGlibc/requiredGlibcxx as a max
max_glibc = glibc if glibc_versioned else None
max_glibcxx = glibcxx if glibcxx_versioned else None
if glibc != "2.29" or glibc_versioned != 1 or glibc_null != 0:
    raise SystemExit(f"GLIBC_UNEXPECTED:{glibc}")
if glibcxx is not None or glibcxx_versioned != 0 or glibcxx_null != 1:
    raise SystemExit(f"GLIBCXX_UNEXPECTED:{glibcxx}")
if f.get("architecture") not in {"aarch64", "arm64"}:
    raise SystemExit("ARCH:" + str(f.get("architecture")))
if not rep.get("configuredLimitsSatisfied"):
    raise SystemExit("LIMITS_NOT_SATISFIED")
# no RUNPATH/RPATH
dyn = subprocess.check_output(["readelf", "-d", elfs[0]], text=True)
if "RUNPATH" in dyn or "(RPATH)" in dyn:
    raise SystemExit("UNEXPECTED_RUNPATH")
rep["nUniqueElf"] = 1
rep["maxVersionedGlibc"] = max_glibc
rep["maxVersionedGlibcxx"] = max_glibcxx
rep["glibcVersioned"] = glibc_versioned
rep["glibcNull"] = glibc_null
rep["glibcxxVersioned"] = glibcxx_versioned
rep["glibcxxNull"] = glibcxx_null
rep["note"] = (
    "1 unique packaged ELF /usr/bin/gnome-screenshot; requiredGlibc 2.29 "
    "(1 versioned, 0 null); no GLIBCXX (0 versioned, 1 null; null is not "
    "ranked as a max); no RUNPATH; configuredLimitsSatisfied true vs 101"
)
Path(os.environ["REPORT"]).write_text(json.dumps(rep, indent=2) + "\n")
print(
    "PROBE_PASS n_elf=1 unique aarch64 glibc 2.29 (1 versioned, 0 null; no max invented from null) "
    "noGLIBCXX (0 versioned, 1 null; null not ranked as a max) noRUNPATH configuredLimitsSatisfied=true"
)
END_GNOME_SCREENSHOT_PROBE

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Screenshot.svg"
if find "$STAGE/pkg" -name 'gnome-screenshot-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-screenshot/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-screenshot/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.Screenshot.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Screenshot.desktop"
export STAGE_PKG
python3 - << 'END_GNOME_SCREENSHOT_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=gnome-screenshot --interactive\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Name=Screenshot" not in text or "Icon=org.gnome.Screenshot" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
text2 = re.sub(r"^Exec=gnome-screenshot\b", "Exec=/usr/bin/gnome-screenshot", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/gnome-screenshot", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/gnome-screenshot.*$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-screenshot",
        text2,
        count=1,
        flags=re.M,
    )
for expect in (
    "Exec=/usr/bin/gnome-screenshot --interactive",
    "Exec=/usr/bin/gnome-screenshot\n",
    "Exec=/usr/bin/gnome-screenshot -w",
    "Exec=/usr/bin/gnome-screenshot -a",
    "TryExec=/usr/bin/gnome-screenshot",
    "Icon=org.gnome.Screenshot",
    "Name=Screenshot",
    "DBusActivatable=true",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
# no leftover non-absolute Exec
for i, line in enumerate(text2.splitlines(), 1):
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-screenshot"):
        raise SystemExit(f"DESKTOP_NONABS_EXEC:{i}:{line}")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_rewritten_tryexec_added")

# official D-Bus Exec already absolute
bus = Path(os.environ["STAGE_PKG"]) / "usr/share/dbus-1/services/org.gnome.Screenshot.service"
bt = bus.read_text()
if "Exec=/usr/bin/gnome-screenshot --gapplication-service" not in bt:
    raise SystemExit("DBUS_EXEC_UNEXPECTED")
print("dbus_exec_kept_absolute")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        txt = p.read_text(encoding="utf-8")
    except Exception:
        continue
    for i, line in enumerate(txt.splitlines(), 1):
        s = line.strip()
        if "x86_64-linux-gnu" not in s:
            continue
        if s.startswith("#"):
            continue
        leftover.append(f"{p}:{i}:{s}")
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_live_x86_paths")
END_GNOME_SCREENSHOT_DESKTOP

ln -sf /usr/bin/gnome-screenshot "$STAGE/pkg/opt/gnome-screenshot/gnome-screenshot"
ln -sf gnome-screenshot "$STAGE/pkg/usr/bin/kemi-gnome-screenshot"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Attic/GnomeUtils
Source: https://launchpad.net/ubuntu/+source/gnome-screenshot
Homepage: https://wiki.gnome.org/Apps/Attic/GnomeUtils
License: see copyright.upstream
Official Ubuntu 20.04 (focal main) arm64 deb v${VER_UP}
(gnome-screenshot_3.36.0-1ubuntu1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-screenshot_3.36.0-1ubuntu1_arm64.deb
    (focal main; no newer package in focal-updates,
    focal-security, or focal-backports) repackaged for
    KEMI as ${PKG}. Official libc / GTK / cairo /
    canberra / X11 Depends stay Depends and are not
    bundled. Official control has no Recommends and no
    Suggests. Versioned Provides: gnome-screenshot
    (= 3.36.0-1ubuntu1).
  * Official /usr/bin/gnome-screenshot is an aarch64
    ELF and stays under /usr. /opt/gnome-screenshot/*
    are symlinks. Also /usr/bin/kemi-gnome-screenshot
    → gnome-screenshot.
  * Official package ships no .mo and no Yelp help
    (keep official; do not invent language packs).
    Official app icons are SVG only; a 128×128 evidence
    PNG rasterized from the official scalable SVG is
    used only for mall CREATE --icon and is not packed
    in the deb.
  * Official changelog is a real file and was copied
    with cp -L. Official desktop Exec=gnome-screenshot
    (including action Exec lines) is rewritten to
    /usr/bin/gnome-screenshot; TryExec added;
    Icon=org.gnome.Screenshot; Name=Screenshot.
    Official D-Bus Exec is already absolute and is
    kept. Official gschema stays official. Icon-cache,
    desktop-database and glib-compile-schemas hooks
    are added (official package has no maintainer
    scripts).

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Screenshot ${VER_UP} — official Ubuntu 20.04
(focal main) arm64, KEMI repack.

Official /usr/bin/gnome-screenshot is an aarch64 ELF
and stays under /usr. /opt/gnome-screenshot/* are
symlinks. Official libc / GTK / cairo / canberra / X11
Depends stay Depends and are not bundled. Official
control has no Recommends and no Suggests. Official
package ships no .mo. Official icons are SVG only; a
128×128 evidence PNG is used only as mall CREATE
--icon and is not packed. Probe: 1 unique ELF ·
requiredGlibc 2.29 (1 versioned, 0 null; no max
invented from null) · no requiredGlibcxx (0 versioned,
1 null; null not ranked as a max) · no RUNPATH;
within Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal main gnome-screenshot
3.36.0-1ubuntu1 (arm64). Official SHA256 + size
matched ports.ubuntu.com pool files and focal main
arm64 Packages stanza. No librarian URL this run.
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
Depends: libc6 (>= 2.29), libcairo2 (>= 1.10.0), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.2), libgdk-pixbuf2.0-0 (>= 2.23.0), libglib2.0-0 (>= 2.39.90), libgtk-3-0 (>= 3.11.5), libx11-6, libxext6, dconf-gsettings-backend | gsettings-backend
Replaces: gnome-screenshot
Conflicts: gnome-screenshot
Provides: gnome-screenshot (= 3.36.0-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Attic/GnomeUtils
Description: screenshot application for GNOME
 GNOME Screenshot ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
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
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
	update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
grep -q 'Version: 3.36.0-1ubuntu1kemi1' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
grep -q 'libc6 (>= 2.29)' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
grep -q 'Provides: gnome-screenshot (= 3.36.0-1ubuntu1)' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-screenshot-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gnome-screenshot",
    "./usr/bin/kemi-gnome-screenshot",
    "./opt/gnome-screenshot/gnome-screenshot",
    "./usr/share/applications/org.gnome.Screenshot.desktop",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Screenshot.svg",
    "./usr/share/glib-2.0/schemas/org.gnome.gnome-screenshot.gschema.xml",
    "./usr/share/dbus-1/services/org.gnome.Screenshot.service",
    "./usr/share/metainfo/org.gnome.Screenshot.metainfo.xml",
    "./usr/share/man/man1/gnome-screenshot.1.gz",
    "./usr/share/doc/kemi-gnome-screenshot/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gnome-screenshot-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/gnome-screenshot " in line or line.rstrip().endswith("./usr/bin/gnome-screenshot")) and "kemi-gnome-screenshot" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-gnome-screenshot" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
