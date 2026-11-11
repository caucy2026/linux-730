#!/bin/bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# nautilus 1:3.36.3-0ubuntu1.20.04.2 Architecture: arm64
# as kemi-nautilus, bundling same-source exact-version
# hard Depends libnautilus-extension1a
# (= 1:3.36.3-0ubuntu1.20.04.2) and nautilus-data
# (= 1:3.36.3-0ubuntu1.20.04.2). The same official
# stanza is also in focal-security main; newer than
# focal Release 1:3.36.1.1-1ubuntu2 and still Ubuntu
# 20.04 deps (libc6 >= 2.29, within glibc 2.31).
# Official libnautilus-extension-dev and
# gir1.2-nautilus-3.0 are same-source but are not
# GUI hard Depends; they were inspected and are
# not packaged (headers, gtk-doc, typelib, .gir,
# dangling changelog / unversioned .so symlinks).
# Different-source hard Depends (bubblewrap, gvfs,
# tracker*, GTK, gnome-desktop, gstreamer, unity,
# etc.) stay Depends and are not bundled. Official
# Recommends gvfs-backends and librsvg2-common
# stay Recommends / unbundled. Official Suggests
# (eog, evince | pdf-viewer, gnome-sushi,
# nautilus-extension-brasero, nautilus-sendto,
# totem | mp3-decoder, xdg-user-dirs) stay Suggests.
# Official Breaks/Replaces totem (<< 3.31.91-1)
# are kept. Versioned Provides: nautilus
# (= 1:3.36.3-0ubuntu1.20.04.2),
# libnautilus-extension1a
# (= 1:3.36.3-0ubuntu1.20.04.2), nautilus-data
# (= 1:3.36.3-0ubuntu1.20.04.2). Debian epoch 1:
# is omitted from mall version_name and the deb
# filename, and is kept in dpkg Version.
# Official /usr/bin/nautilus and
# nautilus-autorun-software are compiled aarch64
# ELFs (main binary requiredGlibc 2.29; the
# autorun helper, three in-tree extensions and
# libnautilus-extension.so.1.5.0 requiredGlibc
# 2.17; no GLIBCXX, no RUNPATH) and stay at
# official paths (binreloc / compiled /usr
# prefix / XDG /usr/share). Official files stay
# on official paths; /opt/nautilus/* are
# symlinks only. Also /usr/bin/kemi-nautilus →
# nautilus. Official packages ship no .mo
# (Ubuntu language-pack split); keep official
# tree; do not invent packs. Official app icons
# are SVG only (org.gnome.Nautilus.svg +
# symbolic, shipped in nautilus-data); no
# official 256×256 PNG. A 128×128 PNG
# rasterized from the official app SVG via
# Chrome headless --default-background-color=00000000
# lives at evidence/org.gnome.Nautilus-128.png
# and is used only as the mall CREATE --icon;
# it is not shipped in the deb. Official GUI
# changelog.Debian.gz is a dangling symlink
# into the same-source lib doc dir; because
# libnautilus-extension1a is bundled at its
# official doc path, the official symlink is
# kept and resolves; the real official lib
# changelog is also copied with cp -L into the
# kemi doc dir. Official NEWS.gz is a real
# file and is kept. Official desktop
# Name=Files is kept; mall app_name is
# Nautilus. Official desktop Exec=nautilus
# --new-window %U (and the New Window action
# Exec) is rewritten to /usr/bin/nautilus …;
# TryExec=/usr/bin/nautilus is added. Official
# nautilus-autorun-software.desktop
# Name=Run Software, TryExec and Exec are
# kept with only the app path made absolute.
# Official D-Bus Exec paths are already
# absolute and are kept. Official nautilus
# preinst/postinst/prerm/postrm
# (dpkg-maintscript-helper rm_conffile of the
# old autostart desktop, plus official postrm
# purge of leftover /etc/X11 dirs) are kept;
# official libnautilus-extension1a shlibs,
# symbols, and activate-noawait ldconfig
# trigger are kept; icon-cache,
# desktop-database and glib-compile-schemas
# hooks are appended. Official packages have
# no py3compile hooks; none are invented.
# Probe: Architecture arm64 · 6 unique
# packaged ELFs · requiredGlibc max 2.29
# (6 versioned: 1 at 2.29, 5 at 2.17; 0
# null) · no GLIBCXX (0 versioned, 6 null;
# null is not ranked as a max) · within 101
# ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool
# files and the Ubuntu 20.04 focal-updates
# main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed; same stanza
# in focal-security main). No librarian URL
# and no .buildinfo is recorded this run
# (pool 404). KEMI version
# 3.36.3-0ubuntu1.20.04.2kemi1 is 28 chars
# (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28
# char siblings succeeded). Epoch omitted
# from that string; no tilde; no shortening
# applied unless the mall later rejects 28.
# gork.bot协助开发 · Verify ≠ compile

