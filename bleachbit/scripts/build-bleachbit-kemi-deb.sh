#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) bleachbit
# 3.9.0-1 Architecture: all as kemi-bleachbit.
# No newer package in focal-updates. The bleachbit source
# ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official Depends
# (gir1.2-gtk-3.0, libgtk-3-0, policykit-1,
# python3-chardet, python3-gi, python3-requests,
# python3:any) are different-source typelibs / GTK /
# PolicyKit / Python and stay Depends, unbundled.
# Official control has no Recommends and no Suggests.
# Versioned Provides: bleachbit (= 3.9.0-1). No Debian
# epoch. Official /usr/bin/bleachbit is a symlink to
# ../share/bleachbit/bleachbit.py; that launcher is a
# Python 3 wrapper (shebang #! /usr/bin/python3), not an
# ELF, and must not be counted as an ELF. Official files
# stay on official paths (wrapper embeds /usr/share/ and
# /usr/share/bleachbit; official pixmap
# /usr/share/pixmaps/bleachbit.png); /opt/bleachbit/* are
# symlinks. Also /usr/bin/kemi-bleachbit → bleachbit.
# Official package ships 63 .mo including zh_CN / zh_TW
# (keep official; do not invent extra language packs).
# Official package ships no Yelp help. Official app icon
# is a 256×256 PNG at /usr/share/pixmaps/bleachbit.png
# (plus an official .xpm); there is no hicolor app icon
# tree. Do not invent a PNG inside the package. The
# official 256×256 pixmap is used as the mall CREATE
# --icon (Zim / gitg / gnote pattern) and is not packed a
# second time. Official changelog.Debian.gz is a real
# file and is copied with cp -L. Official package has
# py3compile/py3clean maintainer scripts and a python3
# rtupdate hook targeting /usr/share/bleachbit; they are
# retargeted to kemi-bleachbit (blueman / zim /
# gnome-tweaks / devhelp / d-feet pattern). Official
# desktop org.bleachbit.BleachBit.desktop Exec=bleachbit
# is rewritten to /usr/bin/bleachbit; TryExec is rewritten
# to /usr/bin/bleachbit; Icon=bleachbit and Name=BleachBit
# are kept. Official root desktop bleachbit-root.desktop
# Exec=pkexec bleachbit is rewritten to
# pkexec /usr/bin/bleachbit; official TryExec=pkexec is
# kept (it checks pkexec, not bleachbit). Official
# PolicyKit action already annotates
# org.freedesktop.policykit.exec.path=/usr/bin/bleachbit
# and is kept. Official man page, cleaners XML, app-menu
# UI, Python modules under /usr/share/bleachbit and
# AUTHORS-less copyright stay in the official tree.
# Probe: Architecture all · 0 unique packaged ELF
# (vacuous PASS) · requiredGlibc none (0 versioned, 0
# null; do not invent a max) · no GLIBCXX (0 versioned,
# 0 null) · Python 3 GTK3 typelib system cleaner ·
# vacuously within 101 ≤2.31 / ≤3.4.28. Official SHA256
# + size matched official ports.ubuntu.com pool files
# and the Ubuntu 20.04 focal universe arm64 Packages
# stanza (Aliyun ubuntu-ports mirror, streamed; arch:all
# is listed in the arm64 index). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI
# version 3.9.0-1kemi1 is 12 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 13–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-bleachbit
VER_UP=3.9.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-bleachbit
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/bleachbit_3.9.0-1_all.deb"
EXPECT_SHA=156360042df0f89247933bb05b678851139a31de06cdebef9291261fe1f74ab8
EXPECT_BYTES=424204
python3 - << PY
s="${VER_DEB}"
assert len(s) == 12, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -L "$UNPACK/usr/bin/bleachbit"
test -x "$UNPACK/usr/share/bleachbit/bleachbit.py"
python3 - << PY
from pathlib import Path
link = Path("$UNPACK/usr/bin/bleachbit")
assert link.is_symlink()
assert str(link.readlink()) == "../share/bleachbit/bleachbit.py"
p = Path("$UNPACK/usr/share/bleachbit/bleachbit.py")
assert not p.is_symlink()
data = p.read_bytes()
assert data[:4] != bytes([0x7F]) + b"ELF"
assert data[:2] == b"#!"
icon = Path("$UNPACK/usr/share/pixmaps/bleachbit.png")
assert icon.is_file() and not icon.is_symlink()
assert icon.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"
print("official_symlink_wrapper_not_elf official_256_pixmap_ok")
PY
test -f "$UNPACK/usr/share/applications/org.bleachbit.BleachBit.desktop"
test -f "$UNPACK/usr/share/applications/bleachbit-root.desktop"
test -f "$UNPACK/usr/share/polkit-1/actions/org.bleachbit.policy"
test -f "$UNPACK/usr/share/python3/runtime.d/bleachbit.rtupdate"
test ! -L "$UNPACK/usr/share/doc/bleachbit/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/bleachbit/changelog.Debian.gz"
test -f "$ROOT/evidence/bleachbit-256.png"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 63
test ! -d "$UNPACK/usr/share/help"
test ! -d "$UNPACK/usr/share/icons"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/bleachbit"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/share/bleachbit/bleachbit.py"
# keep official /usr/bin/bleachbit symlink
test -L "$STAGE/pkg/usr/bin/bleachbit"

