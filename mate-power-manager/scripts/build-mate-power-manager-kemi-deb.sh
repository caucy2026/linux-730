#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-power-manager 1.24.1-0ubuntu1 Architecture: arm64
# as kemi-mate-power-manager. Official same-source
# mate-power-manager-common is an exact-version
# hard Depends (= 1.24.1-0ubuntu1) and is bundled.
# Newest official U20 pin: focal Release universe
# only; not in focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source field
# is absent and was not defaulted; sibling stanza
# lists Source: mate-power-manager. No Debian
# epoch, no tilde. Official different-source
# Depends stay Depends. Official control has no
# Recommends. Official Suggests mate-polkit stay
# Suggests. Official common Breaks/Replaces
# mate-power-manager (<< 1.9.0) are kept. No
# official same-source gir / -dev / transitional
# dummy. Versioned Provides: mate-power-manager
# (= 1.24.1-0ubuntu1) and
# mate-power-manager-common (= 1.24.1-0ubuntu1).
# Official user-facing binaries stay at official
# /usr paths (mate-power-manager,
# mate-power-preferences, mate-power-statistics,
# applets, and /usr/sbin/mate-power-backlight-helper).
# /opt/mate-power-manager/* are symlinks only.
# Also /usr/bin/kemi-mate-power-manager →
# mate-power-manager. Official common ships 128
# official .mo; none invented. Official packages
# ship app icons including official 128 PNG
# mate-power-manager.png (packed once at the
# official path and used as mall CREATE --icon).
# Official SVG and in-app status/action/help
# artwork stay official and are not used as the
# mall icon. Official GUI changelog.Debian.gz is
# a real file and is kept official; also copied
# with cp -L into the kemi doc dir. Official
# common changelog is a different real file and
# is kept at its official path. Official desktop
# Names (Power Manager, Power Management, Power
# Statistics) are kept. No official GenericName.
# No official appdata. Mall app_name is MATE
# Power Manager (the usual distinctive product
# title; polkit vendor is also MATE Power
# Manager). Official relative Exec rewritten
# absolute; TryExec added when missing. Official
# NoDisplay=false on mate-power-statistics.desktop
# is kept; no NoDisplay is invented where official
# has none. Official D-Bus and panel-applet
# Location/Exec are already absolute and are
# kept. Official conffiles for the autostart
# desktop are kept. Official GUI and common have
# no maintainer scripts. glib-compile-schemas,
# desktop-database, and icon-cache hooks are
# appended. No ldconfig (no bundled shared lib).
# Probe: 6 unique aarch64 ELFs, requiredGlibc
# 2.27, no GLIBCXX; PASS vs 101. Official SHA256
# + size matched ports.ubuntu.com and Aliyun
# ubuntu-ports (https) pool files and the Ubuntu
# 20.04 focal universe arm64 / all Packages
# stanzas. No librarian URL and no .buildinfo
# this run. KEMI mall version_name
# 1.24.1-0ubuntu1kemi1 is 20 chars. No epoch, no
# tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-power-manager
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-power-manager
VER_UP=1.24.1-0ubuntu1
VER_NAME=1.24.1-0ubuntu1kemi1
VER_DEB=1.24.1-0ubuntu1kemi1
ARCH=arm64
OFF_GUI="$DL/mate-power-manager_${VER_UP}_arm64.deb"
OFF_COMMON="$DL/mate-power-manager-common_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "1.24.1-0ubuntu1kemi1"
assert len(s) == 20, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-power-manager" ]; then
  rm -rf "$UNPACK/gui"
  mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -d "$UNPACK/common/usr/share/glib-2.0/schemas" ]; then
  rm -rf "$UNPACK/common"
  mkdir -p "$UNPACK/common"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
fi

# pack official GUI + bundled exact-version same-source common
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/common/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
# official conffiles kept
cp -a "$UNPACK/gui/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

# official ELF stays at official path; /opt and kemi-* are symlinks only
mkdir -p "$STAGE/pkg/opt/mate-power-manager"
ln -s /usr/bin/mate-power-manager "$STAGE/pkg/opt/mate-power-manager/mate-power-manager"
ln -s mate-power-manager "$STAGE/pkg/usr/bin/kemi-mate-power-manager"
test -x "$STAGE/pkg/usr/bin/mate-power-manager"
test -x "$STAGE/pkg/usr/bin/mate-power-preferences"
test -x "$STAGE/pkg/usr/bin/mate-power-statistics"
test -x "$STAGE/pkg/usr/sbin/mate-power-backlight-helper"
test -L "$STAGE/pkg/opt/mate-power-manager/mate-power-manager"
test -L "$STAGE/pkg/usr/bin/kemi-mate-power-manager"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-power-manager/stage/pkg")
desktops = [
    root / "etc/xdg/autostart/mate-power-manager.desktop",
    root / "usr/share/applications/mate-power-preferences.desktop",
    root / "usr/share/applications/mate-power-statistics.desktop",
]

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

