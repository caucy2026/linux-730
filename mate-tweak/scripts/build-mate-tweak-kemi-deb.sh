#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-tweak 20.04.0-1ubuntu3 Architecture: all
# as kemi-mate-tweak. This is a real official
# lean GUI (Python/GTK) with official desktop
# files, not a transitional dummy, -dev, or
# docs package. Official U20 is Architecture:
# all (not amd64-only). Newest official U20
# pin: focal Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source
# field is absent and was not defaulted. No
# Debian epoch, no tilde. There is no official
# same-source exact-version hard Depends to
# bundle. Official different-source Depends
# stay Depends (including gir1.2-*, which are
# not packaged). Official Recommends
# mate-indicator-applet (>= 1.18.0) stay
# Recommends. Official Suggests stay Suggests.
# Official GUI has no Conflicts/Breaks.
# Versioned Provides: mate-tweak
# (= 20.04.0-1ubuntu3). Official files stay at
# official /usr paths. /opt/mate-tweak/* and
# /usr/bin/kemi-mate-tweak are symlinks only
# (official mate-tweak command exists). Official
# package ships no app icon (desktop Icon is
# the theme name user-desktop). Official 162
# .mo files live in this official GUI package
# and are packed; none invented. A 128×128
# evidence PNG rasterized from official Ubuntu
# 20.04 humanity-icon-theme 0.6.15
# places/128/user-desktop.svg (named by official
# mate-tweak.desktop) is used only as the mall
# CREATE --icon; it is not packed. Theme not
# bundled. Official GUI changelog.Debian.gz is
# a real file; official kept and also cp -L
# into the kemi doc dir. Official desktop
# Name=MATE Tweak is kept in
# mate-tweak.desktop and is mall app_name (the
# usual distinctive title). Official
# NoDisplay=true on marco-compton.desktop and
# marco-no-composite.desktop is kept; none
# invented on the main launcher. No official
# GenericName or official appdata. Official
# relative Exec rewritten absolute; TryExec
# added when missing. Official GUI has no
# maintainer scripts. Official lintian override
# is official packaging text and is packed;
# leftover-x86 skips official lintian
# overrides. desktop-database hooks are
# appended (no ELF, no official hicolor icons,
# no schemas, so no ldconfig / icon-cache /
# glib-compile-schemas). Probe: 0 unique
# packaged ELFs (Architecture: all, official
# Python scripts only); vacuous PASS vs 101.
# Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64/all Packages stanzas.
# Official Homepage
# https://github.com/ubuntu-mate/mate-tweak is
# copied exactly. No librarian URL and no
# .buildinfo this run. KEMI mall version_name
# 20.04.0-1ubuntu3kemi1 is 21 chars. No epoch,
# no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-tweak
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-tweak
VER_UP=20.04.0-1ubuntu3
VER_NAME=20.04.0-1ubuntu3kemi1
VER_DEB=20.04.0-1ubuntu3kemi1
ARCH=all
OFF_GUI="$ROOT/upstream/mate-tweak_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "20.04.0-1ubuntu3kemi1"
assert len(s) == 21, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-tweak" ]; then
  rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/mate-tweak"
ln -s /usr/bin/mate-tweak "$STAGE/pkg/opt/mate-tweak/mate-tweak"
ln -s mate-tweak "$STAGE/pkg/usr/bin/kemi-mate-tweak"
test -x "$STAGE/pkg/usr/bin/mate-tweak"
test -L "$STAGE/pkg/opt/mate-tweak/mate-tweak"
test -L "$STAGE/pkg/usr/bin/kemi-mate-tweak"
test -x "$STAGE/pkg/usr/bin/marco-compton"
test -x "$STAGE/pkg/usr/bin/marco-no-composite"
test -x "$STAGE/pkg/usr/lib/mate-tweak/mate-tweak-helper"
test -f "$STAGE/pkg/usr/share/lintian/overrides/mate-tweak"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 162

