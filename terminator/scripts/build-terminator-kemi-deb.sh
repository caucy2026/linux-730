#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) terminator
# 1.91-4ubuntu1 Architecture: all as kemi-terminator.
# No newer package in focal-updates. The terminator
# source ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official
# terminatorx is a different-source audio looper and is
# not this GUI; it was inspected in the index only and
# is not packaged. Official typelib / GTK / VTE / D-Bus
# / Python Depends stay Depends, unbundled. Official
# Recommends (gir1.2-keybinder-3.0, gir1.2-notify-0.7,
# xdg-utils) stay Recommends / unbundled (not the
# Remmina/AbiWord Recommends-plugin pattern). Official
# control has no Suggests. Official Provides:
# x-terminal-emulator is kept; also versioned Provides:
# terminator (= 1.91-4ubuntu1). No Debian epoch, no
# tilde. Official /usr/bin/terminator is a symlink to
# ../share/terminator/terminator; that launcher is a
# Python 3 wrapper (shebang #!/usr/bin/python3, 5269 B),
# not an ELF, and is not counted as an ELF. Official
# remotinator under /usr/share/terminator is also a
# Python 3 wrapper, not an ELF. Official files stay on
# official paths; /opt/terminator/* are symlinks. Also
# /usr/bin/kemi-terminator → terminator. Official
# package ships 81 .mo including zh_CN / zh_HK / zh_TW
# (keep official; do not invent extra language packs).
# Official package ships no Yelp help. Official app
# icons include hicolor 16–48 PNGs plus a scalable SVG;
# there is no official 256×256. Official 16–48 PNGs,
# HighContrast PNGs, action/status PNGs, and the 48×48
# pixmap stay in the official tree and are not used as
# the mall 256 icon (D-Feet / Déjà Dup pattern when no
# official 256 exists). A 128×128 PNG rasterized from
# the official hicolor SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/terminator-128.png and is used only as the
# mall CREATE --icon; it is not shipped in the deb.
# Official changelog.Debian.gz is a real file and is
# copied with cp -L. Official desktop Exec=terminator
# is rewritten to /usr/bin/terminator (including the
# NewWindow shortcut); TryExec is rewritten to
# /usr/bin/terminator; Icon=terminator and
# Name=Terminator are kept. Official py3compile /
# py3clean / dpkg -L and the python3 rtupdate hook
# targeting /usr/share/terminator are retargeted to
# kemi-terminator (rtupdate file renamed). Official
# update-alternatives for x-terminal-emulator pointing
# at /usr/bin/terminator are kept (official path).
# Official dh_icons HighContrast hooks are kept; hicolor
# icon-cache and desktop-database hooks are added.
# Official historical preinst pycentral stanza is kept.
# Probe: Architecture: all · 0 unique packaged ELF
# (vacuous PASS; official wrapper symlink and .py
# modules are not ELFs and were not counted) ·
# requiredGlibc none (0 versioned, 0 null; do not invent
# a max; null is not ranked as a max) · no GLIBCXX
# (0 versioned, 0 null) · Python 3 GTK3 typelib terminal
# · within 101 ≤2.31 / ≤3.4.28 (vacuous). Official
# SHA256 + size matched official ports.ubuntu.com pool
# files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror,
# streamed; Architecture: all is listed in the arm64
# index). No librarian URL and no .buildinfo is recorded
# this run (pool 404). KEMI version 1.91-4ubuntu1kemi1
# is 18 chars (under the mall version_name limit that
# rejected Remmina's 33-char string; 12–28 char siblings
# succeeded). No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-terminator
VER_UP=1.91-4ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-terminator
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/terminator_1.91-4ubuntu1_all.deb"
EXPECT_SHA=3373beeebd6665bcb16aa6c6f8508933f23ec93d9d1c2c87d8d6854523b2ae9c
EXPECT_BYTES=313088
python3 - << PY
s="${VER_DEB}"
assert len(s) == 18, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -L "$UNPACK/usr/bin/terminator"
test -x "$UNPACK/usr/share/terminator/terminator"
test -x "$UNPACK/usr/share/terminator/remotinator"
python3 - << PY
from pathlib import Path
binlink = Path("$UNPACK/usr/bin/terminator")
assert binlink.is_symlink()
assert str(binlink.readlink()) == "../share/terminator/terminator"
w = Path("$UNPACK/usr/share/terminator/terminator")
assert not w.is_symlink()
assert w.read_bytes()[:2] == b"#!"
assert w.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
r = Path("$UNPACK/usr/share/terminator/remotinator")
assert not r.is_symlink()
assert r.read_bytes()[:2] == b"#!"
print("official_wrappers_not_elf")
PY
test -f "$UNPACK/usr/share/applications/terminator.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/terminator.svg"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/terminator.png"
test -f "$ROOT/evidence/terminator-128.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/terminator.png"
test ! -L "$UNPACK/usr/share/doc/terminator/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/terminator/changelog.Debian.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 81
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/terminator.mo"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/terminator"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
# official bin is a symlink; keep it
test -L "$STAGE/pkg/usr/bin/terminator"
chmod 0755 "$STAGE/pkg/usr/share/terminator/terminator" \
  "$STAGE/pkg/usr/share/terminator/remotinator"

