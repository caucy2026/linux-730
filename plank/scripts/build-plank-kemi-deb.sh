#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# plank 0.11.89-1 Architecture: arm64 as
# kemi-plank. Official same-source
# exact-version hard Depends libplank1
# (= 0.11.89-1) is bundled; that sibling's
# exact-version same-source hard Depends
# libplank-common (= 0.11.89-1) is bundled
# too. Official libplank-dev and
# libplank-doc are inspected and not
# packaged. Newest official U20 pin:
# focal Release universe only; not in
# focal-updates, focal-security, or
# focal-backports. Official GUI stanza
# Source field is absent and was not
# defaulted; sibling stanzas list
# Source: plank, which is not copied
# onto the kemi control. No Debian
# epoch, no tilde. When bundling,
# uncovered / stricter different-source
# Depends from libplank1 and
# libplank-common (including
# dconf-gsettings-backend |
# gsettings-backend, and libc6 tightened
# from official GUI >= 2.17 to the
# bundled lib's >= 2.29) are merged into
# kemi Depends. Official Suggests
# libplank-doc stay Suggests. Official
# Recommends: none. Official ELFs stay
# at official /usr paths. /opt/plank/plank
# and /usr/bin/kemi-plank are symlinks
# only (official /usr/bin/plank exists).
# Official desktop Name=Plank and
# GenericName=Dock and official appdata
# <name>Plank</name> are kept; mall
# app_name is Plank. Official relative
# Exec is rewritten absolute; TryExec is
# added; official NoDisplay=false is
# kept. Official hicolor SVG app icons
# including 128 are packed at official
# paths. A 128 evidence PNG rasterized
# from the official 128 SVG is used only
# as CREATE --icon and is not packed.
# Official 58 .mo and official schema
# live in bundled common and are packed;
# none of the .mo are invented. Official
# GUI changelog.Debian.gz is a symlink
# into the bundled libplank1 doc dir;
# official symlink is kept after it
# resolves, and also cp -L into the kemi
# doc dir. Official common changelog is
# a different real file and is kept at
# the official path. Official GUI
# lintian override is official packaging
# text and is packed. Official lib
# shlibs and ldconfig triggers are kept
# (no official symbols file). Official
# conffile is kept. desktop-database,
# gtk-update-icon-cache,
# glib-compile-schemas, and ldconfig
# hooks are appended. Official Homepage
# https://launchpad.net/plank is copied
# exactly. KEMI mall version_name
# 0.11.89-1kemi1 is 14 chars. No epoch,
# no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-plank
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-plank
VER_UP=0.11.89-1
VER_NAME=0.11.89-1kemi1
VER_DEB=0.11.89-1kemi1
ARCH=arm64
OFF_GUI="$ROOT/debs/ports-plank_${VER_UP}_arm64.deb"
OFF_LIB="$ROOT/debs/ports-libplank1_${VER_UP}_arm64.deb"
OFF_COMMON="$ROOT/debs/ports-libplank-common_${VER_UP}_all.deb"

python3 - << 'PYCHECK'
s = "0.11.89-1kemi1"
assert len(s) == 14, len(s)
assert ":" not in s
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/lib" "$UNPACK/common" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

rm -rf "$UNPACK/gui"; mkdir -p "$UNPACK/gui"
dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
rm -rf "$UNPACK/lib"; mkdir -p "$UNPACK/lib"
dpkg-deb -x "$OFF_LIB" "$UNPACK/lib"
dpkg-deb -e "$OFF_LIB" "$UNPACK/lib/DEBIAN"
rm -rf "$UNPACK/common"; mkdir -p "$UNPACK/common"
dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"

cp -a "$UNPACK/gui/." "$STAGE/pkg/"
cp -a "$UNPACK/lib/." "$STAGE/pkg/"
cp -a "$UNPACK/common/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"
cp -a "$UNPACK/lib/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$UNPACK/lib/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"
test ! -e "$UNPACK/lib/DEBIAN/symbols"
cp -a "$UNPACK/gui/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

