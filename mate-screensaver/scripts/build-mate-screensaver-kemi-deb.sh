#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-screensaver 1.24.0-1 Architecture: arm64
# as kemi-mate-screensaver. Official same-source
# mate-screensaver-common is an exact-version
# hard Depends (= 1.24.0-1) and is bundled.
# Newest official U20 pin: focal Release
# universe only; not in focal-updates,
# focal-security, or focal-backports. Official
# GUI stanza Source field is absent and was
# not defaulted; sibling stanza lists Source:
# mate-screensaver. No Debian epoch, no tilde.
# Official different-source Depends stay
# Depends. When bundling common, its
# dconf-gsettings-backend | gsettings-backend
# Depends is merged into kemi Depends.
# Official Recommends mate-power-manager stay
# Recommends. Official Suggests rss-glx,
# xscreensaver-data stay Suggests. Official
# GUI Breaks/Replaces mate-screensaver-common
# (<< 1.9.0) and official common Breaks
# mate-screensaver (<< 1.5.2) are kept.
# Versioned Provides: mate-screensaver and
# mate-screensaver-common (= 1.24.0-1).
# Official ELFs stay at official /usr paths.
# /opt/mate-screensaver/* and
# /usr/bin/kemi-mate-screensaver are symlinks
# only (official mate-screensaver command
# exists). Official GUI ships no app icon
# (desktop Icon is the theme name
# preferences-desktop-screensaver). Official
# common 106 .mo, schemas, man, pixmaps, and
# cosmos backgrounds are official and packed
# (bundled exact-version common); none of the
# .mo are invented. Official pixmaps are
# in-app artwork, not the mall icon. A 128×128
# evidence PNG rasterized from official Ubuntu
# 20.04 humanity-icon-theme 0.6.15
# apps/48/preferences-desktop-screensaver.svg
# (named by official preferences desktop;
# theme has no official 128 for this icon) is
# used only as the mall CREATE --icon; it is
# not packed. Theme not bundled. Official GUI
# changelog.Debian.gz is a real file; official
# kept and also cp -L into the kemi doc dir.
# Official common changelog is a different
# real file and is kept at the official path.
# Official desktop Name=Screensaver is kept
# in the desktop files and is not mall
# app_name. Mall app_name is MATE Screensaver
# (the usual distinctive title). No official
# GenericName or official appdata. Official
# relative Exec rewritten absolute; TryExec
# added when missing. Official NoDisplay=true
# on the autostart desktop is kept; none
# invented on the preferences desktop.
# Official screensaver-module Exec/TryExec
# already absolute, kept. Official D-Bus Exec
# already absolute, kept. Official GUI and
# common have no maintainer scripts. Official
# conffiles from both packages are kept.
# desktop-database and glib-compile-schemas
# hooks are appended (no official hicolor
# icons packed, no bundled shared lib, so no
# icon-cache / ldconfig). Probe: 8 unique
# aarch64 ELFs, requiredGlibc 2.29, no
# GLIBCXX; PASS vs 101. Official SHA256 +
# size matched ports.ubuntu.com and Aliyun
# ubuntu-ports (https) pool files and the
# Ubuntu 20.04 focal universe arm64 / all
# Packages stanzas. Official Homepage
# http://www.mate-desktop.org/ is copied
# exactly. No librarian URL and no .buildinfo
# this run. KEMI mall version_name
# 1.24.0-1kemi1 is 13 chars. No epoch, no
# tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-screensaver
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-screensaver
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$ROOT/upstream/mate-screensaver_${VER_UP}_arm64.deb"
OFF_COMMON="$ROOT/upstream/mate-screensaver-common_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-screensaver" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -f "$UNPACK/common/usr/share/glib-2.0/schemas/org.mate.screensaver.gschema.xml" ]; then
  rm -rf "$UNPACK/common"; mkdir -p "$UNPACK/common"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/common/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
cat "$UNPACK/gui/DEBIAN/conffiles" "$UNPACK/common/DEBIAN/conffiles" > "$STAGE/pkg/DEBIAN/conffiles"

mkdir -p "$STAGE/pkg/opt/mate-screensaver"
ln -s /usr/bin/mate-screensaver "$STAGE/pkg/opt/mate-screensaver/mate-screensaver"
ln -s mate-screensaver "$STAGE/pkg/usr/bin/kemi-mate-screensaver"
test -x "$STAGE/pkg/usr/bin/mate-screensaver"
test -x "$STAGE/pkg/usr/bin/mate-screensaver-preferences"
test -x "$STAGE/pkg/usr/bin/mate-screensaver-command"
test -L "$STAGE/pkg/opt/mate-screensaver/mate-screensaver"
test -L "$STAGE/pkg/usr/bin/kemi-mate-screensaver"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.screensaver.gschema.xml"
test -f "$STAGE/pkg/etc/xdg/autostart/mate-screensaver.desktop"
test -f "$STAGE/pkg/etc/pam.d/mate-screensaver"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 106