# retarget official python3 rtupdate hook to the kemi package name
if [ -f "$STAGE/pkg/usr/share/python3/runtime.d/bleachbit.rtupdate" ]; then
  sed -e 's/-p bleachbit/-p kemi-bleachbit/g' \
    "$STAGE/pkg/usr/share/python3/runtime.d/bleachbit.rtupdate" \
    > "$STAGE/pkg/usr/share/python3/runtime.d/kemi-bleachbit.rtupdate"
  chmod 0755 "$STAGE/pkg/usr/share/python3/runtime.d/kemi-bleachbit.rtupdate"
  rm -f "$STAGE/pkg/usr/share/python3/runtime.d/bleachbit.rtupdate"
  grep -q 'kemi-bleachbit' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-bleachbit.rtupdate"
  if grep -q -- '-p bleachbit' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-bleachbit.rtupdate"; then
    echo "RTUPDATE_NOT_RETARGETED" >&2
    exit 1
  fi
  grep -q '/usr/share/bleachbit' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-bleachbit.rtupdate"
fi

# 0-ELF vacuous probe (None-safe; do not invent a glibc max; do not call probe_elf.py with no --elf)
REPORT="$ROOT/probe/kemi-bleachbit.json"
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
script = Path("$STAGE/pkg/usr/share/bleachbit/bleachbit.py")
if script.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_SCRIPT")
link = Path("$STAGE/pkg/usr/bin/bleachbit")
if not link.is_symlink():
    raise SystemExit("BIN_NOT_OFFICIAL_SYMLINK")
mods = list(Path("$STAGE/pkg/usr/share/bleachbit").rglob("*.py"))
if len(mods) < 5:
    raise SystemExit("MISSING_PY_MODULES:" + str(len(mods)))
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "official bleachbit 3.9.0-1 is Architecture: all Python 3 / GTK3 typelib GUI; packaged tree contains 0 ELF files; official /usr/bin/bleachbit is a symlink to bleachbit.py and official .py modules are not ELFs",
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
        "binSymlink": str(link.readlink()),
    },
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 python3_wrapper glibc_versioned=0 glibc_null=0 noGLIBCXX configuredLimitsSatisfied=true (vacuous; no packaged ELF; official wrapper symlink and .py modules not counted as ELFs)")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 63
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/bleachbit.mo"
test -f "$STAGE/pkg/usr/share/pixmaps/bleachbit.png"
test ! -d "$STAGE/pkg/usr/share/icons"
if find "$STAGE/pkg" -name 'bleachbit-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# official pixmap must appear only once
png_count=$(find "$STAGE/pkg" -name 'bleachbit.png' | wc -l)
test "$png_count" = 1

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/bleachbit/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/bleachbit/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite_simple(src, dst):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=bleachbit(\s.*)?$", r"Exec=/usr/bin/bleachbit\1", text, flags=re.M)
    if re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^TryExec=bleachbit\s*$", "TryExec=/usr/bin/bleachbit", text2, flags=re.M)
    else:
        text2 = re.sub(r"^Exec=/usr/bin/bleachbit.*$", lambda m: m.group(0) + "\nTryExec=/usr/bin/bleachbit", text2, count=1, flags=re.M)
    if re.search(r"^Exec=bleachbit(\s|$)", text2, flags=re.M):
        raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN:" + str(src))
    for expect in ("Exec=/usr/bin/bleachbit",
                   "TryExec=/usr/bin/bleachbit",
                   "Icon=bleachbit",
                   "Name=BleachBit"):
        if expect not in text2:
            raise SystemExit("DESKTOP_MISSING:" + expect)
    dst.write_text(text2)

