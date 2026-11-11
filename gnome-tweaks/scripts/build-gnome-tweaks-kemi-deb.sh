#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) gnome-tweaks
# 3.34.0-2ubuntu1 Architecture: all as kemi-gnome-tweaks.
# The gnome-tweaks source in focal ships two binary packages:
# gnome-tweaks (the real GUI) and gnome-tweak-tool (transitional
# dummy, Section: oldlibs, Depends: gnome-tweaks, only copyright
# + a dangling changelog symlink). This script packages the real
# GUI package, not the dummy. Official control has no Recommends
# and no Suggests. System typelib / GNOME Depends stay Depends
# and are not bundled (different-source, not exact-version data).
# Versioned Provides: gnome-tweaks (= 3.34.0-2ubuntu1). Official
# Breaks/Replaces gnome-tweak-tool (<= 3.27.4) are kept so the
# current transitional dummy (3.34.0-2ubuntu1, Depends:
# gnome-tweaks) can remain installed via the versioned Provides.
# Official /usr/bin/gnome-tweaks is a Python 3 wrapper (not an
# ELF). The lid-inhibitor helper under
# /usr/lib/gnome-tweak-tool/ is also a Python 3 script. App
# code lives under /usr/lib/python3/dist-packages/gtweak and
# data under /usr/share/gnome-tweaks (defs.py hardcodes the
# official /usr prefix). Official files stay on official
# paths; /opt/gnome-tweaks/* are symlinks. Official package
# ships no .mo (Ubuntu language-pack split; desktop
# X-Ubuntu-Gettext-Domain=gnome-tweaks; changelog already
# documents X-Ubuntu-Use-Langpack: yes). Keep the official
# tree; do not invent or bundle language packs. Official
# package has no /usr/share/help tree; do not invent one.
# Official icons are SVG only (org.gnome.tweaks.svg and
# symbolic). Do not invent a PNG inside the package. A
# 128x128 PNG rasterized from the official SVG may be used
# only as the mall CREATE --icon and must live under
# evidence/ (GNOME Clocks / GNOME Calendar pattern). Official
# changelog is a real file. Official maintainer scripts use
# py3compile/py3clean/dpkg -L -p gnome-tweaks and must be
# retargeted to kemi-gnome-tweaks (Zim / Blueman pattern).
# Official desktop Exec=gnome-tweaks is rewritten to
# /usr/bin/gnome-tweaks; Icon=org.gnome.tweaks is kept.
# Probe: Architecture all · 0 packaged ELF · no
# requiredGlibc / requiredGlibcxx version-needs · Python 3
# GTK3 typelib GUI · vacuously within 101 ≤2.31 / ≤3.4.28
# (no ELF to exceed the baseline). No PEP 585 annotations
# in official Python sources (safe on Ubuntu 20.04 / 3.8).
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed;
# arch:all listed in the arm64 index). No newer package in
# focal-updates (0 hits). No librarian URL and no .buildinfo
# is recorded this run (pool 404).
# KEMI version 3.34.0-2ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars). No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-tweaks
VER_UP=3.34.0-2ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-gnome-tweaks
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/gnome-tweaks_3.34.0-2ubuntu1_all.deb"
EXPECT_SHA=5f56ac248a2e95e9b896c445d7ee1c88eacc10bcf8c7b5b3dd4468117c026a14
EXPECT_BYTES=58404
# version_name length check (mall rejected Remmina at 33)
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-tweaks"
test "$(head -n 1 "$UNPACK/usr/bin/gnome-tweaks")" = "#! /usr/bin/python3"
python3 - << PY
from pathlib import Path
magic = bytes([0x7F]) + b"ELF"
for rel in ("usr/bin/gnome-tweaks",
            "usr/lib/gnome-tweak-tool/gnome-tweak-tool-lid-inhibitor"):
    p = Path("$UNPACK") / rel
    assert p.is_file()
    assert p.read_bytes()[:4] != magic
print("official_no_elf")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.tweaks.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.tweaks.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.tweaks-symbolic.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.tweaks.png"
test ! -d "$UNPACK/usr/share/icons/hicolor/48x48"
test ! -d "$UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/gnome-tweaks/changelog.Debian.gz"
test -f "$UNPACK/usr/lib/python3/dist-packages/gtweak/defs.py"
test -f "$UNPACK/DEBIAN/postinst" && test -f "$UNPACK/DEBIAN/prerm"
grep -q 'py3compile -p gnome-tweaks' "$UNPACK/DEBIAN/postinst"
grep -q 'py3clean -p gnome-tweaks' "$UNPACK/DEBIAN/prerm"
test -f "$ROOT/evidence/org.gnome.tweaks-128.png"
# evidence raster must not already be in the official tree
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.tweaks.png"

