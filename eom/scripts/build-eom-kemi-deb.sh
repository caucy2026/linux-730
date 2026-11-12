#!/usr/bin/env bash
# Repack official Ubuntu 20.04 eom 1.24.0-1 arm64 (focal universe)
# together with bundled same-source exact-version hard Depends
# eom-common (= 1.24.0-1) Architecture: all. Official unversioned
# Depends gir1.2-eom-1.0 is a gir package and is inspected, not
# packaged; it stays Depends. eom-dev and transitional gir1.2-eom
# are inspected, not packaged. Official GUI Source field is absent
# and is not defaulted (eom-common lists Source: eom, which is not
# copied onto kemi). Official Homepage http://www.mate-desktop.org/
# is copied exactly (http, no scheme upgrade). Official ELF stays
# at official /usr path. /opt/eom/eom and /usr/bin/kemi-eom are
# only symlinks to official /usr/bin/eom. Official desktop
# Name=Eye of MATE Image Viewer kept; mall app_name=Eye of MATE
# Image Viewer (official desktop Name / usual English product
# title; official appdata <name>Eye of MATE</name> is packed with
# bundled common). Relative Exec/TryExec rewritten absolute with
# %U kept. Official GUI schema, man, copyright, lintian override,
# plugins, and bundled-common icons/mo/appdata/help/toolbar are
# packed. Official GUI changelog is a dangling symlink into
# unbundled gir1.2-eom-1.0; do not pack the broken link. Official
# changelog content is cp -L from the inspected gir target into
# the kemi doc dir only. Bundled eom-common changelog is a regular
# file and is kept. Evidence 128 PNG is CREATE-only and is not
# packed (official eom.svg is packed once at the official path
# because common is bundled).
set -euo pipefail

ROOT=/workspace/t143-20261112-eom
GUI="$ROOT/unpack/official/data"
COMMON="$ROOT/unpack/common/data"
GIRDOC="$ROOT/unpack/gir/data/usr/share/doc/gir1.2-eom-1.0/changelog.Debian.gz"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-eom
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/eom_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$GUI/." "$STAGE/pkg/"
cp -a "$COMMON/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

# official GUI changelog dangling into unbundled gir: do not pack
python3 - << 'PYCL'
from pathlib import Path
p = Path("/workspace/t143-20261112-eom/stage/pkg/usr/share/doc/eom/changelog.Debian.gz")
assert p.is_symlink(), p
target = p.readlink()
assert str(target) == "../gir1.2-eom-1.0/changelog.Debian.gz"
resolved = (p.parent / target)
assert not resolved.exists(), resolved
p.unlink()
assert not p.exists()
# bundled common changelog is a regular file
c = Path("/workspace/t143-20261112-eom/stage/pkg/usr/share/doc/eom-common/changelog.Debian.gz")
assert c.is_file() and not c.is_symlink()
print("removed_dangling_official_changelog; common_changelog_regular", c.stat().st_size)
PYCL

mkdir -p "$STAGE/pkg/opt/eom" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/eom"
test ! -L "$STAGE/pkg/usr/bin/eom"
ln -s "/usr/bin/eom" "$STAGE/pkg/opt/eom/eom"
ln -s "/usr/bin/eom" "$STAGE/pkg/usr/bin/kemi-eom"
test -L "$STAGE/pkg/opt/eom/eom"
test -L "$STAGE/pkg/usr/bin/kemi-eom"
# no invented secondary kemi launchers
test ! -e "$STAGE/pkg/usr/bin/kemi-eom-plugin"
test ! -e "$STAGE/pkg/usr/lib/kemi-eom"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-eom/stage/pkg/usr/share/applications/eom.desktop")
text = p.read_text()
assert "Name=Eye of MATE Image Viewer" in text
assert "Icon=eom" in text
assert "TryExec=eom" in text
assert "Exec=eom %U" in text
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
            out.append("TryExec=/usr/bin/eom" + ending)
            added = True
    new_lines = out