set -euo pipefail
ROOT=/workspace/t142-20261112-nautilus
VER_UP=3.36.3-0ubuntu1.20.04.2
VER_DEB="${VER_UP}kemi1"
VER_DPKG="1:${VER_DEB}"
ARCH=arm64
PKG=kemi-nautilus
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/nautilus_3.36.3-0ubuntu1.20.04.2_arm64}"
LIB="${LIB:-$ROOT/unpack-official/libnautilus-extension1a_3.36.3-0ubuntu1.20.04.2_arm64}"
DATA="${DATA:-$ROOT/unpack-official/nautilus-data_3.36.3-0ubuntu1.20.04.2_all}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/nautilus_3.36.3-0ubuntu1.20.04.2_arm64.deb"
UP_LIB="$DL/libnautilus-extension1a_3.36.3-0ubuntu1.20.04.2_arm64.deb"
UP_DATA="$DL/nautilus-data_3.36.3-0ubuntu1.20.04.2_all.deb"
EXPECT_SHA=ca934cad628412e688f640b892aae8f2499807b76f219ba2168bbb550cd14727
EXPECT_BYTES=547232
EXPECT_LIB_SHA=902313d5548353c8c1140a954fa16ad6b62830230219fa41b3dcc49131904cc2
EXPECT_LIB_BYTES=14744
EXPECT_DATA_SHA=a4ba4190eddae3b5f3e8dd8a637018872a383843e5692758fe7943875f3be559
EXPECT_DATA_BYTES=10908
python3 - << PY
s="${VER_DEB}"
assert len(s) == 28, len(s)
assert ":" not in s, s
assert "${VER_DPKG}".startswith("1:")
assert "${VER_DPKG}" == "1:3.36.3-0ubuntu1.20.04.2kemi1"
print("version_name_len", len(s), s)
print("dpkg_version_with_epoch", "${VER_DPKG}")
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB" && test -f "$UP_LIB" && test -f "$UP_DATA"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_LIB")" = "$EXPECT_LIB_BYTES"
test "$(stat -c%s "$UP_DATA")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_LIB_SHA  $UP_LIB" | sha256sum -c -
echo "$EXPECT_DATA_SHA  $UP_DATA" | sha256sum -c -
test -x "$UNPACK/usr/bin/nautilus"
test -x "$UNPACK/usr/bin/nautilus-autorun-software"
python3 - << PY
from pathlib import Path
expect = {
    Path("$UNPACK/usr/bin/nautilus"): ("eaa9f8ea605ef0d0dbfeb2f68a4aef54fc8ae9975706069cce355e3b315d1b14", 1730408),
    Path("$UNPACK/usr/bin/nautilus-autorun-software"): ("69a12d61f1c57bb88b0b6a17df04e53065c3a87749a5695b8d60f4bbc2b66ed4", 22616),
    Path("$UNPACK/usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libnautilus-image-properties.so"): ("c64769b8c560f6e81a592d1b084ccf0418af78df20d2c245070f9afd300fb33a", 26752),
    Path("$UNPACK/usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libnautilus-sendto.so"): ("459e4d4e45b339ad1beaad794c1f5a478162b38804be608e625cd4e6486c0164", 10240),
    Path("$UNPACK/usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libtotem-properties-page.so"): ("5d8de431072760915937d6a3f444e5ac832e6fc7004448ed7618613becfbe158", 39256),
    Path("$LIB/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1.5.0"): ("0a38e4ba4caf8c7161037b9181cf0b9060edcd31852fa2c53009caa0c1213e06", 42856),
}
import hashlib
for p, (sha, nbytes) in expect.items():
    assert not p.is_symlink(), p
    data = p.read_bytes()
    assert data[:4] == bytes([0x7F]) + b"ELF", p
    assert p.stat().st_size == nbytes, (p, p.stat().st_size)
    assert hashlib.sha256(data).hexdigest() == sha, p
