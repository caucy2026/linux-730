#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-control-center 1.24.0-1 Architecture: arm64
# as kemi-mate-control-center. Official
# same-source libmate-slab0 and
# libmate-window-settings1 are exact-version
# hard Depends (= 1.24.0-1) and are bundled.
# Official same-source
# mate-control-center-common is a range Depends
# (>= 1.24.0-1) and is not bundled
# (exact-version rule); it stays Depends.
# libmate-slab-dev and
# libmate-window-settings-dev are inspected
# and not packaged. Newest official U20 pin:
# focal Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source
# field is absent and was not defaulted;
# sibling stanzas list Source:
# mate-control-center. No Debian epoch, no
# tilde. Official different-source Depends
# stay Depends, including libmate-menu2 from
# bundled libmate-slab0. Official control has
# no Recommends. Official Suggests gconf2 stay
# Suggests. Official GUI Breaks
# ubuntu-mate-default-settings (<< 16.04) and
# official lib Breaks mate-control-center
# (<< 1.9.0) are kept. Versioned Provides:
# mate-control-center, libmate-slab0, and
# libmate-window-settings1 (= 1.24.0-1).
# Official ELFs stay at official /usr paths.
# /opt/mate-control-center/* and
# /usr/bin/kemi-mate-control-center are
# symlinks only. Official GUI and libs ship
# no app icon (desktop Icons are theme names;
# common typing-monitor / pixmap artwork is
# not packed). Official common 142 official
# .mo, schemas, man, help, and icons are not
# packed; none invented. A 128×128 evidence
# PNG rasterized from official Ubuntu 20.04
# humanity-icon-theme 0.6.15
# categories/48/preferences-desktop.svg
# (named by official matecc.desktop; theme
# has no official 128 for this icon) via
# Chrome headless
# --default-background-color=00000000 is used
# only as the mall CREATE --icon; it is not
# packed. Theme not bundled. Official GUI
# changelog.Debian.gz is a dangling symlink
# into bundled libmate-slab0; official
# symlink is kept (resolves after merge) and
# the real file is also copied with cp -L.
# Official desktop Name=Control Center is
# kept in matecc.desktop. Official
# GenericName=The MATE configuration tool
# stays in that desktop file and is not mall
# app_name. No official appdata. Mall
# app_name is MATE Control Center (the usual
# distinctive product title). Official
# relative Exec rewritten absolute; TryExec
# added when missing. Official NoDisplay=true
# on mate-theme-installer.desktop is kept;
# none invented elsewhere. Official GUI has
# no maintainer scripts. Official lib shlibs,
# symbols, and activate-noawait ldconfig
# triggers are kept (merged). Official
# conffiles for matecc.menu are kept.
# desktop-database and ldconfig hooks are
# appended. Probe: 19 unique aarch64 ELFs,
# requiredGlibc 2.29, no GLIBCXX; PASS vs
# 101. Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64 / all Packages
# stanzas. No librarian URL and no .buildinfo
# this run. KEMI mall version_name
# 1.24.0-1kemi1 is 13 chars. No epoch, no
# tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-control-center
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-control-center
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$DL/mate-control-center_${VER_UP}_arm64.deb"
OFF_SLAB="$DL/libmate-slab0_${VER_UP}_arm64.deb"
OFF_WIN="$DL/libmate-window-settings1_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/slab" "$UNPACK/win" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-control-center" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -f "$UNPACK/slab/usr/lib/aarch64-linux-gnu/libmate-slab.so.0.0.0" ]; then
  rm -rf "$UNPACK/slab"; mkdir -p "$UNPACK/slab"
  dpkg-deb -x "$OFF_SLAB" "$UNPACK/slab"
  dpkg-deb -e "$OFF_SLAB" "$UNPACK/slab/DEBIAN"
fi
if [ ! -f "$UNPACK/win/usr/lib/aarch64-linux-gnu/libmate-window-settings.so.1.0.0" ]; then
  rm -rf "$UNPACK/win"; mkdir -p "$UNPACK/win"
  dpkg-deb -x "$OFF_WIN" "$UNPACK/win"
  dpkg-deb -e "$OFF_WIN" "$UNPACK/win/DEBIAN"
fi

