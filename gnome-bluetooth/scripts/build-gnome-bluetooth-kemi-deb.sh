#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# gnome-bluetooth 3.34.3-0ubuntu1
# Architecture: arm64 as
# kemi-gnome-bluetooth. Official user-facing
# binary is /usr/bin/bluetooth-sendto (desktop
# Name=Bluetooth Transfer). Official
# same-source libgnome-bluetooth13
# (>= 3.12.0) is a loose library Depends with
# two official focal versions (Release
# 3.34.1-1 and updates 3.34.3-0ubuntu1) and
# stays Depends, unbundled (same-source >=
# library Depends that are not exact-version
# stay Depends; cheese-common exception does
# not apply). Official same-source
# gir1.2-gnomebluetooth-1.0 and
# libgnome-bluetooth-dev are inspected and
# not packaged. Official Recommends stay
# Recommends. Official control has no
# Suggests. Official Conflicts bluez-gnome
# kept (old name inspected, not packaged).
# Official Breaks gnome-shell (<< 3.12) kept.
# Newer than focal Release 3.34.1-1; not in
# focal-security or focal-backports. No
# Debian epoch, no tilde. Official ELF stays
# at /usr/bin/bluetooth-sendto.
# /opt/gnome-bluetooth/* are symlinks only.
# Also /usr/bin/kemi-gnome-bluetooth →
# bluetooth-sendto. Official packages ship
# no .mo (Ubuntu language-pack split); none
# invented. Official app icons are 16–48
# hicolor PNGs plus scalable bluetooth.svg
# (no official 256). A 128×128 evidence PNG
# rasterized from the official SVG via Chrome
# headless --default-background-color=00000000
# lives at evidence/bluetooth-128.png and is
# used only as the mall CREATE --icon; it is
# not packed. Official icons are packed once
# at official paths. Official status icons
# stay official and are not used as the mall
# icon. Official GUI changelog.Debian.gz is
# a dangling symlink into unbundled
# libgnome-bluetooth13 and is not packed;
# the real official changelog is copied with
# cp -L into the kemi doc dir only. Official
# NEWS.gz is a real file and is kept.
# Official desktop Name=Bluetooth Transfer
# is kept. Official relative Exec is
# rewritten absolute; TryExec is added.
# Official NoDisplay=true is kept. Official
# packages ship no maintainer scripts;
# icon-cache and desktop-database hooks are
# appended. Probe: 1 unique aarch64 ELF,
# requiredGlibc 2.17 (1 versioned, 0 null),
# no GLIBCXX (0 versioned, 1 null, not
# ranked as a max); PASS vs 101. Official
# SHA256 + size matched ports.ubuntu.com and
# Aliyun ubuntu-ports pool files and the
# Ubuntu 20.04 focal-updates main arm64
# Packages stanza. No librarian URL and no
# .buildinfo this run (pool 404). KEMI mall
# version_name 3.34.3-0ubuntu1kemi1 is 20
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-bluetooth
VER_UP=3.34.3-0ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-bluetooth
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/gnome-bluetooth}"
UNPACK_LIB="${UNPACK_LIB:-$ROOT/unpack-official/libgnome-bluetooth13}"
GUI_DEB="$DL/gnome-bluetooth_3.34.3-0ubuntu1_arm64.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 52664
echo "482c66b2cfeaf5e2dec119a24437a91df5113c21f46e008c1e0f948b6cc407cb  $GUI_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/bluetooth-sendto"
test -f "$UNPACK_GUI/usr/share/applications/bluetooth-sendto.desktop"
test -L "$UNPACK_GUI/usr/share/doc/gnome-bluetooth/changelog.Debian.gz"
test ! -e "$UNPACK_GUI/usr/share/doc/gnome-bluetooth/changelog.Debian.gz"
test -f "$UNPACK_LIB/usr/share/doc/libgnome-bluetooth13/changelog.Debian.gz"
test ! -L "$UNPACK_LIB/usr/share/doc/libgnome-bluetooth13/changelog.Debian.gz"
test -f "$UNPACK_GUI/usr/share/doc/gnome-bluetooth/NEWS.gz"
test ! -L "$UNPACK_GUI/usr/share/doc/gnome-bluetooth/NEWS.gz"
test -f "$ROOT/evidence/bluetooth-128.png"
test -f "$ROOT/evidence/bluetooth.svg"
test -f "$UNPACK_GUI/usr/share/icons/hicolor/scalable/apps/bluetooth.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/bluetooth-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "e67c9f7eae61b076487dff1ed37fca163c8598b253f3f578202d2ace628b4413"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/bluetooth.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "48595f9bc01c45785746a75cf68747ccd8eb0d5ab778bedaf221d9aea50c64e0"
icons = list(Path("$UNPACK_GUI/usr/share/icons").rglob("*"))
n = sum(1 for x in icons if x.is_file() and x.suffix.lower() in {".png", ".svg"})
assert n == 21, n
mos = list(Path("$UNPACK_GUI").rglob("*.mo"))
assert len(mos) == 0, len(mos)
print("official_icons_21_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-bluetooth"

cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/bluetooth-sendto"

# official GUI changelog is a dangling symlink into unbundled
# libgnome-bluetooth13 — do not pack it; copy the real official
# changelog with cp -L into the kemi doc dir only.
rm -f "$STAGE/pkg/usr/share/doc/gnome-bluetooth/changelog.Debian.gz"
test ! -e "$STAGE/pkg/usr/share/doc/gnome-bluetooth/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/gnome-bluetooth/NEWS.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
# do not pack lib / gir / -dev / evidence / theme
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libgnome-bluetooth.so.13"
test ! -d "$STAGE/pkg/usr/share/gir-1.0"
if find "$STAGE/pkg" -name 'bluetooth-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi

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
REPORT="$ROOT/probe/kemi-gnome-bluetooth.json"
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
versioned = [v for v in glibcs if v is not None]
assert versioned and max(versioned, key=lambda s: tuple(int(x) for x in s.split("."))) == "2.17"
assert gn == 0 and gv == 1
assert cv == 0 and cn == 1
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=1 requiredGlibc=2.17 (1 versioned, 0 null); requiredGlibcxx none (0 versioned, 1 null, not ranked as a max); configuredLimitsSatisfied=true")
d["n_elf"] = 1
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
Path("$REPORT").write_text(json.dumps(d, indent=2) + "\n")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/gnome-bluetooth/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
# real official changelog from unbundled same-source lib, kemi doc only
cp --remove-destination -L \
  "$UNPACK_LIB/usr/share/doc/libgnome-bluetooth13/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "17e193dc71148ebbdedd39fbe26a6bf81575954010993f48364612b0c433f3ac"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/bluetooth-sendto.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/bluetooth-sendto.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Bluetooth Transfer\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if re.search(r"^GenericName=", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERICNAME_UNEXPECTED")
