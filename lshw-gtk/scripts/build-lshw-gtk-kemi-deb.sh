#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe)
# lshw-gtk 02.18.85-0.3ubuntu2.20.04.1
# Architecture: arm64 as kemi-lshw-gtk.
# Official user-facing binary is
# /usr/bin/lshw-gtk (desktop Name=Hardware
# Lister). Official Source: lshw (explicit).
# Same-source CLI package lshw at the same
# official updates pin is NOT a Depends (nor
# a Recommends) of lshw-gtk and is not
# bundled. Official Depends are all
# different-source and stay Depends.
# Official Recommends menu, pciutils,
# usbutils stay Recommends. Official control
# has no Suggests. No transitional dummy /
# gir / -dev packaging candidates. Newer
# than focal Release 02.18.85-0.3ubuntu2;
# not in focal-security or
# focal-backports. No Debian epoch, no
# tilde. Official ELF stays at
# /usr/bin/lshw-gtk. /opt/lshw-gtk/* are
# symlinks only. Also
# /usr/bin/kemi-lshw-gtk → lshw-gtk.
# Official package ships no .mo; none
# invented. Official app icon is
# /usr/share/pixmaps/lshw-gtk.svg only (no
# official PNG / 256), plus 37 official
# in-app artwork SVGs packed once at
# official paths and not used as the mall
# icon. A 128×128 evidence PNG rasterized
# from the official pixmap SVG via Chrome
# headless --default-background-color=00000000
# lives at evidence/lshw-gtk-128.png and is
# used only as the mall CREATE --icon; it is
# not packed. Official changelog.Debian.gz
# is a real file and is kept at the official
# doc path; also copied with cp -L into the
# kemi doc dir. Official desktop
# Name=Hardware Lister is kept. Official
# Exec=su-to-root -X -c lshw-gtk is rewritten
# with absolute paths; TryExec=/usr/bin/lshw-gtk
# is added. Official package has no
# NoDisplay field; none invented. Official
# postinst/postrm (dh_installmenu
# update-menus hooks) are kept and appended
# with desktop-database / icon-cache hooks.
# Official /usr/share/menu/lshw-gtk
# ?package(lshw-gtk) is retargeted to
# ?package(kemi-lshw-gtk). Probe: 1 unique
# aarch64 ELF, requiredGlibc 2.27 (1
# versioned, 0 null), requiredGlibcxx 3.4.21
# (1 versioned, 0 null) ≤ 3.4.28; PASS vs
# 101. Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal-updates universe arm64 Packages
# stanza. No librarian URL and no
# .buildinfo this run (not present in the
# ports pool directory listings). KEMI mall
# version_name 02.18.85-0.3ubuntu2.20.04.1kemi1
# is 32 chars (at the upper end of the
# observed 28–33 window; Remmina 33 was
# rejected). No shortening unless the mall
# rejects it.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-lshw-gtk
VER_UP=02.18.85-0.3ubuntu2.20.04.1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-lshw-gtk
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/lshw-gtk}"
GUI_DEB="$DL/lshw-gtk_02.18.85-0.3ubuntu2.20.04.1_arm64.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 32, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 311748
echo "81865e53fb59e4765f1fcb582468b1f9fccfe00fa2ab798214249a398403bea7  $GUI_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/lshw-gtk"
test -f "$UNPACK_GUI/usr/share/applications/lshw-gtk.desktop"
test -f "$UNPACK_GUI/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test ! -L "$UNPACK_GUI/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test -f "$ROOT/evidence/lshw-gtk-128.png"
test -f "$ROOT/evidence/lshw-gtk.svg"
test -f "$UNPACK_GUI/usr/share/pixmaps/lshw-gtk.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/lshw-gtk-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "ed4533f8fec79f878a9eafdd9d0ed3feca6d899dde2cfe1c9249ddaa4733121c"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/lshw-gtk.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "a5f1920d1ee37b2755de45283932de70aa9d8276f80079b8dfd8e8f459093739"
icons = list(Path("$UNPACK_GUI").rglob("*.svg")) + list(Path("$UNPACK_GUI").rglob("*.png"))
n = sum(1 for x in icons if x.is_file() and x.suffix.lower() in {".png", ".svg"})
assert n == 38, n
mos = list(Path("$UNPACK_GUI").rglob("*.mo"))
assert len(mos) == 0, len(mos)
print("official_icons_38_svg_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/lshw-gtk"

cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/lshw-gtk"

# keep official maintainer scripts; retarget later if needed; append hooks
cp -a "$UNPACK_GUI/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK_GUI/DEBIAN/postrm" "$STAGE/pkg/DEBIAN/postrm"
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

test -f "$STAGE/pkg/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 38
# do not pack CLI lshw, evidence PNG, or theme
test ! -e "$STAGE/pkg/usr/bin/lshw" || test "$(readlink -f "$STAGE/pkg/usr/bin/lshw" 2>/dev/null || true)" = "$STAGE/pkg/usr/bin/lshw-gtk"
# official tree has only lshw-gtk binary
test -f "$STAGE/pkg/usr/bin/lshw-gtk"
if find "$STAGE/pkg" -name 'lshw-gtk-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi

# retarget official menu package() tag to the kemi package name
python3 - << PY
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/menu/lshw-gtk")
text = p.read_text()
if "?package(lshw-gtk)" not in text:
    raise SystemExit("MENU_PACKAGE_TAG")
text = text.replace("?package(lshw-gtk)", "?package(kemi-lshw-gtk)", 1)
p.write_text(text)
print("menu_retargeted")
PY

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
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-lshw-gtk.json"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
d = json.loads(Path("$REPORT").read_text())
files = d.get("files") or []
assert len(files) == 1, len(files)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
gver = [v for v in glibcs if v is not None]
cver = [v for v in cxxs if v is not None]
assert gver and max(gver, key=lambda s: tuple(int(x) for x in s.split("."))) == "2.27"
assert cver and max(cver, key=lambda s: tuple(int(x) for x in s.split("."))) == "3.4.21"
assert tuple(int(x) for x in "3.4.21".split(".")) <= tuple(int(x) for x in "3.4.28".split("."))
assert gn == 0 and gv == 1
assert cn == 0 and cv == 1
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=1 requiredGlibc=2.27 (1 versioned, 0 null); requiredGlibcxx=3.4.21 (1 versioned, 0 null) <= 3.4.28; configuredLimitsSatisfied=true")
d["n_elf"] = 1
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
Path("$REPORT").write_text(json.dumps(d, indent=2) + "\n")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/lshw-gtk/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/lshw-gtk/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "acd0a8fe559e834f785264cd98d5428f9a1f9f1929266fb91aa9ff0da430a068"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/lshw-gtk.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/lshw-gtk.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Hardware Lister\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if re.search(r"^GenericName=", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERICNAME_UNEXPECTED")
if not re.search(r"^Icon=lshw-gtk\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ICON")
m = re.search(r"^Exec=(.*)$", text, flags=re.M)
if not m:
    raise SystemExit("DESKTOP_NO_EXEC")
exec_line = m.group(1)
if exec_line != "su-to-root -X -c lshw-gtk":
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED:" + exec_line)
new_exec = "Exec=/usr/bin/su-to-root -X -c /usr/bin/lshw-gtk"
text = re.sub(r"^Exec=su-to-root -X -c lshw-gtk\s*$", new_exec, text, count=1, flags=re.M)
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_UNEXPECTED")
text = re.sub(
    r"^Exec=/usr/bin/su-to-root -X -c /usr/bin/lshw-gtk\s*$",
    "Exec=/usr/bin/su-to-root -X -c /usr/bin/lshw-gtk\nTryExec=/usr/bin/lshw-gtk",
    text,
    count=1,
    flags=re.M,
)
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
if "Exec=/usr/bin/su-to-root -X -c /usr/bin/lshw-gtk" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/lshw-gtk" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if re.search(r"^NoDisplay=", text, flags=re.M):
    raise SystemExit("DESKTOP_NODISPLAY_INVENTED")
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_rewritten")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-lshw-gtk/scripts/build-lshw-gtk-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/lshw-gtk\\1"' in text or 'r"Exec=/usr/bin/su-to-root\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/lshw-gtk "$STAGE/pkg/opt/lshw-gtk/lshw-gtk"
ln -sf lshw-gtk "$STAGE/pkg/usr/bin/kemi-lshw-gtk"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".ui"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
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
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

# append desktop-database / icon-cache hooks with a quoted heredoc (do not expand $1)
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-menus' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-menus' "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_ok"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-lshw-gtk (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates
    universe) lshw-gtk 02.18.85-0.3ubuntu2.20.04.1
    arm64, KEMI mall linuxpkg repack.
    Official user-facing binary is
    /usr/bin/lshw-gtk. Official Source: lshw.
    Same-source CLI lshw is not a Depends
    and is not bundled. Official
    different-source Depends stay Depends.
    Official Recommends stay Recommends.
    Official control has no Suggests.
    Official ELF stays at the official path;
    /opt/lshw-gtk/* are symlinks. Also
    /usr/bin/kemi-lshw-gtk → lshw-gtk.
    Official desktop Name=Hardware Lister
    kept; official Exec=su-to-root -X -c
    lshw-gtk rewritten with absolute paths;
    TryExec=/usr/bin/lshw-gtk added.
    Official changelog kept at the official
    path and copied with cp -L into the
    kemi doc dir. Official pixmap SVG packed
    once; 128 evidence PNG from the official
    pixmap SVG is CREATE --icon only and is
    not packed. Official packages ship no
    .mo; none invented. Official
    postinst/postrm kept; desktop-database
    and icon-cache hooks appended. Official
    menu ?package() retargeted to
    kemi-lshw-gtk. gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Hardware Lister — official Ubuntu 20.04
(focal-updates universe) lshw-gtk
02.18.85-0.3ubuntu2.20.04.1 Architecture:
arm64, KEMI repack. Official user-facing
binary is /usr/bin/lshw-gtk and stays under
/usr. /opt/lshw-gtk/* are symlinks.
Official Source: lshw (explicit). Same-source
CLI lshw is not a Depends and is not
bundled. Official different-source Depends
stay Depends. Official Recommends menu,
pciutils, usbutils stay Recommends. Official
control has no Suggests. Official package
ships no .mo; none invented. Official app
icon is /usr/share/pixmaps/lshw-gtk.svg;
official SVGs stay official and are packed
once. A 128×128 evidence PNG rasterized
from the official pixmap SVG is used only
as mall CREATE --icon and is not packed.
Official in-app artwork SVGs stay official
and are not used as the mall icon. Official
desktop Name=Hardware Lister is kept; mall
app_name is Hardware Lister (official
desktop Name, the usual user-facing title).
This package has no appdata <name> and no
GenericName. Probe: 1 unique aarch64 ELF,
requiredGlibc 2.27 (1 versioned, 0 null),
requiredGlibcxx 3.4.21 (1 versioned, 0 null)
≤ 3.4.28; PASS vs Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04
focal-updates universe lshw-gtk
02.18.85-0.3ubuntu2.20.04.1 (arm64), newer
than focal Release 02.18.85-0.3ubuntu2.
Official SHA256 + size matched
ports.ubuntu.com and Aliyun ubuntu-ports
(https) pool files and the focal-updates
universe Packages stanza. No librarian URL
this run. 合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Source: lshw
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.27), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.12.0), libgtk2.0-0 (>= 2.12.0), libstdc++6 (>= 5.2)
Recommends: menu, pciutils, usbutils
Conflicts: lshw-gtk
Replaces: lshw-gtk
Provides: lshw-gtk (= 02.18.85-0.3ubuntu2.20.04.1)
Homepage: https://github.com/lyonel/lshw
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: graphical information about hardware configuration
 Hardware Lister ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of
 lshw-gtk. glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-lshw-gtk_02.18.85-0.3ubuntu2.20.04.1kemi1_arm64.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'Version: 02.18.85-0.3ubuntu2.20.04.1kemi1' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'lshw-gtk (= 02.18.85-0.3ubuntu2.20.04.1)' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'libc6 (>= 2.27)' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'libstdc++6 (>= 5.2)' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
grep -q 'Recommends: menu, pciutils, usbutils' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-lshw-gtk-control.txt"
! grep -q '^ Depends:.*lshw,' "$ROOT/evidence/kemi-lshw-gtk-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/lshw-gtk.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Hardware Lister" in desk
assert "Exec=/usr/bin/su-to-root -X -c /usr/bin/lshw-gtk" in desk
assert "TryExec=/usr/bin/lshw-gtk" in desk
assert "Icon=lshw-gtk" in desk
assert "NoDisplay=" not in desk
menu = Path("$CHECK/usr/share/menu/lshw-gtk").read_text()
assert "?package(kemi-lshw-gtk)" in menu
assert "?package(lshw-gtk)" not in menu
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/lshw-gtk"
test ! -L "$CHECK/usr/bin/lshw-gtk"
test -L "$CHECK/usr/bin/kemi-lshw-gtk"
test "$(readlink "$CHECK/usr/bin/kemi-lshw-gtk")" = "lshw-gtk"
test -L "$CHECK/opt/lshw-gtk/lshw-gtk"
test "$(readlink "$CHECK/opt/lshw-gtk/lshw-gtk")" = "/usr/bin/lshw-gtk"
test ! -e "$CHECK/usr/bin/lshw" -o -L "$CHECK/usr/bin/kemi-lshw-gtk"
# official CLI binary must not be packed
if [ -e "$CHECK/usr/bin/lshw" ]; then
  echo "CLI_LSHW_PACKED" >&2
  exit 1
fi
test -f "$CHECK/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test ! -L "$CHECK/usr/share/doc/lshw-gtk/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test "$(find "$CHECK" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 38
test -f "$CHECK/usr/share/pixmaps/lshw-gtk.svg"
if find "$CHECK" -name 'lshw-gtk-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
