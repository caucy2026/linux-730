#!/usr/bin/env bash
# Repack official Ubuntu 20.04 evince 3.36.10-0ubuntu1 arm64
# (focal-updates main) together with bundled same-source
# exact-version hard Depends libevdocument3-4 (= 3.36.10-0ubuntu1)
# and libevview3-3 (= 3.36.10-0ubuntu1). Same-source range Depends
# evince-common (>= 3.36), evince-common (<< 3.37) stays Depends
# and is not bundled. Official GUI Source field is absent and is
# not defaulted. Official Homepage https://wiki.gnome.org/Apps/Evince
# is copied exactly. Official ELF stays at official /usr path.
# /opt/evince/* and /usr/bin/kemi-evince are only symlinks to
# official /usr/bin/evince (opt also links official previewer and
# thumbnailer). No invented kemi-evince-previewer,
# kemi-evince-thumbnailer, or kemi-evinced. Official desktop
# Name=Document Viewer kept; mall app_name=Evince Document Viewer
# (official appdata <name>Evince</name> plus usual English product
# title; official desktop Name is generic). Relative Exec/TryExec
# rewritten absolute with %U kept. Official GUI schema, appdata,
# man, copyright, apparmor, and official hicolor app icons packed.
# Official GUI changelog is a dangling symlink into bundled
# libevdocument3-4; keep the official symlink if it resolves and
# also cp -L into the kemi doc dir. Official common in-app icons /
# help are not packed. Evidence 128 PNG is CREATE-only and is not
# packed. Official apparmor postinst/postrm kept; hooks appended.
set -euo pipefail

ROOT=/workspace/t143-20261112-evince
GUI="$ROOT/unpack/official/data"
LIBDOC="$ROOT/unpack/libdoc/data"
LIBVIEW="$ROOT/unpack/libview/data"
GUICTRL="$ROOT/unpack/official/ctrl"
LIBDOCCTRL="$ROOT/unpack/libdoc/ctrl"
LIBVIEWCTRL="$ROOT/unpack/libview/ctrl"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-evince
VER_UP=3.36.10-0ubuntu1
VER_NAME=3.36.10-0ubuntu1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/evince_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "3.36.10-0ubuntu1kemi1"
assert len(s) == 21, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$GUI/." "$STAGE/pkg/"
cp -a "$LIBDOC/." "$STAGE/pkg/"
cp -a "$LIBVIEW/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

# official changelog symlink into bundled libevdocument3-4 must resolve
python3 - << 'PYCL'
from pathlib import Path
p = Path("/workspace/t143-20261112-evince/stage/pkg/usr/share/doc/evince/changelog.Debian.gz")
assert p.is_symlink()
target = p.parent / p.readlink()
assert target.is_file() and not target.is_symlink(), target
v = Path("/workspace/t143-20261112-evince/stage/pkg/usr/share/doc/libevview3-3/changelog.Debian.gz")
assert v.is_symlink()
vt = v.parent / v.readlink()
assert vt.is_file() and not vt.is_symlink()
print("changelog_symlinks_resolve", target, vt)
PYCL

mkdir -p "$STAGE/pkg/opt/evince" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/evince"
test ! -L "$STAGE/pkg/usr/bin/evince"
test -f "$STAGE/pkg/usr/bin/evince-previewer"
test -f "$STAGE/pkg/usr/bin/evince-thumbnailer"
ln -s "/usr/bin/evince" "$STAGE/pkg/opt/evince/evince"
ln -s "/usr/bin/evince-previewer" "$STAGE/pkg/opt/evince/evince-previewer"
ln -s "/usr/bin/evince-thumbnailer" "$STAGE/pkg/opt/evince/evince-thumbnailer"
ln -s "/usr/bin/evince" "$STAGE/pkg/usr/bin/kemi-evince"
test -L "$STAGE/pkg/opt/evince/evince"
test -L "$STAGE/pkg/usr/bin/kemi-evince"
test ! -e "$STAGE/pkg/usr/bin/kemi-evince-previewer"
test ! -e "$STAGE/pkg/usr/bin/kemi-evince-thumbnailer"
test ! -e "$STAGE/pkg/usr/bin/kemi-evinced"
test ! -e "$STAGE/pkg/usr/libexec/kemi-evinced"

