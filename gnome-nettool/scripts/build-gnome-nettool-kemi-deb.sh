#!/bin/bash
# Wrap official Ubuntu 20.04 (focal universe)
# gnome-nettool 3.8.1-3 Architecture: arm64 as
# kemi-gnome-nettool. No newer package in
# focal-updates, focal-security, or
# focal-backports. The gnome-nettool source
# ships only this one binary package in focal
# (no same-source -data/-common or
# exact-version library to bundle). Official
# Depends (GTK / glib / cairo / pango /
# gdk-pixbuf / gtop, libc6 (>= 2.17),
# dconf-gsettings-backend | gsettings-backend,
# dnsutils, finger, iputils-ping | ping,
# iputils-tracepath, net-tools, nmap, whois)
# are different-source and stay Depends,
# unbundled. Official control has no
# Recommends and no Suggests (Suggests:
# gnome-system-tools was dropped upstream of
# this official Debian revision). Versioned
# Provides: gnome-nettool (= 3.8.1-3). No
# Debian epoch, no tilde. Official
# /usr/bin/gnome-nettool is a compiled
# aarch64 ELF (requiredGlibc 2.17, no
# GLIBCXX, no RUNPATH) and stays at the
# official path. Official files stay on
# official paths; /opt/gnome-nettool/* are
# symlinks only. Also
# /usr/bin/kemi-gnome-nettool →
# gnome-nettool. Official package ships 89
# .mo including zh_CN, zh_HK and zh_TW (keep
# official; do not invent extra language
# packs). Official help (C plus translated
# pages; figures in other langs are official
# symlinks into C) stays official. Official
# in-app pixmaps under
# /usr/share/gnome-nettool/pixmaps stay
# official. Official hicolor app icons are
# 16/22/24/32 PNG plus scalable SVG; there
# is no official hicolor 256×256 PNG, but
# official pixmap
# /usr/share/gnome-nettool/pixmaps/gnome-nettool.png
# is already 256×256 and is used as the mall
# CREATE --icon; it is packed only at that
# official path, not a second time. No 128
# raster is invented. Official desktop
# Name=Network Tools is kept; mall app_name
# is GNOME Nettool (the usual upstream name
# used in the official package Description
# and README; the historical project title
# "GNOME Network Tools" is not used as
# mall app_name). Official desktop
# Exec=gnome-nettool is rewritten to
# /usr/bin/gnome-nettool; TryExec is added.
# Official changelog.Debian.gz is a real
# file and is copied with cp -L into the
# kemi doc dir; official NEWS.gz is a real
# file. Official package has no maintainer
# scripts; icon-cache, desktop-database and
# glib-compile-schemas hooks are added. No
# py3compile hooks; none are invented.
# Probe: Architecture arm64 · 1 unique
# packaged ELF · requiredGlibc 2.17 (1
# versioned, 0 null) · no GLIBCXX (0
# versioned, 1 null; null is not ranked as
# a max) · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal universe arm64 Packages stanza
# (Aliyun ubuntu-ports mirror, streamed). No
# librarian URL and no .buildinfo is recorded
# this run (pool 404). KEMI version
# 3.8.1-3kemi1 is 12 chars (under the mall
# version_name limit that rejected Remmina's
# 33-char string; 12–28 char siblings
# succeeded). No epoch, no tilde, no
# shortening applied unless the mall later
# rejects 12. gork.bot协助开发 · Verify ≠
# compile

set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-nettool
VER_UP=3.8.1-3
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-nettool
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/gnome-nettool_3.8.1-3_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-nettool_3.8.1-3_arm64.deb"
EXPECT_SHA=660c9e87081b8def199adec80a6c2ff51e5a3b405493ce74449077c4a3711b90
EXPECT_BYTES=284264
python3 - << PY
s="${VER_DEB}"
assert len(s) == 12, len(s)
assert ":" not in s, s
assert "~" not in s, s
assert s == "3.8.1-3kemi1"
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-nettool"
python3 - << PY
from pathlib import Path
import hashlib
elf = Path("$UNPACK/usr/bin/gnome-nettool")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 117776
assert hashlib.sha256(elf.read_bytes()).hexdigest() == "332bcd728fdb54f71206e91aa714c94e61e8156bfade247ad085ed2ee505b348"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/gnome-nettool.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/gnome-nettool.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/gnome-nettool.png"
test -f "$UNPACK/usr/share/gnome-nettool/pixmaps/gnome-nettool.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnome-nettool.gschema.xml"
test ! -L "$UNPACK/usr/share/doc/gnome-nettool/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-nettool/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-nettool/NEWS.gz"
test -f "$ROOT/evidence/gnome-nettool-256.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
official = Path("$UNPACK/usr/share/gnome-nettool/pixmaps/gnome-nettool.png")
evidence = Path("$ROOT/evidence/gnome-nettool-256.png")
for p in (official, evidence):
    data = p.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    w, h = unpack(">II", data[16:24])
    assert (w, h) == (256, 256), (p, w, h)
    assert hashlib.sha256(data).hexdigest() == "6facd2735d3100b8cead2714f3b2a7dff730fb8f3099a88b827942267a599521"
    assert p.stat().st_size == 25893
print("official_256_pixmap_ok")
mos = list(Path("$UNPACK").rglob("*.mo"))
langs = sorted({p.parent.parent.name for p in mos if p.parent.name == "LC_MESSAGES"})
assert "zh_CN" in langs and "zh_TW" in langs
assert len(mos) == 89, len(mos)
print("official_mo", len(mos), "includes zh_CN/zh_HK/zh_TW")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-nettool"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-nettool"

