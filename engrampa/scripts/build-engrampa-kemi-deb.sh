#!/usr/bin/env bash
# Repack official Ubuntu 20.04 engrampa 1.24.0-2 arm64 together with
# bundled same-source exact-version hard Depends engrampa-common
# (= 1.24.0-2) all, as kemi-engrampa. Official GUI Source field is
# absent and is not defaulted (sibling common lists Source: engrampa,
# which is not copied onto kemi). Official Homepage
# http://www.mate-desktop.org/ is copied exactly (http, not upgraded).
# Official ELF stays at official /usr path. /opt/engrampa/engrampa and
# /usr/bin/kemi-engrampa are only symlinks to official /usr/bin/engrampa.
# No invented kemi-engrampa-server. Official desktop Name=Engrampa
# Archive Manager kept; relative Exec/TryExec rewritten absolute with
# %U kept. Official 133 .mo, schemas, appdata, man, help, and hicolor
# icons from bundled common are packed. Evidence 128 PNG is CREATE-only
# and is not packed.
set -euo pipefail

ROOT=/workspace/t143-20261112-engrampa
GUI="$ROOT/unpack/official/data"
COMMON="$ROOT/unpack/common/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-engrampa
VER_UP=1.24.0-2
VER_NAME=1.24.0-2kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/engrampa_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "1.24.0-2kemi1"
assert len(s) == 13, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$GUI/." "$STAGE/pkg/"
# bundle common (no path overlap)
cp -a "$COMMON/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/engrampa" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/engrampa"
test ! -L "$STAGE/pkg/usr/bin/engrampa"
ln -s "/usr/bin/engrampa" "$STAGE/pkg/opt/engrampa/engrampa"
# also symlink official server into opt only (optional? GST only symlinked official /usr/bin commands.
# Rule: /opt/<app>/* are symlinks only to official /usr binaries.
# official has /usr/bin/engrampa and /usr/lib/engrampa/engrampa-server.
# I'll only add opt/engrampa/engrampa -> /usr/bin/engrampa, not invent kemi-engrampa-server.
# Could add opt symlink to server as well since it's an official binary, but
# previous titles only symlinked official /usr/bin commands. Stick to that.
ln -s "/usr/bin/engrampa" "$STAGE/pkg/usr/bin/kemi-engrampa"
test -L "$STAGE/pkg/opt/engrampa/engrampa"
test -L "$STAGE/pkg/usr/bin/kemi-engrampa"
test ! -e "$STAGE/pkg/usr/bin/kemi-engrampa-server"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-engrampa/stage/pkg/usr/share/applications/engrampa.desktop")
text = p.read_text()
assert "Name=Engrampa Archive Manager" in text
assert "GenericName=Archive Manager" in text
assert "Icon=engrampa" in text
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
            out.append("TryExec=/usr/bin/engrampa" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/engrampa %U" in new
assert "TryExec=/usr/bin/engrampa" in new
assert "Name=Engrampa Archive Manager" in new
assert "GenericName=Archive Manager" in new
assert "Icon=engrampa" in new
assert "NoDisplay=" not in new
assert "Exec=engrampa" not in new
assert "TryExec=engrampa\n" not in new and "TryExec=engrampa" != [ln for ln in new.splitlines() if ln.startswith("TryExec=")][0]
p.write_text(new)
print("desktop_rewrite_ok")
print([ln for ln in new.splitlines() if ln.startswith(("Exec=","TryExec=","Name=","GenericName=","Icon=")) and "[" not in ln])
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/engrampa/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/engrampa/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-engrampa (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    engrampa 1.24.0-2 arm64, bundled same-source
    exact-version hard Depends engrampa-common
    (= 1.24.0-2), KEMI mall linuxpkg repack.
    Official ELF stays under /usr.
    Official desktop Name=Engrampa Archive
    Manager kept; mall app_name=Engrampa
    Archive Manager.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database + icon-cache +
# glib-compile-schemas (bundled common schemas + hicolor + desktop).
# no ldconfig: no bundled shared library from a Depends; official
# caja extension .so is GUI content and official had no ldconfig.
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
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
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
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

scan_x86() {
python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-engrampa/stage/pkg")
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
}

scan_x86

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: bzip2 (>= 1.0.1), gzip (>= 1.3.2), p7zip-full, tar (>= 1.13.25), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libcaja-extension1 (>= 1.18), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libjson-glib-1.0-0 (>= 0.12.0), libmagic1 (>= 5.12), libpango-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend
Recommends: gvfs, unzip, xz-utils, zip
Suggests: arj, binutils, cpio, lha, lzip, lzma, lzop, ncompress, rar, rpm2cpio, rzip, sharutils, unace, unalz, unar | unrar | p7zip-rar, zoo
Breaks: engrampa-common (<< 1.8.0), engrampa (<= 1.0.3-1), parchives (<< 1.1.5-1~)
Replaces: parchives (<< 1.1.5-1~), engrampa, engrampa-common
Conflicts: engrampa, engrampa-common
Provides: engrampa (= ${VER_UP}), engrampa-common (= ${VER_UP})
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: archive manager for MATE
 Engrampa Archive Manager ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of engrampa
 with bundled engrampa-common (= ${VER_UP}).
 glibc<=2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

scan_x86

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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-engrampa-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-engrampa/debs/kemi-engrampa_1.24.0-2kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/engrampa",
    "./usr/bin/kemi-engrampa",
    "./opt/engrampa/engrampa",
    "./usr/lib/engrampa/engrampa-server",
    "./usr/lib/engrampa/engrampa/isoinfo.sh",
    "./usr/lib/aarch64-linux-gnu/caja/extensions-2.0/libcaja-engrampa.so",
    "./usr/share/applications/engrampa.desktop",
    "./usr/share/doc/engrampa/changelog.Debian.gz",
    "./usr/share/doc/engrampa/copyright",
    "./usr/share/doc/engrampa-common/changelog.Debian.gz",
    "./usr/share/doc/engrampa-common/copyright",
    "./usr/share/man/man1/engrampa.1.gz",
    "./usr/share/metainfo/engrampa.appdata.xml",
    "./usr/share/glib-2.0/schemas/org.mate.engrampa.gschema.xml",
    "./usr/share/icons/hicolor/scalable/apps/engrampa.svg",
    "./usr/share/dbus-1/services/org.mate.Engrampa.service",
    "./usr/share/caja/extensions/libcaja-engrampa.caja-extension",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and "./usr/bin/engrampa" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-engrampa" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/engrampa/engrampa" in ln for ln in lines)
# evidence not packed; no invented kemi-engrampa-server
for needle in ("engrampa-128.png", "evidence", "kemi-engrampa-server", "humanity-icon-theme"):
    assert not any(needle in ln for ln in lines), needle
assert sum(1 for ln in lines if ln.endswith("engrampa.mo")) == 133
# official app icon packed
assert any("hicolor/32x32/apps/engrampa.png" in ln for ln in lines)
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
