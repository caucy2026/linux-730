#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) menulibre
# 2.2.1-1 Architecture: all as kemi-menulibre.
# No newer package in focal-updates. The menulibre
# source ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official typelib
# / GTK / gnome-menus / Python Depends stay Depends,
# unbundled. Official control has no Recommends and no
# Suggests. Versioned Provides: menulibre (= 2.2.1-1).
# No Debian epoch, no tilde. Official /usr/bin/menulibre
# and /usr/bin/menulibre-menu-validate are Python 3
# wrappers (shebang #!/usr/bin/python3), not ELFs, and
# are not counted as ELFs. Official .py modules under
# /usr/lib/python3/dist-packages are not ELFs. Official
# files stay on official paths; /opt/menulibre/* are
# symlinks. Also /usr/bin/kemi-menulibre → menulibre.
# Official package ships 42 .mo including zh_CN / zh_HK
# / zh_TW (keep official; do not invent extra language
# packs). Official package ships no Yelp help and no
# appdata. Official app icons are SVG only (hicolor
# 16–64 and scalable menulibre.svg); there is no
# official 256×256. Official 48×48 pixmap
# /usr/share/pixmaps/menulibre.png stays in the official
# tree and is not used as the mall 256 icon (D-Feet /
# Terminator / Tilix pattern when no official 256
# exists). A 128×128 PNG rasterized from the official
# scalable SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/menulibre-128.png and is used only as the
# mall CREATE --icon; it is not shipped in the deb.
# Official changelog.Debian.gz is a real file and is
# copied with cp -L. Official NEWS.gz is a dangling
# symlink to changelog.gz and is not packed (devhelp /
# glade pattern); do not invent changelog.gz. Official
# desktop Exec=/usr/bin/menulibre is already absolute
# and is kept; TryExec is added; Icon=menulibre;
# official Name=Menu Editor is kept (mall app_name is
# MenuLibre). Official py3compile / py3clean / dpkg -L
# hooks are retargeted to kemi-menulibre. Official
# package has no python3 rtupdate hook. Probe:
# Architecture: all · 0 unique packaged ELF (vacuous
# PASS; official wrappers and .py modules are not ELFs
# and were not counted) · requiredGlibc none (0
# versioned, 0 null; do not invent a max; null is not
# ranked as a max) · no GLIBCXX (0 versioned, 0 null) ·
# Python 3 GTK3 typelib menu editor · within 101 ≤2.31
# / ≤3.4.28 (vacuous). Official SHA256 + size matched
# official ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed; Architecture: all is
# listed in the arm64 index). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI
# version 2.2.1-1kemi1 is 12 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-menulibre
VER_UP=2.2.1-1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-menulibre
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/menulibre_2.2.1-1_all.deb"
EXPECT_SHA=c03a6860540cdabe74e02c36fd03176057baf0e0f1773aa6591b7b8803d5bb7c
EXPECT_BYTES=148264
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
test -x "$UNPACK/usr/bin/menulibre"
test -x "$UNPACK/usr/bin/menulibre-menu-validate"
python3 - << PY
from pathlib import Path
for rel in ("usr/bin/menulibre", "usr/bin/menulibre-menu-validate"):
    p = Path("$UNPACK") / rel
    assert not p.is_symlink(), rel
    assert p.read_bytes()[:2] == b"#!"
    assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_wrappers_not_elf")
PY
test -f "$UNPACK/usr/share/applications/menulibre.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/menulibre.svg"
test -f "$UNPACK/usr/share/pixmaps/menulibre.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/menulibre.png"
test -f "$ROOT/evidence/menulibre-128.png"
test ! -L "$UNPACK/usr/share/doc/menulibre/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/menulibre/changelog.Debian.gz"
test -L "$UNPACK/usr/share/doc/menulibre/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 42
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/menulibre.mo"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/menulibre"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
# do not pack official dangling NEWS.gz -> changelog.gz
rm -f "$STAGE/pkg/usr/share/doc/menulibre/NEWS.gz"
chmod 0755 "$STAGE/pkg/usr/bin/menulibre" "$STAGE/pkg/usr/bin/menulibre-menu-validate"