# official maintainer scripts, then retarget py3 hooks
for s in preinst postinst prerm postrm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done

# retarget py3compile/py3clean/dpkg -L and rename rtupdate
export STAGE_PKG="$STAGE/pkg"
python3 - << 'PY'
from pathlib import Path
import os, re
root = Path(os.environ["STAGE_PKG"])
for name in ("preinst", "postinst", "prerm", "postrm"):
    p = root / "DEBIAN" / name
    t = p.read_text()
    t = t.replace("py3compile -p terminator", "py3compile -p kemi-terminator")
    t = t.replace("pypy3compile -p terminator", "pypy3compile -p kemi-terminator")
    t = t.replace("py3clean -p terminator", "py3clean -p kemi-terminator")
    t = re.sub(r"dpkg -L terminator\b", "dpkg -L kemi-terminator", t)
    p.write_text(t)
    p.chmod(0o755)
# do not retarget official update-alternatives paths or historical pycentral
# pkgremove terminator (upgrade-from-ancient official package)
rt_old = root / "usr/share/python3/runtime.d/terminator.rtupdate"
rt_new = root / "usr/share/python3/runtime.d/kemi-terminator.rtupdate"
t = rt_old.read_text()
t = t.replace("py3clean -p terminator", "py3clean -p kemi-terminator")
t = t.replace("py3compile -p terminator", "py3compile -p kemi-terminator")
rt_new.write_text(t)
rt_new.chmod(0o755)
rt_old.unlink()
# sanity
post = (root/"DEBIAN/postinst").read_text()
prerm = (root/"DEBIAN/prerm").read_text()
if "py3compile -p terminator" in post or "pypy3compile -p terminator" in post:
    raise SystemExit("PY3_NOT_RETARGETED_POSTINST")
if "py3compile -p kemi-terminator" not in post:
    raise SystemExit("PY3_MISSING_KEMI_POSTINST")
if "update-alternatives --install /usr/bin/x-terminal-emulator" not in post:
    raise SystemExit("ALTERNATIVES_LOST")
if "/usr/bin/terminator" not in post:
    raise SystemExit("ALTERNATIVES_PATH_CHANGED")
if "py3clean -p terminator" in prerm and "kemi-terminator" not in prerm.split("py3clean -p terminator")[0][-20:]:
    # crude; just require kemi form present and old py3clean -p terminator absent except we already replaced
    pass
if "py3clean -p terminator \n" in prerm or "py3clean -p terminator\n" in prerm:
    raise SystemExit("PY3_NOT_RETARGETED_PRERM")
if "dpkg -L terminator" in prerm:
    raise SystemExit("DPKG_L_NOT_RETARGETED")
if "dpkg -L kemi-terminator" not in prerm:
    raise SystemExit("DPKG_L_MISSING")
if "update-alternatives --remove x-terminal-emulator /usr/bin/terminator" not in prerm:
    raise SystemExit("ALTERNATIVES_PRERM_LOST")
