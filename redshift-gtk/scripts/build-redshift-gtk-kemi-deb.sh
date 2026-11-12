#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# redshift-gtk 1.12-2 Architecture: all as
# kemi-redshift-gtk. Official same-source
# Depends redshift (>= 1.12-2) is a range
# and stays Depends; it is not bundled just
# because it is same-source. Official
# redshift and the transitional dummy
# gtk-redshift are inspected and not
# packaged. Official different-source
# gnome-shell-extension-redshift and
# plasma-applet-redshift-control are
# different products and are not packaged.
# Newest official U20 pin: focal Release
# universe only; not in focal-updates,
# focal-security, or focal-backports.
# Official GUI Source field redshift is
# copied exactly. Official Homepage
# http://jonls.dk/redshift/ is copied
# exactly (http, scheme not upgraded).
# No Debian epoch, no tilde. Official
# Recommends at-spi2-core stay Recommends.
# Official Suggests: none. Official
# Breaks/Replaces gtk-redshift (<< 1.10-2~)
# are kept. Architecture: all is kept; arm64
# is not invented. Official Python scripts
# stay at official /usr paths.
# /opt/redshift-gtk/redshift-gtk and
# /usr/bin/kemi-redshift-gtk are symlinks
# only (official /usr/bin/redshift-gtk
# exists). Official desktop Name=Redshift
# and GenericName=Color temperature
# adjustment are kept; official appdata has
# no <name>; mall app_name is Redshift.
# Official relative Exec is rewritten
# absolute; TryExec is added; official has
# no NoDisplay and none is invented.
# Official hicolor and ubuntu-mono SVG
# icons are packed at official paths. A
# 128 evidence PNG rasterized from the
# official redshift.svg is used only as
# CREATE --icon and is not packed. Official
# GUI changelog/NEWS/README/man are
# dangling symlinks into unbundled redshift
# doc/man dirs and are not packed.
# Official copyright is a real file and is
# kept. Official maintainer scripts are
# kept and package-name hooks are
# retargeted to kemi-redshift-gtk; desktop-
# database and gtk-update-icon-cache hooks
# are appended. Official py3compile /
# update-menus / ubuntu-mono icon-cache
# hooks are kept after retarget. No
# official .mo; none invented. Vacuous
# 0-ELF probe PASS (Architecture: all
# Python GUI). mall version_name
# 1.12-2kemi01 is 12 chars: official
# 1.12-2 plus kemi1 would be 11, below the
# mall 12–32 minimum, so the kemi suffix
# is padded to kemi01; no epoch, no tilde,
# no invented upstream version.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-redshift-gtk
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-redshift-gtk
VER_UP=1.12-2
VER_NAME=1.12-2kemi01
VER_DEB=1.12-2kemi01
ARCH=all
OFF_GUI="$ROOT/debs/ports-redshift-gtk_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "1.12-2kemi01"
assert len(s) == 12, len(s)
assert ":" not in s
assert "1.12-2kemi1" != s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

# dangling official symlinks into unbundled redshift — do not pack
rm -f "$STAGE/pkg/usr/share/doc/redshift-gtk/changelog.Debian.gz"
rm -f "$STAGE/pkg/usr/share/doc/redshift-gtk/NEWS.Debian.gz"
rm -f "$STAGE/pkg/usr/share/doc/redshift-gtk/README.gz"
rm -f "$STAGE/pkg/usr/share/man/man1/redshift-gtk.1.gz"
if [ -d "$STAGE/pkg/usr/share/man/man1" ]; then
  rmdir --ignore-fail-on-non-empty "$STAGE/pkg/usr/share/man/man1" || true
  rmdir --ignore-fail-on-non-empty "$STAGE/pkg/usr/share/man" || true
fi
# assert they are gone and were not replaced with copied unbundled files
test ! -e "$STAGE/pkg/usr/share/doc/redshift-gtk/changelog.Debian.gz"
test ! -e "$STAGE/pkg/usr/share/doc/redshift-gtk/NEWS.Debian.gz"
test ! -e "$STAGE/pkg/usr/share/doc/redshift-gtk/README.gz"
test ! -e "$STAGE/pkg/usr/share/man/man1/redshift-gtk.1.gz"
# do not pack unbundled redshift or the dummy
test ! -e "$STAGE/pkg/usr/bin/redshift" || { [ -L "$STAGE/pkg/usr/bin/redshift" ] && echo "UNEXPECTED_REDSHIFT_BIN" >&2 && exit 1; }
test ! -d "$STAGE/pkg/usr/share/doc/redshift"
test ! -d "$STAGE/pkg/usr/share/doc/gtk-redshift"

