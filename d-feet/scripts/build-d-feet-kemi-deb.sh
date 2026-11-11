#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) d-feet
# 0.3.15-2 Architecture: all as kemi-d-feet.
# No newer package in focal-updates. The d-feet source
# ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official Depends
# (gir1.2-glib-2.0, gir1.2-gtk-3.0, python3-gi,
# dconf-gsettings-backend | gsettings-backend,
# python3:any) are different-source typelibs / Python
# and stay Depends, unbundled. Official control has no
# Recommends and no Suggests. Versioned Provides:
# d-feet (= 0.3.15-2). No Debian epoch.
# Official /usr/bin/d-feet is a Python 3 wrapper (shebang
# #!/usr/bin/python3), not an ELF, and must not be counted
# as an ELF. Official files stay on official paths
# (wrapper embeds /usr/share/d-feet and official
# dist-packages); /opt/d-feet/* are symlinks. Also
# /usr/bin/kemi-d-feet → d-feet. Official package ships
# 26 .mo including zh_CN (keep official; do not invent
# extra language packs). Official Yelp help has a real C
# tree plus official translated help for cs, de, el, es,
# hu, pl, pt_BR, sv (0 dangling; some figure PNGs are
# official symlinks to C). Official help figure PNGs stay
# in the official help tree and are not the mall icon.
# Official app icon is SVG only (org.gnome.dfeet.svg +
# symbolic). Official 16×16 hicolor PNGs are in-app icons
# (method/signal/property/object/service) and stay in the
# official tree; they are not a mall app icon and are not
# packed a second time. Do not invent a PNG inside the
# package. A 128×128 PNG rasterized from the official app
# SVG via Chrome headless lives at
# evidence/org.gnome.dfeet-128.png and is used only as the
# mall CREATE --icon (GNOME Clocks / Calculator / Devhelp
# pattern); it is not shipped in the deb. Official
# changelog.Debian.gz is a real file and is copied with
# cp -L. Official package has py3compile/py3clean
# maintainer scripts (no python3 rtupdate hook); they are
# retargeted to kemi-d-feet (blueman / zim / gnome-tweaks
# / devhelp pattern). Official desktop Exec=d-feet is
# rewritten to /usr/bin/d-feet; TryExec is added;
# Icon=org.gnome.dfeet is kept; Name=D-Feet is kept.
# Official gsettings schema, man page, appdata, AUTHORS
# and NEWS stay in the official tree. Official Python
# modules stay under /usr/lib/python3/dist-packages/dfeet.
# Probe: Architecture all · 0 unique packaged ELF
# (vacuous PASS) · requiredGlibc none (0 versioned, 0
# null; do not invent a max) · no GLIBCXX (0 versioned,
# 0 null) · Python 3 GTK3 typelib D-Bus debugger ·
# vacuously within 101 ≤2.31 / ≤3.4.28. Official SHA256
# + size matched official ports.ubuntu.com pool files
# and the Ubuntu 20.04 focal universe arm64 Packages
# stanza (Aliyun ubuntu-ports mirror, streamed; arch:all
# is listed in the arm64 index). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI
# version 0.3.15-2kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 13–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-d-feet
VER_UP=0.3.15-2
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-d-feet
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/d-feet_0.3.15-2_all.deb"
EXPECT_SHA=0268171f0c1dfb158831bdf31bb34af4e263359c6fa3e260461ef365a71e61d8
EXPECT_BYTES=55952
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
test -x "$UNPACK/usr/bin/d-feet"
python3 - << PY
from pathlib import Path
p = Path("$UNPACK/usr/bin/d-feet")
assert not p.is_symlink()
data = p.read_bytes()
assert data[:4] != bytes([0x7F]) + b"ELF"
assert data[:2] == b"#!"
assert b"#!/usr/bin/python3" in data.splitlines()[0]
print("official_wrapper_not_elf")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.dfeet.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.dfeet.svg"
test ! -L "$UNPACK/usr/share/doc/d-feet/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/d-feet/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.dfeet-128.png"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 26
test -d "$UNPACK/usr/share/help/C/d-feet"
test -f "$UNPACK/usr/lib/python3/dist-packages/dfeet/application.py"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/d-feet"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/d-feet"

