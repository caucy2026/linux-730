#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal main) gnome-characters
# 3.34.0-1 arm64 as kemi-gnome-characters.
# No newer package in focal-updates, focal-security, or
# focal-backports. The gnome-characters source ships only
# this one binary package in focal (no same-source
# -data/-common or exact-version library Depends to
# bundle; the private typelib and libgc.so already ship
# inside this official package). Official typelib / gjs /
# GTK / glib / unistring / dconf Depends stay Depends,
# unbundled. Official Recommends fonts-noto-color-emoji
# stays Recommends, unbundled. Official control has no
# Suggests. Versioned Provides: gnome-characters
# (= 3.34.0-1). No Debian epoch, no tilde. Official
# /usr/bin/gnome-characters is a symlink to the official
# GJS wrapper under /usr/share/org.gnome.Characters/ and
# stays official. Official GJS wrappers bind prefix=/usr
# and libdir=/usr/lib/aarch64-linux-gnu and stay at the
# official path. Official private aarch64 ELF
# /usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so
# stays official. /opt/gnome-characters/* and
# /usr/bin/kemi-gnome-characters are symlinks only
# (kemi-gnome-characters → gnome-characters). Official
# package ships no .mo (Ubuntu language-pack split; keep
# official tree; do not invent language packs). Official
# app icons are SVG only (hicolor scalable
# org.gnome.Characters.svg and symbolic). There is no
# official 256×256 PNG. A 128×128 evidence PNG rasterized
# from the official scalable SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/gnome-characters-128.png and is used only as
# the mall CREATE --icon; it is not shipped in the deb.
# Official changelog.Debian.gz and NEWS.gz are real files
# and are copied with cp -L. Official desktop Name=
# Characters is kept (mall app_name is GNOME Characters).
# Official desktop Exec=/usr/bin/gnome-characters is
# already absolute and is kept; TryExec is added; Icon=
# org.gnome.Characters. Official D-Bus Exec lines are
# already absolute and are kept. Official DBusActivatable
# =true is kept. Official gschema, search-provider,
# appdata, typelib and gresources stay official. Official
# package has no maintainer scripts; icon-cache,
# desktop-database and glib-compile-schemas hooks are
# added. Probe: arm64 · 1 unique packaged ELF (libgc.so)
# · requiredGlibc 2.17 (1 versioned, 0 null; do not
# invent a max from null) · no GLIBCXX (0 versioned, 1
# null; null is not ranked as a max) · no RUNPATH ·
# within 101 ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool files and the
# Ubuntu 20.04 focal main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL and
# no .buildinfo is recorded this run (pool 404). KEMI
# version 3.34.0-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded, including
# Synaptic at 18 and Gufw at 21). No epoch, no tilde, no
# shortening needed. gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-characters
VER_UP=3.34.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-characters
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/gnome-characters_3.34.0-1_arm64.deb"
EXPECT_SHA=6fb2086d9d5a2718044182cfc8b5decbb752b067a27d7f228bc34a8030ba7873
EXPECT_BYTES=130512
python3 -c 's="'"$VER_DEB"'"; assert len(s)==13, len(s); assert ":" not in s, s; print("version_name_len", len(s), s)'
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

if [ ! -f "$UNPACK/usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so" ]; then
  rm -rf "$UNPACK"
  mkdir -p "$UNPACK"
  dpkg-deb -x "$UP_DEB" "$UNPACK"
  dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"
fi

