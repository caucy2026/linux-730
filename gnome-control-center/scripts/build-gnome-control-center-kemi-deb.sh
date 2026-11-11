#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates /
# focal-security identical) gnome-control-center
# 1:3.36.5-0ubuntu4.1 Architecture: arm64 as
# kemi-gnome-control-center. Official same-source
# gnome-control-center-data is a range Depends
# (<< 1:3.37 and >= 1:3.36.5-0ubuntu4.1), not an
# exact-version hard Depends, and is not bundled;
# it stays Depends. Official same-source
# gnome-control-center-faces is a Recommends and
# stays Recommends (not bundled). Official
# gnome-control-center-dev is inspected and not
# packaged. Newest official U20 pin: identical
# 1:3.36.5-0ubuntu4.1 in focal-updates and
# focal-security main, newer than focal Release
# 1:3.36.1-1ubuntu5. Official GUI stanza Source
# field is absent and was not defaulted; sibling
# stanzas list Source: gnome-control-center.
# Official GUI control has no Homepage; none is
# invented. Debian epoch 1: is omitted from mall
# version_name and the deb filename, kept in dpkg
# Version. Official different-source Depends stay
# Depends. Official Recommends stay Recommends;
# official Suggests stay Suggests. Official GUI
# has no Conflicts/Breaks/Replaces/Provides;
# kemi Adds versioned Provides gnome-control-center
# (= 1:3.36.5-0ubuntu4.1) plus Conflicts/Replaces
# of the official name. Official ELFs stay at
# official /usr paths. /opt/gnome-control-center/*
# and /usr/bin/kemi-gnome-control-center are
# symlinks only (official gnome-control-center
# command exists). Official GUI ships no app icon;
# official org.gnome.Settings icons live only in
# unbundled data and are not packed. Official data
# .mo (none), schemas, pixmaps, and icons are not
# packed; none invented. A 128×128 evidence PNG
# rasterized from official U20
# gnome-control-center-data
# org.gnome.Settings.svg (named by official
# gnome-control-center.desktop; official humanity
# 0.6.15 has no org.gnome.Settings) is used only
# as the mall CREATE --icon; it is not packed.
# Data and theme are not bundled. Official GUI
# changelog.Debian.gz is a real file; official
# kept and also cp -L into the kemi doc dir.
# Official data changelog is a different real
# file and is not packed. Official desktop
# Name=Settings is kept in
# gnome-control-center.desktop. Official appdata
# <name>=GNOME Settings is packed (it lives in
# the official GUI tree) and is mall app_name
# (more distinctive than Settings). No official
# GenericName. Official relative Exec rewritten
# absolute; TryExec added when missing. Official
# NoDisplay=true on panel desktops is kept; none
# invented on the main launcher. Official GUI has
# no maintainer scripts. desktop-database hooks
# are appended (no schemas or hicolor icons
# packed, no bundled shared lib, so no
# glib-compile-schemas / icon-cache / ldconfig).
# Probe: 4 unique aarch64 ELFs, requiredGlibc
# 2.29, no GLIBCXX; PASS vs 101. Official SHA256
# + size matched ports.ubuntu.com and Aliyun
# ubuntu-ports (https) pool files and the Ubuntu
# 20.04 focal-updates/focal-security main arm64 /
# all Packages stanzas. No librarian URL and no
# .buildinfo this run. KEMI mall version_name
# 3.36.5-0ubuntu4.1kemi1 is 22 chars. Epoch kept
# only in dpkg Version. No tilde, no shortening
# needed. gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-control-center
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-gnome-control-center
VER_UP=3.36.5-0ubuntu4.1
VER_UP_EPOCH=1:3.36.5-0ubuntu4.1
VER_NAME=3.36.5-0ubuntu4.1kemi1
VER_DEB=1:3.36.5-0ubuntu4.1kemi1
ARCH=arm64
OFF_GUI="$ROOT/upstream/gnome-control-center_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "3.36.5-0ubuntu4.1kemi1"
assert len(s) == 22, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/gnome-control-center" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/gnome-control-center"
ln -s /usr/bin/gnome-control-center "$STAGE/pkg/opt/gnome-control-center/gnome-control-center"
ln -s gnome-control-center "$STAGE/pkg/usr/bin/kemi-gnome-control-center"
test -x "$STAGE/pkg/usr/bin/gnome-control-center"
test -L "$STAGE/pkg/opt/gnome-control-center/gnome-control-center"
test -L "$STAGE/pkg/usr/bin/kemi-gnome-control-center"
test -f "$STAGE/pkg/usr/share/metainfo/gnome-control-center.appdata.xml"

