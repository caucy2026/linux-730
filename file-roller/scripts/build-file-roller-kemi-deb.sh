#!/usr/bin/env bash
# Repack official Ubuntu 20.04 file-roller 3.36.3-0ubuntu1.1 arm64
# (focal-updates/security main) as kemi-file-roller. 16-index found
# no same-source siblings and no exact-version same-source hard
# Depends, so nothing is bundled. Official GUI Source field is
# absent and is not defaulted. Official Homepage
# https://wiki.gnome.org/Apps/FileRoller is copied exactly.
# Official ELF stays at official /usr path.
# /opt/file-roller/file-roller and /usr/bin/kemi-file-roller are
# only symlinks to official /usr/bin/file-roller. No invented
# kemi-rpm2cpio or kemi-isoinfo.sh for official libexec helpers
# of a different name. Official desktop Name=Archive Manager
# kept; mall app_name=File Roller (official appdata <name>File
# Roller</name>; official desktop Name is generic). Relative
# Exec/TryExec rewritten absolute with %U kept. Official GUI
# schema, appdata, man, copyright, changelog, official hicolor
# app icons, nautilus extension, dbus services, and help (including
# official help-langpack dangling symlinks) are packed. Official
# changelog is a regular file, not a dangling symlink. Evidence
# 128 PNG is CREATE-only and is not packed. 0 official .mo in the
# GUI package (translations live in language packs, not bundled).
set -euo pipefail

