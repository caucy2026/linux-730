#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) alacarte
# 3.36.0-1 Architecture: all as kemi-alacarte.
# No newer package in focal-updates. The alacarte
# source ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official typelib
# / GTK / gnome-menus / Python Depends stay Depends,
# unbundled. Official control has no Recommends and no
# Suggests. Versioned Provides: alacarte (= 3.36.0-1).
# No Debian epoch, no tilde. Official /usr/bin/alacarte
# is a Python 3 wrapper (shebang #! /usr/bin/python3
# -OOt), not an ELF, and is not counted as an ELF.
# Official .py modules under /usr/share/alacarte are
# not ELFs. Official files stay on official paths;
# /opt/alacarte/* are symlinks. Also
# /usr/bin/kemi-alacarte → alacarte. Official package
# ships no .mo and no Yelp help / appdata (Ubuntu
# language-pack split; keep official tree; do not
# invent language packs). Official hicolor app PNGs
# exist at 16/22/24/32/48/256; official 256×256
# (19892 B) is used for mall CREATE --icon and is not
# packed a second time. Official in-app / help PNGs are
# not present beyond those app icons. Official
# changelog.Debian.gz and NEWS.gz are real files and
# are copied with cp -L. Official desktop Exec=alacarte
# is rewritten to /usr/bin/alacarte; TryExec is added;
# Icon=alacarte; official Name=Main Menu is kept (mall
# app_name is Alacarte). Official py3compile / py3clean
# / dpkg -L and the python3 rtupdate hook targeting
# /usr/share/alacarte are retargeted to kemi-alacarte
# (rtupdate file renamed). Official Alacarte/config.py
# contains an unused configure leftover
# libdir="/usr/lib/x86_64-linux-gnu" that is never read
# by any official module; it is kept official and is
# not rewritten. Probe: Architecture: all · 0 unique
# packaged ELF (vacuous PASS; official wrapper and .py
# modules are not ELFs and were not counted) ·
# requiredGlibc none (0 versioned, 0 null; do not
# invent a max; null is not ranked as a max) · no
# GLIBCXX (0 versioned, 0 null) · Python 3 GTK3 typelib
# menu editor · within 101 ≤2.31 / ≤3.4.28 (vacuous).
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04
# focal universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed; Architecture: all is
# listed in the arm64 index). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI
# version 3.36.0-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-alacarte
VER_UP=3.36.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-alacarte
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-kemi}"
UP_DEB="$DL/alacarte_3.36.0-1_all.deb"
EXPECT_SHA=ad34d050e2aca47db5da1d632519986308d6f542d78ed2c832a6d66e79f112b8
EXPECT_BYTES=48620
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

rm -rf "$UNPACK"
mkdir -p "$UNPACK"
dpkg-deb -x "$UP_DEB" "$UNPACK"
dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"

test -x "$UNPACK/usr/bin/alacarte"
python3 - << PY
from pathlib import Path
p = Path("$UNPACK") / "usr/bin/alacarte"
assert not p.is_symlink()
assert p.read_bytes()[:2] == b"#!"
assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_wrapper_not_elf")
PY
test -f "$UNPACK/usr/share/applications/alacarte.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/alacarte.png"
test ! -L "$UNPACK/usr/share/doc/alacarte/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/alacarte/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/alacarte/NEWS.gz"
test -f "$UNPACK/usr/share/doc/alacarte/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
# official 256 used for CREATE; evidence copy must match and not be packed later
install -m 0644 \
  "$UNPACK/usr/share/icons/hicolor/256x256/apps/alacarte.png" \
  "$ROOT/evidence/alacarte-256.png"
cmp -s "$UNPACK/usr/share/icons/hicolor/256x256/apps/alacarte.png" \
  "$ROOT/evidence/alacarte-256.png"
