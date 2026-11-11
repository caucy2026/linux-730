#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-utils 1.24.0-1 Architecture: arm64
# as kemi-mate-utils. Official same-source
# libmatedict6 is an exact-version hard Depends
# (= 1.24.0-1) and is bundled. Official
# same-source mate-utils-common is a range
# Depends (>= 1.24.0-1), not an exact-version
# hard Depends, and is not bundled (exact-version
# rule); it stays Depends. libmatedict-dev is
# inspected and not packaged. Newest official
# U20 pin: focal Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source
# field is absent and was not defaulted;
# sibling stanzas list Source: mate-utils. No
# Debian epoch, no tilde. Official
# different-source Depends stay Depends.
# Official control has no Recommends and no
# Suggests. Official lib Breaks/Replaces
# mate-utils (<< 1.8.0) are kept. Versioned
# Provides: mate-utils (= 1.24.0-1) and
# libmatedict6 (= 1.24.0-1). Official ELFs stay
# at official /usr paths. /opt/mate-utils/*
# are symlinks only to official binaries.
# There is no official mate-utils command, so
# no invented /usr/bin/kemi-mate-utils launcher
# is added. Official GUI and lib ship no app
# icon (desktop Icons are theme names or names
# that live only in unbundled common). Official
# common icons, 123 official .mo, schemas,
# appdata, man, and help are not packed; none
# are invented. A 128×128 evidence PNG
# rasterized from official Ubuntu 20.04
# humanity-icon-theme 0.6.15
# apps/128/accessories-dictionary.svg (named by
# official mate-dictionary.desktop) via Chrome
# headless --default-background-color=00000000
# lives at evidence/accessories-dictionary-128.png
# and is used only as the mall CREATE --icon;
# it is not packed. The theme package is not
# bundled. Official GUI changelog.Debian.gz is
# a dangling symlink into bundled libmatedict6;
# the official symlink is kept (resolves after
# merge) and the real file is also copied with
# cp -L into the kemi doc dir. Official desktop
# Names are kept. No official GenericName. Official
# appdata <name> values live in unbundled common
# (inspected, not packed). Mall app_name is
# MATE Utilities (the usual distinctive suite
# title from official Description: tools
# bundled as MATE utilities). Official relative
# Exec rewritten absolute; TryExec added when
# missing. No official NoDisplay; none invented.
# Official GUI has no maintainer scripts.
# Official lib shlibs, symbols, and
# activate-noawait ldconfig triggers are kept.
# desktop-database and ldconfig hooks are
# appended. Probe: 8 unique aarch64 ELFs,
# requiredGlibc 2.29, no GLIBCXX; PASS vs 101.
# Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64 / all Packages stanzas.
# No librarian URL and no .buildinfo this run.
# KEMI mall version_name 1.24.0-1kemi1 is 13
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-utils
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-utils
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$DL/mate-utils_${VER_UP}_arm64.deb"
OFF_LIB="$DL/libmatedict6_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/lib" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-dictionary" ]; then
  rm -rf "$UNPACK/gui"
  mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi
if [ ! -f "$UNPACK/lib/usr/lib/aarch64-linux-gnu/libmatedict.so.6.0.7" ]; then
  rm -rf "$UNPACK/lib"
  mkdir -p "$UNPACK/lib"
  dpkg-deb -x "$OFF_LIB" "$UNPACK/lib"
  dpkg-deb -e "$OFF_LIB" "$UNPACK/lib/DEBIAN"
fi

# pack official GUI + bundled exact-version same-source lib; do not merge unbundled common
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/lib/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
# official lib packaging metadata kept
cp -a "$UNPACK/lib/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$UNPACK/lib/DEBIAN/symbols" "$STAGE/pkg/DEBIAN/symbols"
cp -a "$UNPACK/lib/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

# official ELF stays at official path; /opt is symlinks only
mkdir -p "$STAGE/pkg/opt/mate-utils"
for b in mate-dictionary mate-disk-image-mounter mate-disk-usage-analyzer mate-screenshot mate-search-tool mate-system-log; do
  test -x "$STAGE/pkg/usr/bin/$b"
  ln -s "/usr/bin/$b" "$STAGE/pkg/opt/mate-utils/$b"
  test -L "$STAGE/pkg/opt/mate-utils/$b"
done
test -L "$STAGE/pkg/usr/bin/mate-panel-screenshot"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmatedict.so.6.0.7"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libmatedict.so.6"
# do not invent /usr/bin/kemi-mate-utils (no official mate-utils command)
if [ -e "$STAGE/pkg/usr/bin/kemi-mate-utils" ]; then
  echo "INVENTED_KEMI_LAUNCHER" >&2
  exit 1
