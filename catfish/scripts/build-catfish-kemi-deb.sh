#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) catfish 1.4.13-1 all.deb as kemi-catfish.
# Probe: arch=all · 0 ELF · Python 3 + GTK3 typelibs; Ubuntu 20.04 deps packagable.
# Official Depends already match focal (python3 3.8.2, python3-gi-cairo,
# python3-dbus, python3-pexpect, gir1.2-gtk-3.0, gir1.2-gdkpixbuf-2.0,
# gir1.2-glib-2.0, gir1.2-pango-1.0).
# Official launcher requires GTK 3.10 (focal has 3.24).
# No PEP 585 / PEP 604 typings, walrus, or match-case; safe on Python 3.8.
# UI data stays at compiled-in /usr/share/catfish/; locales on standard
# gettext path. PYTHONPATH points at /opt/catfish/lib/python3/dist-packages.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-catfish
VER_UP=1.4.13
VER_DEB="${VER_UP}-1kemi1"
ARCH=all
PKG=kemi-catfish
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/probe/catfish-1413-1-focal-unpack}"
UP_DEB="$DL/catfish_1.4.13-1_all.deb"
EXPECT_SHA=043ba471620618b0ecd03de876acb2a79ee1c255374139141cd01c59a3e63bf7
EXPECT_BYTES=188780
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/catfish"
test -f "$UNPACK/usr/share/applications/org.xfce.Catfish.desktop"
test -f "$UNPACK/usr/share/catfish/ui/CatfishWindow.ui"
test -f "$UNPACK/usr/lib/python3/dist-packages/catfish_lib/catfishconfig.py"
test -d "$UNPACK/usr/lib/python3/dist-packages/catfish"
test -d "$UNPACK/usr/lib/python3/dist-packages/catfish_lib"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/catfish" \
  "$STAGE/pkg/opt/catfish/bin" \
  "$STAGE/pkg/opt/catfish/lib/python3/dist-packages"

# Python packages under /opt/catfish (hardlink to avoid doubling disk).
cp -al "$UNPACK/usr/lib/python3/dist-packages/catfish" \
  "$STAGE/pkg/opt/catfish/lib/python3/dist-packages/catfish"
cp -al "$UNPACK/usr/lib/python3/dist-packages/catfish_lib" \
  "$STAGE/pkg/opt/catfish/lib/python3/dist-packages/catfish_lib"
if [[ -f "$UNPACK/usr/lib/python3/dist-packages/catfish-1.4.13.egg-info" ]]; then
  cp -al "$UNPACK/usr/lib/python3/dist-packages/catfish-1.4.13.egg-info" \
    "$STAGE/pkg/opt/catfish/lib/python3/dist-packages/catfish-1.4.13.egg-info"
fi

# Official __catfish_data_directory__ is already absolute /usr/share/catfish/;
# get_data_path() uses that path as-is. Keep UI data on that compiled-in path.
cp -al "$UNPACK/usr/share/catfish/." "$STAGE/pkg/usr/share/catfish/"
python3 - << PY
from pathlib import Path
p = Path("$STAGE/pkg/opt/catfish/lib/python3/dist-packages/catfish_lib/catfishconfig.py")
t = p.read_text()
if "__catfish_data_directory__ = '/usr/share/catfish/'" not in t:
    raise SystemExit("DATADIR_UNEXPECTED")
if "__version__ = '1.4.13'" not in t:
    raise SystemExit("VERSION_UNEXPECTED")
print("DATADIR_KEPT /usr/share/catfish/")
PY

# Official launcher: insert sys.path so "import catfish" finds /opt/catfish.
python3 - << PY
from pathlib import Path
src = Path("$UNPACK/usr/bin/catfish").read_text()
needle = "import catfish\ncatfish.main()"
insert = (
    "sys.path.insert(0, \"/opt/catfish/lib/python3/dist-packages\")\n"
    + needle
)
if needle not in src:
    raise SystemExit("LAUNCHER_NEEDLE_MISS")
if src.count(needle) != 1:
    raise SystemExit("LAUNCHER_NEEDLE_AMBIGUOUS")
dst = Path("$STAGE/pkg/opt/catfish/bin/catfish")
dst.write_text(src.replace(needle, insert, 1))
dst.chmod(0o755)
PY
ln -s /opt/catfish/bin/catfish "$STAGE/pkg/usr/bin/catfish"

# Locales stay on the standard gettext path (textdomain 'catfish').
if [[ -d "$UNPACK/usr/share/locale" ]]; then
  while IFS= read -r -d '' mo; do
    rel="${mo#*$UNPACK/usr/share/locale/}"
    dest="$STAGE/pkg/usr/share/locale/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -al "$mo" "$dest"
  done < <(find "$UNPACK/usr/share/locale" -name '*.mo' -print0)
fi