python3 - << PY
import struct
from pathlib import Path
p = Path("$ROOT/evidence/alacarte-256.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (256, 256), (w, h)
assert p.stat().st_size == 19892
print("official_256_for_create", w, h, p.stat().st_size)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/alacarte"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/alacarte"

for s in postinst prerm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done

export STAGE_PKG="$STAGE/pkg"
python3 - << 'END_ALACARTE_HOOKS'
from pathlib import Path
import os, re
root = Path(os.environ["STAGE_PKG"])
for name in ("postinst", "prerm"):
    p = root / "DEBIAN" / name
    t = p.read_text()
    t = t.replace("py3compile -p alacarte", "py3compile -p kemi-alacarte")
    t = t.replace("pypy3compile -p alacarte", "pypy3compile -p kemi-alacarte")
    t = t.replace("py3clean -p alacarte", "py3clean -p kemi-alacarte")
    t = re.sub(r"dpkg -L alacarte\b", "dpkg -L kemi-alacarte", t)
    p.write_text(t)
    p.chmod(0o755)
rt_old = root / "usr/share/python3/runtime.d/alacarte.rtupdate"
rt_new = root / "usr/share/python3/runtime.d/kemi-alacarte.rtupdate"
t = rt_old.read_text()
t = t.replace("py3clean -p alacarte", "py3clean -p kemi-alacarte")
t = t.replace("py3compile -p alacarte", "py3compile -p kemi-alacarte")
rt_new.write_text(t)
rt_new.chmod(0o755)
rt_old.unlink()
post = (root/"DEBIAN/postinst").read_text()
prerm = (root/"DEBIAN/prerm").read_text()
rt = rt_new.read_text()
if "py3compile -p alacarte" in post or "pypy3compile -p alacarte" in post:
    raise SystemExit("PY3_NOT_RETARGETED_POSTINST")
if "py3compile -p kemi-alacarte" not in post:
    raise SystemExit("PY3_MISSING_KEMI_POSTINST")
if "py3clean -p alacarte " in prerm or "py3clean -p alacarte\n" in prerm:
    raise SystemExit("PY3_NOT_RETARGETED_PRERM")
if "dpkg -L alacarte" in prerm:
    raise SystemExit("DPKG_L_NOT_RETARGETED")
if "dpkg -L kemi-alacarte" not in prerm:
    raise SystemExit("DPKG_L_MISSING")
if "py3clean -p alacarte" in rt or "py3compile -p alacarte" in rt:
    raise SystemExit("RTUPDATE_NOT_RETARGETED")
if "py3compile -p kemi-alacarte" not in rt:
    raise SystemExit("RTUPDATE_MISSING_KEMI")
if (root / "usr/share/python3/runtime.d/alacarte.rtupdate").exists():
    raise SystemExit("OLD_RTUPDATE_STILL_PRESENT")
print("py3_hooks_and_rtupdate_retargeted")
END_ALACARTE_HOOKS

REPORT="$ROOT/probe/kemi-alacarte.json"
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
w = root / "usr/bin/alacarte"
if w.read_bytes()[:2] != b"#!":
    raise SystemExit("WRAPPER_MISSING")
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
    "note": "0 unique packaged ELF; official /usr/bin/alacarte is a Python 3 wrapper; official .py modules are not ELFs and were not counted; vacuous PASS vs 101; null requiredGlibc/requiredGlibcxx is not ranked as a max",
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 unique vacuous PASS Architecture: all glibc none (0 versioned, 0 null; no max invented) noGLIBCXX (0 versioned, 0 null; null not ranked as a max) official wrapper is Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/alacarte.png"
test -f "$STAGE/pkg/usr/share/doc/alacarte/NEWS.gz"
if find "$STAGE/pkg" -name 'alacarte-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/alacarte/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/alacarte/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/alacarte.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/alacarte.desktop"
export STAGE_PKG
python3 - << 'END_ALACARTE_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=alacarte\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
text2 = re.sub(r"^Exec=alacarte\b", "Exec=/usr/bin/alacarte", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/alacarte", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/alacarte.*$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/alacarte",
        text2,
        count=1,
        flags=re.M,
    )
for expect in (
    "Exec=/usr/bin/alacarte",
    "TryExec=/usr/bin/alacarte",
    "Icon=alacarte",
    "Name=Main Menu",
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
        # official unused configure leftover in Architecture: all
        # Alacarte/config.py; never read by any official module;
        # keep official, do not rewrite
        if p.name == "config.py" and "Alacarte" in p.parts and s.startswith("libdir="):
            continue
        leftover.append(f"{p}:{i}:{s}")
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_live_used_x86_paths")
END_ALACARTE_DESKTOP

# confirm official unused libdir remains official
grep -q 'libdir="/usr/lib/x86_64-linux-gnu"' \
  "$STAGE/pkg/usr/share/alacarte/Alacarte/config.py"

ln -sf /usr/bin/alacarte "$STAGE/pkg/opt/alacarte/alacarte"
ln -sf alacarte "$STAGE/pkg/usr/bin/kemi-alacarte"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gitlab.gnome.org/GNOME/alacarte
Source: https://launchpad.net/ubuntu/+source/alacarte
Homepage: https://gitlab.gnome.org/GNOME/alacarte
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: all deb v${VER_UP}
(alacarte_3.36.0-1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 alacarte_3.36.0-1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official typelib /
    GTK / gnome-menus / Python Depends stay Depends and
    are not bundled. Official control has no Recommends
    and no Suggests. Versioned Provides: alacarte
    (= 3.36.0-1).
  * Official /usr/bin/alacarte is a Python 3 wrapper,
    not an ELF. Official files stay under /usr.
    /opt/alacarte/* are symlinks. Also
    /usr/bin/kemi-alacarte → alacarte.
  * Official package ships no .mo and no Yelp help
    (keep official; do not invent language packs).
    Official hicolor PNGs exist including 256×256;
    official 256 is used for mall CREATE --icon and is
    not packed a second time.
  * Official changelog and NEWS.gz are real files and
    were copied with cp -L. Official desktop
    Exec=alacarte is rewritten to /usr/bin/alacarte;
    TryExec added; Icon=alacarte; Name=Main Menu.
    Official py3 hooks and the rtupdate hook are
    retargeted to kemi-alacarte. Official unused
    config.py libdir leftover is kept official and is
    not rewritten.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Alacarte ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: all, KEMI repack.

Official /usr/bin/alacarte is a Python 3 wrapper
(not an ELF). /opt/alacarte/* are symlinks. Official
typelib / GTK / gnome-menus / Python Depends stay
Depends and are not bundled. Official control has no
Recommends and no Suggests. Official package ships no
.mo. Official hicolor 256×256 PNG is used as mall
CREATE --icon and is not packed a second time. Probe:
0 unique ELF · vacuous PASS · no requiredGlibc
(0 versioned, 0 null; no max invented) · no
requiredGlibcxx (0 versioned, 0 null; null not ranked
as a max); Python 3 GTK3 typelib menu editor; within
Ubuntu 20.04 / glibc 2.31 (vacuous). Official
publication: Ubuntu 20.04 focal universe alacarte
3.36.0-1 (Architecture: all). Official SHA256 + size
matched ports.ubuntu.com pool files and focal universe
arm64 Packages stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Multi-Arch: foreign
Installed-Size: $INSTALLED_SIZE
Depends: python3:any, gnome-menus (>= 3.5.3), python3-gi, gir1.2-gtk-3.0, gir1.2-gmenu-3.0 (>= 3.5.3), gir1.2-glib-2.0, gir1.2-gdkpixbuf-2.0
Replaces: alacarte
Conflicts: alacarte
Provides: alacarte (= 3.36.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gitlab.gnome.org/GNOME/alacarte
Description: easy GNOME menu editing tool
 Alacarte ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib menu editor.
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
grep -q 'py3compile -p kemi-alacarte' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg -L kemi-alacarte' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'py3compile -p kemi-alacarte' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-alacarte.rtupdate"
test ! -e "$STAGE/pkg/usr/share/python3/runtime.d/alacarte.rtupdate"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-alacarte-control.txt"
grep -q 'Version: 3.36.0-1kemi1' "$ROOT/evidence/kemi-alacarte-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-alacarte-control.txt"
grep -q 'gir1.2-gmenu-3.0 (>= 3.5.3)' "$ROOT/evidence/kemi-alacarte-control.txt"
grep -q 'Provides: alacarte (= 3.36.0-1)' "$ROOT/evidence/kemi-alacarte-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-alacarte-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-alacarte-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/alacarte",
    "./usr/bin/kemi-alacarte",
    "./opt/alacarte/alacarte",
    "./usr/share/applications/alacarte.desktop",
    "./usr/share/icons/hicolor/256x256/apps/alacarte.png",
    "./usr/share/alacarte/Alacarte/MainWindow.py",
    "./usr/share/alacarte/alacarte.ui",
    "./usr/share/man/man1/alacarte.1.gz",
    "./usr/share/python3/runtime.d/kemi-alacarte.rtupdate",
    "./usr/share/doc/kemi-alacarte/changelog.upstream.gz",
    "./usr/share/doc/alacarte/NEWS.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "alacarte-256.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "runtime.d/alacarte.rtupdate" in out:
    raise SystemExit("OLD_RTUPDATE_PACKED")
found_bin = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/alacarte " in line or line.rstrip().endswith("./usr/bin/alacarte")) and "kemi-alacarte" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-alacarte" in line:
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