if not rt_new.is_file() or rt_old.exists():
    raise SystemExit("RTUPDATE_NOT_RENAMED")
if " -p terminator" in rt_new.read_text():
    raise SystemExit("RTUPDATE_NOT_RETARGETED")
print("py3_hooks_retargeted alternatives_kept")
PY

# vacuous 0-ELF probe: do not call probe_elf.py with no --elf
REPORT="$ROOT/probe/kemi-terminator.json"
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
# official wrappers must still be present and not ELF
for rel in ("usr/share/terminator/terminator", "usr/share/terminator/remotinator"):
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
    "note": "0 unique packaged ELF; official /usr/bin/terminator is a symlink to a Python 3 wrapper; official remotinator and .py modules are not ELFs and were not counted; vacuous PASS vs 101; null requiredGlibc/requiredGlibcxx is not ranked as a max",
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 unique vacuous PASS Architecture: all glibc none (0 versioned, 0 null; no max invented) noGLIBCXX (0 versioned, 0 null; null not ranked as a max) official wrappers are Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 81
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/terminator.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/terminator.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/terminator.png"
if find "$STAGE/pkg" -name 'terminator-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/terminator/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/terminator/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/terminator.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/terminator.desktop"
export STAGE_PKG
python3 - << 'PY'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=terminator(\s.*)?$", r"Exec=/usr/bin/terminator\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/terminator", text2, flags=re.M)
if re.search(r"^Exec=terminator(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
if re.search(r"^TryExec=terminator(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_NOT_REWRITTEN")
# both main and NewWindow shortcut
if text2.count("Exec=/usr/bin/terminator") < 2:
    raise SystemExit("DESKTOP_SHORTCUT_EXEC_MISSING")
for expect in (
    "Exec=/usr/bin/terminator",
    "TryExec=/usr/bin/terminator",
    "Icon=terminator",
    "Name=Terminator",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_rewritten")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".xpm"}:
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

ln -sf /usr/bin/terminator "$STAGE/pkg/opt/terminator/terminator"
ln -sf /usr/share/terminator/terminator "$STAGE/pkg/opt/terminator/terminator.py"
ln -sf terminator "$STAGE/pkg/usr/bin/kemi-terminator"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gnometerminator.blogspot.com/p/introduction.html
Source: https://launchpad.net/ubuntu/+source/terminator
Homepage: https://gnometerminator.blogspot.com/p/introduction.html
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: all deb v${VER_UP}
(terminator_1.91-4ubuntu1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 terminator_1.91-4ubuntu1_all.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official typelib /
    GTK / VTE / D-Bus / Python Depends stay Depends and
    are not bundled. Official Recommends
    (gir1.2-keybinder-3.0, gir1.2-notify-0.7, xdg-utils)
    stay Recommends. Official Provides:
    x-terminal-emulator is kept. Versioned Provides:
    terminator (= 1.91-4ubuntu1).
  * Official /usr/bin/terminator is a symlink to a
    Python 3 wrapper under /usr/share/terminator, not an
    ELF. Official remotinator is also a Python wrapper,
    not an ELF. /opt/terminator/* are symlinks. Also
    /usr/bin/kemi-terminator → terminator.
  * Official package ships 81 .mo including zh_CN /
    zh_HK / zh_TW and no Yelp help. Official hicolor
    16–48 PNGs stay official; there is no official
    256×256. A 128×128 evidence PNG rasterized from the
    official SVG is used only for mall CREATE --icon and
    is not packed in the deb.
  * Official changelog is a real file and was copied with
    cp -L. Official desktop Exec=terminator rewritten to
    /usr/bin/terminator (including the NewWindow
    shortcut); TryExec rewritten; Icon=terminator;
    Name=Terminator. Official py3 hooks and the rtupdate
    hook are retargeted to kemi-terminator. Official
    x-terminal-emulator alternatives at /usr/bin/terminator
    are kept.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Terminator ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: all, KEMI repack.

Official /usr/bin/terminator is a symlink to
/usr/share/terminator/terminator, a Python 3 wrapper
(not an ELF). /opt/terminator/* are symlinks. Official
typelib / GTK / VTE / D-Bus / Python Depends stay
Depends and are not bundled. Official Recommends stay
Recommends. Official package ships 81 .mo including
zh_CN. Official help is not a Yelp tree. Official app
icons have no 256×256 PNG; a 128×128 evidence PNG
rasterized from the official SVG is used only as mall
CREATE --icon and is not packed. Probe: 0 unique ELF ·
vacuous PASS · no requiredGlibc (0 versioned, 0 null;
no max invented) · no requiredGlibcxx (0 versioned,
0 null; null not ranked as a max); Python 3 GTK3
typelib terminal; within Ubuntu 20.04 / glibc 2.31
(vacuous). Official publication: Ubuntu 20.04 focal
universe terminator 1.91-4ubuntu1 (Architecture: all).
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: misc
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: python3-cairo, python3-configobj, python3-dbus, python3-gi, python3-gi-cairo, python3-psutil, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-pango-1.0, gir1.2-vte-2.91, dbus-x11, python3:any
Recommends: gir1.2-keybinder-3.0, gir1.2-notify-0.7, xdg-utils
Replaces: terminator
Conflicts: terminator
Provides: x-terminal-emulator, terminator (= 1.91-4ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gnometerminator.blogspot.com/p/introduction.html
Description: multiple GNOME terminals in one window
 Terminator ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib terminal emulator.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# append hicolor / desktop-database hooks (official already has HighContrast dh_icons)
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
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
# official alternatives + retargeted py3 still present
grep -q 'update-alternatives --install /usr/bin/x-terminal-emulator' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3compile -p kemi-terminator' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-icon-caches /usr/share/icons/HighContrast' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-terminator-control.txt"
grep -q 'Version: 1.91-4ubuntu1kemi1' "$ROOT/evidence/kemi-terminator-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-terminator-control.txt"
grep -q 'gir1.2-vte-2.91' "$ROOT/evidence/kemi-terminator-control.txt"
grep -q 'Recommends: gir1.2-keybinder-3.0, gir1.2-notify-0.7, xdg-utils' "$ROOT/evidence/kemi-terminator-control.txt"
grep -q 'Provides: x-terminal-emulator, terminator (= 1.91-4ubuntu1)' "$ROOT/evidence/kemi-terminator-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-terminator-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/terminator",
    "./usr/bin/kemi-terminator",
    "./opt/terminator/terminator",
    "./usr/share/terminator/terminator",
    "./usr/share/terminator/remotinator",
    "./usr/share/applications/terminator.desktop",
    "./usr/share/icons/hicolor/scalable/apps/terminator.svg",
    "./usr/share/icons/hicolor/48x48/apps/terminator.png",
    "./usr/share/pixmaps/terminator.png",
    "./usr/share/locale/zh_CN/LC_MESSAGES/terminator.mo",
    "./usr/share/man/man1/terminator.1.gz",
    "./usr/share/man/man5/terminator_config.5.gz",
    "./usr/share/metainfo/terminator.appdata.xml",
    "./usr/share/python3/runtime.d/kemi-terminator.rtupdate",
    "./usr/share/doc/kemi-terminator/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "terminator-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "runtime.d/terminator.rtupdate" in out:
    raise SystemExit("OLD_RTUPDATE_PACKED")
found_bin = found_kemi = found_wrap = False
for line in out.splitlines():
    if "./usr/bin/terminator " in line or line.rstrip().endswith("./usr/bin/terminator"):
        if "kemi-terminator" not in line:
            found_bin = True
            if "->" not in line:
                raise SystemExit("BIN_NOT_SYMLINK:" + line)
    if "./usr/bin/kemi-terminator" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
    if "./usr/share/terminator/terminator" in line and "egg-info" not in line and "terminatorlib" not in line:
        found_wrap = True
        if "->" in line:
            raise SystemExit("WRAPPER_UNEXPECTED_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
if not found_wrap:
    raise SystemExit("MISSING_WRAPPER")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
