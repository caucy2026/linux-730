#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) arandr
# 0.1.10-1.1 Architecture: all as kemi-arandr.
# No newer package in focal-updates. The arandr
# source ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official typelib
# / GTK / Python / x11-xserver-utils Depends stay
# Depends, unbundled. Official control has no Recommends
# and no Suggests. Versioned Provides: arandr
# (= 0.1.10-1.1). No Debian epoch, no tilde. Official
# /usr/bin/arandr (1407 B) and /usr/bin/unxrandr (1127 B)
# are Python 3 wrappers (shebang #!/usr/bin/python3),
# not ELFs, and are not counted as ELFs. Official .py
# modules under /usr/lib/python3/dist-packages/screenlayout
# are not ELFs. Official files stay on official paths;
# /opt/arandr/* are symlinks. Also
# /usr/bin/kemi-arandr → arandr (the GUI). Official
# package ships 38 .mo including zh_CN / zh_Hant (keep
# official; do not invent extra language packs). Official
# package ships no Yelp help and no appdata. Official
# package ships no app icon files (no hicolor, no pixmap,
# no SVG). Official desktop Icon=display (theme icon) is
# kept. Official About dialog uses logo_icon_name
# video-display. A 128×128 evidence PNG rasterized from
# the box Adwaita theme icon video-display.svg (the
# official in-app icon name) via Chrome headless
# --default-background-color=00000000 lives at
# evidence/arandr-128.png and is used only as the mall
# CREATE --icon; it is not shipped in the deb and is not
# an invented packaged app icon. Official
# changelog.Debian.gz, NEWS.gz and README.gz are real
# files and are copied with cp -L. Official
# screenlayout/data/gpl-3.txt is a symlink to
# /usr/share/common-licenses/GPL-3 (standard Debian
# common-licenses; dangling only in a bare unpack) and
# is kept official. Official desktop Exec=arandr is
# rewritten to /usr/bin/arandr; TryExec is added;
# Icon=display and Name=ARandR are kept (mall app_name
# is ARandR). Official py3compile / py3clean / dpkg -L
# hooks are retargeted to kemi-arandr. Official package
# has no python3 rtupdate hook. Probe: Architecture:
# all · 0 unique packaged ELF (vacuous PASS; official
# wrappers and .py modules are not ELFs and were not
# counted) · requiredGlibc none (0 versioned, 0 null;
# do not invent a max; null is not ranked as a max) ·
# no GLIBCXX (0 versioned, 0 null) · Python 3 GTK3
# typelib XRandR front end · within 101 ≤2.31 / ≤3.4.28
# (vacuous). Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04
# focal universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed; Architecture: all is
# listed in the arm64 index). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI
# version 0.1.10-1.1kemi1 is 15 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-arandr
VER_UP=0.1.10-1.1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-arandr
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-kemi}"
UP_DEB="$DL/arandr_0.1.10-1.1_all.deb"
EXPECT_SHA=8e78546c82c072a6a1e7694a07db8fe98c3b89566664e22a04e91398bd0e27c5
EXPECT_BYTES=54844
python3 - << PY
s="${VER_DEB}"
assert len(s) == 15, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

rm -rf "$UNPACK"
mkdir -p "$UNPACK"
dpkg-deb -x "$UP_DEB" "$UNPACK"
dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"

test -x "$UNPACK/usr/bin/arandr"
test -x "$UNPACK/usr/bin/unxrandr"
python3 - << PY
from pathlib import Path
for rel in ("usr/bin/arandr", "usr/bin/unxrandr"):
    p = Path("$UNPACK") / rel
    assert not p.is_symlink(), rel
    assert p.read_bytes()[:2] == b"#!"
    assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_wrappers_not_elf")
PY
test -f "$UNPACK/usr/share/applications/arandr.desktop"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 38
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/arandr.mo"
test -f "$UNPACK/usr/share/locale/zh_Hant/LC_MESSAGES/arandr.mo"
# official package ships no app icons
if find "$UNPACK" \( -name '*.png' -o -name '*.svg' -o -name '*.xpm' \) | grep -q .; then
  echo "UNEXPECTED_OFFICIAL_ICON" >&2
  exit 1
