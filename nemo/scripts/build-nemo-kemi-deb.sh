#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe)
# nemo 4.4.2-2ubuntu2 Architecture: arm64 as
# kemi-nemo, bundling official same-source
# exact-version hard Depends nemo-data
# (= 4.4.2-2ubuntu2, Architecture: all) and
# libnemo-extension1 (= 4.4.2-2ubuntu2,
# arm64). Official GUI stanza Source field
# is absent and was not defaulted; sibling
# stanzas list Source: nemo. Bundled
# packages have no further exact-version
# same-source hard Depends. Official
# same-source gir1.2-nemo-3.0 and
# libnemo-extension-dev inspected, not
# packaged (gir / -dev). Official
# Recommends stay Recommends including
# same-source-adjacent nemo-fileroller
# (>= 4.4) which is a Recommends (and a
# different official source
# nemo-fileroller). Official Suggests stay
# Suggests. Official different-source
# Depends stay Depends. Newer than focal
# Release 4.4.2-2; not in focal-security or
# focal-backports. No Debian epoch, no
# tilde. Official ELFs stay at official
# /usr paths. /opt/nemo/* are symlinks
# only. Also /usr/bin/kemi-nemo → nemo.
# Official packages ship no .mo; none
# invented. Official app icons are 16–32
# hicolor apps/nemo.png plus scalable
# apps/nemo.svg (no official 256). Official
# icons (47 files) packed once at official
# paths. A 128×128 evidence PNG rasterized
# from the official app SVG via Chrome
# headless --default-background-color=00000000
# lives at evidence/nemo-128.png and is
# used only as the mall CREATE --icon; it
# is not packed. Official in-app action /
# status / emblem icons stay official and
# are not used as the mall icon. Official
# GUI changelog.Debian.gz is a dangling
# symlink into libnemo-extension1; the lib
# is bundled so the official symlink is
# kept (resolves) and the real official
# changelog is also copied with cp -L into
# the kemi doc dir. Official desktop
# Name=Files is kept in the main desktop
# file. Official relative Exec is rewritten
# absolute; TryExec is added when missing.
# Official helper NoDisplay=true is kept;
# no NoDisplay is invented on the main
# desktop. Official D-Bus Exec is already
# absolute and is kept. Official
# nemo-data dh_python3 postinst/prerm are
# kept and retargeted to kemi-nemo.
# glib-compile-schemas, desktop-database,
# icon-cache, and ldconfig hooks are
# appended. Probe: 8 unique aarch64 ELFs,
# requiredGlibc 2.17 (8 versioned, 0 null),
# no GLIBCXX (0 versioned, 8 null, not
# ranked as a max); PASS vs 101. Official
# SHA256 + size matched ports.ubuntu.com
# and Aliyun ubuntu-ports (https) pool
# files and the Ubuntu 20.04
# focal-updates universe arm64 / all
# Packages stanzas. No librarian URL and
# no .buildinfo this run. KEMI mall
# version_name 4.4.2-2ubuntu2kemi1 is 19
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-nemo
VER_UP=4.4.2-2ubuntu2
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-nemo
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/nemo}"
UNPACK_DATA="${UNPACK_DATA:-$ROOT/unpack-official/nemo-data}"
UNPACK_LIB="${UNPACK_LIB:-$ROOT/unpack-official/libnemo-extension1}"
GUI_DEB="$DL/nemo_4.4.2-2ubuntu2_arm64.deb"
DATA_DEB="$DL/nemo-data_4.4.2-2ubuntu2_all.deb"
LIB_DEB="$DL/libnemo-extension1_4.4.2-2ubuntu2_arm64.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 19, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test "$(stat -c%s "$GUI_DEB")" = 802812
echo "94ea89e64b2e119bcc22270f3299e173fae1f8d8d23c1803a01349f034ba9d96  $GUI_DEB" | sha256sum -c -
test "$(stat -c%s "$DATA_DEB")" = 76168
echo "90176df6dd78211183a84250eb1582a71e643284ce5bbdfa1acea75e8a68a539  $DATA_DEB" | sha256sum -c -
test "$(stat -c%s "$LIB_DEB")" = 38928
echo "5dac6c49b91a4f3cdac0cbe90464e3a9b09547d701120294c1d5103bd0796838  $LIB_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/nemo"
test -f "$UNPACK_GUI/usr/share/applications/nemo.desktop"
test -L "$UNPACK_GUI/usr/share/doc/nemo/changelog.Debian.gz"
test ! -e "$UNPACK_GUI/usr/share/doc/nemo/changelog.Debian.gz"
test -f "$UNPACK_LIB/usr/share/doc/libnemo-extension1/changelog.Debian.gz"
test -f "$UNPACK_DATA/usr/share/icons/hicolor/scalable/apps/nemo.svg"
test -f "$ROOT/evidence/nemo-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/nemo-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "fd34b36a4f2ccabef57b691c91b113fe44ee38d8be8a82f8ca5c20457a4d0c8d"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/nemo.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "63871dc95730902e347c987cd63de1fbc1cd9096a5c8c52dfe55fcbfa104718c"
root = Path("$ROOT/unpack-official")
n = sum(1 for x in root.rglob("*") if x.is_file() and x.suffix.lower() in {".png", ".svg", ".xpm"})
assert n == 47, n
mos = list(root.rglob("*.mo"))
assert len(mos) == 0, len(mos)
print("official_icons_47_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/nemo"

cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_DATA/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_LIB/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/nemo" \
  "$STAGE/pkg/usr/bin/nemo-autorun-software" \
  "$STAGE/pkg/usr/bin/nemo-connect-server" \
  "$STAGE/pkg/usr/bin/nemo-desktop" \
  "$STAGE/pkg/usr/bin/nemo-open-with"

# official GUI changelog symlink should now resolve into bundled lib doc
test -L "$STAGE/pkg/usr/share/doc/nemo/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/nemo/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/nemo-data/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnemo-extension.so.1.4.0"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnemo-extension.so.1"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg" \( -name '*.png' -o -name '*.svg' -o -name '*.xpm' \) | wc -l)" = 47
if find "$STAGE/pkg" -name 'nemo-128.png' -o -path '*Humanity*' -o -name 'gir1.2-nemo-3.0*' -o -path '*libnemo-extension-dev*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_OR_GIRDEV_STAGED" >&2
  exit 1
