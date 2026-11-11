#!/usr/bin/env bash
# Wrap official Ubuntu/Debian meld 3.22.3-2 all.deb as kemi-meld.
# Probe: arch=all · 0 ELF · Python/GTK3 + GtkSourceView 4; Ubuntu 20.04 deps packagable.
# Official Depends already match focal (python3 3.8.2, python3-gi 3.36.0,
# gir1.2-gtk-3.0, gir1.2-gtksource-4 4.6.0, patch, dconf).
# Runtime check in official launcher: Python 3.6, Gtk 3.20, GLib 2.48,
# GtkSource 4.0, pygobject 3.30, pycairo 1.15.
# Meld 3.24.1 official all.deb was not used: PEP 585 typings
# (dict[int, str] / tuple[...]) without from __future__ import annotations
# would fail at import on Ubuntu 20.04 Python 3.8.
# DATADIR rewritten from /usr/share/meld to /opt/meld/share/meld;
# PYTHONPATH points at /opt/meld/lib/python3/dist-packages.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-meld
VER_UP=3.22.3
VER_DEB="${VER_UP}-1kemi1"
ARCH=all
PKG=kemi-meld
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/probe/meld-3223-unpack}"
UP_DEB="$DL/meld_3.22.3-2_all.deb"
EXPECT_SHA=c83842cd5ea7c2d228425e98d04d7c1bc8cffeafdc26706a5b7c11fa895a92b2
EXPECT_BYTES=591508
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/meld"
test -f "$UNPACK/usr/share/applications/org.gnome.Meld.desktop"
test -f "$UNPACK/usr/share/meld/org.gnome.Meld.gresource"
test -f "$UNPACK/usr/lib/python3/dist-packages/meld/conf.py"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/mime/packages" \
  "$STAGE/pkg/opt/meld/bin" \
  "$STAGE/pkg/opt/meld/lib/python3/dist-packages" \
  "$STAGE/pkg/opt/meld/share"

# Python package + app data under /opt/meld (hardlink to avoid doubling disk).
cp -al "$UNPACK/usr/lib/python3/dist-packages/meld" \
  "$STAGE/pkg/opt/meld/lib/python3/dist-packages/meld"
cp -al "$UNPACK/usr/share/meld" "$STAGE/pkg/opt/meld/share/meld"

# Official DATADIR was /usr/share/meld; point at /opt/meld/share/meld.
# LOCALEDIR stays the standard gettext path.
python3 - << PY
from pathlib import Path
p = Path("$STAGE/pkg/opt/meld/lib/python3/dist-packages/meld/conf.py")
t = p.read_text()
old = "DATADIR = '/usr/share/meld'"
new = "DATADIR = '/opt/meld/share/meld'"
if old not in t:
    raise SystemExit("DATADIR_REWRITE_MISS")
p.write_text(t.replace(old, new, 1))
# keep LOCALEDIR = '/usr/share/locale'
if "LOCALEDIR = '/usr/share/locale'" not in p.read_text():
    raise SystemExit("LOCALEDIR_UNEXPECTED")
PY

# Official launcher with sys.path so "import meld" finds /opt/meld.
python3 - << PY
from pathlib import Path
src = Path("$UNPACK/usr/bin/meld").read_text()
needle = "import meld.conf  # noqa: E402"
insert = (
    "sys.path.insert(0, \"/opt/meld/lib/python3/dist-packages\")\n"
    + needle
)
if needle not in src:
    raise SystemExit("LAUNCHER_NEEDLE_MISS")
if src.count(needle) != 1:
    raise SystemExit("LAUNCHER_NEEDLE_AMBIGUOUS")
dst = Path("$STAGE/pkg/opt/meld/bin/meld")
dst.write_text(src.replace(needle, insert, 1))
dst.chmod(0o755)
PY
ln -s /opt/meld/bin/meld "$STAGE/pkg/usr/bin/meld"

# Locales stay on the standard gettext path.
if [[ -d "$UNPACK/usr/share/locale" ]]; then
  while IFS= read -r -d '' mo; do
    rel="${mo#*$UNPACK/usr/share/locale/}"
    dest="$STAGE/pkg/usr/share/locale/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -al "$mo" "$dest"
  done < <(find "$UNPACK/usr/share/locale" -name '*.mo' -print0)
fi

# Help (yelp) stays under /usr/share/help.
if [[ -d "$UNPACK/usr/share/help" ]]; then
  mkdir -p "$STAGE/pkg/usr/share"
  cp -al "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
fi

