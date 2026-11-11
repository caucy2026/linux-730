#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal main)
# gnome-power-manager 3.32.0-2 Architecture: arm64
# as kemi-gnome-power-manager. No newer package
# in focal-updates / focal-security /
# focal-backports. The gnome-power-manager source
# ships only this one binary package in focal
# (no same-source -data/-common or exact-version
# library to bundle). Official different-source
# Depends (GTK / glib / cairo / pango /
# pangocairo / libupower-glib3 / libc6 /
# dconf-gsettings-backend | gsettings-backend /
# default-dbus-session-bus | dbus-session-bus /
# gnome-settings-daemon-common / upower) stay
# Depends, unbundled. Official control has no
# Recommends and no Suggests. Versioned Provides:
# gnome-power-manager (= 3.32.0-2). No Debian
# epoch, no tilde. Official user-facing binary
# is /usr/bin/gnome-power-statistics (compiled
# aarch64 ELF, glibc 2.27, no GLIBCXX, no
# RUNPATH) and stays at the official path;
# /opt/gnome-power-manager/* are symlinks only.
# Also /usr/bin/kemi-gnome-power-manager →
# gnome-power-statistics. Official package ships
# no .mo (Ubuntu language-pack split); invent
# none. Official app icons are 16/22/24/32/48
# PNG plus scalable and symbolic SVG; no official
# 256×256 PNG. A 128×128 PNG rasterized from the
# official app SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/org.gnome.PowerStats-128.png and is
# used only as the mall CREATE --icon; it is not
# shipped in the deb. Official 16–48 PNGs and
# SVGs pack once at official paths. Official
# changelog.Debian.gz and NEWS.gz are real files
# and are copied with cp -L. Official desktop
# Name=Power Statistics is kept; mall app_name
# is GNOME Power Statistics (official appdata
# <name>). Official desktop Exec=gnome-power-statistics
# is rewritten to /usr/bin/gnome-power-statistics;
# TryExec is added; Icon=org.gnome.PowerStats is
# kept. Official maintainer scripts
# (dpkg-maintscript-helper rm_conffile for
# historical gnome-power-manager conffiles) are
# kept; the rm_conffile package argument stays
# the official historical name. Icon-cache,
# desktop-database and glib-compile-schemas hooks
# are appended. Official package has no
# py3compile hooks; none are invented. Probe:
# Architecture arm64 · 1 unique packaged ELF ·
# requiredGlibc 2.27 (1 versioned, 0 null) · no
# GLIBCXX (0 versioned, 1 null; null is not
# ranked as a max) · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com and Aliyun ubuntu-ports pool
# files and the Ubuntu 20.04 focal main arm64
# Packages stanza (streamed). No librarian URL
# and no .buildinfo is recorded this run (pool
# 404). KEMI version 3.32.0-2kemi1 is 13 chars
# (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28 char
# siblings succeeded). No epoch, no tilde, no
# shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-power-statistics
VER_UP=3.32.0-2
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-power-manager
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/gnome-power-manager}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-power-manager_3.32.0-2_arm64.deb"
EXPECT_SHA=cd7eff3bdd3ca0991d407a948954f4c6141e2ea276e140cbd65389918b3ce89d
EXPECT_BYTES=47056
python3 - << PY
s="${VER_DEB}"
assert len(s) == 13, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-power-statistics"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/bin/gnome-power-statistics")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 63560
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.PowerStats.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.PowerStats.svg"
test -f "$UNPACK/usr/share/icons/hicolor/16x16/apps/org.gnome.PowerStats.png"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/org.gnome.PowerStats.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.PowerStats.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.power-manager.gschema.xml"
test ! -L "$UNPACK/usr/share/doc/gnome-power-manager/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-power-manager/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-power-manager/NEWS.gz"
test -f "$ROOT/evidence/org.gnome.PowerStats-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.PowerStats-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "77f620d0a861403a6688a160d99b888dcbe069c219a7fd1d43824ab3ac25cf3a"
print("evidence_128_ok", w, h, p.stat().st_size)
mos = list(Path("$UNPACK").rglob("*.mo"))
assert mos == [], mos
print("official_mo_0_none_invented")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-power-manager"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
# official maintainer scripts (rm_conffile keeps the official historical package name)
cp -a "$UNPACK/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/DEBIAN/postrm" "$STAGE/pkg/DEBIAN/postrm"
cp -a "$UNPACK/DEBIAN/preinst" "$STAGE/pkg/DEBIAN/preinst"
cp -a "$UNPACK/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-power-statistics"
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm" \
  "$STAGE/pkg/DEBIAN/preinst" "$STAGE/pkg/DEBIAN/prerm"

REPORT="$ROOT/probe/kemi-gnome-power-manager.json"
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
if Path(f["path"]).name != "gnome-power-statistics":
    raise SystemExit("PROBE_NAME")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.27":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + str(f.get("requiredGlibcxx")))
if f.get("sha256") != "66a0a76cacbf25c527f0ba0e7c11dcc8af13058073f583eb391d5cec7cf3731e":
    raise SystemExit("PROBE_SHA:" + str(f.get("sha256")))