# Desktop / icons / metainfo / man / docs stay under /usr/share.
cp -a --remove-destination \
  "$UNPACK/usr/share/applications/org.xfce.Catfish.desktop" \
  "$STAGE/pkg/usr/share/applications/org.xfce.Catfish.desktop"
# Official already has Exec=/usr/bin/catfish %f
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/org.xfce.Catfish.desktop"; then
  sed -i '/^Exec=/a TryExec=/usr/bin/catfish' \
    "$STAGE/pkg/usr/share/applications/org.xfce.Catfish.desktop"
fi
grep -q '^Exec=/usr/bin/catfish %f' "$STAGE/pkg/usr/share/applications/org.xfce.Catfish.desktop"
grep -q '^TryExec=/usr/bin/catfish' "$STAGE/pkg/usr/share/applications/org.xfce.Catfish.desktop"

cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/scalable/apps/catfish.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/catfish.svg"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/catfish.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/catfish.appdata.xml"
if [[ -f "$UNPACK/usr/share/man/man1/catfish.1.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/man/man1/catfish.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/catfish.1.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/catfish/copyright" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/catfish/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/catfish/changelog.Debian.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/catfish/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/catfish/README" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/catfish/README" \
    "$STAGE/pkg/usr/share/doc/$PKG/README.upstream"
fi

# Probe report: 0 ELF (Python + GTK typelibs + data).
REPORT="$ROOT/probe/kemi-catfish.json"
python3 - << PY
import json
from pathlib import Path
root = Path("$STAGE/pkg")
elfs = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        magic = f.read(4)
    if magic.startswith(b"\x7fELF"):
        elfs.append(str(p.relative_to(root)))
conf = (root / "opt/catfish/lib/python3/dist-packages/catfish_lib/catfishconfig.py").read_text()
launch = (root / "opt/catfish/bin/catfish").read_text()
if "__catfish_data_directory__ = '/usr/share/catfish/'" not in conf:
    raise SystemExit("CONF_DATADIR_CHANGED")
if "/opt/catfish/lib/python3/dist-packages" not in launch:
    raise SystemExit("LAUNCHER_PATH_NOT_INSERTED")
if not (root / "usr/share/catfish/ui/CatfishWindow.ui").is_file():
    raise SystemExit("UI_DATA_MISSING")
if not (root / "usr/bin/catfish").is_symlink():
    raise SystemExit("USR_BIN_NOT_SYMLINK")
report = {
    "package": "$PKG",
    "version": "$VER_DEB",
    "architecture": "$ARCH",
    "target_arch": "arm64",
    "max_glibc": "2.31",
    "elf_count": len(elfs),
    "elfs": elfs,
    "requiredGlibc": None,
    "pass": len(elfs) == 0,
    "note": "arch=all Python/GTK3 file search; no native ELF. Runtime: python3 (focal 3.8.2), python3-gi-cairo, python3-dbus, python3-pexpect, gir1.2-gtk-3.0, gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-pango-1.0 — all packagable on Ubuntu 20.04 focal arm64. Official launcher checks Gtk 3.10 (focal 3.24). No PEP 585 typings. UI data stays at compiled-in /usr/share/catfish/.",
}
Path("$REPORT").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
if elfs:
    raise SystemExit("UNEXPECTED_ELF")
print("PROBE_PASS elf_count=0")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 (focal) catfish_1.4.13-1_all.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/catfish + /usr/bin/catfish; UI data kept at compiled-in
    /usr/share/catfish/.
  * Depends kept for Ubuntu 20.04 (python3, python3-gi-cairo,
    python3-dbus, python3-pexpect, gir1.2-gtk-3.0 and related typelibs).
  * Python 3.8 compatible (no PEP 585 typings).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:16:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Catfish ${VER_UP} — official Ubuntu 20.04 (focal) all.deb, KEMI repack.

Installs under /opt/catfish/; launcher /usr/bin/catfish.
UI data stays at /usr/share/catfish/ (compiled-in path).
No native ELF (Python + GTK3 typelibs + data). Ubuntu 20.04 / glibc 2.31 OK.
Runtime: python3 (focal 3.8), python3-gi-cairo, python3-dbus, python3-pexpect,
gir1.2-gtk-3.0, gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-pango-1.0.
Recommends: mlocate | locate.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-pango-1.0, python3-dbus, python3-gi-cairo, python3-pexpect, python3:any
Recommends: mlocate | locate
Conflicts: catfish
Replaces: catfish
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://docs.xfce.org/apps/catfish/start
Description: Catfish file searching tool (GTK3)
 Catfish ${VER_UP} — official Ubuntu 20.04 all.deb, KEMI repack.
 Lightweight GTK3 file search (Python + typelibs). glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v python3 >/dev/null 2>&1; then
  python3 -m compileall -q /opt/catfish/lib/python3/dist-packages >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-catfish-control.txt"