# 0-ELF vacuous probe (None-safe; do not invent a glibc max; do not call probe_elf.py with no --elf)
REPORT="$ROOT/probe/kemi-d-feet.json"
python3 - << PY
from pathlib import Path
import json
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs=[]
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
script = Path("$STAGE/pkg/usr/bin/d-feet")
if script.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_SCRIPT")
# official Python modules must not be counted as ELFs
mods = list(Path("$STAGE/pkg/usr/lib/python3/dist-packages/dfeet").glob("*.py"))
if len(mods) < 10:
    raise SystemExit("MISSING_PY_MODULES:" + str(len(mods)))
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "official d-feet 0.3.15-2 is Architecture: all Python 3 / GTK3 typelib GUI; packaged tree contains 0 ELF files; official /usr/bin/d-feet is a Python wrapper and official .py modules are not ELFs",
    "hostArchitecture": "x86_64",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "elfCount": 0,
    "glibcVersioned": 0,
    "glibcNull": 0,
    "glibcxxVersioned": 0,
    "glibcxxNull": 0,
    "maxVersionedGlibc": None,
    "maxVersionedGlibcxx": None,
    "wrapper": {
        "path": str(script),
        "shebang": script.read_text(encoding="utf-8").splitlines()[0],
        "bytes": script.stat().st_size,
        "isELF": False,
    },
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 python3_wrapper glibc_versioned=0 glibc_null=0 noGLIBCXX configuredLimitsSatisfied=true (vacuous; no packaged ELF; official wrapper and .py modules not counted as ELFs)")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 26
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/d-feet.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.dfeet.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/16x16/apps/dfeet-method.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.dfeet.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.dfeet.png"
test -f "$STAGE/pkg/usr/share/help/C/d-feet/index.page"
test -f "$STAGE/pkg/usr/share/help/C/d-feet/figures/icon.png"
if find "$STAGE/pkg" -name 'org.gnome.dfeet-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/d-feet/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/d-feet/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.dfeet.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.dfeet.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=d-feet(\s.*)?$", r"Exec=/usr/bin/d-feet\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/d-feet", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/d-feet.*$", lambda m: m.group(0) + "\nTryExec=/usr/bin/d-feet", text2, count=1, flags=re.M)
if re.search(r"^Exec=d-feet(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/d-feet",
               "TryExec=/usr/bin/d-feet",
               "Icon=org.gnome.dfeet",
               "Name=D-Feet"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

# official wrapper contains commented-out historical x86_64 typelib paths;
# those comments are kept as official text. Fail only on a live (uncommented) path.
leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".page"}:
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
print("no_live_x86_paths (official commented x86 typelib lines kept)")
PY