fi
test ! -d "$UNPACK/usr/share/icons"
test ! -d "$UNPACK/usr/share/pixmaps"
test ! -L "$UNPACK/usr/share/doc/arandr/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/arandr/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/arandr/NEWS.gz"
test -f "$UNPACK/usr/share/doc/arandr/NEWS.gz"
test -L "$UNPACK/usr/lib/python3/dist-packages/screenlayout/data/gpl-3.txt"
test "$(readlink "$UNPACK/usr/lib/python3/dist-packages/screenlayout/data/gpl-3.txt")" = "../../../../../share/common-licenses/GPL-3"
test -f "$ROOT/evidence/arandr-128.png"
python3 - << PY
import struct
from pathlib import Path
p = Path("$ROOT/evidence/arandr-128.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (128, 128), (w, h)
print("evidence_128_for_create", w, h, p.stat().st_size)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/arandr"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/arandr" "$STAGE/pkg/usr/bin/unxrandr"
# keep official gpl-3.txt symlink (resolves on Ubuntu via base-files)

for s in postinst prerm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done

export STAGE_PKG="$STAGE/pkg"
python3 - << 'END_ARANDR_HOOKS'
from pathlib import Path
import os, re
root = Path(os.environ["STAGE_PKG"])
for name in ("postinst", "prerm"):
    p = root / "DEBIAN" / name
    t = p.read_text()
    t = t.replace("py3compile -p arandr", "py3compile -p kemi-arandr")
    t = t.replace("pypy3compile -p arandr", "pypy3compile -p kemi-arandr")
    t = t.replace("py3clean -p arandr", "py3clean -p kemi-arandr")
    t = re.sub(r"dpkg -L arandr\b", "dpkg -L kemi-arandr", t)
    p.write_text(t)
    p.chmod(0o755)
if (root / "usr/share/python3/runtime.d").exists():
    raise SystemExit("UNEXPECTED_RTUPDATE")
post = (root/"DEBIAN/postinst").read_text()
prerm = (root/"DEBIAN/prerm").read_text()
if "py3compile -p arandr" in post or "pypy3compile -p arandr" in post:
    raise SystemExit("PY3_NOT_RETARGETED_POSTINST")
if "py3compile -p kemi-arandr" not in post:
    raise SystemExit("PY3_MISSING_KEMI_POSTINST")
if "py3clean -p arandr " in prerm or "py3clean -p arandr\n" in prerm:
    raise SystemExit("PY3_NOT_RETARGETED_PRERM")
if "dpkg -L arandr" in prerm:
    raise SystemExit("DPKG_L_NOT_RETARGETED")
if "dpkg -L kemi-arandr" not in prerm:
    raise SystemExit("DPKG_L_MISSING")
print("py3_hooks_retargeted")
END_ARANDR_HOOKS

REPORT="$ROOT/probe/kemi-arandr.json"
python3 - << PY
import json
from pathlib import Path
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
for rel in ("usr/bin/arandr", "usr/bin/unxrandr"):
    w = root / rel
    if w.read_bytes()[:2] != b"#!":
        raise SystemExit("WRAPPER_MISSING:" + rel)
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "maxVersionedGlibc": None,
    "maxVersionedGlibcxx": None,
    "nUniqueElf": 0,
    "glibcVersioned": 0,
    "glibcNull": 0,
    "glibcxxVersioned": 0,
    "glibcxxNull": 0,
    "note": "0 unique packaged ELF; official /usr/bin/arandr and /usr/bin/unxrandr are Python 3 wrappers; official .py modules are not ELFs and were not counted; vacuous PASS vs 101; null requiredGlibc/requiredGlibcxx is not ranked as a max",
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 unique vacuous PASS Architecture: all glibc none (0 versioned, 0 null; no max invented) noGLIBCXX (0 versioned, 0 null; null not ranked as a max) official wrappers are Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 38
if find "$STAGE/pkg" \( -name '*.png' -o -name '*.svg' \) | grep -q .; then
  echo "ICON_UNEXPECTEDLY_STAGED" >&2
  exit 1
fi
if find "$STAGE/pkg" -name 'arandr-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
test -L "$STAGE/pkg/usr/lib/python3/dist-packages/screenlayout/data/gpl-3.txt"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/arandr/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/arandr/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/arandr.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/arandr.desktop"
export STAGE_PKG
python3 - << 'END_ARANDR_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=arandr\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Icon=display" not in text or "Name=ARandR" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
text2 = re.sub(r"^Exec=arandr\b", "Exec=/usr/bin/arandr", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/arandr", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/arandr.*$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/arandr",
        text2,
        count=1,
        flags=re.M,
    )
for expect in (
    "Exec=/usr/bin/arandr",
    "TryExec=/usr/bin/arandr",
    "Icon=display",
    "Name=ARandR",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_rewritten_tryexec_added")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
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
END_ARANDR_DESKTOP

ln -sf /usr/bin/arandr "$STAGE/pkg/opt/arandr/arandr"
ln -sf /usr/bin/unxrandr "$STAGE/pkg/opt/arandr/unxrandr"
ln -sf arandr "$STAGE/pkg/usr/bin/kemi-arandr"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://christian.amsuess.com/tools/arandr/
Source: https://launchpad.net/ubuntu/+source/arandr
Homepage: http://christian.amsuess.com/tools/arandr/
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: all deb v${VER_UP}
(arandr_0.1.10-1.1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 arandr_0.1.10-1.1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official typelib /
    GTK / Python / x11-xserver-utils Depends stay
    Depends and are not bundled. Official control has
    no Recommends and no Suggests. Versioned Provides:
    arandr (= 0.1.10-1.1).
  * Official /usr/bin/arandr and /usr/bin/unxrandr are
    Python 3 wrappers, not ELFs. Official files stay
    under /usr. /opt/arandr/* are symlinks. Also
    /usr/bin/kemi-arandr → arandr.
  * Official package ships 38 .mo including zh_CN /
    zh_Hant and no Yelp help. Official package ships no
    app icon files; official desktop Icon=display is
    kept. A 128×128 evidence PNG rasterized from the
    theme icon officially named by the About dialog
    (video-display) is used only for mall CREATE --icon
    and is not packed in the deb.
  * Official changelog is a real file and was copied
    with cp -L. Official gpl-3.txt common-licenses
    symlink is kept official. Official desktop
    Exec=arandr is rewritten to /usr/bin/arandr;
    TryExec added; Icon=display; Name=ARandR. Official
    py3 hooks are retargeted to kemi-arandr.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
ARandR ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: all, KEMI repack.

Official /usr/bin/arandr and /usr/bin/unxrandr are
Python 3 wrappers (not ELFs). /opt/arandr/* are
symlinks. Official typelib / GTK / Python /
x11-xserver-utils Depends stay Depends and are not
bundled. Official control has no Recommends and no
Suggests. Official package ships 38 .mo including
zh_CN. Official package ships no app icon files;
official desktop Icon=display is kept. A 128×128
evidence PNG is used only as mall CREATE --icon and
is not packed. Probe: 0 unique ELF · vacuous PASS ·
no requiredGlibc (0 versioned, 0 null; no max
invented) · no requiredGlibcxx (0 versioned, 0 null;
null not ranked as a max); Python 3 GTK3 typelib
XRandR front end; within Ubuntu 20.04 / glibc 2.31
(vacuous). Official publication: Ubuntu 20.04 focal
universe arandr 0.1.10-1.1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: x11
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: python3:any, x11-xserver-utils, python3-gi, python3-gi-cairo, gir1.2-gtk-3.0
Replaces: arandr
Conflicts: arandr
Provides: arandr (= 0.1.10-1.1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://christian.amsuess.com/tools/arandr/
Description: Simple visual front end for XRandR
 ARandR ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib XRandR front end.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'py3compile -p kemi-arandr' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg -L kemi-arandr' "$STAGE/pkg/DEBIAN/prerm"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-arandr-control.txt"
grep -q 'Version: 0.1.10-1.1kemi1' "$ROOT/evidence/kemi-arandr-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-arandr-control.txt"
grep -q 'x11-xserver-utils' "$ROOT/evidence/kemi-arandr-control.txt"
grep -q 'Provides: arandr (= 0.1.10-1.1)' "$ROOT/evidence/kemi-arandr-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-arandr-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-arandr-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/arandr",
    "./usr/bin/unxrandr",
    "./usr/bin/kemi-arandr",
    "./opt/arandr/arandr",
    "./opt/arandr/unxrandr",
    "./usr/share/applications/arandr.desktop",
    "./usr/share/locale/zh_CN/LC_MESSAGES/arandr.mo",
    "./usr/lib/python3/dist-packages/screenlayout/gui.py",
    "./usr/share/man/man1/arandr.1.gz",
    "./usr/share/doc/kemi-arandr/changelog.upstream.gz",
    "./usr/lib/python3/dist-packages/screenlayout/data/gpl-3.txt",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "arandr-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if ".svg" in out or "hicolor" in out:
    # official package has no icons; do not invent
    raise SystemExit("UNEXPECTED_ICON_IN_DEB")
found_bin = found_unx = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/arandr " in line or line.rstrip().endswith("./usr/bin/arandr")) and "kemi-arandr" not in line and "unxrandr" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/unxrandr" in line:
        found_unx = True
        if "->" in line:
            raise SystemExit("UNXRANDR_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-arandr" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_unx:
    raise SystemExit("MISSING_UNXRANDR")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