test -L "$UNPACK/usr/bin/gnome-characters"
test -x "$UNPACK/usr/share/org.gnome.Characters/org.gnome.Characters"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so"
python3 - << 'END_GNOME_CHARACTERS_ELFCHECK'
from pathlib import Path
root = Path("/workspace/t142-20261112-gnome-characters/unpack-official")
binp = root / "usr/bin/gnome-characters"
assert binp.is_symlink()
wrap = root / "usr/share/org.gnome.Characters/org.gnome.Characters"
assert wrap.read_bytes().startswith(b"#!/usr/bin/gjs")
libp = root / "usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so"
assert not libp.is_symlink()
assert libp.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
bg = root / "usr/share/org.gnome.Characters/org.gnome.Characters.BackgroundService"
assert bg.read_bytes().startswith(b"#!/usr/bin/gjs")
print("official_gjs_symlink_and_elf", libp.stat().st_size, wrap.stat().st_size)
END_GNOME_CHARACTERS_ELFCHECK
test -f "$UNPACK/usr/share/applications/org.gnome.Characters.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Characters.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Characters.png"
test ! -L "$UNPACK/usr/share/doc/gnome-characters/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-characters/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-characters/NEWS.gz"
test -f "$UNPACK/usr/share/doc/gnome-characters/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -f "$ROOT/evidence/gnome-characters-128.png"
python3 - << 'END_GNOME_CHARACTERS_EVIDENCE'
import struct
from pathlib import Path
p = Path("/workspace/t142-20261112-gnome-characters/evidence/gnome-characters-128.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (128, 128), (w, h)
print("evidence_128_for_create", w, h, p.stat().st_size)
END_GNOME_CHARACTERS_EVIDENCE

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-characters"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
rm -rf "$STAGE/pkg/usr/DEBIAN" || true
chmod 0755 "$STAGE/pkg/usr/share/org.gnome.Characters/org.gnome.Characters" \
  "$STAGE/pkg/usr/share/org.gnome.Characters/org.gnome.Characters.BackgroundService"

REPORT="$ROOT/probe/kemi-gnome-characters.json"
export STAGE_PKG="$STAGE/pkg"
export REPORT
python3 - << 'END_GNOME_CHARACTERS_PROBE'
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
if not str(Path(elfs[0])).endswith("/usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so"):
    raise SystemExit("UNEXPECTED_ELF:" + elfs[0])
cmd = [
    sys.executable,
    "/workspace/t142-20261112-gnome-characters/scripts/probe_elf.py",
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
if glibc != "2.17" or glibc_versioned != 1 or glibc_null != 0:
    raise SystemExit(f"GLIBC_UNEXPECTED:{glibc}")
if glibcxx is not None or glibcxx_versioned != 0 or glibcxx_null != 1:
    raise SystemExit(f"GLIBCXX_UNEXPECTED:{glibcxx}")
if f.get("architecture") not in {"aarch64", "arm64"}:
    raise SystemExit("ARCH:" + str(f.get("architecture")))
if not rep.get("configuredLimitsSatisfied"):
    raise SystemExit("LIMITS_NOT_SATISFIED")
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
    "1 unique packaged ELF /usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so; "
    "official /usr/bin/gnome-characters is a symlink to a GJS wrapper and is not "
    "counted as an ELF; official BackgroundService is a GJS wrapper and is not "
    "counted; requiredGlibc 2.17 (1 versioned, 0 null); no GLIBCXX (0 versioned, "
    "1 null; null is not ranked as a max); no RUNPATH; configuredLimitsSatisfied "
    "true vs 101"
)
Path(os.environ["REPORT"]).write_text(json.dumps(rep, indent=2) + "\n")
print(
    "PROBE_PASS n_elf=1 unique aarch64 libgc.so glibc 2.17 (1 versioned, 0 null; no max invented from null) "
    "noGLIBCXX (0 versioned, 1 null; null not ranked as a max) noRUNPATH configuredLimitsSatisfied=true"
)
END_GNOME_CHARACTERS_PROBE

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Characters.svg"
if find "$STAGE/pkg" -name 'gnome-characters-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-characters/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-characters/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-characters/NEWS.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.Characters.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Characters.desktop"
export STAGE_PKG
python3 - << 'END_GNOME_CHARACTERS_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=/usr/bin/gnome-characters\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Name=Characters" not in text or "Icon=org.gnome.Characters" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_UNEXPECTED_OFFICIAL_TRYEXEC")
text2 = text
text2 = re.sub(
    r"^Exec=/usr/bin/gnome-characters.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-characters",
    text2,
    count=1,
    flags=re.M,
)
for expect in (
    "Exec=/usr/bin/gnome-characters",
    "TryExec=/usr/bin/gnome-characters",
    "Icon=org.gnome.Characters",
    "Name=Characters",
    "DBusActivatable=true",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
for i, line in enumerate(text2.splitlines(), 1):
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-characters"):
        raise SystemExit(f"DESKTOP_NONABS_EXEC:{i}:{line}")
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-characters":
        raise SystemExit(f"DESKTOP_TRYEXEC:{i}:{line}")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_kept_absolute_tryexec_added")

bus = Path(os.environ["STAGE_PKG"]) / "usr/share/dbus-1/services/org.gnome.Characters.service"
bt = bus.read_text()
if "Exec=/usr/bin/gnome-characters --gapplication-service" not in bt:
    raise SystemExit("DBUS_EXEC_UNEXPECTED")
print("dbus_exec_kept_absolute")
bgbus = Path(os.environ["STAGE_PKG"]) / "usr/share/dbus-1/services/org.gnome.Characters.BackgroundService.service"
bgt = bgbus.read_text()
if "Exec=/usr/share/org.gnome.Characters/org.gnome.Characters.BackgroundService" not in bgt:
    raise SystemExit("DBUS_BG_EXEC_UNEXPECTED")
print("dbus_bg_exec_kept_absolute")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".gresource", ".typelib"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw.startswith(bytes([0x7F]) + b"ELF"):
        continue
    try:
        txt = raw.decode("utf-8")
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
END_GNOME_CHARACTERS_DESKTOP

python3 - << 'END_GNOME_CHARACTERS_DESKTOP_SRCCHECK'
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-characters/scripts/build-gnome-characters-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-characters\\1"' in text:
    raise SystemExit("BAD_DESKTOP_REPLACEMENT")
if "Exec=/usr/bin/gnome-characters" not in text:
    raise SystemExit("MISSING_ABS_EXEC_IN_SCRIPT")
if "m.group(0)" not in text:
    raise SystemExit("MISSING_GROUP0")
print("desktop_script_replacements_ok")
END_GNOME_CHARACTERS_DESKTOP_SRCCHECK

ln -sf /usr/bin/gnome-characters "$STAGE/pkg/opt/gnome-characters/gnome-characters"
ln -sf gnome-characters "$STAGE/pkg/usr/bin/kemi-gnome-characters"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Design/Apps/CharacterMap
Source: official Ubuntu 20.04 focal main
Homepage: https://wiki.gnome.org/Design/Apps/CharacterMap
License: see copyright.upstream
Official Ubuntu 20.04 (focal main) arm64 deb v${VER_UP}
(gnome-characters_3.34.0-1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-characters_3.34.0-1_arm64.deb
    (focal main; no newer package in focal-updates,
    focal-security, or focal-backports) repackaged for
    KEMI as ${PKG}. Official typelib / gjs / GTK / glib
    / unistring / dconf Depends stay Depends and are
    not bundled. Official Recommends
    fonts-noto-color-emoji stays Recommends and is not
    bundled. Official control has no Suggests.
    Versioned Provides: gnome-characters (= 3.34.0-1).
  * Official /usr/bin/gnome-characters is a symlink to
    the official GJS wrapper and stays official.
    Official private aarch64 ELF libgc.so stays under
    /usr. /opt/gnome-characters/* are symlinks. Also
    /usr/bin/kemi-gnome-characters → gnome-characters.
  * Official package ships no .mo (keep official; do
    not invent language packs). Official app icons are
    SVG only; a 128×128 evidence PNG rasterized from
    the official scalable SVG is used only for mall
    CREATE --icon and is not packed in the deb.
  * Official changelog is a real file and was copied
    with cp -L. Official desktop Exec is already
    absolute and is kept; TryExec added; Icon=
    org.gnome.Characters; Name=Characters. Official
    D-Bus Exec is already absolute and is kept.
    Official gschema stays official. Icon-cache,
    desktop-database and glib-compile-schemas hooks
    are added (official package has no maintainer
    scripts).

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Characters ${VER_UP} — official Ubuntu 20.04
(focal main) arm64, KEMI repack.

Official /usr/bin/gnome-characters is a GJS symlink
and stays under /usr. Official private aarch64 ELF
libgc.so stays official. /opt/gnome-characters/* are
symlinks. Official typelib / gjs / GTK / glib /
unistring / dconf Depends stay Depends and are not
bundled. Official Recommends fonts-noto-color-emoji
stays Recommends and is unbundled. Official control
has no Suggests. Official package ships no .mo.
Official icons are SVG only; a 128×128 evidence PNG
is used only as mall CREATE --icon and is not packed.
Probe: 1 unique ELF (libgc.so) · requiredGlibc 2.17
(1 versioned, 0 null; no max invented from null) ·
no requiredGlibcxx (0 versioned, 1 null; null not
ranked as a max) · no RUNPATH; within Ubuntu 20.04 /
glibc 2.31. Official publication: Ubuntu 20.04 focal
main gnome-characters 3.34.0-1 (arm64). Official
SHA256 + size matched ports.ubuntu.com pool files
and the focal main arm64 Packages stanza. No
librarian URL this run.
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
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gnomedesktop-3.0, gir1.2-gtk-3.0 (>= 3.20.0), gir1.2-pango-1.0, gjs (>= 1.49), libglib2.0-bin (>= 2.40.0-3), dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libglib2.0-0 (>= 2.39), libgtk-3-0 (>= 3.0.0), libpango-1.0-0 (>= 1.18.0), libunistring2 (>= 0.9.7)
Recommends: fonts-noto-color-emoji
Replaces: gnome-characters
Conflicts: gnome-characters
Provides: gnome-characters (= 3.34.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Design/Apps/CharacterMap
Description: character map application
 GNOME Characters ${VER_UP} — official Ubuntu 20.04
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
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'Version: 3.34.0-1kemi1' "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'gjs (>= 1.49)' "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'Provides: gnome-characters (= 3.34.0-1)' "$ROOT/evidence/kemi-gnome-characters-control.txt"
grep -q 'Recommends: fonts-noto-color-emoji' "$ROOT/evidence/kemi-gnome-characters-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-characters-control.txt"

python3 - << END_GNOME_CHARACTERS_TREE
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gnome-characters",
    "./usr/bin/kemi-gnome-characters",
    "./opt/gnome-characters/gnome-characters",
    "./usr/share/applications/org.gnome.Characters.desktop",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Characters.svg",
    "./usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so",
    "./usr/lib/aarch64-linux-gnu/org.gnome.Characters/girepository-1.0/Gc-1.0.typelib",
    "./usr/share/org.gnome.Characters/org.gnome.Characters",
    "./usr/share/glib-2.0/schemas/org.gnome.Characters.gschema.xml",
    "./usr/share/dbus-1/services/org.gnome.Characters.service",
    "./usr/share/metainfo/org.gnome.Characters.appdata.xml",
    "./usr/share/doc/kemi-gnome-characters/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gnome-characters-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = found_kemi = found_lib = False
for line in out.splitlines():
    if ("./usr/bin/gnome-characters " in line or line.rstrip().endswith("./usr/bin/gnome-characters")) and "kemi-gnome-characters" not in line:
        found_bin = True
        if "->" not in line:
            raise SystemExit("BIN_EXPECTED_OFFICIAL_SYMLINK:" + line)
    if "./usr/bin/kemi-gnome-characters" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
    if "./usr/lib/aarch64-linux-gnu/org.gnome.Characters/libgc.so" in line:
        found_lib = True
        if "->" in line:
            raise SystemExit("LIB_UNEXPECTED_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
if not found_lib:
    raise SystemExit("MISSING_LIB")
print("DEB_TREE_OK")
END_GNOME_CHARACTERS_TREE
echo "BUILD_OK $DEB"
