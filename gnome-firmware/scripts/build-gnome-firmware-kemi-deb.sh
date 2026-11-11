#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe)
# gnome-firmware 3.34.0-2ubuntu1
# Architecture: arm64 as
# kemi-gnome-firmware. Official user-facing
# binary is /usr/bin/gnome-firmware (desktop
# Name=Firmware; official appdata <name> is
# also Firmware). No official same-source
# siblings in official U20 arm64 indexes
# (Source field on the GUI stanza is absent
# and was not defaulted; pool contains only
# gnome-firmware itself at the U20 versions).
# Official Depends are all different-source
# and stay Depends, including libc6 (>= 2.17)
# and libfwupd2 (>= 1.7.9). Official control
# has no Recommends and no Suggests. No
# transitional dummy / gir / -dev packages
# were found to inspect as packaging
# candidates. Newer than focal Release
# 3.34.0-2; not in focal-security or
# focal-backports. No Debian epoch, no
# tilde. Official ELF stays at
# /usr/bin/gnome-firmware.
# /opt/gnome-firmware/* are symlinks only.
# Also /usr/bin/kemi-gnome-firmware →
# gnome-firmware. Official package ships
# one official en_GB .mo; it is packed
# official; no invented translations (no
# zh_CN invented). Official app icon is
# scalable SVG only (plus a symbolic SVG;
# no official PNG / 256). A 128×128
# evidence PNG rasterized from the official
# app SVG via Chrome headless
# --default-background-color=00000000 lives
# at evidence/org.gnome.Firmware-128.png and
# is used only as the mall CREATE --icon;
# it is not packed. Official SVGs are packed
# once at official paths. The official
# symbolic SVG is not used as the mall icon.
# Official changelog.Debian.gz is a real
# file (not a dangling symlink) and is kept
# at the official doc path; also copied
# with cp -L into the kemi doc dir.
# Official desktop Name=Firmware is kept.
# Official relative Exec is rewritten
# absolute; TryExec is added. Official
# NoDisplay=false is kept. Official package
# ships no maintainer scripts; icon-cache
# and desktop-database hooks are appended.
# Probe: 1 unique aarch64 ELF,
# requiredGlibc 2.17 (1 versioned, 0 null),
# no GLIBCXX (0 versioned, 1 null, not
# ranked as a max); PASS vs 101. Official
# SHA256 + size matched ports.ubuntu.com
# and Aliyun ubuntu-ports (https; http
# Aliyun 500) pool files and the Ubuntu
# 20.04 focal-updates universe arm64
# Packages stanza. No librarian URL and no
# .buildinfo this run (not present in the
# ports pool directory listing). KEMI mall
# version_name 3.34.0-2ubuntu1kemi1 is 20
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-firmware
VER_UP=3.34.0-2ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-firmware
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/gnome-firmware}"
GUI_DEB="$DL/gnome-firmware_3.34.0-2ubuntu1_arm64.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 35516
echo "c5073c0e01fd2f307ab1061cbda92ec70944992e260b70e516392637bb279e52  $GUI_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/gnome-firmware"
test -f "$UNPACK_GUI/usr/share/applications/org.gnome.Firmware.desktop"
test -f "$UNPACK_GUI/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test ! -L "$UNPACK_GUI/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.Firmware-128.png"
test -f "$ROOT/evidence/org.gnome.Firmware.svg"
test -f "$UNPACK_GUI/usr/share/icons/hicolor/scalable/apps/org.gnome.Firmware.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Firmware-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "e3c28179ee4477cc70401ef4a6a3cc60dc7ef055d6ba300ee7f3e57f5cfabd10"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/org.gnome.Firmware.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "65b37932305500e6af96206992768a5e0ee12370063fd83285b0d2d49abce61d"
icons = list(Path("$UNPACK_GUI/usr/share/icons").rglob("*"))
n = sum(1 for x in icons if x.is_file() and x.suffix.lower() in {".png", ".svg"})
assert n == 2, n
mos = list(Path("$UNPACK_GUI").rglob("*.mo"))
assert len(mos) == 1, len(mos)
assert mos[0].name == "gnome-firmware.mo"
assert "en_GB" in str(mos[0])
print("official_icons_2_svg_one_en_GB_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-firmware"

cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-firmware"

test -f "$STAGE/pkg/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 1
test "$(find "$STAGE/pkg/usr/share/icons" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 2
# do not pack evidence PNG / theme
if find "$STAGE/pkg" -name 'org.gnome.Firmware-128.png' -o -path '*Humanity*' | grep -q .; then
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
REPORT="$ROOT/probe/kemi-gnome-firmware.json"
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
  "$UNPACK_GUI/usr/share/doc/gnome-firmware/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/gnome-firmware/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "5b0760d91fa9f0c740bdd1add8912c388abb803bf89217414a23f9e7007c79e1"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/org.gnome.Firmware.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Firmware.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Firmware\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if re.search(r"^GenericName=", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERICNAME_UNEXPECTED")
