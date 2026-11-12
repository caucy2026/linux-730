#!/usr/bin/env bash
# Repack official Ubuntu 20.04 eog 3.36.3-0ubuntu1 arm64
# (focal-updates main) as kemi-eog. 16-index found no eog-common
# and no exact-version same-source hard Depends, so nothing is
# bundled. Official same-source eog-dev is inspected, not packaged.
# Official unversioned/ranged gir Depends gir1.2-gtk-3.0 and
# gir1.2-peas-1.0 are different-source and stay Depends.
# Official GUI Source field is absent and is not defaulted
# (eog-dev lists Source: eog, which is not copied onto kemi).
# Official Homepage https://wiki.gnome.org/Apps/EyeOfGnome is
# copied exactly. Official ELF stays at official /usr path.
# /opt/eog/eog and /usr/bin/kemi-eog are only symlinks to
# official /usr/bin/eog. Official desktop Name=Image Viewer
# kept; mall app_name=Eye of GNOME Image Viewer (official
# appdata <name>Eye of GNOME</name> plus usual English product
# title; official desktop Name is generic). Relative
# Exec/TryExec rewritten absolute with %U kept. Official GUI
# schema, appdata, man, copyright, changelog (regular file),
# typelib, private libeog.so, plugins, in-app icons, official
# hicolor app icons, and help (including official help-langpack
# dangling symlinks) are packed. Evidence 128 PNG is CREATE-only
# and is not packed. Official SVG is packed once at the official
# path. 0 official .mo in the GUI package.
set -euo pipefail