# Desktop / icons / schema / metainfo / mime / man / docs stay under /usr/share.
cp -a --remove-destination \
  "$UNPACK/usr/share/applications/org.gnome.Meld.desktop" \
  "$STAGE/pkg/usr/share/applications/org.gnome.Meld.desktop"
sed -i -e 's|^Exec=meld %F|Exec=/usr/bin/meld %F|' \
  "$STAGE/pkg/usr/share/applications/org.gnome.Meld.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/org.gnome.Meld.desktop"; then
  sed -i '/^Exec=/a TryExec=/usr/bin/meld' \
    "$STAGE/pkg/usr/share/applications/org.gnome.Meld.desktop"
fi
grep -q '^Exec=/usr/bin/meld %F' "$STAGE/pkg/usr/share/applications/org.gnome.Meld.desktop"

cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Meld.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Meld.svg"
cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Meld-symbolic.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps/org.gnome.Meld-symbolic.svg"
cp -a --remove-destination \
  "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.meld.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.meld.gschema.xml"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/org.gnome.Meld.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.gnome.Meld.appdata.xml"
cp -a --remove-destination \
  "$UNPACK/usr/share/mime/packages/org.gnome.Meld.xml" \
  "$STAGE/pkg/usr/share/mime/packages/org.gnome.Meld.xml"
if [[ -f "$UNPACK/usr/share/man/man1/meld.1.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/man/man1/meld.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/meld.1.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/meld/copyright" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/meld/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/meld/changelog.Debian.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/meld/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/meld/NEWS.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/meld/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi

# Probe report: 0 ELF (Python + GTK typelibs + data).
REPORT="$ROOT/probe/kemi-meld.json"
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
# sanity: rewritten paths present
conf = (root / "opt/meld/lib/python3/dist-packages/meld/conf.py").read_text()
launch = (root / "opt/meld/bin/meld").read_text()
if "DATADIR = '/opt/meld/share/meld'" not in conf:
    raise SystemExit("CONF_DATADIR_NOT_REWRITTEN")
if "/opt/meld/lib/python3/dist-packages" not in launch:
    raise SystemExit("LAUNCHER_PATH_NOT_INSERTED")
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
    "note": "arch=all Python/GTK3 diff+merge; no native ELF. Runtime: python3>=3.6 (focal 3.8.2), python3-gi>=3.20 (3.36.0), python3-gi-cairo, gir1.2-gtk-3.0 (GTK 3.24), gir1.2-gtksource-4 (4.6.0), patch, dconf-gsettings-backend. Official launcher checks Python 3.6 / Gtk 3.20 / GLib 2.48 / GtkSource 4.0 / pygobject 3.30 / pycairo 1.15 — all packagable on Ubuntu 20.04 focal arm64. Meld 3.24.1 official all.deb skipped (PEP 585 typings break Python 3.8 import).",
}
Path("$REPORT").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
if elfs:
    raise SystemExit("UNEXPECTED_ELF")
print("PROBE_PASS elf_count=0")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu/Debian meld_3.22.3-2_all.deb repackaged for KEMI as ${PKG}.
  * Layout /opt/meld + /usr/bin/meld; DATADIR rewritten to /opt/meld/share/meld.
  * Depends kept for Ubuntu 20.04 (python3, python3-gi, gir1.2-gtk-3.0,
    gir1.2-gtksource-4, patch).
  * Meld 3.24.1 official all.deb not used (Python 3.9 typing, breaks 3.8).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Meld ${VER_UP} — official Ubuntu/Debian all.deb, KEMI repack.

Installs under /opt/meld/; launcher /usr/bin/meld.
No native ELF (Python + GTK3 typelibs + data). Ubuntu 20.04 / glibc 2.31 OK.
Runtime: python3 (>= 3.6; focal 3.8), python3-gi (>= 3.20), python3-gi-cairo,
gir1.2-gtk-3.0, gir1.2-gtksource-4, patch, a GSettings backend.
Meld 3.24.1 official all.deb needs Python 3.9 typings and is not used.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: gnome
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: dconf-gsettings-backend | gsettings-backend, gir1.2-gtk-3.0, gir1.2-gtksource-4, patch, python3, python3-gi (>= 3.20), python3-gi-cairo
Recommends: yelp
Conflicts: meld
Replaces: meld
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://meld.app
Description: Meld graphical diff and merge tool (GTK3)
 Meld ${VER_UP} — official Ubuntu/Debian all.deb, KEMI repack.
 Graphical file and directory diff/merge (Python + GTK3). glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v python3 >/dev/null 2>&1; then
  python3 -m compileall -q /opt/meld/lib/python3/dist-packages/meld >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-meld-control.txt"