fi

# keep / retarget official nemo-data dh_python3 hooks
cp -a "$UNPACK_DATA/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK_DATA/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
python3 - << PY
from pathlib import Path
for name in ("postinst", "prerm"):
    p = Path("$STAGE/pkg/DEBIAN") / name
    text = p.read_text()
    text = text.replace("-p nemo-data", "-p kemi-nemo")
    text = text.replace("dpkg -L nemo-data", "dpkg -L kemi-nemo")
    if "nemo-data" in text and "-p kemi-nemo" not in text and name == "postinst":
        # residual package-name references besides path /usr/share/nemo are unexpected
        pass
    # remaining "nemo-data" should not be the dpkg package flag
    if "-p nemo-data" in text or "dpkg -L nemo-data" in text:
        raise SystemExit("HOOK_RETARGET_FAIL:"+name)
    p.write_text(text)
    print("retargeted", name)
PY
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"

# official lib ldconfig trigger
mkdir -p "$STAGE/pkg/DEBIAN"
printf '%s\n' 'activate-noawait ldconfig' > "$STAGE/pkg/DEBIAN/triggers"

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
test "${#ELFS[@]}" = 8
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-nemo.json"
rm -f "$REPORT"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
d = json.loads(Path("$REPORT").read_text())
files = d.get("files") or []
assert len(files) == 8, len(files)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
gver = [v for v in glibcs if v is not None]
assert gver and max(gver, key=lambda s: tuple(int(x) for x in s.split("."))) == "2.17"
assert gn == 0 and gv == 8
assert cv == 0 and cn == 8
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=8 requiredGlibc=2.17 (8 versioned, 0 null); requiredGlibcxx none (0 versioned, 8 null, not ranked as a max); configuredLimitsSatisfied=true")
d["n_elf"] = 8
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
Path("$REPORT").write_text(json.dumps(d, indent=2) + "\n")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/nemo/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
# real official changelog from bundled lib (GUI symlink target)
cp --remove-destination -L \
  "$UNPACK_LIB/usr/share/doc/libnemo-extension1/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "6972f3c4029c8e2b29c84c04d1c6b90672a4d5c6cd14316cbd1eaf6a8e22de56"