if not re.search(r"^Icon=org\.gnome\.Firmware\s*$", text, flags=re.M):
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
if abs_exec != "/usr/bin/gnome-firmware":
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
if "Exec=/usr/bin/gnome-firmware" not in text or "TryExec=/usr/bin/gnome-firmware" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if not re.search(r"^NoDisplay=false\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NODISPLAY")
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_rewritten", abs_exec)
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-firmware/scripts/build-gnome-firmware-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-firmware\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-firmware "$STAGE/pkg/opt/gnome-firmware/gnome-firmware"
ln -sf gnome-firmware "$STAGE/pkg/usr/bin/kemi-gnome-firmware"

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
kemi-gnome-firmware (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates
    universe) gnome-firmware 3.34.0-2ubuntu1
    arm64, KEMI mall linuxpkg repack.
    Official user-facing binary is
    /usr/bin/gnome-firmware. Official
    different-source Depends stay Depends.
    Official control has no Recommends and
    no Suggests. Official ELF stays at the
    official path; /opt/gnome-firmware/*
    are symlinks. Also
    /usr/bin/kemi-gnome-firmware →
    gnome-firmware. Official desktop
    Name=Firmware kept; relative Exec
    rewritten absolute; TryExec added;
    official NoDisplay=false kept. Official
    changelog kept at the official path and
    copied with cp -L into the kemi doc
    dir. Official app SVG packed once; 128
    evidence PNG from the official SVG is
    CREATE --icon only and is not packed.
    Official en_GB .mo packed official;
    none invented. Icon-cache and
    desktop-database hooks appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Firmware — official Ubuntu 20.04
(focal-updates universe) gnome-firmware
3.34.0-2ubuntu1 Architecture: arm64, KEMI
repack. Official user-facing binary is
/usr/bin/gnome-firmware and stays under
/usr. /opt/gnome-firmware/* are symlinks.
Official different-source Depends stay
Depends. Official control has no Recommends
and no Suggests. Official package ships
one official en_GB .mo; it is packed
official; none invented. Official app icon
is scalable SVG only; official SVGs stay
official and are packed once. A 128×128
evidence PNG rasterized from the official
org.gnome.Firmware.svg is used only as
mall CREATE --icon and is not packed.
Official desktop Name=Firmware is kept;
mall app_name is Firmware (official
desktop Name and official appdata <name>,
which match; no more distinctive official
title). Official GenericName: none. Probe:
1 unique aarch64 ELF, requiredGlibc 2.17
(1 versioned, 0 null), no GLIBCXX
(0 versioned, 1 null, not ranked as a max);
PASS vs Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal-updates
universe gnome-firmware 3.34.0-2ubuntu1
(arm64), newer than focal Release 3.34.0-2.
Official SHA256 + size matched
ports.ubuntu.com and Aliyun ubuntu-ports
(https) pool files and the focal-updates
universe Packages stanza. No librarian URL
this run. 合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: gnome
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libfwupd2 (>= 1.7.9), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.22.29), libsoup2.4-1 (>= 2.51.92), libxmlb2 (>= 0.1.0), fwupd
Conflicts: gnome-firmware
Replaces: gnome-firmware
Provides: gnome-firmware (= 3.34.0-2ubuntu1)
Homepage: https://gitlab.gnome.org/hughsie/gnome-firmware-updater
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: GTK front end for fwupd
 Firmware ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack of gnome-firmware.
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
echo "$DEB" | grep -q 'kemi-gnome-firmware_3.34.0-2ubuntu1kemi1_arm64.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-firmware-control.txt"
grep -q 'Version: 3.34.0-2ubuntu1kemi1' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
grep -q 'gnome-firmware (= 3.34.0-2ubuntu1)' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
grep -q 'libfwupd2 (>= 1.7.9)' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-firmware-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-firmware-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/org.gnome.Firmware.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Firmware" in desk
assert "Exec=/usr/bin/gnome-firmware" in desk
assert "TryExec=/usr/bin/gnome-firmware" in desk
assert "Icon=org.gnome.Firmware" in desk
assert "NoDisplay=false" in desk
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-firmware"
test ! -L "$CHECK/usr/bin/gnome-firmware"
test -L "$CHECK/usr/bin/kemi-gnome-firmware"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-firmware")" = "gnome-firmware"
test -L "$CHECK/opt/gnome-firmware/gnome-firmware"
test "$(readlink "$CHECK/opt/gnome-firmware/gnome-firmware")" = "/usr/bin/gnome-firmware"
test -f "$CHECK/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test ! -L "$CHECK/usr/share/doc/gnome-firmware/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 1
test -f "$CHECK/usr/share/locale/en_GB/LC_MESSAGES/gnome-firmware.mo"
test "$(find "$CHECK/usr/share/icons" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 2
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/org.gnome.Firmware.svg"
test -f "$CHECK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Firmware-symbolic.svg"
if find "$CHECK" -name 'org.gnome.Firmware-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
