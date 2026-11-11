#!/bin/bash
# Wrap official Ubuntu 20.04 (focal-updates
# main) cheese 3.34.0-1ubuntu1 Architecture:
# arm64 as kemi-cheese. Newer than focal
# Release 3.34.0-1build1. Not present in
# focal-security or focal-backports. Official
# same-source arch:all cheese-common
# 3.34.0-1ubuntu1 is bundled: the GUI hard
# Depends is cheese-common (>= 3.34.0-1ubuntu1),
# a >= of the named same-source data package,
# and only that one official focal version
# matches (3.34.0-1build1 does not satisfy the
# constraint). This is the official -data /
# gnome-todo-common / gnome-terminal-data
# pattern. Same-source library Depends
# libcheese-gtk25 (>= 3.18.0) and libcheese8
# (>= 3.18.0) are not exact-version and are
# not a tight same-series range; they stay
# Depends, unbundled. Same-source
# gir1.2-cheese-3.0, libcheese-dev,
# libcheese-gtk-dev and libcheese-doc were
# inspected and are not packaged. Different-
# source Depends stay Depends. Official
# Recommends gvfs, yelp stay Recommends.
# Official Suggests gnome-video-effects-frei0r
# stay Suggests. Versioned Provides: cheese
# (= 3.34.0-1ubuntu1), cheese-common
# (= 3.34.0-1ubuntu1). No Debian epoch, no
# tilde. Official /usr/bin/cheese is a
# compiled aarch64 ELF (requiredGlibc 2.17,
# no GLIBCXX, no RUNPATH) and stays at the
# official path. Official files stay on
# official paths; /opt/cheese/* are
# symlinks only. Also /usr/bin/kemi-cheese →
# cheese. Official packages ship no .mo
# (Ubuntu language-pack split); do not invent
# language packs. Official help in bundled
# cheese-common (C plus translated trees;
# some figures resolve into C; help-langpack
# page symlinks may dangle) stays official.
# Official help PNGs stay official and are
# not used as mall icons. Official icons in
# cheese-common are SVG only
# (org.gnome.Cheese.svg plus symbolic); there
# is no official 256×256 PNG. A 128×128 PNG
# rasterized from the official scalable SVG
# is used only as the mall CREATE --icon and
# is not packed. Official desktop Name=Cheese
# is kept; mall app_name is Cheese (the usual
# upstream name used in the official package
# Description, README, appdata and
# wiki.gnome.org/Apps/Cheese; official
# GenericName=Webcam Booth is kept in the
# desktop file and is not used as mall
# app_name). Official desktop Exec=cheese is
# rewritten to /usr/bin/cheese; TryExec is
# added. Official D-Bus Exec is already
# absolute and is kept. Official GUI
# changelog.Debian.gz is a dangling symlink
# into ../libcheese-gtk25/changelog.Debian.gz,
# which itself is a dangling symlink into
# libcheese8; those libs are not bundled, so
# the dangling GUI symlink is not packed.
# The real official changelog from
# libcheese8 is copied with cp -L into the
# kemi doc dir only. Official cheese-common
# changelog is a real file and stays at its
# official path. Official NEWS.gz is a real
# file. Official packages have no maintainer
# scripts; icon-cache, desktop-database and
# glib-compile-schemas hooks are added. No
# py3compile hooks; none are invented.
# cheese-common Depends
# (dconf-gsettings-backend | gsettings-backend)
# are merged into the kemi Depends. Probe:
# Architecture arm64 · 1 unique packaged ELF
# · requiredGlibc 2.17 (1 versioned, 0 null)
# · no GLIBCXX (0 versioned, 1 null; null is
# not ranked as a max) · within 101 ≤2.31 /
# ≤3.4.28. Official SHA256 + size matched
# official ports.ubuntu.com pool files and
# the Ubuntu 20.04 focal-updates main arm64
# Packages stanza (Aliyun ubuntu-ports
# mirror, streamed). No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 3.34.0-1ubuntu1kemi1 is 20
# chars (under the mall version_name limit
# that rejected Remmina's 33-char string;
# 12–28 char siblings succeeded, including
# Vinagre 28). No epoch, no tilde, no
# shortening applied unless the mall later
# rejects 20. gork.bot协助开发 · Verify ≠
# compile