expect_name = {
    "mate-power-manager.desktop": "Name=Power Manager",
    "mate-power-preferences.desktop": "Name=Power Management",
    "mate-power-statistics.desktop": "Name=Power Statistics",
}

for p in desktops:
    text = p.read_text()
    want = expect_name[p.name]
    assert want in text, (p, want)
    keys = untranslated_keys(text)
    if p.name == "mate-power-statistics.desktop":
        assert "NoDisplay=false" in text
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
        # insert TryExec after Exec
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
    assert want in new
    p.write_text(new)
    print("desktop_ok", p.name)

# assertions after rewrite
auto = (root / "etc/xdg/autostart/mate-power-manager.desktop").read_text()
assert "Exec=/usr/bin/mate-power-manager" in auto
assert "TryExec=/usr/bin/mate-power-manager" in auto
assert "Name=Power Manager" in auto
assert "Icon=mate-power-manager" in auto
assert "NoDisplay" not in untranslated_keys(auto)

pref = (root / "usr/share/applications/mate-power-preferences.desktop").read_text()
assert "Exec=/usr/bin/mate-power-preferences" in pref
assert "TryExec=/usr/bin/mate-power-preferences" in pref
assert "Name=Power Management" in pref
assert "Icon=mate-power-manager" in pref
assert "NoDisplay" not in untranslated_keys(pref)

stat = (root / "usr/share/applications/mate-power-statistics.desktop").read_text()
assert "Exec=/usr/bin/mate-power-statistics" in stat
assert "TryExec=/usr/bin/mate-power-statistics" in stat
assert "Name=Power Statistics" in stat
assert "Icon=mate-power-statistics" in stat
assert "NoDisplay=false" in stat
print("desktop_rewrite_ok")

# D-Bus already absolute
for svc in (root / "usr/share/dbus-1/services").glob("*.service"):
    t = svc.read_text()
    for line in t.splitlines():
        if line.startswith("Exec="):
            assert line.startswith("Exec=/"), (svc, line)
print("dbus_absolute_ok")
PYDESK

# official GUI changelog is a real file; keep it and also cp -L into kemi doc
mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
test ! -L "$STAGE/pkg/usr/share/doc/mate-power-manager/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-power-manager/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-power-manager/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
# official common changelog stays at official path
test -f "$STAGE/pkg/usr/share/doc/mate-power-manager-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-power-manager-common/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-power-manager (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-power-manager 1.24.1-0ubuntu1 arm64,
    KEMI mall linuxpkg repack, bundling official
    same-source exact-version
    mate-power-manager-common (= 1.24.1-0ubuntu1).
    Official ELF stays under /usr. Official
    desktop Names kept; mall app_name=MATE
    Power Manager.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; append hooks (quoted heredoc)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
# End automatically added section
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas || true
	fi
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_ok"

# evidence 128 used for CREATE lives under evidence/; official 128 PNG is packed at official path only
if find "$STAGE/pkg" -name 'mate-power-manager-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_PACKED_AS_EXTRA" >&2
  exit 1
fi
test -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/mate-power-manager.png"
echo "mo_count $(find "$STAGE/pkg" -name '*.mo' | wc -l)"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: default-dbus-session-bus | dbus-session-bus, mate-notification-daemon | notification-daemon, policykit-1, systemd | elogind | consolekit, upower, libc6 (>= 2.27), libcairo2 (>= 1.10.0), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.2), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.88), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.39.4), libgtk-3-0 (>= 3.21.4), libmate-panel-applet-4-1 (>= 1.18), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.22.0), libpangocairo-1.0-0 (>= 1.14.0), libupower-glib3 (>= 0.99.8), libx11-6, libxext6, libxrandr2 (>= 2:1.2.99.2), dconf-gsettings-backend | gsettings-backend
Suggests: mate-polkit
Provides: mate-power-manager (= ${VER_UP}), mate-power-manager-common (= ${VER_UP})
Conflicts: mate-power-manager, mate-power-manager-common
Replaces: mate-power-manager, mate-power-manager-common
Breaks: mate-power-manager (<< 1.9.0)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: power management tool for the MATE desktop
 MATE Power Manager 1.24.1-0ubuntu1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-power-manager, bundling official
 mate-power-manager-common. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-power-manager/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
        continue
    try:
        st = p.lstat()
    except FileNotFoundError:
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

python3 - << 'PYLIT'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-power-manager/stage/pkg")
for p in list(root.rglob("*.desktop")):
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
p = Path("/workspace/t142-20261112-mate-power-manager/debs/kemi-mate-power-manager_1.24.1-0ubuntu1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-power-manager/dl/mate-power-manager_1.24.1-0ubuntu1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-power-manager-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'mate-power-manager-128.png'; then
  echo PACKED_EVIDENCE_NAME >&2
  exit 1
fi
echo "evidence_extra_name_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-power-manager/stage/pkg")
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
test "${#ELFS[@]}" -eq 6
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-power-manager.json"
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
assert gmax == "2.27"
assert gv == 6 and gn == 0
assert cmax is None
assert cv == 0 and cn == 6
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