python3 - << 'PYDESK'
from pathlib import Path

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

def rewrite_desktop(path: Path, expect_name: str, expect_exec_prefix: str, expect_try: str, nodisplay: bool | None):
    text = path.read_text()
    assert f"Name={expect_name}" in text
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
                out.append(f"TryExec={expect_try}" + ending)
                added = True
        new_lines = out
    new = "".join(new_lines)
    assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
    assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
    assert expect_exec_prefix in new
    assert f"TryExec={expect_try}" in new
    assert f"Name={expect_name}" in new
    if nodisplay is True:
        assert "NoDisplay=true" in new
    elif nodisplay is False:
        assert "NoDisplay=" not in new
    path.write_text(new)
    print("desktop_ok", path.name, [ln for ln in new.splitlines() if ln.startswith(("Exec=","TryExec=","Name=","Icon=","NoDisplay=")) and "[" not in ln])

base = Path("/workspace/t143-20261112-evince/stage/pkg/usr/share/applications")
rewrite_desktop(
    base / "org.gnome.Evince.desktop",
    expect_name="Document Viewer",
    expect_exec_prefix="Exec=/usr/bin/evince %U",
    expect_try="/usr/bin/evince",
    nodisplay=False,
)
rewrite_desktop(
    base / "org.gnome.Evince-previewer.desktop",
    expect_name="Print Preview",
    expect_exec_prefix="Exec=/usr/bin/evince-previewer %U",
    expect_try="/usr/bin/evince-previewer",
    nodisplay=True,
)
assert "Icon=org.gnome.Evince" in (base / "org.gnome.Evince.desktop").read_text()
assert "Icon=document-print-preview" in (base / "org.gnome.Evince-previewer.desktop").read_text()

# official thumbnailer relative Exec/TryExec -> absolute, keep args
th = Path("/workspace/t143-20261112-evince/stage/pkg/usr/share/thumbnailers/evince.thumbnailer")
t = th.read_text()
out = []
for raw in t.splitlines(keepends=True):
    if raw.startswith("Exec="):
        out.append(rewrite_first_token(raw, "Exec"))
    elif raw.startswith("TryExec="):
        out.append(rewrite_first_token(raw, "TryExec"))
    else:
        out.append(raw)