set -euo pipefail
ROOT=/workspace/t142-20261112-cheese
VER_UP=3.34.0-1ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-cheese
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/cheese_3.34.0-1ubuntu1_arm64}"
COMMON="${COMMON:-$ROOT/unpack-official/cheese-common_3.34.0-1ubuntu1_all}"
LIB8="${LIB8:-$ROOT/unpack-official/libcheese8_3.34.0-1ubuntu1_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/cheese_3.34.0-1ubuntu1_arm64.deb"
COMMON_DEB="$DL/cheese-common_3.34.0-1ubuntu1_all.deb"
EXPECT_SHA=505e1299716ec33473bdd6292f7c5790e75cb39f9b8639385160ed657a2c676d
EXPECT_BYTES=135376
COMMON_SHA=c7eae12d2aae9b031ac09592c471dd681f839685178fc0878b066c3ef6b04def
COMMON_BYTES=390200
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
assert "~" not in s, s
assert s == "3.34.0-1ubuntu1kemi1"
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$COMMON_DEB"
test "$(stat -c%s "$COMMON_DEB")" = "$COMMON_BYTES"
echo "$COMMON_SHA  $COMMON_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/cheese"
python3 - << PY
from pathlib import Path
import hashlib
elf = Path("$UNPACK/usr/bin/cheese")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 260240
assert hashlib.sha256(elf.read_bytes()).hexdigest() == "ad455d46233399471286d583015aa760b58f287ca625e420c568e74267f1e10f"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Cheese.desktop"
test -f "$COMMON/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg"
test ! -f "$COMMON/usr/share/icons/hicolor/256x256/apps/org.gnome.Cheese.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Cheese.png"
test -f "$COMMON/usr/share/glib-2.0/schemas/org.gnome.Cheese.gschema.xml"
test -L "$UNPACK/usr/share/doc/cheese/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/cheese/changelog.Debian.gz"
test -f "$LIB8/usr/share/doc/libcheese8/changelog.Debian.gz"
test ! -L "$LIB8/usr/share/doc/libcheese8/changelog.Debian.gz"
test -f "$COMMON/usr/share/doc/cheese-common/changelog.Debian.gz"
test ! -L "$COMMON/usr/share/doc/cheese-common/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.Cheese-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib, re
ev = Path("$ROOT/evidence/org.gnome.Cheese-128.png")
data = ev.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128)
assert hashlib.sha256(data).hexdigest() == "84fc9e2c556691a0784a8c845519f71b02394e605d09894d175fc126b0cd7586"
assert ev.stat().st_size == 7611
svg = Path("$COMMON/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "6f8b597082d61be7faf895d43e5a3f142cc4acec9819fd36089ad4b1ae72eb85"
assert svg.stat().st_size == 5940
assert list(Path("$UNPACK").rglob("*.mo")) == []
assert list(Path("$COMMON").rglob("*.mo")) == []
desk = Path("$UNPACK/usr/share/applications/org.gnome.Cheese.desktop").read_text()
assert re.search(r"^Name=Cheese\s*$", desk, flags=re.M)
assert re.search(r"^Icon=org.gnome.Cheese\s*$", desk, flags=re.M)
assert re.search(r"^GenericName=Webcam Booth\s*$", desk, flags=re.M)
print("official_icons_and_desktop_ok")
chg = Path("$LIB8/usr/share/doc/libcheese8/changelog.Debian.gz")
assert hashlib.sha256(chg.read_bytes()).hexdigest() == "16c6740b238999e0b1a5f97c33a345aef18f5fd6f6bfd0b623397acb6fd87641"
assert chg.stat().st_size == 1211
print("official_libcheese8_changelog_ok")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/cheese"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
cp -a "$COMMON/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/cheese"

# Official GUI changelog is a dangling symlink into
# unbundled libcheese-gtk25 / libcheese8; do not pack it.
if [[ -L "$STAGE/pkg/usr/share/doc/cheese/changelog.Debian.gz" ]]; then
  rm -f "$STAGE/pkg/usr/share/doc/cheese/changelog.Debian.gz"
fi
test ! -e "$STAGE/pkg/usr/share/doc/cheese/changelog.Debian.gz"
# bundled cheese-common official changelog stays
test -f "$STAGE/pkg/usr/share/doc/cheese-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/cheese-common/changelog.Debian.gz"
# do not pack unbundled lib trees
test ! -d "$STAGE/pkg/usr/share/doc/libcheese8"
test ! -d "$STAGE/pkg/usr/share/doc/libcheese-gtk25"
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libcheese.so.8"
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libcheese-gtk.so.25"

REPORT="$ROOT/probe/kemi-cheese.json"
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
if Path(f["path"]).name != "cheese":
    raise SystemExit("PROBE_NAMES:" + Path(f["path"]).name)
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
if f.get("sha256") != "ad455d46233399471286d583015aa760b58f287ca625e420c568e74267f1e10f":
    raise SystemExit("PROBE_SHA")
if int(f.get("bytes") or 0) != 260240:
    raise SystemExit("PROBE_BYTES")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if None in {x.get("requiredGlibc") for x in versioned}:
    raise SystemExit("PROBE_NULL_RANKED_AS_MAX")
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
print("PROBE_PASS n_elf=1 unique aarch64 requiredGlibc 2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Cheese.png"
if find "$STAGE/pkg" -name 'org.gnome.Cheese-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/help/C/cheese/figures/cheese.png"
test -f "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Cheese.service"
grep -qx 'Exec=/usr/bin/cheese --gapplication-service' "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Cheese.service"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/cheese/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
# real official changelog from libcheese8 (what the official GUI symlink chain would resolve to)
cp --remove-destination -L \
  "$LIB8/usr/share/doc/libcheese8/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
from pathlib import Path
import hashlib
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "16c6740b238999e0b1a5f97c33a345aef18f5fd6f6bfd0b623397acb6fd87641"
print("kemi_changelog_from_libcheese8_ok")
PY

export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Cheese.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
src = Path("/workspace/t142-20261112-cheese/unpack-official/cheese_3.34.0-1ubuntu1_arm64/usr/share/applications/org.gnome.Cheese.desktop")
text = src.read_text()
if not re.search(r"^Name=Cheese\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=cheese\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
out = []
inserted = False
for line in text.splitlines(True):
    if line.startswith("Exec=cheese"):
        rest = line[len("Exec="):]
        line = "Exec=/usr/bin/" + rest
        out.append(line)
        if not inserted:
            out.append("TryExec=/usr/bin/cheese\n")
            inserted = True
    else:
        out.append(line)
text = "".join(out)
if not re.search(r"^Exec=/usr/bin/cheese\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if text.count("TryExec=/usr/bin/cheese") != 1:
    raise SystemExit("DESKTOP_TRYEXEC_COUNT")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
if not re.search(r"^Name=Cheese\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME_LOST")
if not re.search(r"^GenericName=Webcam Booth\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERIC")
if not re.search(r"^Icon=org.gnome.Cheese\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ICON")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/cheese"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/cheese":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-cheese/scripts/build-cheese-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/cheese\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/cheese "$STAGE/pkg/opt/cheese/cheese"
ln -sf cheese "$STAGE/pkg/usr/bin/kemi-cheese"

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

python3 - << PY
import subprocess
from pathlib import Path
root = Path("$STAGE/pkg")
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.read_bytes()[:4] != bytes([0x7F]) + b"ELF":
        continue
    out = subprocess.check_output(["readelf", "-d", str(p)], text=True, errors="replace")
    if "RPATH" in out or "RUNPATH" in out:
        raise SystemExit("UNEXPECTED_RUNPATH:" + str(p))
print("no_runpath")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-cheese (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    cheese 3.34.0-1ubuntu1 arm64, KEMI mall
    linuxpkg repack. Newer than focal Release
    3.34.0-1build1. Official same-source
    arch:all cheese-common 3.34.0-1ubuntu1
    bundled (GUI hard Depends cheese-common
    (>= 3.34.0-1ubuntu1); only one matching
    official focal version). Same-source
    libcheese-gtk25 and libcheese8 stay
    Depends (loose >=, not exact-version).
    Different-source Depends stay Depends.
    Official Recommends gvfs, yelp stay
    Recommends. Official Suggests
    gnome-video-effects-frei0r stay Suggests.
    Versioned Provides: cheese /
    cheese-common (= 3.34.0-1ubuntu1). No
    Debian epoch, no tilde. Official
    /usr/bin/cheese stays at the official
    path; /opt/cheese/* are symlinks. Also
    /usr/bin/kemi-cheese → cheese. Official
    desktop Name=Cheese kept; mall app_name
    is Cheese; Exec rewritten to
    /usr/bin/cheese; TryExec added. Official
    GUI changelog dangling symlink into
    unbundled lib was not packed; real
    official libcheese8 changelog copied
    with cp -L. Official icons are SVG only;
    a 128 evidence PNG is CREATE-only and
    is not packed. Official packages ship
    no .mo; none invented. Icon-cache,
    desktop-database and
    glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 03:26:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Cheese — official Ubuntu 20.04 (focal-updates
main) cheese 3.34.0-1ubuntu1 arm64, KEMI
repack. Official /usr/bin/cheese is an
aarch64 ELF and stays under /usr. /opt/cheese/*
are symlinks. Official same-source
cheese-common 3.34.0-1ubuntu1 is bundled.
Same-source libcheese-gtk25 / libcheese8 stay
Depends. Different-source Depends stay
Depends. Official Recommends gvfs, yelp stay
Recommends. Official Suggests
gnome-video-effects-frei0r stay Suggests.
Official packages ship no .mo. Official icons
are SVG only; a 128 evidence PNG is used only
as mall CREATE --icon and is not packed.
Official desktop Name=Cheese; mall app_name
is Cheese. No Debian epoch, no tilde. Probe: 1
unique ELF · requiredGlibc 2.17 (1 versioned,
0 null; no max invented from null) · no
requiredGlibcxx (0 versioned, 1 null; null not
ranked as a max) · no RUNPATH; within Ubuntu
20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal-updates main cheese
3.34.0-1ubuntu1 (arm64). Official SHA256 +
size matched ports.ubuntu.com pool files and
the Packages stanza. No librarian URL this
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
Depends: libc6 (>= 2.17), libcanberra-gtk3-0 (>= 0.25), libcheese-gtk25 (>= 3.18.0), libcheese8 (>= 3.18.0), libclutter-1.0-0 (>= 1.16), libclutter-gtk-1.0-0 (>= 0.91.8), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.39.90), libgnome-desktop-3-19 (>= 3.17.92), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.21.5), gnome-video-effects, dconf-gsettings-backend | gsettings-backend
Recommends: gvfs, yelp
Suggests: gnome-video-effects-frei0r
Replaces: cheese, cheese-common
Conflicts: cheese, cheese-common
Provides: cheese (= 3.34.0-1ubuntu1), cheese-common (= 3.34.0-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Cheese
Description: tool to take pictures and videos from your webcam
 Cheese ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack. Bundles official
 cheese-common.
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
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'Version: 3.34.0-1ubuntu1kemi1' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'libcheese-gtk25 (>= 3.18.0)' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'libcheese8 (>= 3.18.0)' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'gnome-video-effects' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'dconf-gsettings-backend | gsettings-backend' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'Recommends: gvfs, yelp' "$ROOT/evidence/kemi-cheese-control.txt"
grep -q 'Suggests: gnome-video-effects-frei0r' "$ROOT/evidence/kemi-cheese-control.txt"
# Provides may be one line; check substrings
python3 - << PY
from pathlib import Path
text = Path("$ROOT/evidence/kemi-cheese-control.txt").read_text()
assert "cheese (= 3.34.0-1ubuntu1)" in text
assert "cheese-common (= 3.34.0-1ubuntu1)" in text
assert "Conflicts: cheese, cheese-common" in text or ("Conflicts: cheese" in text and "cheese-common" in text)
print("provides_conflicts_ok")
PY
# cheese-common must not remain a Depends
! grep -q 'cheese-common' <(grep -E '^ Depends:' "$ROOT/evidence/kemi-cheese-control.txt")

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
desk = Path("$CHECK/usr/share/applications/org.gnome.Cheese.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if not re.search(r"^Name=Cheese\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_NAME")
if not re.search(r"^Exec=/usr/bin/cheese\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/cheese" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=cheese\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
if not re.search(r"^Icon=org.gnome.Cheese\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_ICON")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/cheese"
test -L "$CHECK/usr/bin/kemi-cheese"
test "$(readlink "$CHECK/usr/bin/kemi-cheese")" = "cheese"
test -L "$CHECK/opt/cheese/cheese"
test "$(readlink "$CHECK/opt/cheese/cheese")" = "/usr/bin/cheese"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg"
test ! -f "$CHECK/usr/share/icons/hicolor/256x256/apps/org.gnome.Cheese.png"
if find "$CHECK" -name 'org.gnome.Cheese-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -e "$CHECK/usr/share/doc/cheese/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/cheese-common/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test -f "$CHECK/usr/share/glib-2.0/schemas/org.gnome.Cheese.gschema.xml"
test ! -d "$CHECK/usr/share/doc/libcheese8"
test ! -d "$CHECK/usr/share/doc/libcheese-gtk25"
# hash the published deb by explicit path, never find|head
sha256sum "$CHECK/usr/bin/cheese"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