test -f "$STAGE/pkg/usr/share/doc/mate-screensaver/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-screensaver/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/mate-screensaver-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-screensaver-common/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-screensaver/stage/pkg")
app_desktops = sorted((root / "usr/share/applications").rglob("*.desktop"))
auto = root / "etc/xdg/autostart/mate-screensaver.desktop"
assert auto.is_file()
desktops = app_desktops + [auto]
assert [p.name for p in app_desktops] == [
    "mate-screensaver-preferences.desktop",
    "cosmos-slideshow.desktop",
    "footlogo-floaters.desktop",
    "gnomelogo-floaters.desktop",
    "personal-slideshow.desktop",
    "popsquares.desktop",
], [p.name for p in app_desktops]

def untranslated_keys(src: str):
    keys = []
    for ln in src.splitlines():
        if not ln or ln.startswith("#") or "=" not in ln:
            continue
        k = ln.split("=", 1)[0]
        if "[" not in k:
            keys.append(k)
    return keys

def rewrite_first_token(line: str, key: str) -> str:
    prefix = key + "="
    if not line.startswith(prefix):
        return line
    rest = line[len(prefix):]
    if rest == "":
        return line
    parts = rest.split(None, 1)
    cmd = parts[0]
    if "/" not in cmd:
        cmd = "/usr/bin/" + cmd
    if len(parts) == 1:
        return prefix + cmd
    return prefix + cmd + " " + parts[1]

for p in desktops:
    text = p.read_text()
    keys = untranslated_keys(text)
    if p.name == "mate-screensaver-preferences.desktop":
        assert "Name=Screensaver" in text
        assert "Icon=preferences-desktop-screensaver" in text
        assert "NoDisplay" not in keys
        assert "GenericName" not in keys
    elif p.name == "mate-screensaver.desktop" and "autostart" in str(p):
        assert "Name=Screensaver" in text
        assert "Icon=preferences-desktop-screensaver" in text
        assert "NoDisplay=true" in text
    out_lines = []
    have_try = False
    exec_cmd = None
    for line in text.splitlines(keepends=True):
        raw = line[:-1] if line.endswith("\n") else line
        nl = "\n" if line.endswith("\n") else ""
        key = raw.split("=", 1)[0] if "=" in raw and not raw.lstrip().startswith("#") else ""
        if key in ("Exec", "TryExec"):
            raw = rewrite_first_token(raw, key)
        if key == "Exec":
            exec_cmd = raw.split("=", 1)[1].split()[0]
        if key == "TryExec":
            have_try = True
        out_lines.append(raw + nl)
    if not have_try:
        new_lines = []
        inserted = False
        for raw_nl in out_lines:
            new_lines.append(raw_nl)
            raw = raw_nl[:-1] if raw_nl.endswith("\n") else raw_nl
            key = raw.split("=", 1)[0] if "=" in raw and not raw.lstrip().startswith("#") else ""
            if key == "Exec" and not inserted:
                new_lines.append("TryExec=" + exec_cmd + "\n")
                inserted = True
        out_lines = new_lines
    new = "".join(out_lines)
    assert r"\1" not in new
    p.write_text(new)
    print("desktop_ok", p.name)

