#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# mate-terminal 1.24.0-2ubuntu1 Architecture: arm64
# as kemi-mate-terminal, bundling official
# same-source exact-version hard Depends
# mate-terminal-common (= 1.24.0-2ubuntu1),
# Architecture: all. Common has no further
# exact-version same-source Depends to bundle
# (only dconf-gsettings-backend | gsettings-backend,
# merged into kemi Depends). Newest official U20
# pin: focal Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source
# field is absent and was not defaulted;
# sibling stanza lists Source: mate-terminal.
# No Debian epoch, no tilde. Official
# different-source Depends stay Depends,
# unbundled (including mate-desktop-common).
# Official control has no Recommends and no
# Suggests. No official same-source gir / -dev
# / transitional dummy. Versioned Provides:
# mate-terminal and mate-terminal-common
# (= 1.24.0-2ubuntu1), plus official
# unversioned Provides x-terminal-emulator.
# Official common Breaks/Replaces
# mate-terminal (<< 1.1.0-2) kept. Official
# user-facing binary /usr/bin/mate-terminal
# is an aarch64 ELF and stays at the official
# path, as does the official Perl wrapper
# /usr/bin/mate-terminal.wrapper (not ELF).
# /opt/mate-terminal/* are symlinks only.
# Also /usr/bin/kemi-mate-terminal →
# mate-terminal. Official common package
# ships 124 official .mo; they are kept
# official and none are invented. Official
# packages ship no app icon (desktop Icon is
# the theme name utilities-terminal). Official
# help figures stay official and are not used
# as the mall icon. A 128×128 evidence PNG
# rasterized from official Ubuntu 20.04
# humanity-icon-theme 0.6.15
# apps/128/utilities-terminal.svg via Chrome
# headless --default-background-color=00000000
# lives at evidence/utilities-terminal-128.png
# and is used only as the mall CREATE --icon;
# it is not packed. The theme package is not
# bundled. Official GUI and common
# changelog.Debian.gz are real files (different
# sha) and are kept official; the official GUI
# changelog is also copied with cp -L into the
# kemi doc dir. Official desktop Name=MATE
# Terminal is kept. Official GenericName=
# Terminal stays in the desktop file and is
# not used as mall app_name. Official appdata
# <name> is also MATE Terminal. Official
# relative Exec and TryExec are rewritten
# absolute. No official NoDisplay; none is
# invented. Official postinst/prerm
# (update-alternatives for
# x-terminal-emulator → official
# /usr/bin/mate-terminal.wrapper) are kept.
# glib-compile-schemas, desktop-database, and
# icon-cache hooks are appended. No bundled
# shared lib, so no ldconfig hook. Probe: 1
# unique aarch64 ELF, requiredGlibc reported
# from the versioned need; PASS vs 101.
# Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64 / all Packages
# stanzas. No librarian URL and no
# .buildinfo this run. KEMI mall
# version_name 1.24.0-2ubuntu1kemi1 is 20
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-mate-terminal
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-terminal
VER_UP=1.24.0-2ubuntu1
VER_NAME=1.24.0-2ubuntu1kemi1
VER_DEB=1.24.0-2ubuntu1kemi1
ARCH=arm64
OFF_GUI="$DL/mate-terminal_${VER_UP}_arm64.deb"
OFF_COMMON="$DL/mate-terminal-common_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "1.24.0-2ubuntu1kemi1"
assert len(s) == 20, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

# unpack official debs into UNPACK if missing (do not delete existing inventory)
if [ ! -x "$UNPACK/gui/usr/bin/mate-terminal" ]; then
  rm -rf "$UNPACK/gui" "$UNPACK/common"
  mkdir -p "$UNPACK/gui" "$UNPACK/common"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
fi

# merge official trees (common first, then GUI)
cp -a "$UNPACK/common/." "$STAGE/pkg/"
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

# official ELF stays at official path; /opt and kemi-* are symlinks only
mkdir -p "$STAGE/pkg/opt/mate-terminal"
ln -s /usr/bin/mate-terminal "$STAGE/pkg/opt/mate-terminal/mate-terminal"
ln -s mate-terminal "$STAGE/pkg/usr/bin/kemi-mate-terminal"
test -x "$STAGE/pkg/usr/bin/mate-terminal"
test -L "$STAGE/pkg/opt/mate-terminal/mate-terminal"
test -L "$STAGE/pkg/usr/bin/kemi-mate-terminal"

