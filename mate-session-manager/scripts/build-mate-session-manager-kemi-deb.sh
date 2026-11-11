#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-session-manager 1.24.0-2ubuntu1
# Architecture: arm64 as
# kemi-mate-session-manager. Newest official
# U20 pin: focal Release universe only; not
# in focal-updates, focal-security, or
# focal-backports. Official GUI stanza
# Source field is absent and was not
# defaulted; sibling stanza lists Source:
# mate-session-manager. No Debian epoch,
# no tilde. No exact-version same-source
# hard Depends to bundle. Official
# debian-mate-default-settings is same-source
# but the GUI Depends is an alternatives
# range (mint-mate-default-settings |
# ubuntu-mate-default-settings |
# debian-mate-default-settings
# (>= 1.24.0-2ubuntu1)), so it stays
# Depends and is not bundled. Official
# different-source Depends stay Depends.
# Official Recommends caja, marco,
# mate-panel, mate-polkit,
# mate-settings-daemon stay Recommends.
# Official Suggests: none. Official Breaks
# mate-settings-daemon (<< 1.11.0) kept.
# Official Provides x-session-manager kept.
# Official ELFs stay at official /usr
# paths. /opt/mate-session-manager/mate-session
# is a symlink only. There is no official
# mate-session-manager command, so
# /usr/bin/kemi-mate-session-manager is
# not invented. Official GUI ships hicolor
# 16/22/24/32/48 PNG and a scalable SVG
# app icon (mate-session-properties); those
# official icons are packed at official
# paths. There is no official 128 PNG. A
# 128×128 evidence PNG rasterized from the
# official packaged SVG is used only as
# the mall CREATE --icon and is not packed.
# Official 136 .mo and the official schema
# live in this official GUI package and
# are packed; none of the .mo are invented.
# Official GUI changelog.Debian.gz is a
# real file; official kept and also cp -L
# into the kemi doc dir. Official desktop
# Name=Startup Applications is kept in the
# preferences desktop and is not mall
# app_name. Official xsessions Name=MATE
# is kept and is not mall app_name. Mall
# app_name is MATE Session Manager (the
# usual distinctive product title). No
# official GenericName or official appdata.
# Official relative Exec rewritten
# absolute; TryExec added when missing.
# Official xsessions Icon=Type=Application
# is official packaging text and is kept
# (not "fixed"). Official maintainer
# scripts (postinst/prerm
# update-alternatives) are kept; official
# conffiles kept. desktop-database,
# gtk-update-icon-cache, and
# glib-compile-schemas hooks are appended
# (no bundled shared lib, so no ldconfig).
# Probe: 7 unique aarch64 ELFs,
# requiredGlibc 2.17, no GLIBCXX; PASS vs
# 101. Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64 / all Packages
# stanzas. Official Homepage
# http://www.mate-desktop.org/ is copied
# exactly. No librarian URL and no
# .buildinfo this run. KEMI mall
# version_name 1.24.0-2ubuntu1kemi1 is 20
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-session-manager
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-session-manager
VER_UP=1.24.0-2ubuntu1
VER_NAME=1.24.0-2ubuntu1kemi1
VER_DEB=1.24.0-2ubuntu1kemi1
ARCH=arm64
OFF_GUI="$ROOT/upstream/mate-session-manager_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-2ubuntu1kemi1"
assert len(s) == 20, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-session" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
# keep official DEBIAN scripts/conffiles; regenerate control and md5sums later
mkdir -p "$STAGE/pkg/DEBIAN"
cp -a "$UNPACK/gui/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"
cp -a "$UNPACK/gui/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/gui/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"

mkdir -p "$STAGE/pkg/opt/mate-session-manager"
ln -s /usr/bin/mate-session "$STAGE/pkg/opt/mate-session-manager/mate-session"
test -x "$STAGE/pkg/usr/bin/mate-session"
test -x "$STAGE/pkg/usr/bin/mate-session-properties"
test -x "$STAGE/pkg/usr/bin/mate-session-inhibit"
test -x "$STAGE/pkg/usr/bin/mate-session-save"
test -L "$STAGE/pkg/opt/mate-session-manager/mate-session"
# no official mate-session-manager command — do not invent kemi-mate-session-manager
if [ -e "$STAGE/pkg/usr/bin/kemi-mate-session-manager" ]; then
  echo "INVENTED_KEMI_LAUNCHER" >&2
  exit 1
fi
if [ -e "$STAGE/pkg/usr/bin/mate-session-manager" ]; then
  echo "UNEXPECTED_OFFICIAL_PKG_NAMED_BIN" >&2
  exit 1
fi
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.session.gschema.xml"
test -f "$STAGE/pkg/usr/share/applications/mate-session-properties.desktop"
test -f "$STAGE/pkg/usr/share/xsessions/mate.desktop"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/mate-session-properties.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/mate-session-properties.png"
test ! -e "$STAGE/pkg/usr/share/doc/debian-mate-default-settings"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 136