def rewrite_root(src, dst):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=pkexec bleachbit(\s.*)?$", r"Exec=pkexec /usr/bin/bleachbit\1", text, flags=re.M)
    if re.search(r"^Exec=pkexec bleachbit(\s|$)", text2, flags=re.M):
        raise SystemExit("ROOT_EXEC_NOT_REWRITTEN")
    for expect in ("Exec=pkexec /usr/bin/bleachbit",
                   "TryExec=pkexec",
                   "Icon=bleachbit",
                   "Name=BleachBit (as root)"):
        if expect not in text2:
            raise SystemExit("ROOT_DESKTOP_MISSING:" + expect)
    # do not rewrite TryExec=pkexec
    if re.search(r"^TryExec=/usr/bin/bleachbit", text2, flags=re.M):
        raise SystemExit("ROOT_TRYEXEC_CHANGED")
    dst.write_text(text2)

rewrite_simple(
    Path("$UNPACK/usr/share/applications/org.bleachbit.BleachBit.desktop"),
    Path("$STAGE/pkg/usr/share/applications/org.bleachbit.BleachBit.desktop"),
)
rewrite_root(
    Path("$UNPACK/usr/share/applications/bleachbit-root.desktop"),
    Path("$STAGE/pkg/usr/share/applications/bleachbit-root.desktop"),
)
print("desktops_rewritten")

pol = Path("$STAGE/pkg/usr/share/polkit-1/actions/org.bleachbit.policy").read_text(encoding="utf-8")
if 'org.freedesktop.policykit.exec.path">/usr/bin/bleachbit</annotate>' not in pol:
    raise SystemExit("POLKIT_EXEC_CHANGED")
print("polkit_kept")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".xpm", ".mo", ".gz", ".xml"}:
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
PY