soname = Path("$LIB/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1")
assert soname.is_symlink()
assert soname.readlink().as_posix() == "libnautilus-extension.so.1.5.0"
print("official_elfs_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Nautilus.desktop"
test -f "$UNPACK/usr/share/applications/nautilus-autorun-software.desktop"
test -f "$DATA/usr/share/icons/hicolor/scalable/apps/org.gnome.Nautilus.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Nautilus.png"
test ! -f "$DATA/usr/share/icons/hicolor/256x256/apps/org.gnome.Nautilus.png"
test -f "$DATA/usr/share/glib-2.0/schemas/org.gnome.nautilus.gschema.xml"
test -L "$UNPACK/usr/share/doc/nautilus/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/nautilus/changelog.Debian.gz"
test ! -L "$LIB/usr/share/doc/libnautilus-extension1a/changelog.Debian.gz"
test -f "$LIB/usr/share/doc/libnautilus-extension1a/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/nautilus/NEWS.gz"
test ! -L "$UNPACK/usr/share/doc/nautilus/NEWS.gz"
test -f "$LIB/DEBIAN/shlibs"
test -f "$LIB/DEBIAN/symbols"
test -f "$LIB/DEBIAN/triggers"
test -f "$UNPACK/DEBIAN/preinst"
test -f "$UNPACK/DEBIAN/postinst"
test -f "$UNPACK/DEBIAN/prerm"
test -f "$UNPACK/DEBIAN/postrm"
test -f "$ROOT/evidence/org.gnome.Nautilus-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Nautilus-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "abd1b74a9784f7ffa9bfcd4dd4c530bce4b5376af9f1a99c978eb274ebc7616a"
print("evidence_128_ok", w, h, p.stat().st_size)
for root in ("$UNPACK", "$LIB", "$DATA"):
    mos = list(Path(root).rglob("*.mo"))
    assert mos == [], mos
print("official_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/nautilus"

# bundle official exact-version lib and data first, then official GUI
cp -a "$LIB/usr/." "$STAGE/pkg/usr/"
cp -a "$DATA/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/nautilus" \
  "$STAGE/pkg/usr/bin/nautilus-autorun-software"
# official library packaging metadata
cp -a "$LIB/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$LIB/DEBIAN/symbols" "$STAGE/pkg/DEBIAN/symbols"
cp -a "$LIB/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"
# official GUI maintainer scripts kept
for s in preinst postinst prerm postrm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done
# official GUI changelog symlink now resolves into bundled lib doc
test -L "$STAGE/pkg/usr/share/doc/nautilus/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/nautilus/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libnautilus-extension1a/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/nautilus-data/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1"
test -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1"

REPORT="$ROOT/probe/kemi-nautilus.json"
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
test "${#ELFS[@]}" = 6
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
if len(files) != 6:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by_name = {Path(f["path"]).name: f for f in files}
expect = {
    "nautilus": ("eaa9f8ea605ef0d0dbfeb2f68a4aef54fc8ae9975706069cce355e3b315d1b14", 1730408, "2.29"),
    "nautilus-autorun-software": ("69a12d61f1c57bb88b0b6a17df04e53065c3a87749a5695b8d60f4bbc2b66ed4", 22616, "2.17"),
    "libnautilus-image-properties.so": ("c64769b8c560f6e81a592d1b084ccf0418af78df20d2c245070f9afd300fb33a", 26752, "2.17"),
    "libnautilus-sendto.so": ("459e4d4e45b339ad1beaad794c1f5a478162b38804be608e625cd4e6486c0164", 10240, "2.17"),
    "libtotem-properties-page.so": ("5d8de431072760915937d6a3f444e5ac832e6fc7004448ed7618613becfbe158", 39256, "2.17"),
    "libnautilus-extension.so.1.5.0": ("0a38e4ba4caf8c7161037b9181cf0b9060edcd31852fa2c53009caa0c1213e06", 42856, "2.17"),
}
if set(by_name) != set(expect):
    raise SystemExit("PROBE_NAMES:" + ",".join(sorted(by_name)))
for name, (sha, nbytes, glibc) in expect.items():
    f = by_name[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH:" + name)
    if f.get("requiredGlibc") != glibc:
        raise SystemExit("PROBE_GLIBC:" + name + ":" + str(f.get("requiredGlibc")))
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + name)
    if f.get("sha256") != sha:
        raise SystemExit("PROBE_SHA:" + name)
    if int(f.get("bytes") or 0) != nbytes:
        raise SystemExit("PROBE_BYTES:" + name)
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
glibcs = sorted({x.get("requiredGlibc") for x in versioned})
# None-safe: do not rank a null requiredGlibc / requiredGlibcxx as a max
if None in glibcs:
    raise SystemExit("PROBE_NULL_RANKED_AS_MAX")
if len(versioned) != 6 or len(nulls) != 0 or cxx or len(cxx_null) != 6:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
if glibcs != ["2.17", "2.29"]:
    raise SystemExit("PROBE_GLIBC_SET:" + ",".join(glibcs))
soname = Path("$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1")
if not soname.is_symlink():
    raise SystemExit("SONAME_NOT_SYMLINK")
print("PROBE_PASS n_elf=6 unique aarch64 requiredGlibc max 2.29 (6 versioned: 1 at 2.29, 5 at 2.17; 0 null) noGLIBCXX (0 versioned, 6 null; null not ranked as a max) official SONAME symlink not ELF configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Nautilus.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Nautilus.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'org.gnome.Nautilus-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# libnautilus-extension-dev / typelib must not be staged
test ! -d "$STAGE/pkg/usr/include/nautilus"
test ! -d "$STAGE/pkg/usr/share/gtk-doc"
test ! -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/girepository-1.0/Nautilus-3.0.typelib"
test ! -f "$STAGE/pkg/usr/share/gir-1.0/Nautilus-3.0.gir"
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnautilus-extension.so"
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pkgconfig/libnautilus-extension.pc"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/nautilus/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$LIB/usr/share/doc/libnautilus-extension1a/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export STAGE_MAIN="$STAGE/pkg/usr/share/applications/org.gnome.Nautilus.desktop"
export STAGE_AUTORUN="$STAGE/pkg/usr/share/applications/nautilus-autorun-software.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path

def rewrite_prefix(text, kind):
    out = []
    for line in text.splitlines(True):
        if kind == "Exec" and line.startswith("Exec=nautilus"):
            out.append("Exec=/usr/bin/" + line[len("Exec="):])
        elif kind == "TryExec" and line.startswith("TryExec=nautilus"):
            out.append("TryExec=/usr/bin/" + line[len("TryExec="):])
        else:
            out.append(line)
    return "".join(out)

main_src = Path("/workspace/t142-20261112-nautilus/unpack-official/nautilus_3.36.3-0ubuntu1.20.04.2_arm64/usr/share/applications/org.gnome.Nautilus.desktop")
auto_src = Path("/workspace/t142-20261112-nautilus/unpack-official/nautilus_3.36.3-0ubuntu1.20.04.2_arm64/usr/share/applications/nautilus-autorun-software.desktop")
text = main_src.read_text()
if not re.search(r"^Name=Files\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=nautilus --new-window %U\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = rewrite_prefix(text, "Exec")
inserted = False
new = []
for line in text.splitlines(True):
    new.append(line)
    if (not inserted) and line.startswith("Exec=/usr/bin/nautilus"):
        new.append("TryExec=/usr/bin/nautilus\n")
        inserted = True
text = "".join(new)
if "Exec=/usr/bin/nautilus --new-window %U" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if not re.search(r"^Exec=/usr/bin/nautilus --new-window\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ACTION_REWRITE_FAIL")
if text.count("TryExec=/usr/bin/nautilus") != 1:
    raise SystemExit("DESKTOP_TRYEXEC_COUNT")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/nautilus"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/nautilus":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_MAIN"]).write_text(text)

atext = auto_src.read_text()
if not re.search(r"^Name=Run Software\s*$", atext, flags=re.M):
    raise SystemExit("AUTORUN_NAME")
if not re.search(r"^TryExec=nautilus-autorun-software\s*$", atext, flags=re.M):
    raise SystemExit("AUTORUN_TRYEXEC_UNEXPECTED")
if not re.search(r"^Exec=nautilus-autorun-software %u\s*$", atext, flags=re.M):
    raise SystemExit("AUTORUN_EXEC_UNEXPECTED")
atext = rewrite_prefix(atext, "TryExec")
atext = rewrite_prefix(atext, "Exec")
if "Exec=/usr/bin/nautilus-autorun-software %u" not in atext:
    raise SystemExit("AUTORUN_REWRITE_FAIL")
if "TryExec=/usr/bin/nautilus-autorun-software" not in atext:
    raise SystemExit("AUTORUN_TRYEXEC_FAIL")
if r"\1" in atext:
    raise SystemExit("AUTORUN_LITERAL_GROUP")
if "TryExec=/usr/bin/nautilus\n" in atext or re.search(r"^TryExec=/usr/bin/nautilus\s*$", atext, flags=re.M):
    raise SystemExit("AUTORUN_TRYEXEC_REWRITTEN_TO_MAIN")
for line in atext.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/nautilus-autorun-software"):
        raise SystemExit("AUTORUN_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/nautilus-autorun-software":
        raise SystemExit("AUTORUN_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_AUTORUN"]).write_text(atext)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-nautilus/scripts/build-nautilus-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/nautilus\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

# official D-Bus Exec paths already absolute
python3 - << PY
from pathlib import Path
for name in ("org.freedesktop.FileManager1.service", "org.gnome.Nautilus.service"):
    text = Path("$STAGE/pkg/usr/share/dbus-1/services") / name
    body = text.read_text()
    if "Exec=/usr/bin/nautilus --gapplication-service" not in body:
        raise SystemExit("DBUS_EXEC:" + name)
print("dbus_exec_kept_absolute")
PY

ln -sf /usr/bin/nautilus "$STAGE/pkg/opt/nautilus/nautilus"
ln -sf /usr/bin/nautilus-autorun-software "$STAGE/pkg/opt/nautilus/nautilus-autorun-software"
ln -sf nautilus "$STAGE/pkg/usr/bin/kemi-nautilus"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".woff"} or p.name.endswith(".typelib"):
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
kemi-nautilus (${VER_DPKG}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    nautilus 1:3.36.3-0ubuntu1.20.04.2 arm64,
    KEMI mall linuxpkg repack. Same stanza also
    in focal-security main; newer than focal
    Release 1:3.36.1.1-1ubuntu2. Same-source
    exact-version hard Depends
    libnautilus-extension1a
    (= 1:3.36.3-0ubuntu1.20.04.2) and
    nautilus-data (= 1:3.36.3-0ubuntu1.20.04.2)
    bundled. Official libnautilus-extension-dev
    and gir1.2-nautilus-3.0 inspected and not
    packaged. Different-source Depends stay
    Depends. Official Recommends gvfs-backends
    and librsvg2-common stay Recommends.
    Official Suggests stay Suggests. Official
    Breaks/Replaces totem (<< 3.31.91-1) kept.
    Versioned Provides: nautilus
    (= 1:3.36.3-0ubuntu1.20.04.2),
    libnautilus-extension1a
    (= 1:3.36.3-0ubuntu1.20.04.2),
    nautilus-data (= 1:3.36.3-0ubuntu1.20.04.2).
    Debian epoch 1: is kept in dpkg Version and
    omitted from mall version_name and the deb
    filename. Official /usr/bin/nautilus stays
    at the official path; /opt/nautilus/* are
    symlinks. Also /usr/bin/kemi-nautilus →
    nautilus. Official desktop Name=Files kept;
    Exec rewritten to /usr/bin/nautilus
    --new-window %U; TryExec added. Official
    GUI changelog symlink into bundled lib doc
    is kept (resolves); real official lib
    changelog also copied with cp -L into the
    kemi doc dir. Official icons are SVG only;
    a 128×128 evidence PNG rasterized from the
    official SVG is used only as mall CREATE
    --icon and is not packed. Official packages
    ship no .mo; none invented. Official
    maintainer scripts kept. Official
    libnautilus-extension1a shlibs / symbols /
    ldconfig trigger kept. Icon-cache,
    desktop-database and glib-compile-schemas
    hooks added. gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 02:50:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Nautilus — official Ubuntu 20.04 (focal-updates
main) nautilus 1:3.36.3-0ubuntu1.20.04.2 arm64,
KEMI repack. Official /usr/bin/nautilus,
nautilus-autorun-software, in-tree
extensions-3.0 modules and
libnautilus-extension.so.1.5.0 are aarch64
ELFs and stay under /usr. /opt/nautilus/* are
symlinks. Same-source libnautilus-extension1a
(= 1:3.36.3-0ubuntu1.20.04.2) and nautilus-data
(= 1:3.36.3-0ubuntu1.20.04.2) are bundled.
Different-source Depends stay Depends and are
not bundled. Official Recommends stay
Recommends. Official Suggests stay Suggests.
Official packages ship no .mo. Official icons
are SVG only; a 128×128 evidence PNG is used
only as mall CREATE --icon and is not packed.
Debian epoch 1: is kept in dpkg Version and
omitted from mall version_name / filename.
Probe: 6 unique ELFs · requiredGlibc max 2.29
(6 versioned: 1 at 2.29, 5 at 2.17; 0 null;
no max invented from null) · no
requiredGlibcxx (0 versioned, 6 null; null not
ranked as a max) · no RUNPATH; within Ubuntu
20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal-updates main nautilus
1:3.36.3-0ubuntu1.20.04.2 (arm64); same stanza
in focal-security main. Official SHA256 + size
matched ports.ubuntu.com pool files and the
focal-updates main arm64 Packages stanza. No
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
Depends: bubblewrap, desktop-file-utils (>= 0.7), gsettings-desktop-schemas (>= 3.8.0), gvfs (>= 1.3.2), libglib2.0-data, shared-mime-info (>= 0.50), tracker, tracker-miner-fs, tracker-extract, libatk1.0-0 (>= 1.32.0), libc6 (>= 2.29), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.14.0), libdbusmenu-glib4 (>= 0.4.2), libgdk-pixbuf2.0-0 (>= 2.25.2), libgexiv2-2 (>= 0.10.0), libglib2.0-0 (>= 2.58.1), libgnome-autoar-0-0 (>= 0.2.1), libgnome-desktop-3-19 (>= 3.17.92), libgstreamer-plugins-base1.0-0 (>= 1.0.0), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.22.27), libpango-1.0-0 (>= 1.44.6), libpangocairo-1.0-0 (>= 1.42), libselinux1 (>= 2.0), libtracker-sparql-2.0-0 (>= 1.12.0), libunity9 (>= 3.4.6), dconf-gsettings-backend | gsettings-backend
Recommends: gvfs-backends, librsvg2-common
Suggests: eog, evince | pdf-viewer, gnome-sushi, nautilus-extension-brasero, nautilus-sendto, totem | mp3-decoder, xdg-user-dirs
Breaks: totem (<< 3.31.91-1)
Replaces: nautilus, libnautilus-extension1a, nautilus-data, totem (<< 3.31.91-1)
Conflicts: nautilus, libnautilus-extension1a, nautilus-data
Provides: nautilus (= 1:3.36.3-0ubuntu1.20.04.2), libnautilus-extension1a (= 1:3.36.3-0ubuntu1.20.04.2), nautilus-data (= 1:3.36.3-0ubuntu1.20.04.2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/action/show/Apps/Nautilus
Description: file manager and graphical shell for GNOME
 Nautilus ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack. Bundles official
 libnautilus-extension1a and nautilus-data.
 Debian epoch 1: is kept in this Version and
 omitted from the mall version_name.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# append icon / desktop / gschema hooks after official maintainer scripts
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
chmod 0755 "$STAGE/pkg/DEBIAN/preinst" "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'dpkg-maintscript-helper rm_conffile' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'nautilus-autostart.desktop' "$STAGE/pkg/DEBIAN/preinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'activate-noawait ldconfig' "$STAGE/pkg/DEBIAN/triggers"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# filename must not contain the epoch
case "$DEB" in
  *1:*) echo "EPOCH_IN_FILENAME $DEB" >&2; exit 1 ;;
esac
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Version: 1:3.36.3-0ubuntu1.20.04.2kemi1' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'libc6 (>= 2.29)' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'nautilus (= 1:3.36.3-0ubuntu1.20.04.2)' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'libnautilus-extension1a (= 1:3.36.3-0ubuntu1.20.04.2)' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'nautilus-data (= 1:3.36.3-0ubuntu1.20.04.2)' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Conflicts: nautilus, libnautilus-extension1a, nautilus-data' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Recommends: gvfs-backends, librsvg2-common' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Suggests: eog, evince | pdf-viewer' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'Breaks: totem (<< 3.31.91-1)' "$ROOT/evidence/kemi-nautilus-control.txt"
! grep -q 'libnautilus-extension-dev' "$ROOT/evidence/kemi-nautilus-control.txt"
! grep -q 'gir1.2-nautilus-3.0' "$ROOT/evidence/kemi-nautilus-control.txt"
! grep -E 'Depends:.*libnautilus-extension1a \(=' "$ROOT/evidence/kemi-nautilus-control.txt"
! grep -E 'Depends:.*nautilus-data \(=' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'dconf-gsettings-backend | gsettings-backend' "$ROOT/evidence/kemi-nautilus-control.txt"
grep -q 'tracker-miner-fs' "$ROOT/evidence/kemi-nautilus-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
desk = Path("$CHECK/usr/share/applications/org.gnome.Nautilus.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Files" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/nautilus --new-window %U" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/nautilus" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=nautilus\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
auto = Path("$CHECK/usr/share/applications/nautilus-autorun-software.desktop").read_text()
if r"\1" in auto:
    raise SystemExit("BUILT_AUTORUN_LITERAL_GROUP")
if "Name=Run Software" not in auto:
    raise SystemExit("BUILT_AUTORUN_NAME")
if "Exec=/usr/bin/nautilus-autorun-software %u" not in auto:
    raise SystemExit("BUILT_AUTORUN_EXEC")
if "TryExec=/usr/bin/nautilus-autorun-software" not in auto:
    raise SystemExit("BUILT_AUTORUN_TRYEXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/nautilus"
test -x "$CHECK/usr/bin/nautilus-autorun-software"
test -L "$CHECK/usr/bin/kemi-nautilus"
test "$(readlink "$CHECK/usr/bin/kemi-nautilus")" = "nautilus"
test -L "$CHECK/opt/nautilus/nautilus"
test "$(readlink "$CHECK/opt/nautilus/nautilus")" = "/usr/bin/nautilus"
test -L "$CHECK/opt/nautilus/nautilus-autorun-software"
test "$(readlink "$CHECK/opt/nautilus/nautilus-autorun-software")" = "/usr/bin/nautilus-autorun-software"
test -f "$CHECK/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1.5.0"
test -L "$CHECK/usr/lib/aarch64-linux-gnu/libnautilus-extension.so.1"
test -f "$CHECK/usr/share/glib-2.0/schemas/org.gnome.nautilus.gschema.xml"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/org.gnome.Nautilus.svg"
test -L "$CHECK/usr/share/doc/nautilus/changelog.Debian.gz"
test -e "$CHECK/usr/share/doc/nautilus/changelog.Debian.gz"
if find "$CHECK" -name 'org.gnome.Nautilus-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -d "$CHECK/usr/include/nautilus"
test ! -d "$CHECK/usr/share/gtk-doc"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
# hash the published deb by explicit path, never find|head
sha256sum "$CHECK/usr/bin/nautilus"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
