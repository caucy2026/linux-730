#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) ghex 3.18.4-1 arm64 deb as kemi-ghex.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX ·
#   libgtkhex-3 + ATK + GObject/GLib/GIO + GTK3 + GDK3 + PangoCairo + Pango +
#   Cairo + libc · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libatk1.0-0 >= 1.12.4,
#   libc6 >= 2.17, libcairo2 >= 1.2.4, libglib2.0-0 >= 2.37.3,
#   libgtk-3-0 >= 3.3.16, libgtkhex-3-0 >= 3.0.0, libpango-1.0-0 >= 1.14.0,
#   libpangocairo-1.0-0 >= 1.14.0, dconf-gsettings-backend | gsettings-backend).
# Launchpad: ghex 3.18.4-1 in focal arm64, universe/Release, Published 2019-10-18.
# arm64 binary was built in ubuntu eoan PROPOSED (build 17805238) and copied
# to focal Release (HTML: Copied from ubuntu eoan-proposed arm64).
# Official desktop Icon=org.gnome.GHex (hicolor shipped). Exec=ghex %F.
# UI is compiled-in as a GResource (/org/gnome/ghex/ghex-ui.xml).
# Locale path compiled in as /usr/share/locale (this deb ships no .mo;
# translations may come from language packs). Help / schemas / icons /
# metainfo / man stay on standard /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-ghex
VER_UP=3.18.4
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-ghex
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/ghex-3.18.4-1-focal-unpack}"
UP_DEB="$DL/ghex_3.18.4-1_arm64.deb"
EXPECT_SHA=71092110d9afecdb46043bc93ea06c3f5c1fe540d87912494a0f69cb309a269e
EXPECT_BYTES=234188
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/ghex"
test -f "$UNPACK/usr/share/applications/org.gnome.GHex.desktop"
test -f "$UNPACK/usr/share/man/man1/ghex.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.GHex.gschema.xml"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.GHex.png"
test -f "$UNPACK/usr/share/metainfo/org.gnome.GHex.appdata.xml"
test -f "$UNPACK/usr/share/help/C/ghex/index.docbook"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/ghex"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/ghex" "$STAGE/pkg/opt/ghex/ghex"
chmod 0755 "$STAGE/pkg/opt/ghex/ghex"
test -x "$STAGE/pkg/opt/ghex/ghex"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-ghex.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/ghex/ghex" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None,):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libgtkhex-3.so.0", "libatk-1.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0", "libgio-2.0.so.0", "libgtk-3.so.0",
            "libgdk-3.so.0", "libpangocairo-1.0.so.0", "libpango-1.0.so.0",
            "libcairo.so.2", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Help, schemas, icons, metainfo stay on standard /usr/share paths.
# This official deb ships no locale .mo files.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/help" -type f;
         find "$UNPACK/usr/share/glib-2.0/schemas" -type f -name 'org.gnome.GHex.gschema.xml';
         find "$UNPACK/usr/share/icons/hicolor" -type f;
         find "$UNPACK/usr/share/metainfo" -type f -name 'org.gnome.GHex.appdata.xml')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/ghex.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/ghex.1.gz"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/ghex/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/ghex/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi

# Desktop: keep upstream fields; point Exec at the KEMI launcher path.
# Official Icon=org.gnome.GHex (hicolor shipped in this deb).
sed -e 's|^Exec=ghex %F$|Exec=/usr/bin/ghex %F|' \
  "$UNPACK/usr/share/applications/org.gnome.GHex.desktop" \
  > "$STAGE/pkg/usr/share/applications/org.gnome.GHex.desktop"
grep -q '^Exec=/usr/bin/ghex %F$' "$STAGE/pkg/usr/share/applications/org.gnome.GHex.desktop"
grep -q '^Icon=org.gnome.GHex' "$STAGE/pkg/usr/share/applications/org.gnome.GHex.desktop"

ln -sf /opt/ghex/ghex "$STAGE/pkg/usr/bin/ghex"
ln -sf ghex "$STAGE/pkg/usr/bin/kemi-ghex"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Ghex
Source: https://launchpad.net/ubuntu/+source/ghex
Homepage: https://wiki.gnome.org/Apps/Ghex
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (ghex_3.18.4-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 ghex_3.18.4-1_arm64.deb
    repackaged for KEMI as ${PKG}.
  * Layout /opt/ghex + /usr/bin/ghex; help, desktop, man, hicolor
    icons, GSettings schema and metainfo stay on standard /usr/share
    paths. Official desktop Icon=org.gnome.GHex (hicolor shipped).
    UI is compiled-in as a GResource (/org/gnome/ghex/ghex-ui.xml).
    This official deb ships no locale .mo files.
  * Depends kept for Ubuntu 20.04 (GTK3, ATK, Cairo, Pango, GLib,
    libgtkhex-3-0, libc6 >= 2.17, gsettings backend).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:14:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GHex ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/ghex/; launcher /usr/bin/ghex (symlink to /opt/ghex/ghex).
Help, desktop, man, hicolor icons, GSettings schema and metainfo remain on standard /usr/share paths.
Official desktop Icon=org.gnome.GHex (hicolor shipped in this deb).
UI is compiled-in as a GResource (/org/gnome/ghex/ghex-ui.xml).
This official deb ships no locale .mo files (compiled locale path is /usr/share/locale).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · libgtkhex-3 + ATK + GObject/GLib/GIO + GTK3 + GDK3 + PangoCairo + Pango + Cairo; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.3.16), libgtkhex-3-0 (>= 3.0.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend.
Official Launchpad publication: ghex 3.18.4-1 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu eoan PROPOSED (build 17805238) and copied to focal Release.
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
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.3.16), libgtkhex-3-0 (>= 3.0.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend
Conflicts: ghex
Replaces: ghex
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Ghex
Description: GNOME Hex editor for files (arm64)
 GHex ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 hex/ASCII file editor.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-ghex-control.txt"
