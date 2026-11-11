#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) mtPaint 3.40 arm64 deb as kemi-mtpaint.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK2 + gif/tiff/jpeg/png/freetype · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libfreetype6, libgdk-pixbuf2.0-0,
# libgif7, libglib2.0-0, libgtk2.0-0, libjpeg8, libpango-1.0-0, libpng16-16, libtiff5,
# libx11-6, zlib1g, gtklp). gtklp is in focal universe (1.3.1-0.1build1).
# Launchpad: mtpaint 3.40-3 in focal arm64, universe/Release, Published 2019-10-18.
# arm64 binary was built in yakkety and copied unchanged into focal Release.
# No compiled-in /usr/share/mtpaint data dir; locales / pixmaps / desktop / man stay on /usr/share.
# Optional handbook paths /usr/share/doc/mtpaint/index.html are not in the official deb.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-mtpaint
VER_UP=3.40
VER_DEB="${VER_UP}-3kemi1"
ARCH=arm64
PKG=kemi-mtpaint
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/mtpaint-340-3-focal-unpack}"
UP_DEB="$DL/mtpaint_3.40-3_arm64.deb"
EXPECT_SHA=6440875684c8145a84b9bb6e213c71e9d79b6f6c16a3342b3b3d79e76a1c1adf
EXPECT_BYTES=471572
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/mtpaint"
test -f "$UNPACK/usr/share/applications/mtpaint.desktop"
test -f "$UNPACK/usr/share/pixmaps/mtpaint.png"
test -f "$UNPACK/usr/share/man/man1/mtpaint.1.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/mtpaint"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/mtpaint" "$STAGE/pkg/opt/mtpaint/mtpaint"
chmod 0755 "$STAGE/pkg/opt/mtpaint/mtpaint"
test -x "$STAGE/pkg/opt/mtpaint/mtpaint"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-mtpaint.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/mtpaint/mtpaint" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=none arch=aarch64")
PY

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'mtpaint.mo')

cp -a --remove-destination "$UNPACK/usr/share/pixmaps/mtpaint.png" \
  "$STAGE/pkg/usr/share/pixmaps/mtpaint.png"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/mtpaint.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/mtpaint.1.gz"

# Upstream docs (keep official names under kemi-mtpaint so we do not invent a handbook)
for src in copyright changelog.Debian.gz NEWS.gz README.gz; do
  if [[ -f "$UNPACK/usr/share/doc/mtpaint/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      README.gz) dest=README.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/mtpaint/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=mtpaint %U$|Exec=/usr/bin/mtpaint %U|' \
  "$UNPACK/usr/share/applications/mtpaint.desktop" \
  > "$STAGE/pkg/usr/share/applications/mtpaint.desktop"
grep -q '^Exec=/usr/bin/mtpaint %U$' "$STAGE/pkg/usr/share/applications/mtpaint.desktop"
grep -q '^Icon=mtpaint' "$STAGE/pkg/usr/share/applications/mtpaint.desktop"

ln -sf /opt/mtpaint/mtpaint "$STAGE/pkg/usr/bin/mtpaint"
ln -sf mtpaint "$STAGE/pkg/usr/bin/kemi-mtpaint"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://mtpaint.sourceforge.net/
Source: https://sourceforge.net/projects/mtpaint/
Homepage: http://mtpaint.sourceforge.net/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (mtpaint_3.40-3_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 mtpaint_3.40-3_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/mtpaint + /usr/bin/mtpaint; locales, pixmap,
    desktop and man stay on standard /usr/share paths.
  * Depends kept for Ubuntu 20.04 (GTK2, libgif7, libtiff5,
    libjpeg8, libpng16-16, libfreetype6, libpango-1.0-0,
    libgdk-pixbuf2.0-0, libglib2.0-0, libx11-6, zlib1g,
    libc6 >= 2.17, gtklp).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:21:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
mtPaint ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/mtpaint/; launcher /usr/bin/mtpaint (symlink to /opt/mtpaint/mtpaint).
Locales, pixmap, desktop and man remain on standard /usr/share paths.
No compiled-in /usr/share/mtpaint data directory. Optional handbook
/usr/share/doc/mtpaint/index.html is not shipped by the official deb.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK2 + image libs; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libfreetype6 (>= 2.2.1), libgdk-pixbuf2.0-0 (>= 2.22.0), libgif7 (>= 5.1), libglib2.0-0 (>= 2.31.8), libgtk2.0-0 (>= 2.24.0), libjpeg8 (>= 8c), libpango-1.0-0 (>= 1.14.0), libpng16-16 (>= 1.6.2-1), libtiff5 (>= 4.0.3), libx11-6, zlib1g (>= 1:1.2.0), gtklp.
Official Launchpad publication: mtpaint 3.40-3 in focal arm64 (universe, Release).
The arm64 binary was built in yakkety and copied unchanged into focal Release.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: graphics
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libfreetype6 (>= 2.2.1), libgdk-pixbuf2.0-0 (>= 2.22.0), libgif7 (>= 5.1), libglib2.0-0 (>= 2.31.8), libgtk2.0-0 (>= 2.24.0), libjpeg8 (>= 8c), libpango-1.0-0 (>= 1.14.0), libpng16-16 (>= 1.6.2-1), libtiff5 (>= 4.0.3), libx11-6, zlib1g (>= 1:1.2.0), gtklp
Conflicts: mtpaint
Replaces: mtpaint
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://mtpaint.sourceforge.net/
Description: mtPaint pixel-art and photo editor (arm64)
 mtPaint ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2 painting program for pixel art and photos.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-mtpaint-control.txt"