if int(f.get("bytes") or 0) != 63560:
    raise SystemExit("PROBE_BYTES")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.27 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.PowerStats.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/16x16/apps/org.gnome.PowerStats.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/org.gnome.PowerStats.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.PowerStats.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'org.gnome.PowerStats-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-power-manager/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-power-manager/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.PowerStats.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.PowerStats.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Power Statistics\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=gnome-power-statistics\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = re.sub(
    r"^Exec=gnome-power-statistics\b",
    "Exec=/usr/bin/gnome-power-statistics",
    text,
    flags=re.M,
)
text = re.sub(
    r"^Exec=/usr/bin/gnome-power-statistics.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-power-statistics",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/gnome-power-statistics" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/gnome-power-statistics" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-power-statistics"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-power-statistics":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-power-statistics/scripts/build-gnome-power-manager-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-power-statistics\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/gnome-power-statistics" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-power-statistics "$STAGE/pkg/opt/gnome-power-manager/gnome-power-statistics"
ln -sf gnome-power-statistics "$STAGE/pkg/usr/bin/kemi-gnome-power-manager"

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

python3 - << PY
import subprocess
from pathlib import Path
elf = Path("$STAGE/pkg/usr/bin/gnome-power-statistics")
out = subprocess.check_output(["readelf", "-d", str(elf)], text=True, errors="replace")
if "RPATH" in out or "RUNPATH" in out:
    raise SystemExit("UNEXPECTED_RUNPATH")
print("no_runpath")
PY

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-power-manager (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal main)
    gnome-power-manager 3.32.0-2 arm64, KEMI mall
    linuxpkg repack. Official user-facing binary
    is /usr/bin/gnome-power-statistics. No
    same-source -common or exact-version library
    to bundle. Official GTK / glib / cairo /
    pango / upower / libc6 / gnome-settings-daemon-common
    Depends stay Depends. Official control has
    no Recommends and no Suggests. Versioned
    Provides: gnome-power-manager (= 3.32.0-2).
    Official /usr/bin/gnome-power-statistics
    stays at the official path;
    /opt/gnome-power-manager/* are symlinks.
    Also /usr/bin/kemi-gnome-power-manager →
    gnome-power-statistics. Official desktop
    Name=Power Statistics kept; Exec rewritten
    to /usr/bin/gnome-power-statistics; TryExec
    added. Official changelog is a real file and
    was copied with cp -L. Official icons are
    16–48 PNG plus SVG (no official 256 PNG); a
    128×128 evidence PNG rasterized from the
    official SVG is used only as mall CREATE
    --icon and is not packed. Official package
    ships no .mo; none invented. Official
    rm_conffile maintainer scripts kept;
    icon-cache, desktop-database and
    glib-compile-schemas hooks appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
GNOME Power Statistics — official Ubuntu 20.04
(focal main) gnome-power-manager 3.32.0-2
arm64, KEMI repack. Official user-facing
binary /usr/bin/gnome-power-statistics is an
aarch64 ELF and stays under /usr.
/opt/gnome-power-manager/* are symlinks.
Official GTK / glib / cairo / pango / upower /
libc6 / gnome-settings-daemon-common Depends
stay Depends and are not bundled. Official
control has no Recommends and no Suggests.
Official package ships no .mo (keep official;
do not invent language packs). Official icons
are 16–48 PNG plus SVG; a 128×128 evidence PNG
is used only as mall CREATE --icon and is not
packed. Official desktop Name=Power Statistics
is kept; mall app_name is GNOME Power
Statistics (official appdata <name>).
Probe: 1 unique ELF · requiredGlibc 2.27 (1
versioned, 0 null; no max invented from null) ·
no requiredGlibcxx (0 versioned, 1 null; null
not ranked as a max) · no RUNPATH; within
Ubuntu 20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal main gnome-power-manager
3.32.0-2 (arm64). Official SHA256 + size
matched ports.ubuntu.com and Aliyun
ubuntu-ports pool files and the focal main
arm64 Packages stanza. No librarian URL this
run.
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
Depends: libc6 (>= 2.27), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.45.8), libgtk-3-0 (>= 3.4.0), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libupower-glib3 (>= 0.99.8), dconf-gsettings-backend | gsettings-backend, default-dbus-session-bus | dbus-session-bus, gnome-settings-daemon-common, upower (>= 0.99)
Replaces: gnome-power-manager
Conflicts: gnome-power-manager
Provides: gnome-power-manager (= 3.32.0-2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://projects.gnome.org/gnome-power-manager/
Description: power management tool for the GNOME desktop
 GNOME Power Statistics ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of
 gnome-power-manager. Official binary is
 gnome-power-statistics.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Append hooks with a quoted heredoc so $1 is not expanded under set -u
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# kemi hooks
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
HOOK
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
# kemi hooks
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
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg-maintscript-helper rm_conffile' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gnome-power-manager -- "\$@"' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
grep -q 'Version: 3.32.0-2kemi1' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
grep -q 'libc6 (>= 2.27)' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
grep -q 'Provides: gnome-power-manager (= 3.32.0-2)' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
grep -q 'Conflicts: gnome-power-manager' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-power-manager-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
import re
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/org.gnome.PowerStats.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Power Statistics" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/gnome-power-statistics" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-power-statistics" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=gnome-power-statistics\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-power-statistics"
test -L "$CHECK/usr/bin/kemi-gnome-power-manager"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-power-manager")" = "gnome-power-statistics"
test -L "$CHECK/opt/gnome-power-manager/gnome-power-statistics"
test "$(readlink "$CHECK/opt/gnome-power-manager/gnome-power-statistics")" = "/usr/bin/gnome-power-statistics"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/org.gnome.PowerStats.svg"
test -f "$CHECK/usr/share/icons/hicolor/48x48/apps/org.gnome.PowerStats.png"
if find "$CHECK" -name 'org.gnome.PowerStats-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
# official changelog still present at official path (real file)
test -f "$CHECK/usr/share/doc/gnome-power-manager/changelog.Debian.gz"
test ! -L "$CHECK/usr/share/doc/gnome-power-manager/changelog.Debian.gz"
sha256sum "$CHECK/usr/bin/gnome-power-statistics"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
