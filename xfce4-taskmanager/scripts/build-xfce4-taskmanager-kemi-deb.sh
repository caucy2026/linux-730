#!/usr/bin/env bash
# Repack official Ubuntu 20.04 xfce4-taskmanager 1.2.3-0ubuntu1 arm64
# as kemi-xfce4-taskmanager. 16-index found no same-source siblings
# and no exact-version same-source hard Depends, so nothing is bundled.
# Official GUI Source field is absent and is not defaulted. Official
# Homepage https://goodies.xfce.org/projects/applications/xfce4-taskmanager
# is copied exactly. Official ELF stays at official /usr path.
# /opt/xfce4-taskmanager/xfce4-taskmanager and /usr/bin/kemi-xfce4-taskmanager
# are only symlinks to official /usr/bin/xfce4-taskmanager. Official
# desktop Name=Task Manager and GenericName=Task Manager kept; relative
# Exec rewritten absolute; TryExec added. Official 55 .mo, man, changelog,
# copyright, and official hicolor action icons are packed. Evidence 128
# PNG is CREATE-only and is not packed. Theme not bundled.
set -euo pipefail

ROOT=/workspace/t143-20261112-xfce4-taskmanager
UNPACK="$ROOT/unpack/official/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-xfce4-taskmanager
VER_UP=1.2.3-0ubuntu1
VER_NAME=1.2.3-0ubuntu1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/xfce4-taskmanager_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "1.2.3-0ubuntu1kemi1"
assert len(s) == 19, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/xfce4-taskmanager" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/xfce4-taskmanager"
test ! -L "$STAGE/pkg/usr/bin/xfce4-taskmanager"
ln -s "/usr/bin/xfce4-taskmanager" "$STAGE/pkg/opt/xfce4-taskmanager/xfce4-taskmanager"
ln -s "/usr/bin/xfce4-taskmanager" "$STAGE/pkg/usr/bin/kemi-xfce4-taskmanager"
test -L "$STAGE/pkg/opt/xfce4-taskmanager/xfce4-taskmanager"
test -L "$STAGE/pkg/usr/bin/kemi-xfce4-taskmanager"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-xfce4-taskmanager/stage/pkg/usr/share/applications/xfce4-taskmanager.desktop")
text = p.read_text()
assert "Name=Task Manager" in text
assert "GenericName=Task Manager" in text
assert "Icon=utilities-system-monitor" in text
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
            out.append("TryExec=/usr/bin/xfce4-taskmanager" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/xfce4-taskmanager" in new
assert "TryExec=/usr/bin/xfce4-taskmanager" in new
assert "Name=Task Manager" in new
assert "GenericName=Task Manager" in new
assert "Icon=utilities-system-monitor" in new
assert "NoDisplay=" not in new
assert "Exec=xfce4-taskmanager\n" not in new
p.write_text(new)
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/xfce4-taskmanager/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/xfce4-taskmanager/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-xfce4-taskmanager (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    xfce4-taskmanager 1.2.3-0ubuntu1 arm64,
    KEMI mall linuxpkg repack. No same-source
    exact-version hard Depends to bundle.
    Official ELF stays under /usr.
    Official desktop Name=Task Manager
    kept; mall app_name=Xfce Task Manager.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database + icon-cache
# (official hicolor action icons packed); no schemas; no bundled lib
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
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
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-xfce4-taskmanager/stage/pkg")
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.0.0), libwnck-3-0 (>= 2.91.6), libx11-6, libxmu6
Provides: xfce4-taskmanager (= ${VER_UP})
Conflicts: xfce4-taskmanager
Replaces: xfce4-taskmanager
Homepage: https://goodies.xfce.org/projects/applications/xfce4-taskmanager
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: process manager for the Xfce4 Desktop Environment
 Xfce Task Manager ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack of xfce4-taskmanager.
 No same-source exact-version hard Depends to
 bundle. glibc<=2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

python3 - << 'PYX86B'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-xfce4-taskmanager/stage/pkg")
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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-xfce4-taskmanager-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-xfce4-taskmanager/debs/kemi-xfce4-taskmanager_1.2.3-0ubuntu1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/xfce4-taskmanager",
    "./usr/bin/kemi-xfce4-taskmanager",
    "./opt/xfce4-taskmanager/xfce4-taskmanager",
    "./usr/share/applications/xfce4-taskmanager.desktop",
    "./usr/share/doc/xfce4-taskmanager/changelog.Debian.gz",
    "./usr/share/doc/xfce4-taskmanager/copyright",
    "./usr/share/man/man1/xfce4-taskmanager.1.gz",
    "./usr/share/icons/hicolor/scalable/actions/xc_crosshair.svg",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and "./usr/bin/xfce4-taskmanager" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-xfce4-taskmanager" in ln for ln in lines)
# evidence / theme not packed
for needle in ("humanity-icon-theme", "utilities-system-monitor-128", "evidence"):
    assert not any(needle in ln for ln in lines), needle
# official mo packed
assert sum(1 for ln in lines if ln.endswith("xfce4-taskmanager.mo")) == 55
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