for s in postinst prerm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done

export STAGE_PKG="$STAGE/pkg"
python3 - << 'PY'
from pathlib import Path
import os, re
root = Path(os.environ["STAGE_PKG"])
for name in ("postinst", "prerm"):
    p = root / "DEBIAN" / name
    t = p.read_text()
    t = t.replace("py3compile -p menulibre", "py3compile -p kemi-menulibre")
    t = t.replace("pypy3compile -p menulibre", "pypy3compile -p kemi-menulibre")
    t = t.replace("py3clean -p menulibre", "py3clean -p kemi-menulibre")
    t = re.sub(r"dpkg -L menulibre\b", "dpkg -L kemi-menulibre", t)
    p.write_text(t)
    p.chmod(0o755)
post = (root/"DEBIAN/postinst").read_text()
prerm = (root/"DEBIAN/prerm").read_text()
if "py3compile -p menulibre" in post or "pypy3compile -p menulibre" in post:
    raise SystemExit("PY3_NOT_RETARGETED_POSTINST")
if "py3compile -p kemi-menulibre" not in post:
    raise SystemExit("PY3_MISSING_KEMI_POSTINST")
if "py3clean -p menulibre " in prerm or "py3clean -p menulibre\n" in prerm:
    raise SystemExit("PY3_NOT_RETARGETED_PRERM")
if "dpkg -L menulibre" in prerm:
    raise SystemExit("DPKG_L_NOT_RETARGETED")
if "dpkg -L kemi-menulibre" not in prerm:
    raise SystemExit("DPKG_L_MISSING")
print("py3_hooks_retargeted")
PY

REPORT="$ROOT/probe/kemi-menulibre.json"
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
for rel in ("usr/bin/menulibre", "usr/bin/menulibre-menu-validate"):
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
    "note": "0 unique packaged ELF; official /usr/bin/menulibre and /usr/bin/menulibre-menu-validate are Python 3 wrappers; official .py modules are not ELFs and were not counted; vacuous PASS vs 101; null requiredGlibc/requiredGlibcxx is not ranked as a max",
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 unique vacuous PASS Architecture: all glibc none (0 versioned, 0 null; no max invented) noGLIBCXX (0 versioned, 0 null; null not ranked as a max) official wrappers are Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 42
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/menulibre.svg"
test -f "$STAGE/pkg/usr/share/pixmaps/menulibre.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/menulibre.png"
test ! -e "$STAGE/pkg/usr/share/doc/menulibre/NEWS.gz"
if find "$STAGE/pkg" -name 'menulibre-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/menulibre/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/menulibre/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/menulibre.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/menulibre.desktop"
export STAGE_PKG
python3 - << 'PY'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if "Exec=/usr/bin/menulibre" not in text:
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
text2 = text
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/menulibre", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/menulibre.*$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/menulibre",
        text2,
        count=1,
        flags=re.M,
    )