mkdir -p "$STAGE/pkg/opt/plank"
ln -s /usr/bin/plank "$STAGE/pkg/opt/plank/plank"
ln -s plank "$STAGE/pkg/usr/bin/kemi-plank"
test -x "$STAGE/pkg/usr/bin/plank"
test -L "$STAGE/pkg/opt/plank/plank"
test -L "$STAGE/pkg/usr/bin/kemi-plank"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libplank.so.1.0.0"
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libplank.so.1"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/net.launchpad.plank.gschema.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/plank.svg"
test -f "$STAGE/pkg/usr/share/applications/plank.desktop"
test -f "$STAGE/pkg/usr/share/lintian/overrides/plank"
test -f "$STAGE/pkg/etc/apport/crashdb.conf.d/plank-crashdb.conf"
# dev/doc must not be present
if [ -e "$STAGE/pkg/usr/include/plank" ] || [ -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pkgconfig/plank.pc" ] || [ -e "$STAGE/pkg/usr/share/gtk-doc/html/plank" ] || [ -e "$STAGE/pkg/usr/share/vala/vapi/plank.vapi" ]; then
  echo "DEV_OR_DOC_PACKED" >&2
  exit 1
fi

# official GUI changelog symlink into bundled lib must resolve
test -L "$STAGE/pkg/usr/share/doc/plank/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/plank/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libplank1/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libplank1/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libplank-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/libplank-common/changelog.Debian.gz"

MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
echo "mo_count ${MO_COUNT}"
test "$MO_COUNT" -eq 58

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t142-20261112-plank/stage/pkg/usr/share/applications/plank.desktop")
text = p.read_text()

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

keys = untranslated_keys(text)
assert "Name=Plank" in text
assert "GenericName=Dock" in text
assert "Icon=plank" in text
assert "NoDisplay=false" in text
assert "Exec=plank" in text
assert r"\1" not in text
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
assert "Exec=/usr/bin/plank" in new
assert "TryExec=/usr/bin/plank" in new
assert "Name=Plank" in new
assert "GenericName=Dock" in new
assert "Icon=plank" in new
assert "NoDisplay=false" in new
p.write_text(new)
print("desktop_ok")

appdata = Path("/workspace/t142-20261112-plank/stage/pkg/usr/share/metainfo/plank.appdata.xml").read_text()
assert "<name>Plank</name>" in appdata
assert "<id>plank.desktop</id>" in appdata
print("appdata_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/plank/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/plank/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-plank (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    plank 0.11.89-1 arm64, KEMI mall
    linuxpkg repack, bundling official
    same-source exact-version libplank1
    and libplank-common (= 0.11.89-1).
    Official ELF stays under /usr.
    Official desktop Name=Plank and
    GenericName=Dock kept; mall
    app_name=Plank.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v ldconfig >/dev/null 2>&1; then
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
	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
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
python3 - << 'PYHOOK'
from pathlib import Path
post = Path("/workspace/t142-20261112-plank/stage/pkg/DEBIAN/postinst").read_text()
postrm = Path("/workspace/t142-20261112-plank/stage/pkg/DEBIAN/postrm").read_text()
assert "update-desktop-database" in post
assert "gtk-update-icon-cache" in post
assert "glib-compile-schemas" in post
assert "ldconfig" in post
assert '[ "$1" = "remove" ]' in postrm
print("hooks_ok")
PYHOOK

if find "$STAGE/pkg" \( -name 'plank-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: libc6 (>= 2.29), libcairo2 (>= 1.14.0), libgee-0.8-2 (>= 0.8.3), libglib2.0-0 (>= 2.40.0), libgnome-menu-3-0 (>= 3.2.0.1), libgtk-3-0 (>= 3.19.12), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libwnck-3-0 (>= 2.91.6), libbamf3-2 (>= 0.4.0), libdbusmenu-glib4 (>= 0.4.2), libdbusmenu-gtk3-4 (>= 0.4.2), libgdk-pixbuf2.0-0 (>= 2.26.0), libx11-6 (>= 2:1.2.99.901), libxfixes3 (>= 1:5.0), libxi6 (>= 2:1.6.99.1), bamfdaemon, dconf-gsettings-backend | gsettings-backend
Suggests: libplank-doc
Provides: plank (= ${VER_UP}), libplank1 (= ${VER_UP}), libplank-common (= ${VER_UP})
Conflicts: plank, libplank1, libplank-common
Replaces: plank, libplank1, libplank-common
Homepage: https://launchpad.net/plank
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Elegant, simple, clean dock
 Plank 0.11.89-1 — official Ubuntu 20.04
 arm64, KEMI repack of plank, bundling
 official libplank1 and libplank-common.
 Official ELF stays under /usr. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-plank/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: https://launchpad.net/plank\n" in c
assert "Version: 0.11.89-1kemi1\n" in c
assert "dconf-gsettings-backend | gsettings-backend" in c
assert "libc6 (>= 2.29)" in c
assert "Suggests: libplank-doc\n" in c
assert "Source:" not in c
print("control_ok")
PYCTL

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-plank/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif"}:
        continue
    if "lintian/overrides" in str(p.as_posix()):
        continue
    if p.name in {"control", "copyright"}:
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

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, subprocess
from pathlib import Path
p = Path("/workspace/t142-20261112-plank/debs/kemi-plank_0.11.89-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
# content asserts without SIGPIPE
assert any("usr/bin/plank" in ln and not ln.strip().endswith("/usr/bin/plank/") for ln in out.splitlines())
assert any("usr/bin/kemi-plank" in ln for ln in out.splitlines())
assert any("opt/plank/plank" in ln for ln in out.splitlines())
assert any("usr/share/applications/plank.desktop" in ln for ln in out.splitlines())
assert any("usr/share/icons/hicolor/128x128/apps/plank.svg" in ln for ln in out.splitlines())
assert any("usr/lib/aarch64-linux-gnu/libplank.so.1.0.0" in ln for ln in out.splitlines())
assert not any("plank-128.png" in ln for ln in out.splitlines())
assert not any("humanity-icon-theme" in ln for ln in out.splitlines())
assert not any("libplank-dev" in ln for ln in out.splitlines())
assert not any("gtk-doc/html/plank" in ln for ln in out.splitlines())
# kemi-plank and opt must be symlinks
assert any(ln.startswith("lrwxrwxrwx") and "usr/bin/kemi-plank" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "opt/plank/plank" in ln for ln in out.splitlines())
# official binary is a real file, not a symlink
assert any(ln.startswith("-rwxr-xr-x") and "./usr/bin/plank" in ln for ln in out.splitlines())
print("deb_contents_ok")
PYHASH

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-plank-control.txt"
echo "BUILD_OK $OUT"