REPORT="$ROOT/probe/kemi-gnome-nettool.json"
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
if Path(f["path"]).name != "gnome-nettool":
    raise SystemExit("PROBE_NAMES:" + Path(f["path"]).name)
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
if f.get("sha256") != "332bcd728fdb54f71206e91aa714c94e61e8156bfade247ad085ed2ee505b348":
    raise SystemExit("PROBE_SHA")
if int(f.get("bytes") or 0) != 117776:
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

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/gnome-nettool.svg"
test -f "$STAGE/pkg/usr/share/gnome-nettool/pixmaps/gnome-nettool.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/gnome-nettool.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 89
if find "$STAGE/pkg" -name 'gnome-nettool-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-nettool/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-nettool/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/gnome-nettool.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
src = Path("/workspace/t142-20261112-gnome-nettool/unpack-official/gnome-nettool_3.8.1-3_arm64/usr/share/applications/gnome-nettool.desktop")
text = src.read_text()
if not re.search(r"^Name=Network Tools\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=gnome-nettool\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
out = []
inserted = False
for line in text.splitlines(True):
    if line.startswith("Exec=gnome-nettool"):
        line = "Exec=/usr/bin/" + line[len("Exec="):]
        out.append(line)
        if not inserted:
            out.append("TryExec=/usr/bin/gnome-nettool\n")
            inserted = True
    else:
        out.append(line)
text = "".join(out)
if not re.search(r"^Exec=/usr/bin/gnome-nettool\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if text.count("TryExec=/usr/bin/gnome-nettool") != 1:
    raise SystemExit("DESKTOP_TRYEXEC_COUNT")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-nettool"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-nettool":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-nettool/scripts/build-gnome-nettool-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-nettool\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-nettool "$STAGE/pkg/opt/gnome-nettool/gnome-nettool"
ln -sf gnome-nettool "$STAGE/pkg/usr/bin/kemi-gnome-nettool"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".xpm", ".woff"}:
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
kemi-gnome-nettool (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    gnome-nettool 3.8.1-3 arm64, KEMI mall
    linuxpkg repack. No newer package in
    focal-updates / focal-security /
    focal-backports. No same-source package
    to bundle. Different-source Depends stay
    Depends. Official control has no
    Recommends and no Suggests. Versioned
    Provides: gnome-nettool (= 3.8.1-3). No
    Debian epoch, no tilde. Official
    /usr/bin/gnome-nettool stays at the
    official path; /opt/gnome-nettool/* are
    symlinks. Also /usr/bin/kemi-gnome-nettool
    → gnome-nettool. Official desktop
    Name=Network Tools kept; mall app_name is
    GNOME Nettool; Exec rewritten to
    /usr/bin/gnome-nettool; TryExec added.
    Official changelog is a real file and was
    copied with cp -L. Official 256×256
    pixmap is used only as mall CREATE --icon
    and is packed only at the official path;
    no 128 raster invented. Official 89 .mo
    including zh_CN kept; none invented.
    Icon-cache, desktop-database and
    glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 03:15:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
GNOME Nettool — official Ubuntu 20.04 (focal
universe) gnome-nettool 3.8.1-3 arm64, KEMI
repack. Official /usr/bin/gnome-nettool is an
aarch64 ELF and stays under /usr.
/opt/gnome-nettool/* are symlinks. No
same-source package to bundle. Different-source
Depends stay Depends. Official control has no
Recommends or Suggests. Official package ships
89 .mo including zh_CN. Official 256×256
pixmap is used only as mall CREATE --icon and
is packed only at the official path. Official
desktop Name=Network Tools; mall app_name is
GNOME Nettool. No Debian epoch, no tilde.
Probe: 1 unique ELF · requiredGlibc 2.17 (1
versioned, 0 null; no max invented from null) ·
no requiredGlibcxx (0 versioned, 1 null; null
not ranked as a max) · no RUNPATH; within
Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal universe
gnome-nettool 3.8.1-3 (arm64). Official SHA256
+ size matched ports.ubuntu.com pool files and
the focal universe arm64 Packages stanza. No
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.26.0), libgtk-3-0 (>= 3.0.3), libgtop-2.0-11 (>= 2.22.3), libpango-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend, dnsutils, finger, iputils-ping | ping, iputils-tracepath, net-tools, nmap, whois
Replaces: gnome-nettool
Conflicts: gnome-nettool
Provides: gnome-nettool (= 3.8.1-3)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://projects.gnome.org/gnome-network/
Description: network information tool for GNOME
 GNOME Nettool ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'Version: 3.8.1-3kemi1' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'libgtop-2.0-11 (>= 2.22.3)' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'nmap' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'Provides: gnome-nettool (= 3.8.1-3)' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
grep -q 'Conflicts: gnome-nettool' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-nettool-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-nettool-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
desk = Path("$CHECK/usr/share/applications/gnome-nettool.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if not re.search(r"^Name=Network Tools\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_NAME")
if not re.search(r"^Exec=/usr/bin/gnome-nettool\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-nettool" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=gnome-nettool\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-nettool"
test -L "$CHECK/usr/bin/kemi-gnome-nettool"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-nettool")" = "gnome-nettool"
test -L "$CHECK/opt/gnome-nettool/gnome-nettool"
test "$(readlink "$CHECK/opt/gnome-nettool/gnome-nettool")" = "/usr/bin/gnome-nettool"
test -f "$CHECK/usr/share/gnome-nettool/pixmaps/gnome-nettool.png"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/gnome-nettool.svg"
test ! -f "$CHECK/usr/share/icons/hicolor/256x256/apps/gnome-nettool.png"
if find "$CHECK" -name 'gnome-nettool-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 89
test -f "$CHECK/usr/share/locale/zh_CN/LC_MESSAGES/gnome-nettool.mo"
# hash the published deb by explicit path, never find|head
sha256sum "$CHECK/usr/bin/gnome-nettool"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
