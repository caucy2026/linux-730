#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal main) gnome-todo
# 3.28.1-5 Architecture: arm64 as kemi-gnome-todo,
# bundling same-source exact-version hard Depends
# libgnome-todo (= 3.28.1-5) and official arch:all
# -common hard Depends gnome-todo-common (>= 3.28.1-5)
# (only that version exists in any focal pocket).
# No newer package in focal-updates / focal-security /
# focal-backports. Official gir1.2-gtd-1.0 and
# libgnome-todo-dev are same-source but are not GUI
# hard Depends; they were inspected and are not
# packaged (the typelib is used only by optional
# official Python plugins; the -dev package is
# headers / .gir / pkgconfig). Official typelib /
# EDS / GOA / GTK / peas / rest / ical / libc6
# Depends stay Depends, unbundled (different source
# or non-bundled typelib). Official control has no
# Recommends and no Suggests. Official common Depends
# dconf-gsettings-backend | gsettings-backend is
# inherited. Versioned Provides: gnome-todo
# (= 3.28.1-5), gnome-todo-common (= 3.28.1-5),
# libgnome-todo (= 3.28.1-5). No Debian epoch, no
# tilde. Official /usr/bin/gnome-todo is a compiled
# aarch64 ELF (glibc 2.17, no GLIBCXX, no RUNPATH)
# that embeds /usr/lib/aarch64-linux-gnu/gnome-todo
# and /usr/share/gnome-todo; official files stay on
# official paths; /opt/gnome-todo/* are symlinks
# only. Also /usr/bin/kemi-gnome-todo → gnome-todo.
# Official libgnome-todo ships two libpeas Python3
# plugins (score, unscheduled-panel) and no ELF;
# those wrappers must not be counted as ELFs.
# Official packages ship no .mo (Ubuntu language-pack
# split); keep official tree; do not invent packs.
# Official app icons (16/22/32/48/256/512 PNG +
# symbolic SVG) live in gnome-todo-common; official
# 256×256 PNG is used as mall CREATE --icon and is
# packed only at the official hicolor path (evidence
# copy is not packed a second time). Official GUI
# changelog.Debian.gz is a dangling symlink into the
# same-source lib doc dir; because libgnome-todo is
# bundled at its official doc path, the official
# symlink is kept and resolves; the real official
# lib changelog is also copied with cp -L into the
# kemi doc dir. Official desktop Name=To Do is kept;
# mall app_name is GNOME To Do. Official desktop
# Exec=gnome-todo is rewritten to /usr/bin/gnome-todo;
# TryExec is added; Icon=org.gnome.Todo and
# DBusActivatable=true are kept. Official D-Bus
# Exec=/usr/bin/gnome-todo --gapplication-service is
# already absolute and is kept. Official Autostart
# Exec=gapplication action org.gnome.Todo start-client
# is kept official. Official packages have no
# maintainer scripts, no shlibs, and no ldconfig
# trigger; icon-cache, desktop-database and
# glib-compile-schemas hooks are added. Official
# packages have no py3compile hooks (private plugin
# path); none are invented. Probe: Architecture
# arm64 · 1 unique packaged ELF · requiredGlibc 2.17
# (1 versioned, 0 null) · no GLIBCXX (0 versioned,
# 1 null; null is not ranked as a max) · official
# Python plugins are not ELFs · within 101 ≤2.31 /
# ≤3.4.28. Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04
# focal main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL
# and no .buildinfo is recorded this run (pool 404).
# KEMI version 3.28.1-5kemi1 is 13 chars (under the
# mall version_name limit that rejected Remmina's
# 33-char string; 12–28 char siblings succeeded).
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-todo
VER_UP=3.28.1-5
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-todo
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/gnome-todo_3.28.1-5_arm64}"
COMMON="${COMMON:-$ROOT/unpack-official/gnome-todo-common_3.28.1-5_all}"
LIB="${LIB:-$ROOT/unpack-official/libgnome-todo_3.28.1-5_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-todo_3.28.1-5_arm64.deb"
UP_COMMON="$DL/gnome-todo-common_3.28.1-5_all.deb"
UP_LIB="$DL/libgnome-todo_3.28.1-5_arm64.deb"
EXPECT_SHA=7163211212df90d6722e0e802996c716fd5ec22c53d875d567c7ddf1d76edb5e
EXPECT_BYTES=135228
EXPECT_COMMON_SHA=98694f3c64fe78ae175636e4260ac28349a040676f87c2ac655a3f3cb171eefc
EXPECT_COMMON_BYTES=119504
EXPECT_LIB_SHA=39aba3b3df0373beb303d8643836cde17edf38157c8b6a9c20bc242d2a2838c2
EXPECT_LIB_BYTES=5376
python3 - << PY
s="${VER_DEB}"
assert len(s) == 13, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB" && test -f "$UP_COMMON" && test -f "$UP_LIB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
test "$(stat -c%s "$UP_LIB")" = "$EXPECT_LIB_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
echo "$EXPECT_LIB_SHA  $UP_LIB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-todo"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/bin/gnome-todo")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 400400
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Todo.desktop"
test -f "$COMMON/usr/share/icons/hicolor/256x256/apps/org.gnome.Todo.png"
test -f "$COMMON/usr/share/dbus-1/services/org.gnome.Todo.service"
test -f "$COMMON/usr/share/glib-2.0/schemas/org.gnome.todo.gschema.xml"
test -f "$LIB/usr/lib/aarch64-linux-gnu/gnome-todo/plugins/score/score.plugin"
test -f "$LIB/usr/lib/aarch64-linux-gnu/gnome-todo/plugins/unscheduled-panel/unscheduled-panel/__init__.py"
# official GUI changelog is a dangling symlink into lib doc
test -L "$UNPACK/usr/share/doc/gnome-todo/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/gnome-todo/changelog.Debian.gz"
test ! -L "$LIB/usr/share/doc/libgnome-todo/changelog.Debian.gz"
test -f "$LIB/usr/share/doc/libgnome-todo/changelog.Debian.gz"
test ! -L "$COMMON/usr/share/doc/gnome-todo-common/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.Todo-256.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Todo-256.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (256, 256), (w, h)
assert hashlib.sha256(data).hexdigest() == "ffd9741b68d2ff9f7c4dba0ffe9979b326bc677867b75a8a499eca488da76f00"
official = Path("$COMMON/usr/share/icons/hicolor/256x256/apps/org.gnome.Todo.png").read_bytes()
assert official == data
print("evidence_256_matches_official", w, h, p.stat().st_size)
# official plugins are Python, not ELF
for rel in [
    "usr/lib/aarch64-linux-gnu/gnome-todo/plugins/score/score/__init__.py",
    "usr/lib/aarch64-linux-gnu/gnome-todo/plugins/unscheduled-panel/unscheduled-panel/__init__.py",
]:
    b = Path("$LIB", rel).read_bytes()
    assert b[:2] == b"#!"
    assert b[:4] != bytes([0x7F]) + b"ELF"