ROOT=/workspace/t143-20261112-file-roller
UNPACK="$ROOT/unpack/official/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-file-roller
VER_UP=3.36.3-0ubuntu1.1
VER_NAME=3.36.3-0ubuntu1.1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/file-roller_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "3.36.3-0ubuntu1.1kemi1"
assert len(s) == 22, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/file-roller" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/file-roller"
test ! -L "$STAGE/pkg/usr/bin/file-roller"
ln -s "/usr/bin/file-roller" "$STAGE/pkg/opt/file-roller/file-roller"
ln -s "/usr/bin/file-roller" "$STAGE/pkg/usr/bin/kemi-file-roller"
test -L "$STAGE/pkg/opt/file-roller/file-roller"
test -L "$STAGE/pkg/usr/bin/kemi-file-roller"
test ! -e "$STAGE/pkg/usr/bin/kemi-rpm2cpio"
test ! -e "$STAGE/pkg/usr/libexec/kemi-rpm2cpio"
test ! -e "$STAGE/pkg/usr/bin/kemi-isoinfo.sh"
test ! -e "$STAGE/pkg/usr/libexec/file-roller/kemi-isoinfo.sh"
test ! -e "$STAGE/pkg/usr/libexec/kemi-isoinfo.sh"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-file-roller/stage/pkg/usr/share/applications/org.gnome.FileRoller.desktop")
text = p.read_text()
assert "Name=Archive Manager" in text
assert "Icon=org.gnome.ArchiveManager" in text
assert "TryExec=file-roller" in text
assert "Exec=file-roller %U" in text
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
            out.append("TryExec=/usr/bin/file-roller" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/file-roller %U" in new
assert "TryExec=/usr/bin/file-roller" in new
assert "Name=Archive Manager" in new
assert "Icon=org.gnome.ArchiveManager" in new
assert "NoDisplay=" not in new
assert "Exec=file-roller %U" not in new
assert "TryExec=file-roller\n" not in new and "TryExec=file-roller" not in new.split("TryExec=/usr/bin/file-roller")[0]
p.write_text(new)
print("desktop_rewrite_ok")
print([ln for ln in new.splitlines() if ln.startswith(("Exec=", "TryExec=", "Name=", "Icon=")) and "[" not in ln])
PYDESK

# dbus already absolute; leave official
python3 - << 'PYDBUS'
from pathlib import Path
base = Path("/workspace/t143-20261112-file-roller/stage/pkg/usr/share/dbus-1/services")
a = (base / "org.gnome.FileRoller.ArchiveManager1.service").read_text()
b = (base / "org.gnome.FileRoller.service").read_text()
assert "Exec=/usr/bin/file-roller --service" in a
assert "Exec=/usr/bin/file-roller --service" in b
print("dbus_exec_already_absolute")
PYDBUS

# official changelog is a regular file (not a dangling symlink)
python3 - << 'PYCL'
from pathlib import Path
p = Path("/workspace/t143-20261112-file-roller/stage/pkg/usr/share/doc/file-roller/changelog.Debian.gz")
assert p.is_file() and not p.is_symlink()
print("official_changelog_regular_file", p.stat().st_size)
PYCL

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/file-roller/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/file-roller/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/file-roller/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-file-roller (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates/security
    main) file-roller 3.36.3-0ubuntu1.1 arm64,
    KEMI mall linuxpkg repack. No same-source
    exact-version hard Depends to bundle.
    Official ELF stays under /usr.
    Official desktop Name=Archive Manager
    kept; mall app_name=File Roller.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database + icon-cache
# (official hicolor app icons packed) + glib-compile-schemas
# (GUI schema packed). No bundled public shared libs / no ldconfig.
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
root = Path("/workspace/t143-20261112-file-roller/stage/pkg")
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
Depends: bzip2, unzip, zip, dconf-gsettings-backend | gsettings-backend, libarchive13 (>= 3.3.3), libc6 (>= 2.17), libcairo2 (>= 1.4.10), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libjson-glib-1.0-0 (>= 0.12.0), libnautilus-extension1a (>= 3.27.90), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.14.0)
Recommends: gvfs, yelp
Suggests: p7zip-full, arj, lha, lzip, lzma, lzop, ncompress, rpm2cpio, rzip, sharutils, squashfs-tools, unace, unalz, unar, xz-utils, zoo
Provides: file-roller (= ${VER_UP})
Conflicts: file-roller
Replaces: file-roller
Homepage: https://wiki.gnome.org/Apps/FileRoller
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: archive manager for GNOME
 File Roller ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack of file-roller. No
 same-source exact-version hard Depends to
 bundle. glibc<=2.31 (Ubuntu 20.04).
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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-file-roller-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-file-roller/debs/kemi-file-roller_3.36.3-0ubuntu1.1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/file-roller",
    "./usr/bin/kemi-file-roller",
    "./opt/file-roller/file-roller",
    "./usr/libexec/file-roller/isoinfo.sh",
    "./usr/libexec/file-roller/rpm2cpio",
    "./usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libnautilus-fileroller.so",
    "./usr/share/applications/org.gnome.FileRoller.desktop",
    "./usr/share/glib-2.0/schemas/org.gnome.FileRoller.gschema.xml",
    "./usr/share/metainfo/org.gnome.FileRoller.appdata.xml",
    "./usr/share/man/man1/file-roller.1.gz",
    "./usr/share/doc/file-roller/changelog.Debian.gz",
    "./usr/share/doc/file-roller/copyright",
    "./usr/share/doc/kemi-file-roller/changelog.Debian.gz",
    "./usr/share/doc/kemi-file-roller/copyright",
    "./usr/share/doc/kemi-file-roller/changelog.kemi",
    "./usr/share/dbus-1/services/org.gnome.FileRoller.service",
    "./usr/share/dbus-1/services/org.gnome.FileRoller.ArchiveManager1.service",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.ArchiveManager.svg",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.ArchiveManager.Devel.svg",
    "./usr/share/icons/hicolor/symbolic/apps/org.gnome.ArchiveManager-symbolic.svg",
    "./usr/share/file-roller/packages.match",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and ln.endswith("./usr/bin/file-roller") for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-file-roller" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/file-roller/file-roller" in ln for ln in lines)
# official changelog is a regular file, not a symlink
assert any((ln.startswith("-rw") or ln.startswith("-r-")) and "./usr/share/doc/file-roller/changelog.Debian.gz" in ln for ln in lines)
# evidence / invented launchers / theme not packed
for needle in ("file-roller-128", "/evidence/", "kemi-rpm2cpio", "kemi-isoinfo", "humanity-icon-theme", "engrampa", "evince", "atril"):
    assert not any(needle in ln for ln in lines), needle
# official help packed (including official langpack dangling links)
assert any("./usr/share/help/C/file-roller/index.page" in ln for ln in lines)
# 0 mo in official package
assert sum(1 for ln in lines if ln.endswith(".mo")) == 0
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
