#!/usr/bin/env bash
# Repack official Ubuntu 20.04 mate-calc 1.24.0-1 arm64 as kemi-mate-calc.
# Official same-source mate-calc-common is a range Depends
# (>= 1.24.0-1, << 1.24.0-1.1~), not an exact-version hard Depends,
# so it stays Depends and is not bundled. Official GUI Source field
# is absent and is not defaulted. Official Homepage
# http://www.mate-desktop.org/ is copied exactly (http, not upgraded).
# Official ELFs stay at official /usr paths. Official mate-calculator
# symlink is kept. /opt/mate-calc/* and /usr/bin/kemi-mate-calc are
# only symlinks to official /usr/bin/mate-calc (and mate-calc-cmd
# at /opt only). No invented kemi-mate-calc-cmd or kemi-mate-calculator.
# Official desktop Name=MATE Calculator and GenericName=Calculator
# kept; relative Exec rewritten absolute; TryExec added. Official .mo,
# schemas, appdata, man, help, and icons live in unbundled common and
# are not packed. Evidence 128 PNG is CREATE-only and is not packed.
set -euo pipefail

ROOT=/workspace/t143-20261112-mate-calc
UNPACK="$ROOT/unpack/gui/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-mate-calc
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/mate-calc_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

# official command mate-calc exists: opt + kemi-mate-calc symlinks allowed
mkdir -p "$STAGE/pkg/opt/mate-calc" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/mate-calc"
test ! -L "$STAGE/pkg/usr/bin/mate-calc"
test -f "$STAGE/pkg/usr/bin/mate-calc-cmd"
test -L "$STAGE/pkg/usr/bin/mate-calculator"
test "$(readlink "$STAGE/pkg/usr/bin/mate-calculator")" = "mate-calc"
ln -s "/usr/bin/mate-calc" "$STAGE/pkg/opt/mate-calc/mate-calc"
ln -s "/usr/bin/mate-calc-cmd" "$STAGE/pkg/opt/mate-calc/mate-calc-cmd"
ln -s "/usr/bin/mate-calc" "$STAGE/pkg/usr/bin/kemi-mate-calc"
test -L "$STAGE/pkg/opt/mate-calc/mate-calc"
test -L "$STAGE/pkg/usr/bin/kemi-mate-calc"
# do not invent extra kemi launchers
if [ -e "$STAGE/pkg/usr/bin/kemi-mate-calc-cmd" ] || [ -e "$STAGE/pkg/usr/bin/kemi-mate-calculator" ]; then
  echo "INVENTED_EXTRA_KEMI_LAUNCHER" >&2
  exit 1
fi

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-mate-calc/stage/pkg/usr/share/applications/mate-calc.desktop")
text = p.read_text()
assert "Name=MATE Calculator" in text
assert "GenericName=Calculator" in text
assert "Icon=accessories-calculator" in text
assert "NoDisplay=" not in text

def rewrite_first_token(line: str, key: str) -> str:
    prefix = key + "="
    rest = line[len(prefix):]
    ending = ""
    if rest.endswith("\n"):
        ending = "\n"
        rest = rest[:-1]
    parts = rest.split(" ", 1)
    cmd = parts[0]
    args = (" " + parts[1]) if len(parts) == 2 else ""
    if cmd and not cmd.startswith("/"):
        cmd = "/usr/bin/" + cmd
    return prefix + cmd + args + ending

new_lines = []
seen_try = False
for raw in text.splitlines(keepends=True):
    line = raw
    if raw.startswith("Exec="):
        line = rewrite_first_token(raw, "Exec")
    elif raw.startswith("TryExec="):
        line = rewrite_first_token(raw, "TryExec")
        seen_try = True
    new_lines.append(line)