new = "".join(new_lines)
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/eom %U" in new
assert "TryExec=/usr/bin/eom" in new
assert "Name=Eye of MATE Image Viewer" in new
assert "Icon=eom" in new
assert "NoDisplay=" not in new
assert "Exec=eom %U" not in new
p.write_text(new)
print("desktop_rewrite_ok")
print([ln for ln in new.splitlines() if ln.startswith(("Exec=", "TryExec=", "Name=", "Icon=")) and "[" not in ln])
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
# official GUI changelog content from inspected (not packaged) gir target
test -f "$GIRDOC"
test ! -L "$GIRDOC"
cp -L "$GIRDOC" "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/eom/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
test ! -e "$STAGE/pkg/usr/share/doc/eom/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-eom (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    eom 1.24.0-1 arm64, bundled same-source
    exact-version hard Depends eom-common
    (= 1.24.0-1, Architecture: all). gir1.2-eom-1.0
    is a gir Depends, inspected not packaged.
    Official ELF stays under /usr.
    Official desktop Name=Eye of MATE Image
    Viewer kept; mall app_name=Eye of MATE
    Image Viewer.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; desktop-database + icon-cache
# (bundled-common hicolor app icons packed) + glib-compile-schemas
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
root = Path("/workspace/t143-20261112-eom/stage/pkg")
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
Depends: gir1.2-eom-1.0, librsvg2-common (>= 2.36.2), mate-desktop-common, shared-mime-info, libgl1-mesa-glx | libgl1, dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.10.0), libexempi8 (>= 2.5.0), libexif12 (>= 0.6.21-1~), libgdk-pixbuf2.0-0 (>= 2.25.2), libgirepository-1.0-1 (>= 0.9.3), libglib2.0-0 (>= 2.51.5), libgtk-3-0 (>= 3.21.5), libjpeg8 (>= 8c), liblcms2-2 (>= 2.2+git20110628), libmate-desktop-2-17 (>= 1.18), libpeas-1.0-0 (>= 1.0.0), librsvg2-2 (>= 2.36.2), libx11-6, libxml2 (>= 2.7.4), zlib1g (>= 1:1.1.4)
Breaks: eom (<= 1.6.1-1), mate-image-viewer (<= 1.0.0-1)
Replaces: eom, eom-common, mate-image-viewer (<= 1.0.0-1)
Conflicts: eom, eom-common
Provides: eom (= ${VER_UP}), eom-common (= ${VER_UP})
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Eye of MATE graphics viewer program
 Eye of MATE Image Viewer ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of eom with
 bundled eom-common (= ${VER_UP}). gir1.2-eom-1.0
 stays a Depends, not packaged.
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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-eom-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-eom/debs/kemi-eom_1.24.0-1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/eom",
    "./usr/bin/kemi-eom",
    "./opt/eom/eom",
    "./usr/lib/aarch64-linux-gnu/eom/plugins/libfullscreen.so",
    "./usr/lib/aarch64-linux-gnu/eom/plugins/libreload.so",
    "./usr/lib/aarch64-linux-gnu/eom/plugins/libstatusbar-date.so",
    "./usr/share/applications/eom.desktop",
    "./usr/share/glib-2.0/schemas/org.mate.eom.gschema.xml",
    "./usr/share/metainfo/eom.appdata.xml",
    "./usr/share/man/man1/eom.1.gz",
    "./usr/share/doc/eom/copyright",
    "./usr/share/doc/eom-common/changelog.Debian.gz",
    "./usr/share/doc/eom-common/copyright",
    "./usr/share/doc/kemi-eom/changelog.Debian.gz",
    "./usr/share/doc/kemi-eom/copyright",
    "./usr/share/doc/kemi-eom/changelog.kemi",
    "./usr/share/icons/hicolor/scalable/apps/eom.svg",
    "./usr/share/eom/eom-toolbar.xml",
    "./usr/share/lintian/overrides/eom",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and ln.endswith("./usr/bin/eom") for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-eom" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/eom/eom" in ln for ln in lines)
# official dangling changelog not packed
assert not any("./usr/share/doc/eom/changelog.Debian.gz" in ln for ln in lines)
# evidence / gir / dev / invented names not packed
for needle in ("eom-128", "/evidence/", "gir1.2-eom", "eom-dev", "humanity-icon-theme", "atril", "evince", "file-roller"):
    assert not any(needle in ln for ln in lines), needle
# bundled common mo packed
assert sum(1 for ln in lines if ln.endswith("eom.mo")) == 136
# bundled help packed
assert any("./usr/share/help/" in ln for ln in lines)
print("content_asserts_ok", "entries", len(lines), "mo", sum(1 for ln in lines if ln.endswith("eom.mo")))
PYASSERT

echo BUILD_OK