ROOT=/workspace/t143-20261112-eog
UNPACK="$ROOT/unpack/official/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-eog
VER_UP=3.36.3-0ubuntu1
VER_NAME=3.36.3-0ubuntu1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/eog_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "3.36.3-0ubuntu1kemi1"
assert len(s) == 20, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/eog" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/eog"
test ! -L "$STAGE/pkg/usr/bin/eog"
ln -s "/usr/bin/eog" "$STAGE/pkg/opt/eog/eog"
ln -s "/usr/bin/eog" "$STAGE/pkg/usr/bin/kemi-eog"
test -L "$STAGE/pkg/opt/eog/eog"
test -L "$STAGE/pkg/usr/bin/kemi-eog"
test ! -e "$STAGE/pkg/usr/bin/kemi-eog-plugin"
test ! -e "$STAGE/pkg/usr/lib/kemi-eog"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-eog/stage/pkg/usr/share/applications/org.gnome.eog.desktop")
text = p.read_text()
assert "Name=Image Viewer" in text
assert "Icon=org.gnome.eog" in text
assert "TryExec=eog" in text
assert "Exec=eog %U" in text
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
            out.append("TryExec=/usr/bin/eog" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/eog %U" in new
assert "TryExec=/usr/bin/eog" in new
assert "Name=Image Viewer" in new
assert "Icon=org.gnome.eog" in new
assert "NoDisplay=" not in new
assert "Exec=eog %U" not in new
p.write_text(new)
print("desktop_rewrite_ok")
print([ln for ln in new.splitlines() if ln.startswith(("Exec=", "TryExec=", "Name=", "Icon=")) and "[" not in ln])
PYDESK

# official changelog is a regular file (not a dangling symlink)
python3 - << 'PYCL'
from pathlib import Path
p = Path("/workspace/t143-20261112-eog/stage/pkg/usr/share/doc/eog/changelog.Debian.gz")
assert p.is_file() and not p.is_symlink()
print("official_changelog_regular_file", p.stat().st_size)
PYCL

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/eog/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/eog/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/eog/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-eog (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    eog 3.36.3-0ubuntu1 arm64, KEMI mall
    linuxpkg repack. No same-source
    exact-version hard Depends to bundle
    (no eog-common). eog-dev inspected,
    not packaged. Official ELF stays under
    /usr. Official desktop Name=Image Viewer
    kept; mall app_name=Eye of GNOME Image
    Viewer.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database + icon-cache
# (official hicolor app icons packed) + glib-compile-schemas
# (GUI schema packed). Private libeog.so lives under
# /usr/lib/*/eog/; no ldconfig (official had no scripts).
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
root = Path("/workspace/t143-20261112-eog/stage/pkg")
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
Depends: libc6 (>= 2.29), libcairo2 (>= 1.14.0), libexempi8 (>= 2.5.0), libexif12 (>= 0.6.21-1~), libgdk-pixbuf2.0-0 (>= 2.36.5), libgirepository-1.0-1 (>= 0.9.12), libglib2.0-0 (>= 2.42.0), libgnome-desktop-3-19 (>= 3.17.92), libgtk-3-0 (>= 3.22.0), libjpeg8 (>= 8c), liblcms2-2 (>= 2.2+git20110628), libpeas-1.0-0 (>= 1.0.0), librsvg2-2 (>= 2.44), libx11-6, zlib1g (>= 1:1.1.4), dconf-gsettings-backend | gsettings-backend, gir1.2-gtk-3.0 (>= 3.22.0), shared-mime-info (>= 0.20), gsettings-desktop-schemas (>= 2.91.92), gir1.2-peas-1.0
Recommends: librsvg2-common, yelp
Suggests: eog-plugins
Breaks: eog-plugins (<< 3.16.4-2~)
Provides: eog (= ${VER_UP})
Conflicts: eog
Replaces: eog
Homepage: https://wiki.gnome.org/Apps/EyeOfGnome
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Eye of GNOME graphics viewer program
 Eye of GNOME Image Viewer ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of eog. No
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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-eog-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-eog/debs/kemi-eog_3.36.3-0ubuntu1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/eog",
    "./usr/bin/kemi-eog",
    "./opt/eog/eog",
    "./usr/lib/aarch64-linux-gnu/eog/libeog.so",
    "./usr/lib/aarch64-linux-gnu/eog/girepository-1.0/Eog-3.0.typelib",
    "./usr/lib/aarch64-linux-gnu/eog/plugins/libfullscreen.so",
    "./usr/lib/aarch64-linux-gnu/eog/plugins/libreload.so",
    "./usr/lib/aarch64-linux-gnu/eog/plugins/libstatusbar-date.so",
    "./usr/share/applications/org.gnome.eog.desktop",
    "./usr/share/glib-2.0/schemas/org.gnome.eog.gschema.xml",
    "./usr/share/metainfo/eog.appdata.xml",
    "./usr/share/man/man1/eog.1.gz",
    "./usr/share/doc/eog/changelog.Debian.gz",
    "./usr/share/doc/eog/copyright",
    "./usr/share/doc/kemi-eog/changelog.Debian.gz",
    "./usr/share/doc/kemi-eog/copyright",
    "./usr/share/doc/kemi-eog/changelog.kemi",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.eog.svg",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.eog.Devel.svg",
    "./usr/share/icons/hicolor/symbolic/apps/org.gnome.eog-symbolic.svg",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and ln.endswith("./usr/bin/eog") for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-eog" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/eog/eog" in ln for ln in lines)
# official changelog is a regular file, not a symlink
assert any((ln.startswith("-rw") or ln.startswith("-r-")) and "./usr/share/doc/eog/changelog.Debian.gz" in ln for ln in lines)
# evidence / dev / invented / substitutes not packed
for needle in ("eog-128", "/evidence/", "eog-dev", "humanity-icon-theme", "eom", "atril", "evince", "gpicview", "ristretto", "viewnior", "shotwell"):
    assert not any(needle in ln for ln in lines), needle
# official help packed (including official langpack dangling links)
assert any("./usr/share/help/C/eog/" in ln or "/usr/share/help/C/eog/" in ln for ln in lines)
# 0 mo
assert sum(1 for ln in lines if ln.endswith(".mo")) == 0
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
