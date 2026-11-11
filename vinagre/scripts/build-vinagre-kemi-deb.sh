#!/bin/bash
# Wrap official Ubuntu 20.04 (focal-updates /
# focal-security universe)
# vinagre 3.22.0-7ubuntu0.20.04.1
# Architecture: arm64 as kemi-vinagre. Newer
# than focal Release 3.22.0-7. Same file is
# also in focal-security (FreeRDP 2.1.1
# compatibility). No newer in
# focal-backports. The vinagre source ships
# only this one binary package in focal (no
# same-source -data/-common or exact-version
# library to bundle). Official Depends
# (avahi, libc6 (>= 2.17), cairo, freerdp,
# gdk-pixbuf, glib, GTK, gtk-vnc, libsecret,
# spice-client, vte, libxml2,
# dconf-gsettings-backend | gsettings-backend)
# are different-source and stay Depends,
# unbundled. Official control has no
# Recommends and no Suggests. Versioned
# Provides: vinagre (= 3.22.0-7ubuntu0.20.04.1).
# No Debian epoch, no tilde. Official
# /usr/bin/vinagre is a compiled aarch64 ELF
# (requiredGlibc 2.17, no GLIBCXX, no
# RUNPATH) and stays at the official path.
# Official files stay on official paths;
# /opt/vinagre/* are symlinks only. Also
# /usr/bin/kemi-vinagre → vinagre. Official
# package ships 76 .mo including zh_CN,
# zh_HK and zh_TW (keep official; do not
# invent extra language packs). Official
# help (C plus translated pages, including
# official help PNGs; some figures are
# official resolving symlinks) stays
# official. Official in-app UI XML, mime
# package, gschema, GConf convert, man page
# and appdata stay official. Official
# hicolor icons are mimetype and status
# PNGs/SVGs only; the official desktop Icon
# is the theme name
# preferences-desktop-remote-desktop, which
# this package does not ship. A 128×128 PNG
# rasterized from the official Ubuntu 20.04
# humanity-icon-theme 0.6.15 full-color SVG
# of that theme icon is used only as the
# mall CREATE --icon and is not packed. The
# official help figure
# preferences-desktop-remote-desktop.png
# (48×48) stays official and is not used as
# a mall icon. Official desktop
# Name=Remote Desktop Viewer is kept in both
# official .desktop files; mall app_name is
# Vinagre (the usual upstream name used in
# the official package Description, README
# and wiki.gnome.org/Apps/Vinagre). Official
# desktop Exec is rewritten to
# /usr/bin/vinagre …; TryExec is added.
# Official changelog.Debian.gz is a real
# file and is copied with cp -L into the
# kemi doc dir; official NEWS.gz is a real
# file. Official package has no maintainer
# scripts; icon-cache, desktop-database,
# update-mime-database and
# glib-compile-schemas hooks are added. No
# py3compile hooks; none are invented.
# Probe: Architecture arm64 · 1 unique
# packaged ELF · requiredGlibc 2.17 (1
# versioned, 0 null) · no GLIBCXX (0
# versioned, 1 null; null is not ranked as
# a max) · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal-updates / focal-security
# universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No
# librarian URL and no .buildinfo is recorded
# this run (pool 404). KEMI version
# 3.22.0-7ubuntu0.20.04.1kemi1 is 28 chars
# (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28
# char siblings succeeded, including
# Nautilus 28). No epoch, no tilde, no
# shortening applied unless the mall later
# rejects 28. gork.bot协助开发 · Verify ≠
# compile

set -euo pipefail
ROOT=/workspace/t142-20261112-vinagre
VER_UP=3.22.0-7ubuntu0.20.04.1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-vinagre
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/vinagre_3.22.0-7ubuntu0.20.04.1_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/vinagre_3.22.0-7ubuntu0.20.04.1_arm64.deb"
EXPECT_SHA=17af1e78fbe06819500e7641bb0a0ff405a2860567af2b984a41690cfd8abce2
EXPECT_BYTES=1297764
python3 - << PY
s="${VER_DEB}"
assert len(s) == 28, len(s)
assert ":" not in s, s
assert "~" not in s, s
assert s == "3.22.0-7ubuntu0.20.04.1kemi1"
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/vinagre"
python3 - << PY
from pathlib import Path
import hashlib
elf = Path("$UNPACK/usr/bin/vinagre")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 313464
assert hashlib.sha256(elf.read_bytes()).hexdigest() == "476d3dbda613d08375ff743de6483e98a65114082cc730726eb9045b6f773958"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/vinagre.desktop"
test -f "$UNPACK/usr/share/applications/vinagre-file.desktop"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Vinagre.gschema.xml"
test -f "$UNPACK/usr/share/mime/packages/vinagre-mime.xml"
test -f "$UNPACK/usr/share/metainfo/vinagre.appdata.xml"
test ! -L "$UNPACK/usr/share/doc/vinagre/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/vinagre/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/vinagre/NEWS.gz"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/vinagre.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/vinagre.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/preferences-desktop-remote-desktop.svg"
test -f "$ROOT/evidence/vinagre-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib, re
ev = Path("$ROOT/evidence/vinagre-128.png")
data = ev.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128)
assert hashlib.sha256(data).hexdigest() == "14742aa0e476c44ce8b7f9bb3de1aff4cc6c881cda7aa7ecbec5409a4c7801a3"
assert ev.stat().st_size == 9876
mos = list(Path("$UNPACK").rglob("*.mo"))
langs = sorted({p.parent.parent.name for p in mos if p.parent.name == "LC_MESSAGES"})
assert "zh_CN" in langs and "zh_TW" in langs
assert len(mos) == 76, len(mos)
print("official_mo", len(mos), "includes zh_CN/zh_HK/zh_TW")
desk = Path("$UNPACK/usr/share/applications/vinagre.desktop").read_text()
assert re.search(r"^Name=Remote Desktop Viewer\s*$", desk, flags=re.M)
assert re.search(r"^Icon=preferences-desktop-remote-desktop\s*$", desk, flags=re.M)
print("official_desktop_name_ok")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/vinagre"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/vinagre"