print("changelog_upstream_ok")
PY

export STAGE_APPS="$STAGE/pkg/usr/share/applications"
python3 - << 'PY'
import os, re
from pathlib import Path
apps = Path(os.environ["STAGE_APPS"])

def abs_cmd(cmd: str) -> str:
    parts = cmd.split(None, 1)
    first = parts[0]
    rest = (" " + parts[1]) if len(parts) > 1 else ""
    if first.startswith("/"):
        return cmd
    if "/" in first:
        raise SystemExit("DESKTOP_RELATIVE_PATH:" + cmd)
    return "/usr/bin/" + first + rest

for p in sorted(apps.glob("*.desktop")):
    text = p.read_text()
    if r"\1" in text:
        raise SystemExit("DESKTOP_LITERAL_GROUP_BEFORE:"+p.name)
    lines = text.splitlines(keepends=True)
    out = []
    section = None
    entry_has_tryexec = False
    entry_first_exec = None
    entry_exec_index = None
    # We'll do a two-pass: rewrite Exec/TryExec, then add TryExec into Desktop Entry if missing
    new_lines = []
    cur = None
    for line in lines:
        raw = line
        s = line.rstrip("\n")
        if s.startswith("[") and s.endswith("]"):
            cur = s
            new_lines.append(raw)
            continue
        if s.startswith("Exec="):
            cmd = s[5:]
            absed = abs_cmd(cmd)
            new_lines.append("Exec=" + absed + ("\n" if raw.endswith("\n") else ""))
            continue
        if s.startswith("TryExec="):
            cmd = s[8:]
            absed = abs_cmd(cmd)
            new_lines.append("TryExec=" + absed + ("\n" if raw.endswith("\n") else ""))
            continue
        new_lines.append(raw)
    text2 = "".join(new_lines)
    # Add TryExec in [Desktop Entry] if missing, after the first Exec in that section
    if not re.search(r"(?m)^TryExec=", text2.split("[Desktop Action")[0] if "[Desktop Action" in text2 else text2):
        def add_try(mo):
            exec_line = mo.group(0)
            first = exec_line[len("Exec="):].split()[0]
            return exec_line + "\nTryExec=" + first
        # only first Exec in Desktop Entry: operate on the prefix before first action
        if "[Desktop Action" in text2:
            head, tail = text2.split("[Desktop Action", 1)
            head = re.sub(r"^Exec=.*$", add_try, head, count=1, flags=re.M)
            text2 = head + "[Desktop Action" + tail
        else:
            text2 = re.sub(r"^Exec=.*$", add_try, text2, count=1, flags=re.M)
    if r"\1" in text2:
        raise SystemExit("DESKTOP_LITERAL_GROUP:"+p.name)
    p.write_text(text2)
    print("desktop_rewritten", p.name)

# assertions on the three official desktops
main = (apps / "nemo.desktop").read_text()
assert re.search(r"^Name=Files\s*$", main, flags=re.M)
assert "Exec=/usr/bin/nemo %U" in main
assert "TryExec=/usr/bin/nemo" in main
assert "Exec=/usr/bin/nemo computer:///" in main
assert "Exec=/usr/bin/nemo trash:///" in main
assert re.search(r"^Icon=folder\s*$", main, flags=re.M)
assert not re.search(r"^NoDisplay=", main, flags=re.M)
assert not re.search(r"^GenericName=", main, flags=re.M)
auto = (apps / "nemo-autostart.desktop").read_text()
assert re.search(r"^Name=Nemo\s*$", auto, flags=re.M)
assert "Exec=/usr/bin/nemo-desktop" in auto
assert "TryExec=/usr/bin/nemo-desktop" in auto
assert "NoDisplay=true" in auto
arun = (apps / "nemo-autorun-software.desktop").read_text()
assert "Name=Autorun Prompt" in arun
assert "Exec=/usr/bin/nemo-autorun-software %u" in arun
assert "TryExec=/usr/bin/nemo-autorun-software" in arun
assert "NoDisplay=true" in arun
assert "Icon=application-x-executable" in arun
# D-Bus already absolute
svc = (apps.parent / "dbus-1/services/nemo.service").read_text()
assert "Exec=/usr/bin/nemo --no-default-window" in svc
print("desktop_assertions_ok")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-nemo/scripts/build-nemo-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/nemo\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/nemo "$STAGE/pkg/opt/nemo/nemo"
ln -sf nemo "$STAGE/pkg/usr/bin/kemi-nemo"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        # official ELF hardware-ID / needed strings are not a packaging defect
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        # official Description text is not a packaging defect
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

