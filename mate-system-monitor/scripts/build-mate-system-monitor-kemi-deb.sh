#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-system-monitor 1.24.0-1 Architecture: arm64
# as kemi-mate-system-monitor. Official same-source
# mate-system-monitor-common is a range Depends
# (>= 1.24.0-1), not an exact-version hard Depends,
# and is not bundled (exact-version rule). It stays
# Depends. Newest official U20 pin: focal Release
# universe only; not in focal-updates,
# focal-security, or focal-backports. Official GUI
# stanza Source field is absent and was not
# defaulted; sibling stanza lists Source:
# mate-system-monitor. No Debian epoch, no tilde.
# Official different-source Depends stay Depends.
# Official Recommends gvfs stay Recommends.
# Official control has no Suggests. No official
# same-source gir / -dev / transitional dummy.
# Versioned Provides: mate-system-monitor
# (= 1.24.0-1). Official user-facing binary
# /usr/bin/mate-system-monitor is an aarch64 ELF
# and stays at the official path, as do
# msm-kill and msm-renice.
# /opt/mate-system-monitor/* are symlinks only.
# Also /usr/bin/kemi-mate-system-monitor →
# mate-system-monitor. Official GUI package
# ships no .mo (language-pack / common split);
# none are invented. Official packages ship no
# app icon (desktop Icon is the theme name
# utilities-system-monitor). Official common
# in-app pixmaps and help figures are not
# packed because common is not bundled, and
# are not used as the mall icon. A 128×128
# evidence PNG rasterized from official Ubuntu
# 20.04 humanity-icon-theme 0.6.15
# apps/48/utilities-system-monitor.svg (no
# official 128 in that theme) via Chrome
# headless --default-background-color=00000000
# lives at evidence/utilities-system-monitor-128.png
# and is used only as the mall CREATE --icon;
# it is not packed. The theme package is not
# bundled. Official GUI changelog.Debian.gz is
# a real file and is kept official; also
# copied with cp -L into the kemi doc dir.
# Official desktop Name=MATE System Monitor
# is kept. Official GenericName=System Monitor
# stays in the desktop file and is not used as
# mall app_name. Official appdata <name> (in
# unbundled common) is also MATE System
# Monitor. Official relative Exec and TryExec
# are rewritten absolute. No official
# NoDisplay; none is invented. Official GUI
# has no maintainer scripts. desktop-database
# hook is appended. Probe: 3 unique aarch64
# ELFs, requiredGlibc 2.29, requiredGlibcxx
# 3.4.21; PASS vs 101. Official SHA256 + size
# matched ports.ubuntu.com and Aliyun
# ubuntu-ports (https) pool files and the
# Ubuntu 20.04 focal universe arm64 / all
# Packages stanzas. No librarian URL and no
# .buildinfo this run. KEMI mall version_name
# 1.24.0-1kemi1 is 13 chars. No epoch, no
# tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-system-monitor
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-system-monitor
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$DL/mate-system-monitor_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/mate-system-monitor" ]; then
  rm -rf "$UNPACK/gui"
  mkdir -p "$UNPACK/gui"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
fi

# pack official GUI only; do not merge unbundled common
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

# official ELF stays at official path; /opt and kemi-* are symlinks only
mkdir -p "$STAGE/pkg/opt/mate-system-monitor"
ln -s /usr/bin/mate-system-monitor "$STAGE/pkg/opt/mate-system-monitor/mate-system-monitor"
ln -s mate-system-monitor "$STAGE/pkg/usr/bin/kemi-mate-system-monitor"
test -x "$STAGE/pkg/usr/bin/mate-system-monitor"
test -L "$STAGE/pkg/opt/mate-system-monitor/mate-system-monitor"
test -L "$STAGE/pkg/usr/bin/kemi-mate-system-monitor"
# common must not be packed
if [ -e "$STAGE/pkg/usr/share/mate-system-monitor-common" ] || [ -d "$STAGE/pkg/usr/share/doc/mate-system-monitor-common" ]; then
  echo "COMMON_PACKED" >&2
  exit 1