ln -sf /usr/bin/d-feet "$STAGE/pkg/opt/d-feet/d-feet"
ln -sf d-feet "$STAGE/pkg/usr/bin/kemi-d-feet"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/DFeet
Source: https://launchpad.net/ubuntu/+source/d-feet
Homepage: https://wiki.gnome.org/Apps/DFeet
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: all deb v${VER_UP}
(d-feet_0.3.15-2_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 d-feet_0.3.15-2_all.deb
    (focal universe; no newer package in focal-updates;
    Architecture: all) repackaged for KEMI as ${PKG}.
    Official Depends (gir1.2-glib-2.0, gir1.2-gtk-3.0,
    python3-gi, dconf-gsettings-backend | gsettings-backend,
    python3:any) stay Depends and are not bundled. Official
    control has no Recommends and no Suggests. Versioned
    Provides: d-feet (= 0.3.15-2).
  * Official /usr/bin/d-feet is a Python 3 wrapper, not an
    ELF. /opt/d-feet/* are symlinks. Also
    /usr/bin/kemi-d-feet.
  * Official package ships 26 .mo including zh_CN. Official
    Yelp help has a real C tree plus official translated
    help (cs, de, el, es, hu, pl, pt_BR, sv), 0 dangling.
    Official help figure PNGs stay in the official help
    tree. Official app icon is SVG only; official 16×16
    hicolor PNGs are in-app icons and stay official. A
    128×128 evidence PNG is used only for mall CREATE
    --icon and is not packed in the deb.
  * Official py3compile/py3clean and dpkg -L hooks are
    retargeted to kemi-d-feet. Official changelog is a
    real file and was copied with cp -L. Official desktop
    Exec=d-feet rewritten to /usr/bin/d-feet; TryExec
    added; Icon=org.gnome.dfeet.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
D-Feet ${VER_UP} — official Ubuntu 20.04 (focal)
universe Architecture: all, KEMI repack.

Official /usr/bin/d-feet is a Python 3 wrapper (not an
ELF) that embeds /usr/share/d-feet. /opt/d-feet/* are
symlinks. Official typelib / python3-gi Depends stay
Depends and are not bundled. Official control has no
Recommends and no Suggests. Official package ships 26
.mo including zh_CN. Official help C tree is kept;
official translated help has 0 dangling links. Probe:
0 unique ELF (vacuous PASS) · no versioned glibc /
GLIBCXX (0 versioned, 0 null; do not invent a max);
Python 3 GTK3 typelib D-Bus debugger; vacuously within
Ubuntu 20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal universe d-feet 0.3.15-2
(Architecture: all). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-glib-2.0, gir1.2-gtk-3.0 (>= 3.6), python3-gi (>= 3.3.91), dconf-gsettings-backend | gsettings-backend, python3:any
Replaces: d-feet
Conflicts: d-feet
Provides: d-feet (= 0.3.15-2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/DFeet
Description: D-Bus object browser, viewer and debugger
 D-Feet ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib D-Bus debugger.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_python3 (retargeted to kemi-d-feet):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-d-feet
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-d-feet || true
fi
# End automatically added section
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
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
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_python3 (retargeted to kemi-d-feet):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-d-feet
else
	dpkg -L kemi-d-feet | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi
# End automatically added section
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-icon-caches >/dev/null 2>&1; then
	update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

if grep -R -- '-p d-feet' "$STAGE/pkg/DEBIAN" 2>/dev/null | grep -v kemi-d-feet; then
  echo "LEFTOVER_PY3_PKGNAME" >&2
  exit 1
fi
if grep -n 'dpkg -L d-feet' "$STAGE/pkg/DEBIAN/prerm"; then
  echo "LEFTOVER_DPKG_L" >&2
  exit 1
fi

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-d-feet-control.txt"
grep -q 'Version: 0.3.15-2kemi1' "$ROOT/evidence/kemi-d-feet-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-d-feet-control.txt"
grep -q 'python3-gi (>= 3.3.91)' "$ROOT/evidence/kemi-d-feet-control.txt"
grep -q 'Provides: d-feet (= 0.3.15-2)' "$ROOT/evidence/kemi-d-feet-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/d-feet",
    "./usr/bin/kemi-d-feet",
    "./opt/d-feet/d-feet",
    "./usr/share/applications/org.gnome.dfeet.desktop",
    "./usr/lib/python3/dist-packages/dfeet/application.py",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.dfeet.svg",
    "./usr/share/icons/hicolor/16x16/apps/dfeet-method.png",
    "./usr/share/help/C/d-feet/index.page",
    "./usr/share/help/C/d-feet/figures/icon.png",
    "./usr/share/locale/zh_CN/LC_MESSAGES/d-feet.mo",
    "./usr/share/glib-2.0/schemas/org.gnome.dfeet.gschema.xml",
    "./usr/share/man/man1/d-feet.1.gz",
    "./usr/share/metainfo/org.gnome.dfeet.appdata.xml",
    "./usr/share/doc/kemi-d-feet/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "org.gnome.dfeet-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = False
found_kemi = False
for line in out.splitlines():
    if "./usr/bin/d-feet " in line or line.rstrip().endswith("./usr/bin/d-feet"):
        found_bin = True
        if "kemi-d-feet" not in line and "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-d-feet" in line:
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