new = "".join(out)
assert "TryExec=/usr/bin/evince-thumbnailer" in new
assert "Exec=/usr/bin/evince-thumbnailer -s %s %u %o" in new
th.write_text(new)
print("thumbnailer_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/evince/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/evince/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/share/doc/evince/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-evince (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    evince 3.36.10-0ubuntu1 arm64, bundled
    same-source exact-version hard Depends
    libevdocument3-4 and libevview3-3
    (= 3.36.10-0ubuntu1). Same-source range
    Depends evince-common stays Depends, not
    bundled. Official ELF stays under /usr.
    Official desktop Name=Document Viewer
    kept; mall app_name=Evince Document Viewer.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# official apparmor maintainer scripts kept (file-path based, no
# package-name retarget needed); append desktop-database,
# icon-cache (official hicolor packed), glib-compile-schemas
# (GUI schema packed), ldconfig (bundled shared libs).
cp -a "$GUICTRL/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$GUICTRL/postrm" "$STAGE/pkg/DEBIAN/postrm"
cp -a "$GUICTRL/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
  if command -v ldconfig >/dev/null 2>&1; then
    ldconfig
  fi
fi
# End automatically added section
HOOK

cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
  if command -v ldconfig >/dev/null 2>&1; then
    ldconfig
  fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

cat > "$STAGE/pkg/DEBIAN/triggers" << 'TRIG'
# Triggers added by official libevdocument3-4 / libevview3-3 (dh_makeshlibs)
activate-noawait ldconfig
TRIG

cat > "$STAGE/pkg/DEBIAN/shlibs" << 'SHLIBS'
libevdocument3 4 libevdocument3-4 (>= 3.36.10)
libevview3 3 libevview3-3 (>= 3.36.10)
SHLIBS

scan_x86() {
python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-evince/stage/pkg")
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
Depends: evince-common (<< 3.37), evince-common (>= 3.36), gsettings-desktop-schemas, shared-mime-info, dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.14.0), libgdk-pixbuf2.0-0 (>= 2.36.5), libglib2.0-0 (>= 2.51.5), libgnome-desktop-3-19 (>= 3.17.92), libgtk-3-0 (>= 3.21.6), libnautilus-extension1a (>= 3.28), libpango-1.0-0 (>= 1.37.5), libpangocairo-1.0-0 (>= 1.14.0), libsecret-1-0 (>= 0.7), libarchive13 (>= 3.2.1), libdjvulibre21 (>= 3.5.27.1), libgxps2 (>= 0.2.1), libkpathsea6, libpoppler-glib8 (>= 0.34.0), libspectre1 (>= 0.2.3), libsynctex2, libtiff5 (>= 4.0.3), libxml2 (>= 2.7.4), zlib1g (>= 1:1.1.4), gstreamer1.0-plugins-base, libgspell-1-2 (>= 1.8.2), libgstreamer-plugins-base1.0-0 (>= 1.0.0), libgstreamer1.0-0 (>= 1.0.0)
Recommends: default-dbus-session-bus | dbus-session-bus
Suggests: gvfs, nautilus-sendto, poppler-data, unrar
Enhances: nautilus
Breaks: libevdocument3-4 (<< 3.29.91-2~)
Replaces: evince, libevdocument3-4, libevview3-3
Conflicts: evince, libevdocument3-4, libevview3-3
Provides: evince (= ${VER_UP}), libevdocument3-4 (= ${VER_UP}), libevview3-3 (= ${VER_UP}), djvu-viewer, pdf-viewer, postscript-viewer
Homepage: https://wiki.gnome.org/Apps/Evince
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Document (PostScript, PDF) viewer
 Evince Document Viewer ${VER_UP} — official
 Ubuntu 20.04 arm64, KEMI repack of evince
 with bundled libevdocument3-4 and
 libevview3-3 (= ${VER_UP}).
 evince-common is a range Depends, not bundled.
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

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-evince-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-evince/debs/kemi-evince_3.36.10-0ubuntu1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/evince",
    "./usr/bin/evince-previewer",
    "./usr/bin/evince-thumbnailer",
    "./usr/bin/kemi-evince",
    "./opt/evince/evince",
    "./opt/evince/evince-previewer",
    "./opt/evince/evince-thumbnailer",
    "./usr/libexec/evinced",
    "./usr/lib/aarch64-linux-gnu/libevdocument3.so.4.0.0",
    "./usr/lib/aarch64-linux-gnu/libevdocument3.so.4",
    "./usr/lib/aarch64-linux-gnu/libevview3.so.3.0.0",
    "./usr/lib/aarch64-linux-gnu/libevview3.so.3",
    "./usr/lib/aarch64-linux-gnu/evince/4/backends/libpdfdocument.so",
    "./usr/share/applications/org.gnome.Evince.desktop",
    "./usr/share/applications/org.gnome.Evince-previewer.desktop",
    "./usr/share/glib-2.0/schemas/org.gnome.Evince.gschema.xml",
    "./usr/share/metainfo/org.gnome.Evince.appdata.xml",
    "./usr/share/man/man1/evince.1.gz",
    "./usr/share/doc/evince/copyright",
    "./usr/share/doc/evince/changelog.Debian.gz",
    "./usr/share/doc/libevdocument3-4/changelog.Debian.gz",
    "./usr/share/doc/libevview3-3/changelog.Debian.gz",
    "./usr/share/dbus-1/services/org.gnome.evince.Daemon.service",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Evince.svg",
    "./etc/apparmor.d/usr.bin.evince",
    "./etc/apparmor.d/abstractions/evince",
    "./usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libevince-properties-page.so",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and ln.endswith("./usr/bin/evince") for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-evince" in ln for ln in lines)
assert any(ln[0] == "l" and "./usr/share/doc/evince/changelog.Debian.gz" in ln for ln in lines)
for needle in ("evince-128.png", "/evidence/", "kemi-evince-previewer", "kemi-evince-thumbnailer", "kemi-evinced", "evince-common", "humanity-icon-theme"):
    assert not any(needle in ln for ln in lines), needle
# unbundled common help / in-app icons not packed
assert not any("/usr/share/help/" in ln for ln in lines)
assert not any("/usr/share/evince/icons/" in ln for ln in lines)
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