prefs = (root / "usr/share/applications/mate-screensaver-preferences.desktop").read_text()
assert "Name=Screensaver" in prefs
assert "Icon=preferences-desktop-screensaver" in prefs
assert "Exec=/usr/bin/mate-screensaver-preferences" in prefs
assert "TryExec=/usr/bin/mate-screensaver-preferences" in prefs
assert "NoDisplay" not in untranslated_keys(prefs)
auto = (root / "etc/xdg/autostart/mate-screensaver.desktop").read_text()
assert "Exec=/usr/bin/mate-screensaver" in auto
assert "TryExec=/usr/bin/mate-screensaver" in auto
assert "NoDisplay=true" in auto
foot = (root / "usr/share/applications/screensavers/footlogo-floaters.desktop").read_text()
assert "Exec=/usr/lib/mate-screensaver/mate-screensaver/floaters /usr/share/pixmaps/mate-logo-white.svg" in foot
assert "TryExec=/usr/lib/mate-screensaver/mate-screensaver/floaters" in foot
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-screensaver/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-screensaver/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-screensaver (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-screensaver 1.24.0-1 arm64, KEMI
    mall linuxpkg repack, bundling official
    same-source exact-version
    mate-screensaver-common (= 1.24.0-1).
    Official ELF stays under /usr. Official
    desktop Name=Screensaver kept; mall
    app_name=MATE Screensaver.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
# End automatically added section
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
if grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"; then
  echo "UNEXPECTED_LDCONFIG" >&2
  exit 1
fi
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'preferences-desktop-screensaver-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: dbus-x11, mate-desktop-common, mate-session-manager (>= 1.11.0), libc6 (>= 2.29), libcairo2 (>= 1.10.0), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.78), libgdk-pixbuf2.0-0 (>= 2.22.0), libgl1, libglib2.0-0 (>= 2.39.91), libgtk-3-0 (>= 3.21.4), libmate-desktop-2-17 (>= 1.18), libmate-menu2 (>= 1.22.0), libmatekbd4 (>= 1.18), libnotify4 (>= 0.7.0), libpam0g (>= 0.99.7.1), libpango-1.0-0 (>= 1.18.0), librda0 (>= 0.0.3-2~), libsystemd0, libx11-6, libxext6, libxklavier16 (>= 5.0), libxss1, libxxf86vm1, dconf-gsettings-backend | gsettings-backend
Recommends: mate-power-manager
Suggests: rss-glx, xscreensaver-data
Provides: mate-screensaver (= ${VER_UP}), mate-screensaver-common (= ${VER_UP})
Conflicts: mate-screensaver, mate-screensaver-common
Replaces: mate-screensaver, mate-screensaver-common, mate-screensaver-common (<< 1.9.0)
Breaks: mate-screensaver-common (<< 1.9.0), mate-screensaver (<< 1.5.2)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE screen saver and locker
 MATE Screensaver 1.24.0-1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-screensaver, bundling official
 mate-screensaver-common. Official ELF
 stays under /usr. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

grep -q '^Homepage: http://www.mate-desktop.org/$' "$STAGE/pkg/DEBIAN/control"
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-screensaver/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg"}:
        continue
    if "lintian/overrides" in str(p.as_posix()):
        continue
    if p.name in {"control", "copyright"}:
        continue
    try:
        raw = p.read_bytes()
    except FileNotFoundError:
        continue
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
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
PYX86

python3 - << 'PYLIT'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-screensaver/stage/pkg")
for p in root.rglob("*.desktop"):
    t = p.read_text()
    assert r"\1" not in t, p
print("no_literal_group")
PYLIT

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-screensaver/debs/kemi-mate-screensaver_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-screensaver/upstream/mate-screensaver_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-screensaver-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'preferences-desktop-screensaver-128|humanity-icon-theme'; then
  echo PACKED_BAD >&2
  exit 1
fi
# official pixmaps and cosmos backgrounds should be packed
dpkg-deb -c "$OUT" | grep -q 'usr/share/pixmaps/mate-logo-white.svg'
echo "evidence_not_packed_official_artwork_kept"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-screensaver/stage/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PYELF
)
echo "ELF_COUNT ${#ELFS[@]}"
test "${#ELFS[@]}" -eq 8
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-screensaver.json"
rm -f "$REPORT"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT"
N_ELF=${#ELFS[@]}
export N_ELF REPORT
python3 - << 'PYPROBE'
import json, os
from pathlib import Path
report = Path(os.environ["REPORT"])
n = int(os.environ["N_ELF"])
d = json.loads(report.read_text())
files = d.get("files") or []
assert len(files) == n, (len(files), n)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
gver = [v for v in glibcs if v is not None]
def verkey(s):
    return tuple(int(x) for x in s.split("."))
gmax = max(gver, key=verkey) if gver else None
cver = [v for v in cxxs if v is not None]
cmax = max(cver, key=verkey) if cver else None
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=%s requiredGlibc=%s (%s versioned, %s null); requiredGlibcxx=%s (%s versioned, %s null, nulls not ranked as a max); configuredLimitsSatisfied=true" % (n, gmax, gv, gn, cmax, cv, cn))
if cmax is not None:
    assert verkey(cmax) <= (3, 4, 28), cmax
if gmax is not None:
    assert verkey(gmax) <= (2, 31), gmax
assert gmax == "2.29"
assert gv == 8 and gn == 0
assert cmax is None
assert cv == 0 and cn == 8
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