if [ -d "$STAGE/pkg/usr/share/doc/gnome-control-center-data" ]; then
  echo "DATA_PACKED" >&2
  exit 1
fi
if [ -d "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" ]; then
  echo "DATA_ICONS_PACKED" >&2
  exit 1
fi
if find "$STAGE/pkg" -name '*.mo' | grep -q .; then
  echo "INVENTED_OR_DATA_MO" >&2
  exit 1
fi
test -f "$STAGE/pkg/usr/share/doc/gnome-control-center/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/gnome-control-center/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-gnome-control-center/stage/pkg")
desktops = sorted((root / "usr/share/applications").glob("*.desktop"))
assert len(desktops) == 34, [p.name for p in desktops]

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
    if p.name == "gnome-control-center.desktop":
        assert "Name=Settings" in text
        assert "Icon=org.gnome.Settings" in text
        assert "NoDisplay" not in keys
        assert "GenericName=" not in "\n".join(k + "=" for k in keys if k == "GenericName")
        assert "GenericName" not in keys
    else:
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
    assert "Exec=/usr/bin/gnome-control-center" in new
    assert "TryExec=/usr/bin/gnome-control-center" in new
    if p.name == "gnome-control-center.desktop":
        assert "Name=Settings" in new
        assert "Icon=org.gnome.Settings" in new
        assert "NoDisplay" not in untranslated_keys(new)
        assert "Exec=/usr/bin/gnome-control-center\n" in new or new.endswith("Exec=/usr/bin/gnome-control-center")
    else:
        assert "NoDisplay=true" in new
    p.write_text(new)
    print("desktop_ok", p.name)

cc = (root / "usr/share/applications/gnome-control-center.desktop").read_text()
assert "Exec=/usr/bin/gnome-control-center" in cc
assert "TryExec=/usr/bin/gnome-control-center" in cc
assert "Name=Settings" in cc
apps = (root / "usr/share/applications/gnome-applications-panel.desktop").read_text()
assert "Exec=/usr/bin/gnome-control-center applications" in apps
assert "NoDisplay=true" in apps
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/gnome-control-center/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/gnome-control-center/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-control-center (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates /
    focal-security identical)
    gnome-control-center 1:3.36.5-0ubuntu4.1
    arm64, KEMI mall linuxpkg repack. Official
    gnome-control-center-data
    (>= 1:3.36.5-0ubuntu4.1, << 1:3.37) is a
    range Depends and was not bundled. Official
    gnome-control-center-faces stays Recommends.
    Official ELF stays under /usr. Official
    desktop Name=Settings kept; mall
    app_name=GNOME Settings (official appdata
    <name>). 合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
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
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -qv 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'org.gnome.Settings-128.png' -o -name 'org.gnome.Settings.svg' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_DATA_ICON_OR_THEME_PACKED" >&2
  exit 1
