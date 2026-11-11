#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# network-manager-gnome 1.8.24-1ubuntu3
# Architecture: arm64 as
# kemi-network-manager-gnome. The wave title
# is nm-connection-editor; Ubuntu 20.04 has no
# standalone nm-connection-editor binary
# package. The official user-facing editor is
# /usr/bin/nm-connection-editor, shipped by
# network-manager-gnome (source
# network-manager-applet), which also ships
# /usr/bin/nm-applet. Bundles official
# same-source exact-version hard Depends
# libnma0 (= 1.8.24-1ubuntu3). libnma0 has no
# further exact-version same-source Depends.
# Official same-source gir1.2-nma-1.0 and
# libnma-dev are inspected and not packaged.
# Official Recommends stay Recommends.
# Official Suggests stay Suggests. Newer than
# focal Release 1.8.24-1ubuntu2; not in
# focal-security or focal-backports. No Debian
# epoch, no tilde. Official ELFs stay at
# official /usr paths. /opt/network-manager-gnome/*
# are symlinks only. Also
# /usr/bin/kemi-network-manager-gnome →
# nm-connection-editor. Official packages
# ship no .mo (Ubuntu language-pack split);
# none invented. Official editor desktop Icon
# is the theme name preferences-system-network.
# Official applet/status PNG and SVG icons
# stay at official paths and are packed once;
# they are not used as the mall icon. A
# 128×128 evidence PNG rasterized from
# official Ubuntu 20.04 humanity-icon-theme
# 0.6.15 categories/64/preferences-system-network.svg
# via Chrome headless
# --default-background-color=00000000 lives at
# evidence/preferences-system-network-128.png
# and is used only as the mall CREATE --icon;
# it is not shipped in the deb. The theme
# package is not bundled. Official GUI
# changelog.Debian.gz is a symlink into
# bundled libnma0 and is kept (it resolves
# after bundling); the real official changelog
# is also copied with cp -L. Official desktop
# Name=Advanced Network Configuration is kept.
# Official appdata <name> is NetworkManager
# (project/service name, not used as mall
# app_name). Official relative Exec values
# are rewritten absolute; TryExec is added.
# Official libnma0 shlibs, symbols and
# activate-noawait ldconfig triggers are kept.
# Icon-cache, desktop-database, glib-compile-schemas
# and ldconfig hooks are appended. Probe: 3
# unique aarch64 ELFs, requiredGlibc 2.17
# (3 versioned, 0 null), no GLIBCXX
# (0 versioned, 3 null); None-safe; PASS vs
# 101 (glibc <= 2.31). Official SHA256 + size
# matched ports.ubuntu.com and Aliyun
# ubuntu-ports pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza.
# No librarian URL and no .buildinfo this run
# (pool 404). KEMI mall version_name
# 1.8.24-1ubuntu3kemi1 is 20 chars. No epoch,
# no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-nm-connection-editor
VER_UP=1.8.24-1ubuntu3
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-network-manager-gnome
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/network-manager-gnome}"
UNPACK_LIB="${UNPACK_LIB:-$ROOT/unpack-official/libnma0}"
GUI_DEB="$DL/network-manager-gnome_1.8.24-1ubuntu3_arm64.deb"
LIB_DEB="$DL/libnma0_1.8.24-1ubuntu3_arm64.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 301728
echo "ceb3e2ece66e79d40368008456ca0f1ff63a51e9499e10af276d6c9873b1a7ae  $GUI_DEB" | sha256sum -c -
test -f "$LIB_DEB" && test "$(stat -c%s "$LIB_DEB")" = 84624
echo "a92a2a2cd57b85ae5982b16447783b3a12e9f33f81160944e27e1a38c1e64e60  $LIB_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/nm-connection-editor"
test -x "$UNPACK_GUI/usr/bin/nm-applet"
test -f "$UNPACK_LIB/usr/lib/aarch64-linux-gnu/libnma.so.0.0.0"
test -L "$UNPACK_LIB/usr/lib/aarch64-linux-gnu/libnma.so.0"
test -f "$UNPACK_GUI/usr/share/applications/nm-connection-editor.desktop"
test -f "$UNPACK_GUI/usr/share/metainfo/nm-connection-editor.appdata.xml"
test -L "$UNPACK_GUI/usr/share/doc/network-manager-gnome/changelog.Debian.gz"
test -f "$UNPACK_LIB/usr/share/doc/libnma0/changelog.Debian.gz"
test ! -L "$UNPACK_LIB/usr/share/doc/libnma0/changelog.Debian.gz"
test -f "$ROOT/evidence/preferences-system-network-128.png"
test -f "$ROOT/evidence/preferences-system-network.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/preferences-system-network-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "a5b763ffc5643f0df8b770af5dc8c9680b75f26528c649b40f07b37d7ba35911"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/preferences-system-network.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "f87e90ee41a1d69bf12a70792c529816364bf6b7b6015dd1c7d8f847c8e5592d"
icons = list(Path("$UNPACK_GUI/usr/share/icons").rglob("*"))
n = sum(1 for x in icons if x.is_file() and x.suffix.lower() in {".png", ".svg"})
assert n == 82, n
mos = list(Path("$UNPACK_GUI").rglob("*.mo")) + list(Path("$UNPACK_LIB").rglob("*.mo"))
assert len(mos) == 0, len(mos)
appdata = Path("$UNPACK_GUI/usr/share/metainfo/nm-connection-editor.appdata.xml").read_text()
assert "<name>NetworkManager</name>" in appdata
print("official_icons_82_no_mo_appdata_ok")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/network-manager-gnome"