if not re.search(r"^Icon=bluetooth\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ICON")
m = re.search(r"^Exec=(\S+)", text, flags=re.M)
if not m:
    raise SystemExit("DESKTOP_NO_EXEC")
exec_val = m.group(1)
if exec_val.startswith("/"):
    abs_exec = exec_val
else:
    if "/" in exec_val:
        raise SystemExit("DESKTOP_RELATIVE_PATH:" + exec_val)
    abs_exec = "/usr/bin/" + exec_val
if abs_exec != "/usr/bin/bluetooth-sendto":
    raise SystemExit("DESKTOP_EXEC_CMD:" + abs_exec)
def _sub_exec(mo):
    rest = mo.group(0)[len("Exec=" + exec_val):]
    return "Exec=" + abs_exec + rest
text = re.sub(r"^Exec=" + re.escape(exec_val) + r".*$", _sub_exec, text, count=1, flags=re.M)
if re.search(r"^TryExec=", text, flags=re.M):
    text = re.sub(r"^TryExec=.*$", "TryExec=" + abs_exec, text, count=1, flags=re.M)
else:
    text = re.sub(
        r"^Exec=" + re.escape(abs_exec) + r".*$",
        lambda mo: mo.group(0) + "\nTryExec=" + abs_exec,
        text,
        count=1,
        flags=re.M,
    )
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
if "Exec=/usr/bin/bluetooth-sendto" not in text or "TryExec=/usr/bin/bluetooth-sendto" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "NoDisplay=true" not in text:
    raise SystemExit("DESKTOP_NODISPLAY")
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_rewritten", abs_exec)
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-bluetooth/scripts/build-gnome-bluetooth-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/bluetooth-sendto\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/bluetooth-sendto "$STAGE/pkg/opt/gnome-bluetooth/bluetooth-sendto"
ln -sf bluetooth-sendto "$STAGE/pkg/usr/bin/kemi-gnome-bluetooth"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml"}:
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

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-bluetooth (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    gnome-bluetooth 3.34.3-0ubuntu1 arm64,
    KEMI mall linuxpkg repack. Official
    user-facing binary is
    /usr/bin/bluetooth-sendto. Official
    same-source libgnome-bluetooth13
    (>= 3.12.0) stays Depends (loose library
    Depends, two official focal versions).
    Official gir and -dev inspected, not
    packaged. Official different-source
    Depends stay Depends. Official Recommends
    stay Recommends. Official control has no
    Suggests. Official ELF stays at the
    official path; /opt/gnome-bluetooth/*
    are symlinks. Also
    /usr/bin/kemi-gnome-bluetooth →
    bluetooth-sendto. Official desktop
    Name=Bluetooth Transfer kept; relative
    Exec rewritten absolute; TryExec added.
    Official dangling changelog symlink into
    unbundled libgnome-bluetooth13 was not
    packed; the real official changelog was
    copied with cp -L into the kemi doc dir.
    Official NEWS.gz kept. Official app icons
    packed once; 128 evidence PNG from the
    official SVG is CREATE --icon only and is
    not packed. Official packages ship no
    .mo; none invented. Icon-cache and
    desktop-database hooks appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Bluetooth Transfer — official Ubuntu 20.04
(focal-updates main) gnome-bluetooth
3.34.3-0ubuntu1 Architecture: arm64, KEMI
repack. Official user-facing binary is
/usr/bin/bluetooth-sendto and stays under
/usr. /opt/gnome-bluetooth/* are symlinks.
Official same-source libgnome-bluetooth13
(>= 3.12.0) stays Depends and is not
bundled. Official gir1.2-gnomebluetooth-1.0
and libgnome-bluetooth-dev inspected, not
packaged. Official Recommends stay
Recommends. Official control has no
Suggests. Official packages ship no .mo
(Ubuntu language-pack split); none invented.
Official app icons (16–48 PNG plus scalable
SVG) stay official and are packed once. A
128×128 evidence PNG rasterized from the
official bluetooth.svg is used only as mall
CREATE --icon and is not packed. Official
desktop Name=Bluetooth Transfer is kept;
mall app_name is Bluetooth Transfer
(official desktop Name, the usual
user-facing title). This package has no
appdata <name> and no GenericName. Probe:
1 unique aarch64 ELF, requiredGlibc 2.17
(1 versioned, 0 null), no GLIBCXX
(0 versioned, 1 null, not ranked as a max);
PASS vs Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal-updates
main gnome-bluetooth 3.34.3-0ubuntu1
(arm64), newer than focal Release 3.34.1-1.
Official SHA256 + size matched
ports.ubuntu.com and Aliyun ubuntu-ports
pool files and the focal-updates main
Packages stanza. No librarian URL this run.
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
Depends: bluez (>= 5.5), bluez-obexd, udev (>= 154), libc6 (>= 2.17), libglib2.0-0 (>= 2.38.0), libgnome-bluetooth13 (>= 3.12.0), libgtk-3-0 (>= 3.0.0)
Recommends: gnome-control-center | unity-control-center, gvfs-backends
Conflicts: bluez-gnome, gnome-bluetooth
Replaces: gnome-bluetooth
Breaks: gnome-shell (<< 3.12)
Provides: gnome-bluetooth (= 3.34.3-0ubuntu1)
Homepage: https://wiki.gnome.org/Projects/GnomeBluetooth
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: GNOME Bluetooth tools
 Bluetooth Transfer ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of
 gnome-bluetooth (bluetooth-sendto).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_ok"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-gnome-bluetooth_3.34.3-0ubuntu1kemi1_arm64.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'Version: 3.34.3-0ubuntu1kemi1' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'gnome-bluetooth (= 3.34.3-0ubuntu1)' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'libgnome-bluetooth13 (>= 3.12.0)' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
grep -q 'Recommends: gnome-control-center' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-bluetooth-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/bluetooth-sendto.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Bluetooth Transfer" in desk
assert "Exec=/usr/bin/bluetooth-sendto" in desk
assert "TryExec=/usr/bin/bluetooth-sendto" in desk
assert "Icon=bluetooth" in desk
assert "NoDisplay=true" in desk
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/bluetooth-sendto"
test ! -L "$CHECK/usr/bin/bluetooth-sendto"
test -L "$CHECK/usr/bin/kemi-gnome-bluetooth"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-bluetooth")" = "bluetooth-sendto"
test -L "$CHECK/opt/gnome-bluetooth/bluetooth-sendto"
test "$(readlink "$CHECK/opt/gnome-bluetooth/bluetooth-sendto")" = "/usr/bin/bluetooth-sendto"
test ! -e "$CHECK/usr/lib/aarch64-linux-gnu/libgnome-bluetooth.so.13"
test ! -e "$CHECK/usr/share/doc/gnome-bluetooth/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/gnome-bluetooth/NEWS.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test "$(find "$CHECK/usr/share/icons" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 21
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/bluetooth.svg"
if find "$CHECK" -name 'bluetooth-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
