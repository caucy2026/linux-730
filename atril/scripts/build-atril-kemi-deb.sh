#!/usr/bin/env bash
# Repack official Ubuntu 20.04 atril 1.24.0-1ubuntu0.2 arm64 together with
# bundled same-source exact-version hard Depends libatrildocument3 and
# libatrilview3 (= 1.24.0-1ubuntu0.2) arm64, as kemi-atril. Official
# same-source range Depends atril-common (>= 1.24.0-1ubuntu0.2) stays
# Depends and is not bundled. Official GUI Source field is absent and is
# not defaulted (sibling common/libs list Source: atril, which is not
# copied onto kemi). Official Homepage https://mate-desktop.org/ is
# copied exactly. Official ELFs stay at official /usr paths.
# /opt/atril/* and /usr/bin/kemi-atril are only symlinks to official
# /usr/bin commands. No invented kemi-atril-previewer,
# kemi-atril-thumbnailer, or kemi-atrild. Official desktop
# Name=Atril Document Viewer kept; relative Exec/TryExec rewritten
# absolute with %U kept. Official GUI schema and man packed. Official
# 134 .mo, appdata, help, and hicolor apps/atril icons live only in
# unbundled common and are not packed. Official GUI changelog symlink
# into bundled libatrildocument3 is kept and cp -L into the kemi doc
# dir. Evidence 128 PNG is CREATE-only and is not packed.
set -euo pipefail

ROOT=/workspace/t143-20261112-atril
GUI="$ROOT/unpack/official/data"
LIBDOC="$ROOT/unpack/libdoc/data"
LIBVIEW="$ROOT/unpack/libview/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-atril
VER_UP=1.24.0-1ubuntu0.2
VER_NAME=1.24.0-1ubuntu0.2kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/atril_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "1.24.0-1ubuntu0.2kemi1"
assert len(s) == 22, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
cp -a "$GUI/." "$STAGE/pkg/"
# bundle exact-version same-source libs (not atril-common)
cp -a "$LIBDOC/." "$STAGE/pkg/"
cp -a "$LIBVIEW/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"

mkdir -p "$STAGE/pkg/opt/atril" "$STAGE/pkg/usr/bin"
test -f "$STAGE/pkg/usr/bin/atril"
test -f "$STAGE/pkg/usr/bin/atril-previewer"
test -f "$STAGE/pkg/usr/bin/atril-thumbnailer"
test ! -L "$STAGE/pkg/usr/bin/atril"
ln -sfn "/usr/bin/atril" "$STAGE/pkg/opt/atril/atril"
ln -sfn "/usr/bin/atril-previewer" "$STAGE/pkg/opt/atril/atril-previewer"
ln -sfn "/usr/bin/atril-thumbnailer" "$STAGE/pkg/opt/atril/atril-thumbnailer"
ln -sfn "/usr/bin/atril" "$STAGE/pkg/usr/bin/kemi-atril"
test -L "$STAGE/pkg/opt/atril/atril"
test -L "$STAGE/pkg/usr/bin/kemi-atril"
test ! -e "$STAGE/pkg/usr/bin/kemi-atril-previewer"
test ! -e "$STAGE/pkg/usr/bin/kemi-atril-thumbnailer"
test ! -e "$STAGE/pkg/usr/bin/kemi-atrild"
test ! -e "$STAGE/pkg/opt/atril/atrild"

python3 - << 'PYDESK'
from pathlib import Path

p = Path("/workspace/t143-20261112-atril/stage/pkg/usr/share/applications/atril.desktop")
text = p.read_text()
assert "Name=Atril Document Viewer" in text
assert "GenericName=Document Viewer" in text
assert "Icon=atril" in text
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
new = "".join(new_lines)
assert seen_try
assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1
assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1
assert "Exec=/usr/bin/atril %U" in new
assert "TryExec=/usr/bin/atril" in new
assert "TryExec=atril\n" not in new
p.write_text(new)
print([ln for ln in new.splitlines() if ln.startswith(("Exec=","TryExec=","Name=","GenericName=","Icon=")) and "[" not in ln])
PYDESK

# official GUI changelog is a symlink into bundled libatrildocument3;
# keep official symlink (resolves after bundling) and cp -L into kemi doc
mkdir -p "$STAGE/pkg/usr/share/doc/kemi-atril"
CHG_OFF="$STAGE/pkg/usr/share/doc/atril/changelog.Debian.gz"
test -L "$CHG_OFF"
test -e "$CHG_OFF"
cp -L "$CHG_OFF" "$STAGE/pkg/usr/share/doc/kemi-atril/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/atril/copyright" "$STAGE/pkg/usr/share/doc/kemi-atril/copyright"

KEMI_DATE="Thu, 12 Nov 2026 17:37:02 +0800"
cat > "$STAGE/pkg/usr/share/doc/kemi-atril/changelog.kemi" << EOT
kemi-atril (${VER_NAME}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates/security
    universe) atril 1.24.0-1ubuntu0.2 arm64,
    bundled same-source exact-version hard
    Depends libatrildocument3 and libatrilview3
    (= 1.24.0-1ubuntu0.2). Same-source range
    Depends atril-common stays Depends, not
    bundled. Official ELF stays under /usr.
    Official desktop Name=Atril Document Viewer
    kept; mall app_name=Atril Document Viewer.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# official GUI had no maintainer scripts. Bundled shared libs need