cp -a "$UNPACK_LIB/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_GUI/etc" "$STAGE/pkg/etc"
chmod 0755 "$STAGE/pkg/usr/bin/nm-connection-editor" "$STAGE/pkg/usr/bin/nm-applet"
cp -a "$UNPACK_GUI/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"
cp -a "$UNPACK_LIB/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$UNPACK_LIB/DEBIAN/symbols" "$STAGE/pkg/DEBIAN/symbols"
cp -a "$UNPACK_LIB/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

test -L "$STAGE/pkg/usr/share/doc/network-manager-gnome/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/network-manager-gnome/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libnma0/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnma.so.0"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libnma.so.0.0.0"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'preferences-system-network-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi
# do not pack gir or -dev
test ! -d "$STAGE/pkg/usr/share/gir-1.0"
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pkgconfig/libnma.pc"

# probe staged unique non-symlink ELFs
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
test "${#ELFS[@]}" = 3
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-network-manager-gnome.json"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
d = json.loads(Path("$REPORT").read_text())
files = d.get("files") or []
assert len(files) == 3, len(files)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
# None-safe: do not rank a null as a max
versioned = [v for v in glibcs if v is not None]
assert versioned and max(versioned, key=lambda s: tuple(int(x) for x in s.split("."))) == "2.17"
assert gn == 0 and gv == 3
assert cv == 0 and cn == 3
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=3 requiredGlibc=2.17 (3 versioned, 0 null); requiredGlibcxx none (0 versioned, 3 null, not ranked as a max); configuredLimitsSatisfied=true")
# write summary fields into report
d["n_elf"] = 3
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
Path("$REPORT").write_text(json.dumps(d, indent=2) + "\n")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/network-manager-gnome/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_LIB/usr/share/doc/libnma0/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "0841bbe4060e7a0e20890de0212122307ceb9745515f2960a19d4df631364099"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/nm-connection-editor.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/nm-connection-editor.desktop"
export UNPACK_APPLET="$UNPACK_GUI/usr/share/applications/nm-applet.desktop"
export STAGE_APPLET="$STAGE/pkg/usr/share/applications/nm-applet.desktop"
export UNPACK_AUTOSTART="$UNPACK_GUI/etc/xdg/autostart/nm-applet.desktop"
export STAGE_AUTOSTART="$STAGE/pkg/etc/xdg/autostart/nm-applet.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path

def rewrite(src, dest, expect_name, expect_exec_cmd, expect_icon):
    text = Path(src).read_text()
    if not re.search(rf"^Name={re.escape(expect_name)}\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_NAME:" + src)
    if re.search(r"^GenericName=", text, flags=re.M):
        raise SystemExit("DESKTOP_GENERICNAME_UNEXPECTED:" + src)
    if not re.search(rf"^Icon={re.escape(expect_icon)}\s*$", text, flags=re.M):
        raise SystemExit("DESKTOP_ICON:" + src)
    m = re.search(r"^Exec=(\S+)", text, flags=re.M)
    if not m:
        raise SystemExit("DESKTOP_NO_EXEC:" + src)
    exec_val = m.group(1)
    if exec_val.startswith("/"):
        abs_exec = exec_val
    else:
        if "/" in exec_val:
            raise SystemExit("DESKTOP_RELATIVE_PATH:" + exec_val)
        abs_exec = "/usr/bin/" + exec_val
    if not abs_exec.endswith("/" + expect_exec_cmd):
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
        raise SystemExit("DESKTOP_LITERAL_GROUP:" + src)
    if f"Exec={abs_exec}" not in text or f"TryExec={abs_exec}" not in text:
        raise SystemExit("DESKTOP_REWRITE_FAIL:" + src)
    Path(dest).write_text(text)
    print("desktop_rewritten", dest, abs_exec)