# desktop: rewrite relative Exec / TryExec absolute; keep official Name, Icon;
# do not invent NoDisplay; do not use a regex group replacement
STAGE_APPS="$STAGE/pkg/usr/share/applications"
python3 - << 'PYDESK'
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-terminal/stage/pkg/usr/share/applications") / "mate-terminal.desktop"
text = p.read_text()
assert "Name=MATE Terminal" in text
assert "GenericName=Terminal" in text
assert "Icon=utilities-terminal" in text

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
assert "Exec=/usr/bin/mate-terminal" in new
assert "TryExec=/usr/bin/mate-terminal" in new
assert "Name=MATE Terminal" in new
assert "Icon=utilities-terminal" in new
assert "NoDisplay" not in untranslated_keys(new)
p.write_text(new)
print("desktop_rewrite_ok")
PYDESK

# official changelogs are real files; keep them and also cp -L into kemi doc
mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$UNPACK/gui/usr/share/doc/mate-terminal/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/mate-terminal/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test -f "$STAGE/pkg/usr/share/doc/mate-terminal/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/mate-terminal-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-terminal/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/mate-terminal-common/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-terminal (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-terminal 1.24.0-2ubuntu1 arm64,
    KEMI mall linuxpkg repack. Bundled
    official same-source exact-version
    mate-terminal-common (= 1.24.0-2ubuntu1).
    Official ELF stays under /usr. Official
    desktop Name=MATE Terminal kept; mall
    app_name=MATE Terminal. 合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# keep official maintainer scripts (update-alternatives paths stay official)
cp -a "$UNPACK/gui/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/gui/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
# append hooks with quoted heredoc (do not expand $1). No ldconfig (no bundled shared lib).
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# Automatically added by kemi
if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
	glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
		glib-compile-schemas /usr/share/glib-2.0/schemas || true
	fi
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
		gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-alternatives --install /usr/bin/x-terminal-emulator' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-alternatives --remove x-terminal-emulator' "$STAGE/pkg/DEBIAN/prerm"
echo "hooks_ok"

# no evidence PNG / theme in the package
if find "$STAGE/pkg" \( -name 'utilities-terminal-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi
MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
test "$MO_COUNT" = 124
echo "mo_count $MO_COUNT"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: gsettings-desktop-schemas, mate-desktop-common, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdconf1 (>= 0.14.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.50), libgtk-3-0 (>= 3.22), libice6 (>= 1:1.0.0), libpango-1.0-0 (>= 1.14.0), libsm6, libvte-2.91-0 (>= 0.51.90), libx11-6, dconf-gsettings-backend | gsettings-backend
Provides: mate-terminal (= ${VER_UP}), mate-terminal-common (= ${VER_UP}), x-terminal-emulator
Conflicts: mate-terminal, mate-terminal-common
Replaces: mate-terminal, mate-terminal-common
Breaks: mate-terminal (<< 1.1.0-2)
Homepage: http://www.mate-desktop.org
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE terminal emulator application
 MATE Terminal 1.24.0-2ubuntu1 — official
 Ubuntu 20.04 arm64, KEMI repack of
 mate-terminal, bundling official
 mate-terminal-common. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

# leftover-x86: skip comment lines and official ELF; official Description
# or official ELF hardware-ID strings are not a packaging defect
python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-terminal/stage/pkg")
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
        # official ELF hardware-ID / needed strings are not a packaging defect
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        # official Description text is not a packaging defect
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86

python3 - << 'PYLIT'
from pathlib import Path
t = Path("/workspace/t142-20261112-mate-terminal/stage/pkg/usr/share/applications/mate-terminal.desktop").read_text()
assert r"\1" not in t
print("no_literal_group")
PYLIT

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib
from pathlib import Path
p = Path("/workspace/t142-20261112-mate-terminal/debs/kemi-mate-terminal_1.24.0-2ubuntu1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-mate-terminal/dl/mate-terminal_1.24.0-2ubuntu1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-terminal-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'utilities-terminal-128|humanity-icon-theme'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-mate-terminal/stage/pkg")
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
test "${#ELFS[@]}" -ge 1
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-mate-terminal.json"
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
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