fi
echo "mo_count $(find "$STAGE/pkg" -name '*.mo' | wc -l)"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
# Official Depends / Recommends / Suggests copied exactly from official GUI control.
# No Homepage: official GUI control has none, not invented.
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: libaccountsservice0 (>= 0.6.40), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.10.0), libcheese-gtk25 (>= 3.18.0), libcheese8 (>= 3.28.0), libcolord-gtk1 (>= 0.1.24), libcolord2 (>= 1.4.3), libcups2 (>= 1.7.0), libepoxy0 (>= 1.0), libfontconfig1 (>= 2.12.6), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.57.2), libgnome-bluetooth13 (>= 3.18.2), libgnome-desktop-3-19 (>= 3.33.4), libgoa-1.0-0b (>= 3.25.3), libgoa-backend-1.0-1 (>= 3.10.0), libgsound0 (>= 1.0.1), libgtk-3-0 (>= 3.22.20), libgtop-2.0-11 (>= 2.22.3), libgudev-1.0-0 (>= 232), libibus-1.0-5 (>= 1.5.2), libkrb5-3 (>= 1.8+dfsg), libmm-glib0 (>= 0.7.991), libnm0 (>= 1.11.90), libnma0 (>= 1.1.90), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.18.0), libpolkit-gobject-1-0 (>= 0.103), libpulse-mainloop-glib0 (>= 0.99.1), libpulse0 (>= 0.99.1), libpwquality1 (>= 1.1.0), libsecret-1-0 (>= 0.7), libsmbclient (>= 2:4.0.3+dfsg1), libsnapd-glib1 (>= 1.57), libsoup2.4-1 (>= 2.41.90), libudisks2-0 (>= 2.0.0), libupower-glib3 (>= 0.99.8), libwacom2 (>= 1.1), libwayland-server0 (>= 1.0.2), libwhoopsie-preferences0 (>= 0.9), libx11-6, libxi6 (>= 2:1.2.99.4), libxml2 (>= 2.7.4), accountsservice, apg, colord (>= 0.1.30), desktop-file-utils, gnome-control-center-data (<< 1:3.37), gnome-control-center-data (>= 1:3.36.5-0ubuntu4.1), gnome-desktop3-data, gnome-settings-daemon (>= 3.29), gsettings-desktop-schemas (>= 3.31.0), language-selector-gnome (>= 0.179~), system-config-printer (>= 1.4), whoopsie-preferences
Recommends: cups-pk-helper, gnome-online-accounts (>= 3.25.3), gnome-user-docs, gkbd-capplet, ibus, iso-codes, libcanberra-pulse, mousetweaks, policykit-1, network-manager-gnome (>= 0.9.8), cracklib-runtime, pulseaudio-module-bluetooth, gnome-control-center-faces, rygel | rygel-tracker
Suggests: gnome-software | gnome-packagekit, gnome-user-share, realmd, gstreamer1.0-pulseaudio, libcanberra-gtk-module, libcanberra-gtk3-module, x11-xserver-utils
Provides: gnome-control-center (= ${VER_UP_EPOCH})
Conflicts: gnome-control-center
Replaces: gnome-control-center
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: utilities to configure the GNOME desktop
 GNOME Settings 3.36.5-0ubuntu4.1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 gnome-control-center. Official
 gnome-control-center-data stays Depends
 (range, not bundled). Official
 gnome-control-center-faces stays Recommends.
 glibc≤2.31 (Ubuntu 20.04). gork.bot协助开发.
EOF

# do not invent a Homepage
if grep -q '^Homepage:' "$STAGE/pkg/DEBIAN/control"; then
  echo "INVENTED_HOMEPAGE" >&2
  exit 1
fi
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-gnome-control-center/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
        continue
    # official lintian overrides may mention official amd64 tag paths;
    # official packaging text is not a leftover-x86 defect
    if "lintian/overrides" in str(p.as_posix()):
        continue
    # official Description / official copyright legal text is not a defect
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
root = Path("/workspace/t142-20261112-gnome-control-center/stage/pkg")
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
p = Path("/workspace/t142-20261112-gnome-control-center/debs/kemi-gnome-control-center_3.36.5-0ubuntu4.1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-gnome-control-center/upstream/gnome-control-center_3.36.5-0ubuntu4.1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
# epoch omitted from filename
assert "1:" not in p.name
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-gnome-control-center-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'org.gnome.Settings-128|humanity-icon-theme|gnome-control-center-data|gnome-control-center-faces|org.gnome.Settings.svg'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_and_data_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-gnome-control-center/stage/pkg")
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
test "${#ELFS[@]}" -eq 4
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-gnome-control-center.json"
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
assert gv == 4 and gn == 0
assert cmax is None
assert cv == 0 and cn == 4
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