if not seen_try:
    out = []
    added = False
    for line in new_lines:
        out.append(line)
        if (not added) and line.startswith("Exec="):
            ending = "\n" if line.endswith("\n") else ""
            out.append("TryExec=/usr/bin/mate-calc" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/mate-calc" in new
assert "TryExec=/usr/bin/mate-calc" in new
assert "Name=MATE Calculator" in new
assert "GenericName=Calculator" in new
assert "Icon=accessories-calculator" in new
assert "NoDisplay=" not in new
assert "Exec=mate-calc\n" not in new
p.write_text(new)
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/mate-calc/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/mate-calc/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-mate-calc (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    mate-calc 1.24.0-1 arm64, KEMI mall
    linuxpkg repack. Official same-source
    mate-calc-common stays Depends (range,
    not bundled). Official ELFs stay under
    /usr. Official desktop Name=MATE
    Calculator and GenericName=Calculator
    kept; mall app_name=MATE Calculator.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database only (no packed
# hicolor icons, no schemas, no bundled shared lib)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK

cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-mate-calc/stage/pkg")
pat = re.compile(r"x86_64-linux-gnu", re.I)
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw[:4] == b"\x7fELF":
        continue
    if p.suffix.lower() in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".ico"}:
        continue
    if p.name == "copyright":
        continue
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        continue
    rel = str(p.relative_to(root))
    in_desc = False
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if p.name == "control":
            if line.startswith("Description:"):
                in_desc = True
                continue
            if in_desc and (line.startswith(" ") or line.startswith("\t")):
                continue
            if in_desc and line and not line.startswith(" "):
                in_desc = False
        if "lintian" in rel or p.name == "overrides":
            continue
        if pat.search(line):
            bad.append((rel, i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: mate-calc-common (>= 1.24.0-1), mate-calc-common (<< 1.24.0-1.1~), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libglib2.0-0 (>= 2.39.91), libgtk-3-0 (>= 3.21.5), libpango-1.0-0 (>= 1.14.0), libxml2 (>= 2.7.4)
Provides: mate-calc (= ${VER_UP})
Conflicts: mate-calc
Replaces: mate-calc
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE desktop calculator
 MATE Calculator ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack of mate-calc.
 Official mate-calc-common stays Depends
 (range, not bundled).
 glibc<=2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

# leftover-x86 after control
python3 - << 'PYX86B'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-mate-calc/stage/pkg")
pat = re.compile(r"x86_64-linux-gnu", re.I)
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw[:4] == b"\x7fELF":
        continue
    if p.suffix.lower() in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".ico"}:
        continue
    if p.name == "copyright":
        continue
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        continue
    rel = str(p.relative_to(root))
    in_desc = False
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if p.name == "control":
            if line.startswith("Description:"):
                in_desc = True
                continue
            if in_desc and (line.startswith(" ") or line.startswith("\t")):
                continue
            if in_desc and line and not line.startswith(" "):
                in_desc = False
        if "lintian" in rel or p.name == "overrides":
            continue
        if pat.search(line):
            bad.append((rel, i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86_post_control")
PYX86B

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << PYHASH
import hashlib
from pathlib import Path
p = Path("$OUT")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("$OFFICIAL_DEB")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
assert p.stat().st_size != off.stat().st_size
print("differs_from_official", off.stat().st_size, oh)
PYHASH

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-mate-calc-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-mate-calc/debs/kemi-mate-calc_1.24.0-1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/mate-calc",
    "./usr/bin/mate-calc-cmd",
    "./usr/bin/mate-calculator",
    "./usr/bin/kemi-mate-calc",
    "./opt/mate-calc/mate-calc",
    "./opt/mate-calc/mate-calc-cmd",
    "./usr/share/applications/mate-calc.desktop",
    "./usr/share/doc/mate-calc/changelog.Debian.gz",
    "./usr/share/doc/mate-calc/copyright",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and "./usr/bin/mate-calc" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-mate-calc" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/mate-calculator" in ln for ln in lines)
assert not any("kemi-mate-calc-cmd" in ln for ln in lines)
assert not any("kemi-mate-calculator" in ln for ln in lines)
# common / theme / evidence not packed
bad_needles = (
    "mate-calc-common",
    "humanity-icon-theme",
    "accessories-calculator-128",
    "org.mate.calc.gschema",
    "mate-calc.appdata",
    "/usr/share/locale/",
    "/usr/share/help/",
    "/usr/share/man/",
    "evidence",
)
for needle in bad_needles:
    assert not any(needle in ln for ln in lines), needle
# no packed mo
assert not any(ln.endswith(".mo") for ln in lines)
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