fi
# common must not be packed
if [ -d "$STAGE/pkg/usr/share/doc/mate-utils-common" ] || [ -d "$STAGE/pkg/usr/share/metainfo" ]; then
  echo "COMMON_PACKED" >&2
  exit 1
fi
if find "$STAGE/pkg" -name '*.mo' | grep -q .; then
  echo "INVENTED_OR_COMMON_MO" >&2
  exit 1
fi
# official GUI changelog symlink must resolve after lib merge
test -L "$STAGE/pkg/usr/share/doc/mate-utils/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/mate-utils/changelog.Debian.gz"

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t142-20261112-mate-utils/stage/pkg")
desktops = sorted((root / "usr/share/applications").glob("*.desktop"))
assert len(desktops) == 6, desktops

expect = {
    "mate-dictionary.desktop": ("Name=MATE Dictionary", "Icon=accessories-dictionary", "/usr/bin/mate-dictionary"),
    "mate-disk-image-mounter.desktop": ("Name=MATE Disk Image Mounter", "Icon=drive-removable-media", "/usr/bin/mate-disk-image-mounter"),
    "mate-disk-usage-analyzer.desktop": ("Name=MATE Disk Usage Analyzer", "Icon=mate-disk-usage-analyzer", "/usr/bin/mate-disk-usage-analyzer"),
    "mate-screenshot.desktop": ("Name=Take Screenshot", "Icon=applets-screenshooter", "/usr/bin/mate-screenshot"),
    "mate-search-tool.desktop": ("Name=MATE Search Tool", "Icon=system-search", "/usr/bin/mate-search-tool"),
    "mate-system-log.desktop": ("Name=Log File Viewer", "Icon=mate-system-log", "/usr/bin/mate-system-log"),
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
    assert "GenericName" not in keys
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
    assert "Exec=" + exec_abs in new or new.find("Exec=" + exec_abs + " ") >= 0
    assert "TryExec=" + exec_abs in new
    assert "NoDisplay" not in untranslated_keys(new)
    p.write_text(new)
    print("desktop_ok", p.name)

# extra Exec argument assertions
shot = (root / "usr/share/applications/mate-screenshot.desktop").read_text()
assert "Exec=/usr/bin/mate-screenshot --interactive" in shot
mnt = (root / "usr/share/applications/mate-disk-image-mounter.desktop").read_text()
assert "Exec=/usr/bin/mate-disk-image-mounter %U" in mnt
print("desktop_rewrite_ok")
PYDESK

# official changelog dangling into bundled lib; keep official symlink and also cp -L
mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/mate-utils/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-utils/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test -f "$STAGE/pkg/usr/share/doc/libmatedict6/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libmatedict6/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-utils (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-utils 1.24.0-1 arm64, KEMI mall
    linuxpkg repack, bundling official
    same-source exact-version libmatedict6
    (= 1.24.0-1). Official mate-utils-common
    (>= 1.24.0-1) is a range Depends and was
    not bundled. Official ELF stays under
    /usr. Official desktop Names kept; mall
    app_name=MATE Utilities.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# official lib triggers kept; append desktop-database and ldconfig (quoted)
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

if find "$STAGE/pkg" \( -name 'accessories-dictionary-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
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
Depends: mate-desktop-common, mate-utils-common (>= 1.24.0-1), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.10.0), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.2), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libgtop-2.0-11 (>= 2.22.3), libice6 (>= 1:1.0.0), libmate-panel-applet-4-1 (>= 1.18), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libsm6, libudisks2-0 (>= 2.0.0), libx11-6, libxext6, zlib1g (>= 1:1.1.4)
Provides: mate-utils (= ${VER_UP}), libmatedict6 (= ${VER_UP})
Conflicts: mate-utils, libmatedict6
Replaces: mate-utils, libmatedict6
Breaks: mate-utils (<< 1.8.0)
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE desktop utilities
 MATE Utilities 1.24.0-1 — official Ubuntu
 20.04 arm64, KEMI repack of mate-utils,
 bundling official libmatedict6. Official
 mate-utils-common stays Depends (range,
 not bundled). glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-utils/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
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
root = Path("/workspace/t142-20261112-mate-utils/stage/pkg")
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
p = Path("/workspace/t142-20261112-mate-utils/debs/kemi-mate-utils_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-utils/dl/mate-utils_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-utils-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'accessories-dictionary-128|humanity-icon-theme|mate-utils-common'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_and_common_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-utils/stage/pkg")
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
REPORT="$ROOT/probe/kemi-mate-utils.json"
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