# official maintainer scripts kept, package-name hooks retargeted
cp -a "$UNPACK/gui/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/gui/DEBIAN/postrm" "$STAGE/pkg/DEBIAN/postrm"
cp -a "$UNPACK/gui/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
python3 - << 'PYRET'
from pathlib import Path
root = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/DEBIAN")
for name in ("postinst", "postrm", "prerm"):
    p = root / name
    t = p.read_text()
    t = t.replace("py3compile -p redshift-gtk", "py3compile -p kemi-redshift-gtk")
    t = t.replace("py3clean -p redshift-gtk", "py3clean -p kemi-redshift-gtk")
    t = t.replace("dpkg -L redshift-gtk", "dpkg -L kemi-redshift-gtk")
    p.write_text(t)
print("scripts_retargeted")
PYRET

# official menu package() guard retargeted
python3 - << 'PYMENU'
from pathlib import Path
p = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/usr/share/menu/redshift-gtk")
t = p.read_text()
assert '?package(redshift-gtk):' in t
t = t.replace("?package(redshift-gtk):", "?package(kemi-redshift-gtk):")
assert "command=\"redshift-gtk\"" in t
assert "title=\"Redshift\"" in t
p.write_text(t)
print("menu_retargeted")
PYMENU

mkdir -p "$STAGE/pkg/opt/redshift-gtk"
ln -s /usr/bin/redshift-gtk "$STAGE/pkg/opt/redshift-gtk/redshift-gtk"
ln -s redshift-gtk "$STAGE/pkg/usr/bin/kemi-redshift-gtk"
test -x "$STAGE/pkg/usr/bin/redshift-gtk"
test -L "$STAGE/pkg/usr/bin/gtk-redshift"
test -L "$STAGE/pkg/opt/redshift-gtk/redshift-gtk"
test -L "$STAGE/pkg/usr/bin/kemi-redshift-gtk"
test -f "$STAGE/pkg/usr/share/applications/redshift-gtk.desktop"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/redshift.svg"
test -f "$STAGE/pkg/usr/share/appdata/redshift-gtk.appdata.xml"
test -f "$STAGE/pkg/usr/lib/python3/dist-packages/redshift_gtk/statusicon.py"
# no invented redshift CLI desktop from the unbundled package
test ! -e "$STAGE/pkg/usr/share/applications/redshift.desktop"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 0

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/usr/share/applications/redshift-gtk.desktop")
text = p.read_text()

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

keys = untranslated_keys(text)
assert "Name=Redshift" in text
assert "GenericName=Color temperature adjustment" in text
assert "Icon=redshift" in text
assert "NoDisplay" not in keys
assert "Exec=redshift-gtk" in text
assert r"\1" not in text
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
assert "Exec=/usr/bin/redshift-gtk" in new
assert "TryExec=/usr/bin/redshift-gtk" in new
assert "Name=Redshift" in new
assert "GenericName=Color temperature adjustment" in new
assert "Icon=redshift" in new
assert "NoDisplay" not in untranslated_keys(new)
p.write_text(new)
print("desktop_ok")