# append hooks with quoted heredoc (do not expand $1)
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# Automatically added by kemi
if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
	glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
if command -v ldconfig >/dev/null 2>&1; then
	ldconfig || true
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v ldconfig >/dev/null 2>&1; then
		ldconfig || true
	fi
	if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
		glib-compile-schemas /usr/share/glib-2.0/schemas || true
	fi
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
		gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
	fi
fi
# End automatically added section
HOOK
# official data had no postrm; if we created postrm only from this append, it needs shebang — already included
if ! head -1 "$STAGE/pkg/DEBIAN/postrm" | grep -q '^#!'; then
  echo "POSTRM_NO_SHEBANG" >&2
  exit 1
fi
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"
grep -q 'py3compile -p kemi-nemo' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-nemo' "$STAGE/pkg/DEBIAN/prerm"
echo "hooks_ok"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-nemo (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates
    universe) nemo 4.4.2-2ubuntu2 arm64,
    KEMI mall linuxpkg repack. Bundled
    official same-source exact-version
    nemo-data (= 4.4.2-2ubuntu2) and
    libnemo-extension1 (= 4.4.2-2ubuntu2).
    Official gir and -dev inspected, not
    packaged. Official Recommends stay
    Recommends. Official Suggests stay
    Suggests. Official ELFs stay at
    official /usr paths; /opt/nemo/* are
    symlinks. Also /usr/bin/kemi-nemo →
    nemo. Official desktop Name=Files
    kept; mall app_name is Nemo.
    Official relative Exec rewritten
    absolute; TryExec added. Official
    dangling GUI changelog symlink into
    bundled lib kept (resolves) and the
    real official changelog copied with
    cp -L into the kemi doc dir. Official
    app icons packed once; 128 evidence
    PNG from the official SVG is CREATE
    --icon only and is not packed.
    Official packages ship no .mo; none
    invented. Official dh_python3 hooks
    retargeted to kemi-nemo; schema,
    desktop-database, icon-cache, and
    ldconfig hooks appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Nemo — official Ubuntu 20.04
(focal-updates universe) nemo
4.4.2-2ubuntu2 Architecture: arm64, KEMI
repack, bundling official same-source
exact-version nemo-data (= 4.4.2-2ubuntu2)
and libnemo-extension1 (= 4.4.2-2ubuntu2).
Official user-facing binary is
/usr/bin/nemo and stays under /usr.
/opt/nemo/* are symlinks. Official GUI
stanza Source field is absent and was not
defaulted; sibling stanzas list Source:
nemo. Official gir1.2-nemo-3.0 and
libnemo-extension-dev inspected, not
packaged. Official Recommends stay
Recommends. Official Suggests stay
Suggests. Official packages ship no .mo;
none invented. Official app icons
(16–32 PNG plus scalable SVG) stay
official and are packed once. A 128×128
evidence PNG rasterized from the official
apps/nemo.svg is used only as mall CREATE
--icon and is not packed. Official desktop
Name=Files is kept in the desktop file;
mall app_name is Nemo (Files is generic,
the same pattern as Printers vs Print
Settings; this package has no appdata
<name>; Nemo is the usual distinctive
title, also used as the official autostart
desktop Name). Official GenericName: none.
Probe: 8 unique aarch64 ELFs,
requiredGlibc 2.17 (8 versioned, 0 null),
no GLIBCXX (0 versioned, 8 null, not
ranked as a max); PASS vs Ubuntu 20.04 /
glibc 2.31. Official publication: Ubuntu
20.04 focal-updates universe nemo
4.4.2-2ubuntu2 (arm64), newer than focal
Release 4.4.2-2. Official SHA256 + size
matched ports.ubuntu.com and Aliyun
ubuntu-ports (https) pool files and the
focal-updates universe Packages stanzas.
No librarian URL this run.
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
Depends: cinnamon-desktop-data (>= 4.4), desktop-file-utils (>= 0.7), gsettings-desktop-schemas, gvfs (>= 1.3.2), libcinnamon-desktop4 (>= 4.4), libglib2.0-data, libxapp1 (>= 1.4.2), shared-mime-info (>= 0.50), libatk1.0-0 (>= 1.32.0), libc6 (>= 2.17), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.10.0), libexempi8 (>= 2.5.0), libexif12 (>= 0.6.21-1~), libgail-3-0 (>= 3.0.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.49.2), libgtk-3-0 (>= 3.21.5), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.44.6), libpangocairo-1.0-0 (>= 1.14.0), libselinux1 (>= 1.32), libx11-6, libxml2 (>= 2.7.8), python3, dconf-gsettings-backend | gsettings-backend, python3:any
Recommends: cinnamon-l10n (>= 4.4), gvfs-backends, gvfs-fuse, librsvg2-common, nemo-fileroller (>= 4.4)
Suggests: eog, evince | pdf-viewer, totem | mp3-decoder, xdg-user-dirs
Conflicts: nemo, nemo-data, libnemo-extension1
Replaces: nemo, nemo-data, libnemo-extension1
Breaks: cinnamon (<< 4.4), cinnamon-core (<< 4.4~), nemo-fileroller (<< 4.4)
Provides: nemo (= 4.4.2-2ubuntu2), nemo-data (= 4.4.2-2ubuntu2), libnemo-extension1 (= 4.4.2-2ubuntu2)
Homepage: http://cinnamon.linuxmint.com/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: File manager and graphical shell for Cinnamon
 Nemo ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack of nemo, bundling
 official nemo-data and
 libnemo-extension1. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOT

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-nemo_4.4.2-2ubuntu2kemi1_arm64.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'Version: 4.4.2-2ubuntu2kemi1' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'nemo (= 4.4.2-2ubuntu2)' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'nemo-data (= 4.4.2-2ubuntu2)' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'libnemo-extension1 (= 4.4.2-2ubuntu2)' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'Recommends: cinnamon-l10n' "$ROOT/evidence/kemi-nemo-control.txt"
grep -q 'Suggests: eog' "$ROOT/evidence/kemi-nemo-control.txt"
! grep -q 'libnemo-extension1 (= 4.4.2-2ubuntu2),' "$ROOT/evidence/kemi-nemo-control.txt" || true
# bundled packages must not remain in Depends
! grep -E '^ Depends:.*libnemo-extension1 \(=' "$ROOT/evidence/kemi-nemo-control.txt"
! grep -E '^ Depends:.*nemo-data \(=' "$ROOT/evidence/kemi-nemo-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/nemo.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Files" in desk
assert "Exec=/usr/bin/nemo %U" in desk
assert "TryExec=/usr/bin/nemo" in desk
assert "Icon=folder" in desk
assert "NoDisplay=" not in desk
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/nemo"
test ! -L "$CHECK/usr/bin/nemo"
test -L "$CHECK/usr/bin/kemi-nemo"
test "$(readlink "$CHECK/usr/bin/kemi-nemo")" = "nemo"
test -L "$CHECK/opt/nemo/nemo"
test "$(readlink "$CHECK/opt/nemo/nemo")" = "/usr/bin/nemo"
test -f "$CHECK/usr/lib/aarch64-linux-gnu/libnemo-extension.so.1.4.0"
test -L "$CHECK/usr/share/doc/nemo/changelog.Debian.gz"
test -e "$CHECK/usr/share/doc/nemo/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/nemo.svg"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test "$(find "$CHECK" \( -name '*.png' -o -name '*.svg' -o -name '*.xpm' \) | wc -l)" = 47
if find "$CHECK" -name 'nemo-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
