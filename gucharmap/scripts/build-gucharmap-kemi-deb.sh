#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) gucharmap 1:13.0.1-1 arm64 deb as kemi-gucharmap.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · libgucharmap_2_90.so.7 + GTK3 + GDK3 + Pango/PangoCairo + ATK + Cairo + GIO/GObject/GLib + libdl · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libatk1.0-0 >= 1.12.4, libc6 >= 2.17,
# libcairo2 >= 1.2.4, libglib2.0-0 >= 2.37.3, libgtk-3-0 >= 3.4.0,
# libgucharmap-2-90-7 (= 1:13.0.1-1), libpango-1.0-0 >= 1.14.0,
# libpangocairo-1.0-0 >= 1.14.0, dconf-gsettings-backend | gsettings-backend).
# Recommends: yelp.
# Launchpad: gucharmap 1:13.0.1-1 in focal arm64, universe/Release, Published 2020-03-30.
# arm64 binary was built in ubuntu focal PROPOSED and published to Release.
# Official desktop Icon=accessories-character-map (theme icon; not shipped in this deb).
# Exec=gucharmap. Locales / help / desktop / man / metainfo / GSettings schema stay on /usr/share.
# Official changelog.Debian.gz is a dangling symlink into libgucharmap-2-90-7; not copied.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gucharmap
VER_UP=13.0.1
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-gucharmap
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gucharmap-1301-1-focal-unpack}"
UP_DEB="$DL/gucharmap_13.0.1-1_arm64.deb"
EXPECT_SHA=dba92a92154b7f4c3cb4767be08613ce63a0f90871cfc3efa57b0a71516d91bc
EXPECT_BYTES=918884
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gucharmap"
test -f "$UNPACK/usr/share/applications/gucharmap.desktop"
test -f "$UNPACK/usr/share/man/man1/gucharmap.1.gz"
test -L "$UNPACK/usr/share/man/man1/charmap.1.gz"
test -L "$UNPACK/usr/share/man/man1/gnome-character-map.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Charmap.gschema.xml"
test -f "$UNPACK/usr/share/metainfo/gucharmap.metainfo.xml"
test -f "$UNPACK/usr/share/help/C/gucharmap/index.docbook"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/gucharmap"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/gucharmap" "$STAGE/pkg/opt/gucharmap/gucharmap"
chmod 0755 "$STAGE/pkg/opt/gucharmap/gucharmap"
test -x "$STAGE/pkg/opt/gucharmap/gucharmap"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-gucharmap.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/gucharmap/gucharmap" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libgucharmap_2_90.so.7", "libgtk-3.so.0", "libgdk-3.so.0",
            "libpango-1.0.so.0", "libpangocairo-1.0.so.0", "libatk-1.0.so.0",
            "libcairo.so.2", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=none arch=aarch64 n_elf=1")
PY

# Locales, help, schemas, metainfo — keep standard /usr/share paths.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'gucharmap.mo';
         find "$UNPACK/usr/share/help" -type f;
         find "$UNPACK/usr/share/glib-2.0/schemas" -type f -name 'org.gnome.Charmap.gschema.xml';
         find "$UNPACK/usr/share/metainfo" -type f -name 'gucharmap.metainfo.xml')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/gucharmap.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gucharmap.1.gz"
# Official man aliases are relative symlinks; preserve them.
ln -sf gucharmap.1.gz "$STAGE/pkg/usr/share/man/man1/charmap.1.gz"
ln -sf gucharmap.1.gz "$STAGE/pkg/usr/share/man/man1/gnome-character-map.1.gz"

# Upstream docs (skip dangling changelog.Debian.gz -> ../libgucharmap-2-90-7/...)
if [[ -f "$UNPACK/usr/share/doc/gucharmap/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/gucharmap/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi

# Desktop: keep upstream translations / gettext domain; point Exec at the KEMI launcher path.
# Official Icon=accessories-character-map (theme icon; not shipped in this deb).
sed -e 's|^Exec=gucharmap$|Exec=/usr/bin/gucharmap|' \
  "$UNPACK/usr/share/applications/gucharmap.desktop" \
  > "$STAGE/pkg/usr/share/applications/gucharmap.desktop"
grep -q '^Exec=/usr/bin/gucharmap$' "$STAGE/pkg/usr/share/applications/gucharmap.desktop"
grep -q '^Icon=accessories-character-map' "$STAGE/pkg/usr/share/applications/gucharmap.desktop"

ln -sf /opt/gucharmap/gucharmap "$STAGE/pkg/usr/bin/gucharmap"
ln -sf gucharmap "$STAGE/pkg/usr/bin/kemi-gucharmap"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Gucharmap
Source: https://launchpad.net/ubuntu/+source/gucharmap
Homepage: https://wiki.gnome.org/Apps/Gucharmap
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (gucharmap_13.0.1-1_arm64.deb, epoch 1:13.0.1-1) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gucharmap_13.0.1-1_arm64.deb (epoch 1:13.0.1-1)
    repackaged for KEMI as ${PKG}.
  * Layout /opt/gucharmap + /usr/bin/gucharmap; locales, help, desktop,
    man, metainfo and GSettings schema stay on standard /usr/share paths.
    Official desktop Icon=accessories-character-map (theme icon; not
    shipped in this deb). Official changelog.Debian.gz symlink into
    libgucharmap-2-90-7 was not copied (would be dangling).
  * Depends kept for Ubuntu 20.04 (GTK3, libgucharmap-2-90-7 (= 1:13.0.1-1),
    libatk1.0-0, libcairo2, libglib2.0-0, libpango-1.0-0, libpangocairo-1.0-0,
    libc6 >= 2.17, gsettings backend). Recommends: yelp.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:06:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gucharmap ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/gucharmap/; launcher /usr/bin/gucharmap (symlink to /opt/gucharmap/gucharmap).
Locales, help, desktop, man, metainfo and GSettings schema remain on standard /usr/share paths.
Official desktop Icon=accessories-character-map (theme icon; not shipped in this deb).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · libgucharmap_2_90.so.7 + GTK3 + GDK3 + Pango/PangoCairo + ATK + Cairo + GIO/GObject/GLib; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.4.0), libgucharmap-2-90-7 (= 1:13.0.1-1), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend.
Recommends: yelp.
Official Launchpad publication: gucharmap 1:13.0.1-1 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu focal PROPOSED and published to Release.
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
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.4.0), libgucharmap-2-90-7 (= 1:13.0.1-1), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), dconf-gsettings-backend | gsettings-backend
Recommends: yelp
Conflicts: gucharmap
Replaces: gucharmap
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Gucharmap
Description: Unicode character picker and font browser (arm64)
 Gucharmap ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 Unicode character map and font browser.
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gucharmap-control.txt"