ln -sf /usr/bin/bleachbit "$STAGE/pkg/opt/bleachbit/bleachbit"
ln -sf bleachbit "$STAGE/pkg/usr/bin/kemi-bleachbit"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.bleachbit.org/
Source: https://launchpad.net/ubuntu/+source/bleachbit
Homepage: https://www.bleachbit.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: all deb v${VER_UP}
(bleachbit_3.9.0-1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 bleachbit_3.9.0-1_all.deb
    (focal universe; no newer package in focal-updates;
    Architecture: all) repackaged for KEMI as ${PKG}.
    Official Depends (gir1.2-gtk-3.0, libgtk-3-0,
    policykit-1, python3-chardet, python3-gi,
    python3-requests, python3:any) stay Depends and are
    not bundled. Official control has no Recommends and
    no Suggests. Versioned Provides: bleachbit (= 3.9.0-1).
  * Official /usr/bin/bleachbit is a symlink to the
    official Python 3 wrapper
    /usr/share/bleachbit/bleachbit.py, not an ELF.
    /opt/bleachbit/* are symlinks. Also
    /usr/bin/kemi-bleachbit.
  * Official package ships 63 .mo including zh_CN / zh_TW
    and no Yelp help. Official 256×256 pixmap
    /usr/share/pixmaps/bleachbit.png is used as the mall
    CREATE --icon and is not packed a second time.
  * Official py3compile/py3clean, dpkg -L and the python3
    rtupdate hook for /usr/share/bleachbit are retargeted
    to kemi-bleachbit. Official changelog is a real file
    and was copied with cp -L. Official desktop
    Exec=bleachbit rewritten to /usr/bin/bleachbit;
    official root desktop Exec=pkexec bleachbit rewritten
    to pkexec /usr/bin/bleachbit (TryExec=pkexec kept).
    Official PolicyKit exec.path=/usr/bin/bleachbit is
    already absolute and is kept.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
BleachBit ${VER_UP} — official Ubuntu 20.04 (focal)
universe Architecture: all, KEMI repack.

Official /usr/bin/bleachbit is a symlink to a Python 3
wrapper (not an ELF) that embeds /usr/share/bleachbit.
/opt/bleachbit/* are symlinks. Official typelib / GTK /
PolicyKit / Python Depends stay Depends and are not
bundled. Official control has no Recommends and no
Suggests. Official package ships 63 .mo including
zh_CN / zh_TW and no Yelp help. Probe: 0 unique ELF
(vacuous PASS) · no versioned glibc / GLIBCXX (0
versioned, 0 null; do not invent a max); Python 3
GTK3 typelib system cleaner; vacuously within Ubuntu
20.04 / glibc 2.31. Official publication: Ubuntu 20.04
focal universe bleachbit 3.9.0-1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-gtk-3.0, libgtk-3-0, policykit-1, python3-chardet, python3-gi, python3-requests, python3:any
Replaces: bleachbit
Conflicts: bleachbit
Provides: bleachbit (= 3.9.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.bleachbit.org/
Description: delete unnecessary files from the system
 BleachBit ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib system cleaner.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_python3 (retargeted to kemi-bleachbit):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-bleachbit /usr/share/bleachbit
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-bleachbit /usr/share/bleachbit || true
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
# Automatically added by dh_python3 (retargeted to kemi-bleachbit):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-bleachbit
else
	dpkg -L kemi-bleachbit | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
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

if grep -R -- '-p bleachbit' "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/share/python3" 2>/dev/null | grep -v kemi-bleachbit; then
  echo "LEFTOVER_PY3_PKGNAME" >&2
  exit 1
fi
if grep -n 'dpkg -L bleachbit' "$STAGE/pkg/DEBIAN/prerm"; then
  echo "LEFTOVER_DPKG_L" >&2
  exit 1
fi

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-bleachbit-control.txt"
grep -q 'Version: 3.9.0-1kemi1' "$ROOT/evidence/kemi-bleachbit-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-bleachbit-control.txt"
grep -q 'python3-gi' "$ROOT/evidence/kemi-bleachbit-control.txt"
grep -q 'policykit-1' "$ROOT/evidence/kemi-bleachbit-control.txt"
grep -q 'Provides: bleachbit (= 3.9.0-1)' "$ROOT/evidence/kemi-bleachbit-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/bleachbit",
    "./usr/bin/kemi-bleachbit",
    "./opt/bleachbit/bleachbit",
    "./usr/share/bleachbit/bleachbit.py",
    "./usr/share/applications/org.bleachbit.BleachBit.desktop",
    "./usr/share/applications/bleachbit-root.desktop",
    "./usr/share/pixmaps/bleachbit.png",
    "./usr/share/pixmaps/bleachbit.xpm",
    "./usr/share/locale/zh_CN/LC_MESSAGES/bleachbit.mo",
    "./usr/share/polkit-1/actions/org.bleachbit.policy",
    "./usr/share/python3/runtime.d/kemi-bleachbit.rtupdate",
    "./usr/share/man/man1/bleachbit.1.gz",
    "./usr/share/doc/kemi-bleachbit/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "bleachbit-256.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "usr/share/python3/runtime.d/bleachbit.rtupdate" in out:
    raise SystemExit("OLD_RTUPDATE_NAME")
found_bin = False
found_kemi = False
for line in out.splitlines():
    if "./usr/bin/bleachbit " in line or line.rstrip().endswith("./usr/bin/bleachbit"):
        if "kemi-bleachbit" not in line:
            found_bin = True
            if "->" not in line:
                raise SystemExit("BIN_NOT_SYMLINK:" + line)
    if "./usr/bin/kemi-bleachbit" in line:
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