for expect in (
    "Exec=/usr/bin/menulibre",
    "TryExec=/usr/bin/menulibre",
    "Icon=menulibre",
    "Name=Menu Editor",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_kept_absolute_tryexec_added")

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
PY

ln -sf /usr/bin/menulibre "$STAGE/pkg/opt/menulibre/menulibre"
ln -sf /usr/bin/menulibre-menu-validate "$STAGE/pkg/opt/menulibre/menulibre-menu-validate"
ln -sf menulibre "$STAGE/pkg/usr/bin/kemi-menulibre"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://launchpad.net/menulibre
Source: https://launchpad.net/ubuntu/+source/menulibre
Homepage: https://launchpad.net/menulibre
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: all deb v${VER_UP}
(menulibre_2.2.1-1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 menulibre_2.2.1-1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official typelib /
    GTK / gnome-menus / Python Depends stay Depends and
    are not bundled. Official control has no Recommends
    and no Suggests. Versioned Provides: menulibre
    (= 2.2.1-1).
  * Official /usr/bin/menulibre and
    /usr/bin/menulibre-menu-validate are Python 3
    wrappers, not ELFs. Official files stay under /usr.
    /opt/menulibre/* are symlinks. Also
    /usr/bin/kemi-menulibre → menulibre.
  * Official package ships 42 .mo including zh_CN /
    zh_HK / zh_TW and no Yelp help. Official app icons
    are SVG only; official 48×48 pixmap stays official.
    A 128×128 evidence PNG rasterized from the official
    SVG is used only for mall CREATE --icon and is not
    packed in the deb.
  * Official changelog is a real file and was copied with
    cp -L. Official NEWS.gz is a dangling symlink and is
    not packed. Official desktop Exec=/usr/bin/menulibre
    is already absolute and is kept; TryExec added;
    Icon=menulibre; Name=Menu Editor. Official py3 hooks
    are retargeted to kemi-menulibre.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
MenuLibre ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: all, KEMI repack.

Official /usr/bin/menulibre and
/usr/bin/menulibre-menu-validate are Python 3 wrappers
(not ELFs). /opt/menulibre/* are symlinks. Official
typelib / GTK / gnome-menus / Python Depends stay
Depends and are not bundled. Official control has no
Recommends and no Suggests. Official package ships 42
.mo including zh_CN. Official app icons are SVG only;
a 128×128 evidence PNG is used only as mall CREATE
--icon and is not packed. Probe: 0 unique ELF ·
vacuous PASS · no requiredGlibc (0 versioned, 0 null;
no max invented) · no requiredGlibcxx (0 versioned,
0 null; null not ranked as a max); Python 3 GTK3
typelib menu editor; within Ubuntu 20.04 / glibc 2.31
(vacuous). Official publication: Ubuntu 20.04 focal
universe menulibre 2.2.1-1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gmenu-3.0 (>= 3.5.3), gir1.2-gtk-3.0, gnome-menus (>= 3.5.3), python3-gi (>= 3.0), python3-psutil, xdg-utils, python3:any
Replaces: menulibre
Conflicts: menulibre
Provides: menulibre (= 2.2.1-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://launchpad.net/menulibre
Description: advanced FreeDesktop.org compliant menu editor
 MenuLibre ${VER_UP} — official Ubuntu 20.04
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
grep -q 'py3compile -p kemi-menulibre' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg -L kemi-menulibre' "$STAGE/pkg/DEBIAN/prerm"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-menulibre-control.txt"
grep -q 'Version: 2.2.1-1kemi1' "$ROOT/evidence/kemi-menulibre-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-menulibre-control.txt"
grep -q 'gir1.2-gmenu-3.0 (>= 3.5.3)' "$ROOT/evidence/kemi-menulibre-control.txt"
grep -q 'Provides: menulibre (= 2.2.1-1)' "$ROOT/evidence/kemi-menulibre-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-menulibre-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-menulibre-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/menulibre",
    "./usr/bin/menulibre-menu-validate",
    "./usr/bin/kemi-menulibre",
    "./opt/menulibre/menulibre",
    "./usr/share/applications/menulibre.desktop",
    "./usr/share/icons/hicolor/scalable/apps/menulibre.svg",
    "./usr/share/pixmaps/menulibre.png",
    "./usr/share/locale/zh_CN/LC_MESSAGES/menulibre.mo",
    "./usr/share/man/man1/menulibre.1.gz",
    "./usr/share/menulibre/ui/MenulibreWindow.ui",
    "./usr/lib/python3/dist-packages/menulibre/MenulibreApplication.py",
    "./usr/share/doc/kemi-menulibre/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "menulibre-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "NEWS.gz" in out:
    raise SystemExit("DANGLING_NEWS_PACKED")
found_bin = found_val = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/menulibre " in line or line.rstrip().endswith("./usr/bin/menulibre")) and "menu-validate" not in line and "kemi-menulibre" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/menulibre-menu-validate" in line:
        found_val = True
        if "->" in line:
            raise SystemExit("VALIDATE_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-menulibre" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_val:
    raise SystemExit("MISSING_VALIDATE")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