REPORT="$ROOT/probe/kemi-vinagre.json"
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
if Path(f["path"]).name != "vinagre":
    raise SystemExit("PROBE_NAMES:" + Path(f["path"]).name)
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
if f.get("sha256") != "476d3dbda613d08375ff743de6483e98a65114082cc730726eb9045b6f773958":
    raise SystemExit("PROBE_SHA")
if int(f.get("bytes") or 0) != 313464:
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

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 76
# evidence raster must not be staged
if find "$STAGE/pkg" -name 'vinagre-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# do not invent an app icon path that official vinagre did not ship
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/vinagre.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/vinagre.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/preferences-desktop-remote-desktop.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/preferences-desktop-remote-desktop.png"
# official help figure stays
test -f "$STAGE/pkg/usr/share/help/C/vinagre/figures/preferences-desktop-remote-desktop.png"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/vinagre/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/vinagre/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export STAGE_PKG="$STAGE/pkg"
python3 - << 'PY'
import os, re
from pathlib import Path
root = Path(os.environ["STAGE_PKG"])
official = Path("/workspace/t142-20261112-vinagre/unpack-official/vinagre_3.22.0-7ubuntu0.20.04.1_arm64/usr/share/applications")
for name in ("vinagre.desktop", "vinagre-file.desktop"):
    src = official / name
    text = src.read_text()
    if not re.search(r"^Name=Remote Desktop Viewer\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_NAME:" + name)
    if not re.search(r"^Icon=preferences-desktop-remote-desktop\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_ICON:" + name)
    if re.search(r"^TryExec=", text, flags=re.M):
        raise SystemExit("DESKTOP_TRYEXEC_ALREADY:" + name)
    out = []
    inserted = False
    for line in text.splitlines(True):
        if line.startswith("Exec=vinagre"):
            rest = line[len("Exec="):]
            line = "Exec=/usr/bin/" + rest
            out.append(line)
            if not inserted:
                out.append("TryExec=/usr/bin/vinagre\n")
                inserted = True
        else:
            out.append(line)
    text = "".join(out)
    if not re.search(r"^Exec=/usr/bin/vinagre(?:\s|$)", text, flags=re.M):
        raise SystemExit("DESKTOP_REWRITE_FAIL:" + name)
    if text.count("TryExec=/usr/bin/vinagre") != 1:
        raise SystemExit("DESKTOP_TRYEXEC_COUNT:" + name)
    if r"\1" in text:
        raise SystemExit("DESKTOP_LITERAL_GROUP:" + name)
    for line in text.splitlines():
        if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/vinagre"):
            raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + name + ":" + line)
        if line.startswith("TryExec=") and line != "TryExec=/usr/bin/vinagre":
            raise SystemExit("DESKTOP_BAD_TRYEXEC:" + name + ":" + line)
    dest = root / "usr/share/applications" / name
    dest.write_text(text)
    print("desktop_rewritten", name)
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-vinagre/scripts/build-vinagre-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/vinagre\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/vinagre "$STAGE/pkg/opt/vinagre/vinagre"
ln -sf vinagre "$STAGE/pkg/usr/bin/kemi-vinagre"

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
kemi-vinagre (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates /
    focal-security universe) vinagre
    3.22.0-7ubuntu0.20.04.1 arm64, KEMI mall
    linuxpkg repack. Newer than focal Release
    3.22.0-7. No same-source package to
    bundle. Different-source Depends stay
    Depends. Official control has no
    Recommends and no Suggests. Versioned
    Provides: vinagre (= 3.22.0-7ubuntu0.20.04.1).
    No Debian epoch, no tilde. Official
    /usr/bin/vinagre stays at the official
    path; /opt/vinagre/* are symlinks. Also
    /usr/bin/kemi-vinagre → vinagre. Official
    desktop Name=Remote Desktop Viewer kept;
    mall app_name is Vinagre; Exec rewritten
    to /usr/bin/vinagre; TryExec added.
    Official changelog is a real file and
    was copied with cp -L. Official package
    ships no app icon; a 128×128 evidence
    PNG rasterized from official U20
    Humanity theme SVG is used only as mall
    CREATE --icon and is not packed.
    Official 76 .mo including zh_CN kept;
    none invented. Icon-cache,
    desktop-database, mime-database and
    glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 03:20:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Vinagre — official Ubuntu 20.04 (focal-updates
/ focal-security universe)
vinagre 3.22.0-7ubuntu0.20.04.1 arm64, KEMI
repack. Official /usr/bin/vinagre is an
aarch64 ELF and stays under /usr.
/opt/vinagre/* are symlinks. No same-source
package to bundle. Different-source Depends
stay Depends. Official control has no
Recommends or Suggests. Official package ships
76 .mo including zh_CN. Official package does
not ship the desktop Icon theme name; a 128
evidence PNG rasterized from official U20
Humanity SVG is used only as mall CREATE
--icon and is not packed. Official desktop
Name=Remote Desktop Viewer; mall app_name is
Vinagre. No Debian epoch, no tilde. Probe: 1
unique ELF · requiredGlibc 2.17 (1 versioned,
0 null; no max invented from null) · no
requiredGlibcxx (0 versioned, 1 null; null not
ranked as a max) · no RUNPATH; within Ubuntu
20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal-updates / focal-security
universe vinagre 3.22.0-7ubuntu0.20.04.1
(arm64). Official SHA256 + size matched
ports.ubuntu.com pool files and the Packages
stanza. No librarian URL this run.
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
Depends: libavahi-common3 (>= 0.6.16), libavahi-gobject0 (>= 0.6.22), libavahi-ui-gtk3-0 (>= 0.6.30), libc6 (>= 2.17), libcairo2 (>= 1.6.0), libfreerdp2-2 (>= 2.0.0~git20160317.1.75ae3f5+dfsg1), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.9.10), libgtk-vnc-2.0-0 (>= 0.3.10), libsecret-1-0 (>= 0.7), libspice-client-glib-2.0-8 (>= 0.13), libspice-client-gtk-3.0-5 (>= 0.32), libvte-2.91-0 (>= 0.20), libxml2 (>= 2.7.4), dconf-gsettings-backend | gsettings-backend
Replaces: vinagre
Conflicts: vinagre
Provides: vinagre (= 3.22.0-7ubuntu0.20.04.1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Vinagre
Description: remote desktop client for the GNOME Desktop
 Vinagre ${VER_UP} — official Ubuntu
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
	if command -v update-mime-database >/dev/null 2>&1; then
		update-mime-database /usr/share/mime >/dev/null 2>&1 || true
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
if command -v update-mime-database >/dev/null 2>&1; then
	update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-mime-database' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'Version: 3.22.0-7ubuntu0.20.04.1kemi1' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'libfreerdp2-2' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'libgtk-vnc-2.0-0' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'Provides: vinagre (= 3.22.0-7ubuntu0.20.04.1)' "$ROOT/evidence/kemi-vinagre-control.txt"
grep -q 'Conflicts: vinagre' "$ROOT/evidence/kemi-vinagre-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-vinagre-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-vinagre-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
for name in ("vinagre.desktop", "vinagre-file.desktop"):
    desk = Path("$CHECK/usr/share/applications") / name
    text = desk.read_text()
    if r"\1" in text:
        raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP:" + name)
    if not re.search(r"^Name=Remote Desktop Viewer\s*$", text, flags=re.M):
        raise SystemExit("BUILT_NAME:" + name)
    if not re.search(r"^Exec=/usr/bin/vinagre(?:\s|$)", text, flags=re.M):
        raise SystemExit("BUILT_EXEC:" + name)
    if "TryExec=/usr/bin/vinagre" not in text:
        raise SystemExit("BUILT_TRYEXEC:" + name)
    if re.search(r"^Exec=vinagre\b", text, flags=re.M):
        raise SystemExit("BUILT_RELATIVE_EXEC:" + name)
    if not re.search(r"^Icon=preferences-desktop-remote-desktop\s*$", text, flags=re.M):
        raise SystemExit("BUILT_ICON:" + name)
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/vinagre"
test -L "$CHECK/usr/bin/kemi-vinagre"
test "$(readlink "$CHECK/usr/bin/kemi-vinagre")" = "vinagre"
test -L "$CHECK/opt/vinagre/vinagre"
test "$(readlink "$CHECK/opt/vinagre/vinagre")" = "/usr/bin/vinagre"
if find "$CHECK" -name 'vinagre-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -f "$CHECK/usr/share/icons/hicolor/128x128/apps/preferences-desktop-remote-desktop.png"
test ! -f "$CHECK/usr/share/icons/hicolor/scalable/apps/preferences-desktop-remote-desktop.svg"
test -f "$CHECK/usr/share/help/C/vinagre/figures/preferences-desktop-remote-desktop.png"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 76
test -f "$CHECK/usr/share/locale/zh_CN/LC_MESSAGES/vinagre.mo"
test -f "$CHECK/usr/share/mime/packages/vinagre-mime.xml"
# hash the published deb by explicit path, never find|head
sha256sum "$CHECK/usr/bin/vinagre"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