# no PEP 585 in official Python
python3 - << PY
import re
from pathlib import Path
root = Path("$UNPACK")
pat = re.compile(r"\b(list|dict|tuple|set|frozenset|type)\s*\[")
hits = []
for p in root.rglob("*.py"):
    text = p.read_text(encoding="utf-8", errors="replace")
    for i, line in enumerate(text.splitlines(), 1):
        if line.lstrip().startswith("#"):
            continue
        if pat.search(line):
            hits.append(f"{p}:{i}:{line.strip()}")
if hits:
    raise SystemExit("PEP585:" + ";".join(hits))
print("no_pep585")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-tweaks"

# official trees
cp -a "$UNPACK/usr/bin/gnome-tweaks" "$STAGE/pkg/usr/bin/gnome-tweaks"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-tweaks"
cp -a "$UNPACK/usr/lib" "$STAGE/pkg/usr/lib"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

# 0-ELF probe report (None-safe; do not invent a glibc max)
REPORT="$ROOT/probe/kemi-gnome-tweaks.json"
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
script = Path("$STAGE/pkg/usr/bin/gnome-tweaks")
if script.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_SCRIPT")
helper = Path("$STAGE/pkg/usr/lib/gnome-tweak-tool/gnome-tweak-tool-lid-inhibitor")
if helper.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_HELPER")
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "official gnome-tweaks 3.34.0-2ubuntu1 is Architecture: all Python 3 / GTK3 typelib GUI; packaged tree contains 0 ELF files",
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
    },
    "helper": {
        "path": str(helper),
        "shebang": helper.read_text(encoding="utf-8").splitlines()[0],
        "bytes": helper.stat().st_size,
    },
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 python3_wrapper glibc_versioned=0 glibc_null=0 noGLIBCXX configuredLimitsSatisfied=true (vacuous; no packaged ELF)")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.tweaks.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps/org.gnome.tweaks-symbolic.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.tweaks.png"
test ! -f "$STAGE/pkg/usr/share/gnome-tweaks/shell.ui" -o -f "$STAGE/pkg/usr/share/gnome-tweaks/shell.ui"
test -f "$STAGE/pkg/usr/share/gnome-tweaks/shell.ui"
# evidence raster must not be packed
if find "$STAGE/pkg" -name 'org.gnome.tweaks-128.png' | grep -q .; then
  echo "PACKED_EVIDENCE_PNG" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-tweaks/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-tweaks/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.tweaks.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.tweaks.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnome-tweaks(\s.*)?$", r"Exec=/usr/bin/gnome-tweaks\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=gnome-tweaks$", "TryExec=/usr/bin/gnome-tweaks", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gnome-tweaks(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/gnome-tweaks", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnome-tweaks(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gnome-tweaks", "TryExec=/usr/bin/gnome-tweaks",
               "Icon=org.gnome.tweaks", "Name=Tweaks"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in t:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/gnome-tweaks "$STAGE/pkg/opt/gnome-tweaks/gnome-tweaks"
ln -sf gnome-tweaks "$STAGE/pkg/usr/bin/kemi-gnome-tweaks"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Tweaks
Source: https://launchpad.net/ubuntu/+source/gnome-tweaks
Homepage: https://wiki.gnome.org/Apps/Tweaks
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: all deb v${VER_UP}
(gnome-tweaks_3.34.0-2ubuntu1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-tweaks_3.34.0-2ubuntu1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. The same-source
    gnome-tweak-tool package is a transitional dummy and is
    not bundled. Official control has no Recommends and no
    Suggests. Versioned Provides: gnome-tweaks (= 3.34.0-2ubuntu1).
    Official Breaks/Replaces gnome-tweak-tool (<= 3.27.4) kept.
  * Official /usr/bin/gnome-tweaks is a Python 3 wrapper (no
    packaged ELF). Data stays under /usr/share/gnome-tweaks
    (compiled /usr prefix in defs.py). /opt/gnome-tweaks/*
    are symlinks. Also /usr/bin/kemi-gnome-tweaks.
  * Desktop, official SVG icons, official shell.ui/css stay
    on standard paths. Official package ships no .mo and no
    /usr/share/help (language-pack split). Official desktop
    Exec=gnome-tweaks rewritten to /usr/bin/gnome-tweaks;
    Icon=org.gnome.tweaks. Official icons are SVG only; no
    PNG is invented inside the package.
  * Official py3compile/py3clean/dpkg -L scripts retargeted
    to kemi-gnome-tweaks. Official changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Tweaks ${VER_UP} — official Ubuntu 20.04
(focal) universe Architecture: all, KEMI repack.

Official /usr/bin/gnome-tweaks is a Python 3 wrapper
(no packaged ELF). /opt/gnome-tweaks/* are symlinks.
Desktop, official SVG icons and official
/usr/share/gnome-tweaks data remain on standard
paths. Official package ships no .mo (language-pack
split) and no /usr/share/help. Official control has
no Recommends and no Suggests. Probe: 0 ELF · no
requiredGlibc / requiredGlibcxx version-needs;
Python 3 GTK3 typelib GUI; vacuously within
Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04 focal universe
gnome-tweaks 3.34.0-2ubuntu1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com
pool files and focal universe arm64 Packages
stanza. The same-source gnome-tweak-tool package
is a transitional dummy and was not packaged.
No librarian URL this run.
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
Depends: python3:any, gsettings-desktop-schemas (>= 3.28), gnome-settings-daemon, gnome-shell-common (>= 3.24), mutter-common, python3-gi (>= 3.10), gir1.2-gtk-3.0 (>= 3.12), gir1.2-gnomedesktop-3.0 (>= 3.30), gir1.2-handy-0.0, gir1.2-soup-2.4, gir1.2-notify-0.7, gir1.2-glib-2.0 (>= 1.58), gir1.2-pango-1.0, gnome-shell-extension-prefs
Breaks: gnome-tweak-tool (<= 3.27.4)
Replaces: gnome-tweaks, gnome-tweak-tool (<= 3.27.4)
Conflicts: gnome-tweaks
Provides: gnome-tweaks (= 3.34.0-2ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Tweaks
Description: tool to adjust advanced configuration settings for GNOME
 GNOME Tweaks ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Advanced GNOME settings not in gnome-control-center
 (GTK3, Python 3 typelib GUI).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official scripts retargeted to kemi-gnome-tweaks (Zim / Blueman / py3compile pattern)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi-gnome-tweaks):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-gnome-tweaks
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-gnome-tweaks || true
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

# Automatically added by dh_python3 (retargeted to kemi-gnome-tweaks):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-gnome-tweaks
else
	dpkg -L kemi-gnome-tweaks | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
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

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-tweaks-control.txt"
# confirm scripts retargeted
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./postinst | grep -q 'py3compile -p kemi-gnome-tweaks'
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./prerm | grep -q 'py3clean -p kemi-gnome-tweaks'
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./prerm | grep -q 'dpkg -L kemi-gnome-tweaks'
if dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./postinst | grep -q 'py3compile -p gnome-tweaks'; then
  echo "LEFTOVER_PY3COMPILE_UPSTREAM" >&2
  exit 1
fi
# packed tree must still have no invented PNG and no evidence raster
python3 - << PY
import subprocess, tarfile, io
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
if "org.gnome.tweaks-128.png" in out or "128x128/apps/org.gnome.tweaks.png" in out:
    raise SystemExit("PACKED_RASTER_OR_INVENTED_PNG")
# must contain official SVG and python wrapper, kemi symlink, opt symlink
need = [
    "./usr/bin/gnome-tweaks",
    "./usr/bin/kemi-gnome-tweaks",
    "./opt/gnome-tweaks/gnome-tweaks",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.tweaks.svg",
    "./usr/lib/python3/dist-packages/gtweak/defs.py",
    "./usr/lib/gnome-tweak-tool/gnome-tweak-tool-lid-inhibitor",
]
for n in need:
    if n not in out and (n+" ->") not in out and not any(n in line for line in out.splitlines()):
        # dpkg-deb -c lists symlinks as 'path -> target'
        if not any(line.split()[-3] == n or n in line for line in out.splitlines()):
            raise SystemExit("MISSING_IN_DEB:" + n)
print("DEB_TREE_OK")
PY
echo "SCRIPTS_RETARGETED"
echo "BUILD_OK $DEB"