# pack official GUI + bundled exact-version same-source libs; do not merge unbundled common
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/slab/." "$STAGE/pkg/"
cp -a "$UNPACK/win/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
cp -a "$UNPACK/gui/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"
cat "$UNPACK/slab/DEBIAN/shlibs" "$UNPACK/win/DEBIAN/shlibs" > "$STAGE/pkg/DEBIAN/shlibs"
cat "$UNPACK/slab/DEBIAN/symbols" "$UNPACK/win/DEBIAN/symbols" > "$STAGE/pkg/DEBIAN/symbols"
cp -a "$UNPACK/slab/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

mkdir -p "$STAGE/pkg/opt/mate-control-center"
ln -s /usr/bin/mate-control-center "$STAGE/pkg/opt/mate-control-center/mate-control-center"
ln -s mate-control-center "$STAGE/pkg/usr/bin/kemi-mate-control-center"
test -x "$STAGE/pkg/usr/bin/mate-control-center"
test -L "$STAGE/pkg/opt/mate-control-center/mate-control-center"
test -L "$STAGE/pkg/usr/bin/kemi-mate-control-center"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmate-slab.so.0.0.0"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmate-window-settings.so.1.0.0"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/window-manager-settings/libmarco.so"

if [ -d "$STAGE/pkg/usr/share/doc/mate-control-center-common" ]; then
  echo "COMMON_PACKED" >&2
  exit 1
fi
if find "$STAGE/pkg" -name '*.mo' | grep -q .; then
  echo "INVENTED_OR_COMMON_MO" >&2
  exit 1
fi
test -L "$STAGE/pkg/usr/share/doc/mate-control-center/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/mate-control-center/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-control-center/stage/pkg")
desktops = sorted((root / "usr/share/applications").glob("*.desktop"))
assert len(desktops) == 14, [p.name for p in desktops]

expect = {
    "mate-about-me.desktop": ("Name=About Me", "Icon=user-info", "/usr/bin/mate-about-me"),
    "mate-appearance-properties.desktop": ("Name=Appearance", "Icon=preferences-desktop-theme", "/usr/bin/mate-appearance-properties"),
    "mate-at-properties.desktop": ("Name=Assistive Technologies", "Icon=preferences-desktop-accessibility", "/usr/bin/mate-at-properties"),
    "mate-default-applications-properties.desktop": ("Name=Preferred Applications", "Icon=preferences-desktop-default-applications", "/usr/bin/mate-default-applications-properties"),
    "mate-display-properties.desktop": ("Name=Displays", "Icon=preferences-desktop-display", "/usr/bin/mate-display-properties"),
    "mate-font-viewer.desktop": ("Name=MATE Font Viewer", "Icon=preferences-desktop-font", "/usr/bin/mate-font-viewer"),
    "mate-keybinding.desktop": ("Name=Keyboard Shortcuts", "Icon=preferences-desktop-keyboard-shortcuts", "/usr/bin/mate-keybinding-properties"),
    "mate-keyboard.desktop": ("Name=Keyboard", "Icon=input-keyboard", "/usr/bin/mate-keyboard-properties"),
    "mate-network-properties.desktop": ("Name=Network Proxy", "Icon=network-server", "/usr/bin/mate-network-properties"),
    "mate-settings-mouse.desktop": ("Name=Mouse", "Icon=input-mouse", "/usr/bin/mate-mouse-properties"),
    "mate-theme-installer.desktop": ("Name=Theme Installer", "Icon=preferences-desktop-theme", "/usr/bin/mate-appearance-properties"),
    "mate-time-admin.desktop": ("Name=Time And Date Manager", "Icon=preferences-system-time", "/usr/bin/mate-time-admin"),
    "mate-window-properties.desktop": ("Name=Windows", "Icon=preferences-system-windows", "/usr/bin/mate-window-properties"),
    "matecc.desktop": ("Name=Control Center", "Icon=preferences-desktop", "/usr/bin/mate-control-center"),
}

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
    name, icon, exec_abs = expect[p.name]
    assert name in text, (p, name)
    assert icon in text
    keys = untranslated_keys(text)
    if p.name == "matecc.desktop":
        assert "GenericName=The MATE configuration tool" in text
    if p.name == "mate-theme-installer.desktop":
        assert "NoDisplay=true" in text
    else:
        assert "NoDisplay" not in keys
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
    assert name in new
    assert icon in new
    assert ("Exec=" + exec_abs) in new
    assert ("TryExec=" + exec_abs) in new
    if p.name == "mate-theme-installer.desktop":
        assert "NoDisplay=true" in new
    else:
        assert "NoDisplay" not in untranslated_keys(new)
    p.write_text(new)
    print("desktop_ok", p.name)