test -f "$STAGE/pkg/usr/share/doc/mate-tweak/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-tweak/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-tweak/stage/pkg")
desktops = sorted((root / "usr/share/applications").glob("*.desktop"))
assert [p.name for p in desktops] == [
    "marco-compton.desktop",
    "marco-no-composite.desktop",
    "mate-tweak.desktop",
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

for p in desktops:
    text = p.read_text()
    keys = untranslated_keys(text)
    if p.name == "mate-tweak.desktop":
        assert "Name=MATE Tweak" in text
        assert "Icon=user-desktop" in text
        assert "NoDisplay" not in keys
        assert "GenericName" not in keys
    else:
        assert "Name=Marco" in text
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

main = (root / "usr/share/applications/mate-tweak.desktop").read_text()
assert "Name=MATE Tweak" in main
assert "Icon=user-desktop" in main
assert "Exec=/usr/bin/mate-tweak" in main
assert "TryExec=/usr/bin/mate-tweak" in main
assert "NoDisplay" not in untranslated_keys(main)
comp = (root / "usr/share/applications/marco-compton.desktop").read_text()
assert "Exec=/usr/bin/marco-compton" in comp
assert "TryExec=/usr/bin/marco-compton" in comp
assert "NoDisplay=true" in comp
noc = (root / "usr/share/applications/marco-no-composite.desktop").read_text()
assert "Exec=/usr/bin/marco --no-composite" in noc
assert "TryExec=/usr/bin/marco" in noc
assert "NoDisplay=true" in noc
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-tweak/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-tweak/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-tweak (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-tweak 20.04.0-1ubuntu3 all, KEMI
    mall linuxpkg repack. No same-source
    exact-version hard Depends to bundle.
    Official files stay under /usr. Official
    desktop Name=MATE Tweak kept; mall
    app_name=MATE Tweak.
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
if grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"; then
  echo "UNEXPECTED_LDCONFIG" >&2
  exit 1
fi
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'user-desktop-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
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
Depends: dconf-cli, gir1.2-gtk-3.0, gir1.2-notify-0.7, mate-panel (>= 1.18.0), mesa-utils, python3 (>= 3.3), python3-distro, python3-gi, python3-psutil, python3-setproctitle, x11-xserver-utils, python3-pkg-resources, python3:any
Recommends: mate-indicator-applet (>= 1.18.0)
Suggests: compton, ayatana-indicator-application | indicator-application, ayatana-indicator-datetime | indicator-datetime, ayatana-indicator-messages | indicator-messages, ayatana-indicator-sound | indicator-sound, ayatana-indicator-session | indicator-session, ayatana-indicator-power | indicator-power
Provides: mate-tweak (= ${VER_UP})
Conflicts: mate-tweak
Replaces: mate-tweak
Homepage: https://github.com/ubuntu-mate/mate-tweak
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE desktop tweak tool
 MATE Tweak 20.04.0-1ubuntu3 — official
 Ubuntu 20.04 all, KEMI repack of
 mate-tweak. No same-source exact-version
 hard Depends to bundle. Official
 Recommends and Suggests kept.
 glibc≤2.31 (Ubuntu 20.04). gork.bot协助开发.
EOF

grep -q '^Homepage: https://github.com/ubuntu-mate/mate-tweak$' "$STAGE/pkg/DEBIAN/control"
grep -q "^Version: ${VER_DEB}$" "$STAGE/pkg/DEBIAN/control"
grep -q "^Architecture: all$" "$STAGE/pkg/DEBIAN/control"

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-tweak/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
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
root = Path("/workspace/t142-20261112-mate-tweak/stage/pkg")
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
p = Path("/workspace/t142-20261112-mate-tweak/debs/kemi-mate-tweak_20.04.0-1ubuntu3kemi1_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-tweak/upstream/mate-tweak_20.04.0-1ubuntu3_all.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-tweak-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'user-desktop-128|humanity-icon-theme'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_and_theme_not_packed"

python3 - << 'PYELF'
import json
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-tweak/stage/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
print("ELF_COUNT", len(elfs))
assert len(elfs) == 0, elfs
# Vacuous 0-ELF probe PASS: official Architecture: all, Python scripts only.
# Do not call probe_elf.py with no --elf. Do not rank a null requiredGlibcxx as a max.
report = Path("/workspace/t142-20261112-mate-tweak/probe/kemi-mate-tweak.json")
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