rewrite(os.environ["UNPACK_DESKTOP"], os.environ["STAGE_DESKTOP"],
        "Advanced Network Configuration", "nm-connection-editor", "preferences-system-network")
rewrite(os.environ["UNPACK_APPLET"], os.environ["STAGE_APPLET"],
        "Network", "nm-applet", "nm-device-wireless")
rewrite(os.environ["UNPACK_AUTOSTART"], os.environ["STAGE_AUTOSTART"],
        "Network", "nm-applet", "nm-device-wireless")
print("desktops_ok")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-nm-connection-editor/scripts/build-nm-connection-editor-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/nm-connection-editor\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/nm-connection-editor "$STAGE/pkg/opt/network-manager-gnome/nm-connection-editor"
ln -sf /usr/bin/nm-applet "$STAGE/pkg/opt/network-manager-gnome/nm-applet"
ln -sf nm-connection-editor "$STAGE/pkg/usr/bin/kemi-network-manager-gnome"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg"}:
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
kemi-network-manager-gnome (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    network-manager-gnome 1.8.24-1ubuntu3
    arm64, KEMI mall linuxpkg repack of the
    official package that ships
    nm-connection-editor (Ubuntu 20.04 has no
    standalone nm-connection-editor package).
    Bundles official same-source exact-version
    libnma0 (= 1.8.24-1ubuntu3). Official
    different-source Depends stay Depends.
    Official Recommends stay Recommends.
    Official Suggests stay Suggests. Official
    gir1.2-nma-1.0 and libnma-dev inspected,
    not packaged. Official ELFs stay at
    official paths; /opt/network-manager-gnome/*
    are symlinks. Also
    /usr/bin/kemi-network-manager-gnome →
    nm-connection-editor. Official desktop
    Name=Advanced Network Configuration kept;
    relative Exec rewritten absolute; TryExec
    added. Official GUI changelog symlink into
    bundled libnma0 is kept and resolves; the
    real official changelog was also copied
    with cp -L. Official editor desktop Icon
    is the theme name
    preferences-system-network; official
    applet/status icons stay official. A
    128×128 evidence PNG rasterized from
    official Ubuntu 20.04 humanity-icon-theme
    0.6.15 is used only as mall CREATE --icon
    and is not packed. Theme package is not
    bundled. Official packages ship no .mo;
    none invented. Official libnma0 shlibs,
    symbols and ldconfig triggers kept; icon-
    cache, desktop-database, glib-compile-schemas
    and ldconfig hooks appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Advanced Network Configuration — official
Ubuntu 20.04 (focal-updates main)
network-manager-gnome 1.8.24-1ubuntu3
Architecture: arm64, KEMI repack. The wave
title is nm-connection-editor; Ubuntu 20.04
has no standalone nm-connection-editor
binary package. Official user-facing editor
is /usr/bin/nm-connection-editor, shipped by
network-manager-gnome together with
/usr/bin/nm-applet. Official ELFs stay under
/usr. /opt/network-manager-gnome/* are
symlinks. Bundles official same-source
exact-version libnma0 (= 1.8.24-1ubuntu3).
Official different-source Depends stay
Depends. Official Recommends stay Recommends.
Official Suggests stay Suggests. Official
gir1.2-nma-1.0 and libnma-dev inspected, not
packaged. Official packages ship no .mo
(Ubuntu language-pack split); none invented.
Official editor desktop Icon is the theme
name preferences-system-network; official
applet/status icons stay official. A 128×128
evidence PNG rasterized from official Ubuntu
20.04 humanity-icon-theme 0.6.15 is used only
as mall CREATE --icon and is not packed.
Theme package is not bundled. Official
desktop Name=Advanced Network Configuration
is kept; mall app_name is Advanced Network
Configuration (official desktop Name, the
usual user-facing title of this GUI).
Official appdata <name> is NetworkManager
(the project/service name) and is not used
as mall app_name. Official GenericName is
absent. Probe: 3 unique aarch64 ELFs,
requiredGlibc 2.17 (3 versioned, 0 null), no
GLIBCXX (0 versioned, 3 null, not ranked as
a max); PASS vs Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04
focal-updates main network-manager-gnome
1.8.24-1ubuntu3 (arm64), newer than focal
Release 1.8.24-1ubuntu2. Official SHA256 +
size matched ports.ubuntu.com and Aliyun
ubuntu-ports pool files and the
focal-updates main Packages stanza. No
librarian URL this run.
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
Depends: libappindicator3-1 (>= 0.4.90), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.2), libgtk-3-0 (>= 3.10), libjansson4 (>= 2.0.1), libmm-glib0 (>= 0.7.991), libnm0 (>= 1.11.3), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libsecret-1-0 (>= 0.7), libselinux1 (>= 2.1.9), dconf-gsettings-backend | gsettings-backend, network-manager (>= 1.8), gnome-shell | policykit-1-gnome | polkit-1-auth-agent, default-dbus-session-bus | dbus-session-bus, libgck-1-0 (>= 3.3.90), libgcr-base-3-1 (>= 3.14)
Recommends: gnome-shell | notification-daemon, gnome-keyring, mobile-broadband-provider-info, iso-codes
Suggests: network-manager-openconnect-gnome, network-manager-openvpn-gnome, network-manager-vpnc-gnome, network-manager-pptp-gnome
Conflicts: network-manager-gnome, libnma0
Replaces: network-manager-gnome, libnma0
Provides: network-manager-gnome (= 1.8.24-1ubuntu3), libnma0 (= 1.8.24-1ubuntu3)
Homepage: https://www.gnome.org/projects/NetworkManager/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: network management framework (GNOME frontend)
 Advanced Network Configuration ${VER_UP} —
 official Ubuntu 20.04 arm64, KEMI repack of
 network-manager-gnome (ships
 nm-connection-editor). Bundles official
 libnma0. glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Official packages ship no maintainer scripts.
# Keep official shlibs/symbols/ldconfig triggers.
# Append hooks with a quoted heredoc so $1 is not expanded.
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
if command -v ldconfig >/dev/null 2>&1; then
	ldconfig || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
if command -v ldconfig >/dev/null 2>&1; then
	ldconfig || true
fi
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'activate-noawait ldconfig' "$STAGE/pkg/DEBIAN/triggers"
echo "hooks_ok"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-network-manager-gnome_1.8.24-1ubuntu3kemi1_arm64.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'Version: 1.8.24-1ubuntu3kemi1' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'network-manager-gnome (= 1.8.24-1ubuntu3)' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'libnma0 (= 1.8.24-1ubuntu3)' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
! grep -q 'Depends:.*libnma0' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'Recommends: gnome-shell' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"
grep -q 'Suggests: network-manager-openconnect-gnome' "$ROOT/evidence/kemi-network-manager-gnome-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/nm-connection-editor.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
assert "Name=Advanced Network Configuration" in desk
assert "Exec=/usr/bin/nm-connection-editor" in desk
assert "TryExec=/usr/bin/nm-connection-editor" in desk
assert "Icon=preferences-system-network" in desk
applet = Path("$CHECK/usr/share/applications/nm-applet.desktop").read_text()
assert "Name=Network" in applet
assert "Exec=/usr/bin/nm-applet" in applet
assert "TryExec=/usr/bin/nm-applet" in applet
auto = Path("$CHECK/etc/xdg/autostart/nm-applet.desktop").read_text()
assert "Exec=/usr/bin/nm-applet" in auto
assert "TryExec=/usr/bin/nm-applet" in auto
print("built_desktops_ok")
PY
test -x "$CHECK/usr/bin/nm-connection-editor"
test ! -L "$CHECK/usr/bin/nm-connection-editor"
test -x "$CHECK/usr/bin/nm-applet"
test ! -L "$CHECK/usr/bin/nm-applet"
test -L "$CHECK/usr/bin/kemi-network-manager-gnome"
test "$(readlink "$CHECK/usr/bin/kemi-network-manager-gnome")" = "nm-connection-editor"
test -L "$CHECK/opt/network-manager-gnome/nm-connection-editor"
test "$(readlink "$CHECK/opt/network-manager-gnome/nm-connection-editor")" = "/usr/bin/nm-connection-editor"
test -f "$CHECK/usr/lib/aarch64-linux-gnu/libnma.so.0.0.0"
test -L "$CHECK/usr/lib/aarch64-linux-gnu/libnma.so.0"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
test "$(find "$CHECK/usr/share/icons" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 82
if find "$CHECK" -name 'preferences-system-network-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
test -L "$CHECK/usr/share/doc/network-manager-gnome/changelog.Debian.gz"
test -e "$CHECK/usr/share/doc/network-manager-gnome/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/libnma0/changelog.Debian.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$CHECK/usr/share/glib-2.0/schemas/org.gnome.nm-applet.gschema.xml"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