appdata = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/usr/share/appdata/redshift-gtk.appdata.xml").read_text()
assert "<id type=\"desktop\">redshift-gtk.desktop</id>" in appdata
assert "<name" not in appdata.lower()
svc = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/usr/lib/systemd/user/redshift-gtk.service").read_text()
assert "ExecStart=/usr/bin/redshift-gtk" in svc
print("appdata_and_service_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$UNPACK/gui/usr/share/doc/redshift-gtk/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-redshift-gtk (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    redshift-gtk 1.12-2 Architecture: all,
    KEMI mall linuxpkg repack. Official
    same-source range Depends redshift
    (>= 1.12-2) stays Depends and is not
    bundled. Official ELF/Python stays
    under /usr. Official desktop
    Name=Redshift kept; mall
    app_name=Redshift.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# append desktop-database + hicolor icon-cache to official retargeted scripts
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
# End automatically added section
HOOK
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm" "$STAGE/pkg/DEBIAN/prerm"

python3 - << 'PYHOOK'
from pathlib import Path
post = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/DEBIAN/postinst").read_text()
postrm = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/DEBIAN/postrm").read_text()
prerm = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/DEBIAN/prerm").read_text()
assert "py3compile -p kemi-redshift-gtk" in post
assert "py3compile -p redshift-gtk" not in post
assert "update-menus" in post
assert "update-icon-caches /usr/share/icons/ubuntu-mono-dark /usr/share/icons/ubuntu-mono-light" in post
assert "update-desktop-database" in post
assert "gtk-update-icon-cache" in post
assert "ldconfig" not in post
assert "py3clean -p kemi-redshift-gtk" in prerm
assert "dpkg -L kemi-redshift-gtk" in prerm
assert "dpkg -L redshift-gtk" not in prerm
assert '[ "$1" = "remove" ]' in postrm
assert "update-menus" in postrm
print("hooks_ok")
PYHOOK

if find "$STAGE/pkg" \( -name 'redshift-gtk-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Source: redshift
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: redshift (>= 1.12-2), python3:any, python3-xdg, gir1.2-appindicator3-0.1, python3-gi
Recommends: at-spi2-core
Provides: redshift-gtk (= ${VER_UP})
Conflicts: redshift-gtk
Replaces: redshift-gtk, gtk-redshift (<< 1.10-2~)
Breaks: gtk-redshift (<< 1.10-2~)
Homepage: http://jonls.dk/redshift/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Adjusts the color temperature of your screen with GTK+ integration
 Redshift 1.12-2 — official Ubuntu 20.04
 Architecture: all, KEMI repack of
 redshift-gtk. Official same-source range
 Depends redshift (>= 1.12-2) stays
 Depends and is not bundled. Official
 files stay under /usr. gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: http://jonls.dk/redshift/\n" in c
assert "https://jonls.dk/redshift/" not in c
assert "Source: redshift\n" in c
assert "Version: 1.12-2kemi01\n" in c
assert "Architecture: all\n" in c
assert "Depends: redshift (>= 1.12-2), python3:any, python3-xdg, gir1.2-appindicator3-0.1, python3-gi\n" in c
assert "Recommends: at-spi2-core\n" in c
assert "Breaks: gtk-redshift (<< 1.10-2~)\n" in c
print("control_ok")
PYCTL

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-redshift-gtk/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif"}:
        continue
    if "lintian/overrides" in str(p.as_posix()):
        continue
    if p.name in {"control", "copyright"}:
        continue
    try:
        raw = p.read_bytes()
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

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, subprocess, json
from pathlib import Path
p = Path("/workspace/t142-20261112-redshift-gtk/debs/kemi-redshift-gtk_1.12-2kemi01_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/bin/redshift-gtk" in ln and ln.startswith("-rwxr-xr-x") for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-redshift-gtk" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./opt/redshift-gtk/redshift-gtk" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/gtk-redshift" in ln for ln in out.splitlines())
assert any("./usr/share/applications/redshift-gtk.desktop" in ln for ln in out.splitlines())
assert any("./usr/share/icons/hicolor/scalable/apps/redshift.svg" in ln for ln in out.splitlines())
assert not any("redshift-gtk-128.png" in ln for ln in out.splitlines())
assert not any("humanity-icon-theme" in ln for ln in out.splitlines())
assert not any("./usr/bin/redshift " in ln or ln.endswith("./usr/bin/redshift") for ln in out.splitlines())
assert not any("changelog.Debian.gz" in ln for ln in out.splitlines())
assert not any("redshift-gtk.1.gz" in ln for ln in out.splitlines())
assert not any("gtk-redshift/" in ln and "usr/share/doc/gtk-redshift" in ln for ln in out.splitlines())
print("deb_contents_ok")
PYHASH

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-redshift-gtk-control.txt"

# Vacuous 0-ELF probe PASS: official Architecture: all, Python scripts only.
# Do not call probe_elf.py with no --elf.
python3 - << 'PYELF'
import json
from pathlib import Path
import subprocess, tempfile, shutil, hashlib

deb = Path("/workspace/t142-20261112-redshift-gtk/debs/kemi-redshift-gtk_1.12-2kemi01_all.deb")
td = Path("/tmp/t142-redshift-gtk-probe-unpack")
if td.exists():
    shutil.rmtree(td)
td.mkdir()
subprocess.check_call(["dpkg-deb", "-x", str(deb), str(td)])
elfs = []
for p in td.rglob("*"):
    if p.is_file() and not p.is_symlink():
        if p.read_bytes()[:4] == b"\x7fELF":
            elfs.append(str(p))
print("ELF_COUNT", len(elfs))
assert len(elfs) == 0, elfs
report = Path("/workspace/t142-20261112-redshift-gtk/probe/kemi-redshift-gtk.json")
report.parent.mkdir(parents=True, exist_ok=True)
d = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "vacuous 0-ELF PASS: official Architecture: all Python GUI; no packaged ELF; probe_elf.py not invoked with zero --elf",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "n_elf": 0,
    "requiredGlibc": None,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx": None,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
report.write_text(json.dumps(d, indent=2) + "\n")
print("PROBE_PASS n_elf=0 requiredGlibc=None (0 versioned, 0 null); requiredGlibcxx=None (0 versioned, 0 null, nulls not ranked as a max); configuredLimitsSatisfied=true; vacuous=yes")
PYELF

echo "BUILD_OK $OUT"