# ldconfig. Official GUI schema packed (not from unbundled common).
# no icon-cache: official hicolor apps/atril icons are only in
# unbundled common and are not packed.
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
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

cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
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

# official bundled-lib shlibs / ldconfig triggers
cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOF'
libatrildocument 3 libatrildocument3 (>= 1.24.0)
libatrilview 3 libatrilview3 (>= 1.24.0)
EOF
cat > "$STAGE/pkg/DEBIAN/triggers" << 'EOF'
# Triggers added by official libatrildocument3 / libatrilview3 (dh_makeshlibs)
activate-noawait ldconfig
EOF

scan_x86() {
python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-atril/stage/pkg")
pat = re.compile(r"(x86_64|amd64|i386|i686|x86-64)", re.I)
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
    if b"\0" in raw[:4096]:
        continue
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        continue
    rel = str(p.relative_to(root))
    if "lintian" in rel or p.name == "overrides":
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if pat.search(line):
            bad.append((rel, i, line[:180]))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86
}

scan_x86

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
# keep closer-to-du Installed-Size; official undercount is not a defect
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: atril-common (>= 1.24.0-1ubuntu0.2), shared-mime-info, dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcaja-extension1 (>= 1.18), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.61.2), libgtk-3-0 (>= 3.21.5), libice6 (>= 1:1.0.0), libsecret-1-0 (>= 0.7), libsm6, libxml2 (>= 2.7.4), libjs-mathjax, libarchive13 (>= 3.4.0), libcairo2 (>= 1.14.0), libdjvulibre21 (>= 3.5.27.1), libgxps2 (>= 0.2.1), libkpathsea6, libpango-1.0-0 (>= 1.14.0), libpoppler-glib8 (>= 0.22.1), libspectre1 (>= 0.2.3), libsynctex2, libtiff5 (>= 4.0.3), zlib1g (>= 1:1.1.4), libwebkit2gtk-4.0-37 (>= 2.5.3)
Recommends: default-dbus-session-bus | dbus-session-bus, gvfs
Suggests: caja, poppler-data, unrar
Breaks: libatrildocument3 (<< 1.13.0), libatril (<< 1.9.0)
Replaces: atril, libatrildocument3, libatrilview3, libatril (<< 1.9.0)
Conflicts: atril, libatrildocument3, libatrilview3
Provides: atril (= ${VER_UP}), libatrildocument3 (= ${VER_UP}), libatrilview3 (= ${VER_UP}), djvu-viewer, pdf-viewer, postscript-viewer
Homepage: https://mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: MATE document viewer
 Atril Document Viewer 1.24.0-1ubuntu0.2 — official
 Ubuntu 20.04 arm64, KEMI repack of atril
 with bundled libatrildocument3 and
 libatrilview3 (= 1.24.0-1ubuntu0.2).
 atril-common is a range Depends, not bundled.
 glibc<=2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

scan_x86

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
# do not overwrite the published SHA-pinned deb from this recipe check
OUT_BUILD="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.rebuild.deb"
rm -f "$OUT_BUILD"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT_BUILD"

python3 - << PYHASH
import hashlib
from pathlib import Path
p = Path("$OUT_BUILD")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB_REBUILD", p, p.stat().st_size, h)
off = Path("$OFFICIAL_DEB")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert p.stat().st_size != off.stat().st_size or h != oh
print("differs_from_official", off.stat().st_size, oh)
pinned = Path("$OUT")
if pinned.exists():
    ph = hashlib.sha256(pinned.read_bytes()).hexdigest()
    print("PINNED_PUBLISHED", pinned.stat().st_size, ph)
import subprocess
out = subprocess.check_output(["dpkg-deb", "-c", str(p if not pinned.exists() else pinned)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/atril",
    "./usr/bin/atril-previewer",
    "./usr/bin/atril-thumbnailer",
    "./usr/bin/kemi-atril",
    "./opt/atril/atril",
    "./opt/atril/atril-previewer",
    "./opt/atril/atril-thumbnailer",
    "./usr/lib/atril/atrild",
    "./usr/lib/aarch64-linux-gnu/libatrildocument.so.3.0.0",
    "./usr/lib/aarch64-linux-gnu/libatrilview.so.3.0.0",
    "./usr/share/applications/atril.desktop",
    "./usr/share/doc/atril/changelog.Debian.gz",
    "./usr/share/doc/atril/copyright",
    "./usr/share/doc/libatrildocument3/changelog.Debian.gz",
    "./usr/share/doc/kemi-atril/changelog.Debian.gz",
    "./usr/share/doc/kemi-atril/copyright",
    "./usr/share/man/man1/atril.1.gz",
    "./usr/share/glib-2.0/schemas/org.mate.Atril.gschema.xml",
]
for n in need:
    assert any(n in ln for ln in lines), n
assert any(ln.startswith("-rw") and "./usr/bin/atril" in ln and "kemi-atril" not in ln.split()[-1] for ln in lines) or any("./usr/bin/atril " in ln or ln.endswith("./usr/bin/atril") for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-atril" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/atril/atril" in ln for ln in lines)
for needle in ("atril-128.png", "evidence", "kemi-atril-previewer", "kemi-atril-thumbnailer", "kemi-atrild", "humanity-icon-theme", "atril.appdata", "hicolor/scalable/apps/atril.svg"):
    assert not any(needle in ln for ln in lines), needle
assert sum(1 for ln in lines if ln.endswith("atril.mo")) == 0
print("content_asserts_ok", "entries", len(lines))
PYHASH

echo BUILD_OK