fi
if find "$STAGE/pkg" -name '*.mo' | grep -q .; then
  echo "INVENTED_OR_COMMON_MO" >&2
  exit 1
fi

python3 - << 'PYDESK'
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-system-monitor/stage/pkg/usr/share/applications/mate-system-monitor.desktop")
text = p.read_text()
assert "Name=MATE System Monitor" in text
assert "GenericName=System Monitor" in text
assert "Icon=utilities-system-monitor" in text

def untranslated_keys(src: str):
    keys = []
    for ln in src.splitlines():
        if not ln or ln.startswith("#") or "=" not in ln:
            continue
        k = ln.split("=", 1)[0]
        if "[" not in k:
            keys.append(k)
    return keys

assert "NoDisplay" not in untranslated_keys(text)

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

out_lines = []
for line in text.splitlines(keepends=True):
    raw = line[:-1] if line.endswith("\n") else line
    nl = "\n" if line.endswith("\n") else ""
    key = raw.split("=", 1)[0] if "=" in raw and not raw.lstrip().startswith("#") else ""
    if key in ("Exec", "TryExec"):
        raw = rewrite_first_token(raw, key)
    out_lines.append(raw + nl)
new = "".join(out_lines)
assert r"\1" not in new
assert "Exec=/usr/bin/mate-system-monitor" in new
assert "TryExec=/usr/bin/mate-system-monitor" in new
assert "Name=MATE System Monitor" in new
assert "Icon=utilities-system-monitor" in new
assert "NoDisplay" not in untranslated_keys(new)
p.write_text(new)
print("desktop_rewrite_ok")
PYDESK

# official changelog is a real file; keep it and also cp -L into kemi doc
mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
test ! -L "$STAGE/pkg/usr/share/doc/mate-system-monitor/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-system-monitor/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-system-monitor/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
# do not pack unbundled common changelog

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-system-monitor (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-system-monitor 1.24.0-1 arm64,
    KEMI mall linuxpkg repack. Official
    same-source mate-system-monitor-common
    (>= 1.24.0-1) is a range Depends and
    was not bundled. Official ELF stays
    under /usr. Official desktop Name=MATE
    System Monitor kept; mall
    app_name=MATE System Monitor.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; append desktop-database (quoted heredoc)
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
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'utilities-system-monitor-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
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
Depends: mate-system-monitor-common (>= 1.24.0-1), libc6 (>= 2.29), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.2.4), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.45.3), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.21.5), libgtkmm-3.0-1v5 (>= 3.24.0), libgtop-2.0-11 (>= 2.37.90), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), librsvg2-2 (>= 2.14.4), libsigc++-2.0-0v5 (>= 2.2.0), libstdc++6 (>= 5.2), libsystemd0, libwnck-3-0 (>= 2.91.6), libxml2 (>= 2.7.4)
Recommends: gvfs
Provides: mate-system-monitor (= ${VER_UP})
Conflicts: mate-system-monitor
Replaces: mate-system-monitor
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Process viewer and system resource monitor for MATE
 MATE System Monitor 1.24.0-1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-system-monitor. Official
 mate-system-monitor-common stays Depends
 (range, not bundled). glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-system-monitor/stage/pkg")
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
t = Path("/workspace/t142-20261112-mate-system-monitor/stage/pkg/usr/share/applications/mate-system-monitor.desktop").read_text()
assert r"\1" not in t
print("no_literal_group")
PYLIT

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-system-monitor/debs/kemi-mate-system-monitor_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-system-monitor/dl/mate-system-monitor_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-system-monitor-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'utilities-system-monitor-128|humanity-icon-theme|mate-system-monitor-common'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_and_common_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-system-monitor/stage/pkg")
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
test "${#ELFS[@]}" -eq 3
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-system-monitor.json"
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
assert gv == 3 and gn == 0
assert cmax == "3.4.21"
assert cv == 1 and cn == 2
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