print("official_plugins_not_elf")
# no .mo in official trees
from pathlib import Path as P
for root in ("$UNPACK", "$COMMON", "$LIB"):
    mos = list(P(root).rglob("*.mo"))
    assert mos == [], mos
print("official_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-todo"

# bundle official -common and exact-version lib first, then official GUI
cp -a "$COMMON/usr/." "$STAGE/pkg/usr/"
cp -a "$LIB/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-todo"
# official GUI changelog symlink now resolves into bundled lib doc
test -L "$STAGE/pkg/usr/share/doc/gnome-todo/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/gnome-todo/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libgnome-todo/changelog.Debian.gz"

REPORT="$ROOT/probe/kemi-gnome-todo.json"
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
if Path(f["path"]).name != "gnome-todo":
    raise SystemExit("PROBE_NAME")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + str(f.get("requiredGlibcxx")))
if f.get("sha256") != "bc9ebdbf6b4d5ce472760eeaa8cbc64884f1db5b4ca44c331c9e121031e2c299":
    raise SystemExit("PROBE_SHA:" + str(f.get("sha256")))
if int(f.get("bytes") or 0) != 400400:
    raise SystemExit("PROBE_BYTES")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
for rel in [
    "usr/lib/aarch64-linux-gnu/gnome-todo/plugins/score/score/__init__.py",
    "usr/lib/aarch64-linux-gnu/gnome-todo/plugins/unscheduled-panel/unscheduled-panel/__init__.py",
]:
    w = Path("$STAGE/pkg", rel)
    if w.read_bytes()[:2] != b"#!":
        raise SystemExit("PLUGIN_MISSING")
    if w.read_bytes()[:4] == bytes([0x7F]) + b"ELF":
        raise SystemExit("PLUGIN_COUNTED_AS_ELF")
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) official Python plugins not ELF configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Todo.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'org.gnome.Todo-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-todo/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$LIB/usr/share/doc/libgnome-todo/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.Todo.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Todo.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
src = Path(os.environ["UNPACK_DESKTOP"]).read_text()
text = src
if not re.search(r"^Name=To Do\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=gnome-todo\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = re.sub(
    r"^Exec=gnome-todo\b",
    "Exec=/usr/bin/gnome-todo",
    text,
    flags=re.M,
)
text = re.sub(
    r"^Exec=/usr/bin/gnome-todo.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-todo",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/gnome-todo" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/gnome-todo" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-todo"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-todo":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Todo.service").read_text()
if "Exec=/usr/bin/gnome-todo --gapplication-service" not in svc:
    raise SystemExit("DBUS_EXEC")
auto = Path("$STAGE/pkg/usr/share/gnome-todo/org.gnome.Todo.Autostart.desktop").read_text()
if "Exec=gapplication action org.gnome.Todo start-client" not in auto:
    raise SystemExit("AUTOSTART_EXEC")
print("dbus_and_autostart_kept_official")
PY

# confirm this build script did not use a regex \\1 replacement
python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-todo/scripts/build-gnome-todo-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-todo\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/gnome-todo" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-todo "$STAGE/pkg/opt/gnome-todo/gnome-todo"
ln -sf gnome-todo "$STAGE/pkg/usr/bin/kemi-gnome-todo"

# leftover x86: ignore comment lines
python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so"} or p.name.endswith(".typelib"):
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        # ELF may mention nothing; still flag unexpected x86
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

# no RUNPATH on official ELF
python3 - << PY
import subprocess
from pathlib import Path
elf = Path("$STAGE/pkg/usr/bin/gnome-todo")
out = subprocess.check_output(["readelf", "-d", str(elf)], text=True, errors="replace")
if "RPATH" in out or "RUNPATH" in out:
    raise SystemExit("UNEXPECTED_RUNPATH")
print("no_runpath")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-todo (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal main) gnome-todo
    3.28.1-5 arm64, KEMI mall linuxpkg repack.
    Same-source exact-version hard Depends
    libgnome-todo (= 3.28.1-5) bundled (Python
    plugins only; no ELF). Official arch:all
    -common hard Depends gnome-todo-common
    (>= 3.28.1-5), the only focal version, bundled
    (icons, gschemas, D-Bus, autostart). Official
    gir1.2-gtd-1.0 and libgnome-todo-dev inspected
    and not packaged. Official EDS / GOA / GTK /
    peas / rest / ical / typelib / libc6 Depends
    stay Depends. Official control has no
    Recommends and no Suggests. Versioned Provides:
    gnome-todo (= 3.28.1-5), gnome-todo-common
    (= 3.28.1-5), libgnome-todo (= 3.28.1-5).
    Official /usr/bin/gnome-todo stays at the
    official path; /opt/gnome-todo/* are symlinks.
    Also /usr/bin/kemi-gnome-todo → gnome-todo.
    Official desktop Name=To Do kept; Exec rewritten
    to /usr/bin/gnome-todo; TryExec added. Official
    D-Bus Exec already absolute and kept. Official
    GUI changelog symlink into bundled lib doc is
    kept (resolves); real official lib changelog
    also copied with cp -L into the kemi doc dir.
    Official 256×256 hicolor PNG used as mall
    CREATE --icon and is packed only at the official
    path. Official packages ship no .mo; none
    invented. Icon-cache, desktop-database and
    glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 02:20:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
GNOME To Do — official Ubuntu 20.04 (focal main)
gnome-todo 3.28.1-5 arm64, KEMI repack.
Official /usr/bin/gnome-todo is an aarch64 ELF and
stays under /usr. /opt/gnome-todo/* are symlinks.
Same-source libgnome-todo (= 3.28.1-5) and
gnome-todo-common (>= 3.28.1-5) are bundled.
Official EDS / GOA / GTK Depends stay Depends and
are not bundled. Official control has no Recommends
and no Suggests. Official package ships no .mo.
Official 256×256 app icon from gnome-todo-common
is packed only at the official hicolor path.
Probe: 1 unique ELF · requiredGlibc 2.17 (1
versioned, 0 null; no max invented from null) · no
requiredGlibcxx (0 versioned, 1 null; null not
ranked as a max) · no RUNPATH; within Ubuntu 20.04 /
glibc 2.31. Official publication: Ubuntu 20.04 focal
main gnome-todo 3.28.1-5 (arm64). Official SHA256 +
size matched ports.ubuntu.com pool files and the
focal main arm64 Packages stanza. No librarian URL
this run.
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libecal-2.0-1 (>= 3.33.4), libedataserver-1.2-24 (>= 3.33.4), libedataserverui-1.2-2 (>= 3.33.4), libgirepository-1.0-1 (>= 0.9.2), libglib2.0-0 (>= 2.51.2), libgoa-1.0-0b (>= 3.5.1), libgtk-3-0 (>= 3.21.5), libical3 (>= 3.0.0), libjson-glib-1.0-0 (>= 0.12.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libpeas-1.0-0 (>= 1.17), librest-0.7-0 (>= 0.7), evolution-data-server (>= 3.17.1), gsettings-desktop-schemas, dconf-gsettings-backend | gsettings-backend
Replaces: gnome-todo, gnome-todo-common, libgnome-todo
Conflicts: gnome-todo, gnome-todo-common, libgnome-todo
Provides: gnome-todo (= 3.28.1-5), gnome-todo-common (= 3.28.1-5), libgnome-todo (= 3.28.1-5)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Todo
Description: minimalistic personal task manager designed to fit GNOME desktop
 GNOME To Do ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack. Bundles official
 gnome-todo-common and libgnome-todo.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'Version: 3.28.1-5kemi1' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'Provides: gnome-todo (= 3.28.1-5)' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'gnome-todo-common (= 3.28.1-5)' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'libgnome-todo (= 3.28.1-5)' "$ROOT/evidence/kemi-gnome-todo-control.txt"
grep -q 'Conflicts: gnome-todo, gnome-todo-common, libgnome-todo' "$ROOT/evidence/kemi-gnome-todo-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-todo-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-todo-control.txt"
! grep -q 'gir1.2-gtd-1.0' "$ROOT/evidence/kemi-gnome-todo-control.txt"
! grep -q 'libgnome-todo-dev' "$ROOT/evidence/kemi-gnome-todo-control.txt"
# bundled names must not remain as Depends
! grep -E '^ Depends:.*libgnome-todo \(=' "$ROOT/evidence/kemi-gnome-todo-control.txt"
! grep -E '^ Depends:.*gnome-todo-common' "$ROOT/evidence/kemi-gnome-todo-control.txt"

# unpack built deb and assert desktop / no evidence png / symlink / hashes
CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/org.gnome.Todo.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=To Do" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/gnome-todo" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-todo" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if "Exec=gnome-todo\n" in desk or desk.endswith("Exec=gnome-todo"):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-todo"
test -L "$CHECK/usr/bin/kemi-gnome-todo"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-todo")" = "gnome-todo"
test -L "$CHECK/opt/gnome-todo/gnome-todo"
test "$(readlink "$CHECK/opt/gnome-todo/gnome-todo")" = "/usr/bin/gnome-todo"
test -f "$CHECK/usr/share/icons/hicolor/256x256/apps/org.gnome.Todo.png"
if find "$CHECK" -name 'org.gnome.Todo-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -e "$CHECK/usr/lib/aarch64-linux-gnu/girepository-1.0/Gtd-1.0.typelib"
test ! -d "$CHECK/usr/include/gnome-todo"
sha256sum "$CHECK/usr/bin/gnome-todo"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