test -f "$STAGE/pkg/usr/share/doc/mate-session-manager/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-session-manager/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-session-manager/stage/pkg")
prefs = root / "usr/share/applications/mate-session-properties.desktop"
xsess = root / "usr/share/xsessions/mate.desktop"
assert prefs.is_file() and xsess.is_file()
desktops = [prefs, xsess]

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
    if p.name == "mate-session-properties.desktop":
        assert "Name=Startup Applications" in text
        assert "Icon=mate-session-properties" in text
        assert "NoDisplay" not in keys
        assert "GenericName" not in keys
    elif p.name == "mate.desktop":
        assert "Name=MATE" in text
        # official packaging text (gettext leak); keep, do not "fix"
        assert "Icon=Type=Application" in text
        assert "NoDisplay" not in keys
        assert "GenericName" not in keys
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
    print("desktop_ok", p.relative_to(root))

prefs_t = prefs.read_text()
assert "Name=Startup Applications" in prefs_t
assert "Icon=mate-session-properties" in prefs_t
assert "Exec=/usr/bin/mate-session-properties" in prefs_t
assert "TryExec=/usr/bin/mate-session-properties" in prefs_t
assert "NoDisplay" not in untranslated_keys(prefs_t)
xsess_t = xsess.read_text()
assert "Name=MATE" in xsess_t
assert "Exec=/usr/bin/mate-session" in xsess_t
assert "TryExec=/usr/bin/mate-session" in xsess_t
assert "Icon=Type=Application" in xsess_t
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-session-manager/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-session-manager/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-session-manager (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-session-manager 1.24.0-2ubuntu1
    arm64, KEMI mall linuxpkg repack. No
    exact-version same-source hard Depends
    to bundle. Official ELF stays under
    /usr. Official desktop Name=Startup
    Applications kept; mall app_name=MATE
    Session Manager.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# append hooks to official postinst; add postrm for hook cleanup
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
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
	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
	fi
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-alternatives --install' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-alternatives --remove' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
if grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"; then
  echo "UNEXPECTED_LDCONFIG" >&2
  exit 1
fi
# $1 in postrm must still be literal for dpkg
grep -q '\[ "$1" = "remove" \]' "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'mate-session-properties-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
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
Depends: dbus-x11, mate-desktop-common (>= 1.24), mint-mate-default-settings | ubuntu-mate-default-settings | debian-mate-default-settings (>= 1.24.0-2ubuntu1), dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.88), libegl1, libepoxy0 (>= 1.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libgl1, libgles2, libglib2.0-0 (>= 2.39.4), libgtk-3-0 (>= 3.21.4), libice6 (>= 1:1.0.0), libsm6, libsystemd0, libx11-6, libxau6, libxcomposite1 (>= 1:0.3-1), libxext6, libxrender1, libxtst6
Recommends: caja, marco, mate-panel, mate-polkit, mate-settings-daemon
Provides: x-session-manager, mate-session-manager (= ${VER_UP})
Conflicts: mate-session-manager
Replaces: mate-session-manager
Breaks: mate-settings-daemon (<< 1.11.0)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Session manager of the MATE desktop environment
 MATE Session Manager 1.24.0-2ubuntu1 —
 official Ubuntu 20.04 arm64, KEMI
 repack of mate-session-manager. No
 exact-version same-source hard Depends
 to bundle. Official ELF stays under
 /usr. glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

grep -q '^Homepage: http://www.mate-desktop.org/$' "$STAGE/pkg/DEBIAN/control"
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"
grep -q 'debian-mate-default-settings (>= 1.24.0-2ubuntu1)' "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-session-manager/stage/pkg")
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
root = Path("/workspace/t142-20261112-mate-session-manager/stage/pkg")
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
p = Path("/workspace/t142-20261112-mate-session-manager/debs/kemi-mate-session-manager_1.24.0-2ubuntu1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-session-manager/upstream/mate-session-manager_1.24.0-2ubuntu1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-session-manager-control.txt"
python3 - "$OUT" << 'PYLIST'
import subprocess, sys
out = subprocess.check_output(["dpkg-deb", "-c", sys.argv[1]], text=True)
bad = [ln for ln in out.splitlines() if any(s in ln for s in (
    "mate-session-properties-128", "humanity-icon-theme", "debian-mate-default-settings"))]
if bad:
    raise SystemExit("PACKED_BAD:" + repr(bad))
if any("usr/bin/kemi-mate-session-manager" in ln for ln in out.splitlines()):
    raise SystemExit("INVENTED_LAUNCHER_PACKED")
assert any("usr/share/icons/hicolor/scalable/apps/mate-session-properties.svg" in ln for ln in out.splitlines())
assert any("usr/share/icons/hicolor/48x48/apps/mate-session-properties.png" in ln for ln in out.splitlines())
print("evidence_not_packed_official_icons_kept")
PYLIST

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-session-manager/stage/pkg")
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
test "${#ELFS[@]}" -eq 7
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-session-manager.json"
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
assert gmax == "2.17"
assert gv == 7 and gn == 0
assert cmax is None
assert cv == 0 and cn == 7
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