cc = (root / "usr/share/applications/matecc.desktop").read_text()
assert "Exec=/usr/bin/mate-control-center" in cc
assert "GenericName=The MATE configuration tool" in cc
app = (root / "usr/share/applications/mate-appearance-properties.desktop").read_text()
assert "Exec=/usr/bin/mate-appearance-properties %F" in app
font = (root / "usr/share/applications/mate-font-viewer.desktop").read_text()
assert "Exec=/usr/bin/mate-font-viewer %u" in font
inst = (root / "usr/share/applications/mate-theme-installer.desktop").read_text()
assert "Exec=/usr/bin/mate-appearance-properties -i %u" in inst
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-control-center/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-control-center/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test -f "$STAGE/pkg/usr/share/doc/libmate-slab0/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libmate-slab0/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libmate-window-settings1/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libmate-window-settings1/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-control-center (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-control-center 1.24.0-1 arm64, KEMI
    mall linuxpkg repack, bundling official
    same-source exact-version libmate-slab0
    and libmate-window-settings1
    (= 1.24.0-1). Official
    mate-control-center-common (>= 1.24.0-1)
    is a range Depends and was not bundled.
    Official ELF stays under /usr. Official
    desktop Name=Control Center kept; mall
    app_name=MATE Control Center.
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
if [ "$1" = "configure" ]; then
	ldconfig
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
	ldconfig
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'activate-noawait ldconfig' "$STAGE/pkg/DEBIAN/triggers"
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'preferences-desktop-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi
echo "mo_count $(find "$STAGE/pkg" -name '*.mo' | wc -l)"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: caja-common (>= 1.8.0), desktop-file-utils, gsettings-desktop-schemas, libglib2.0-bin, marco-common (>= 1.18), mate-control-center-common (>= 1.24.0-1), mate-desktop (>= 1.22), mate-icon-theme, mate-menus, mate-settings-daemon (>= 1.22), libaccountsservice0 (>= 0.6.8), libc6 (>= 2.29), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.10.0), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.2), libdbus-glib-1-2 (>= 0.78), libdconf1 (>= 0.14.0), libfontconfig1 (>= 2.12.6), libfreetype6 (>= 2.2.1), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.4), libmarco-private2 (>= 1.22.2), libmate-desktop-2-17 (>= 1.24), libmate-menu2 (>= 1.22.0), libmatekbd4 (>= 1.18), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libpolkit-gobject-1-0 (>= 0.99), libx11-6, libxcursor1 (>> 1.1.2), libxi6 (>= 2:1.2.0), libxklavier16 (>= 5.0), libxml2 (>= 2.7.4), libxss1, libatk1.0-0 (>= 1.12.4)
Suggests: gconf2
Provides: mate-control-center (= ${VER_UP}), libmate-slab0 (= ${VER_UP}), libmate-window-settings1 (= ${VER_UP})
Conflicts: mate-control-center, libmate-slab0, libmate-window-settings1
Replaces: mate-control-center, libmate-slab0, libmate-window-settings1
Breaks: ubuntu-mate-default-settings (<< 16.04), mate-control-center (<< 1.9.0)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: utilities to configure the MATE desktop
 MATE Control Center 1.24.0-1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-control-center, bundling official
 libmate-slab0 and
 libmate-window-settings1. Official
 mate-control-center-common stays Depends
 (range, not bundled). glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-control-center/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
        continue
    # official lintian overrides may mention the official amd64 library path;
    # that official packaging text is not a leftover-x86 defect
    if "lintian/overrides" in str(p.as_posix()):
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
root = Path("/workspace/t142-20261112-mate-control-center/stage/pkg")
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
p = Path("/workspace/t142-20261112-mate-control-center/debs/kemi-mate-control-center_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-control-center/dl/mate-control-center_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-control-center-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'preferences-desktop-128|humanity-icon-theme|mate-control-center-common'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_and_common_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-control-center/stage/pkg")
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
test "${#ELFS[@]}" -eq 19
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-control-center.json"
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
assert gv == 19 and gn == 0
assert cmax is None
assert cv == 0 and cn == 19
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
