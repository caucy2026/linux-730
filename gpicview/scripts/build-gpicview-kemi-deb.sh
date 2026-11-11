#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) GPicView 0.2.5 arm64 deb as kemi-gpicview.
# Probe: aarch64 · requiredGlibc 2.29 (1 ELF) · no GLIBCXX · GTK2 + libjpeg · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.29, libcairo2, libgdk-pixbuf2.0-0,
# libglib2.0-0, libgtk2.0-0, libjpeg8, libx11-6). Recommends: xdg-utils.
# Launchpad: gpicview 0.2.5-3 in focal arm64, universe/Release, Published 2019-10-18.
# Compiled-in data dirs /usr/share/gpicview/{pixmaps,ui} MUST stay on /usr/share.
# Locales / icons / desktop / man stay on standard /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gpicview
VER_UP=0.2.5
VER_DEB="${VER_UP}-3kemi1"
ARCH=arm64
PKG=kemi-gpicview
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gpicview-025-3-focal-unpack}"
UP_DEB="$DL/gpicview_0.2.5-3_arm64.deb"
EXPECT_SHA=b648d393f3e3eccf79e2f35cb87f1d2fd33803a5d3b55e7c6a0167d173cd3d9e
EXPECT_BYTES=105488
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gpicview"
test -f "$UNPACK/usr/share/applications/gpicview.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/gpicview.png"
test -f "$UNPACK/usr/share/gpicview/pixmaps/object-rotate-left.png"
test -f "$UNPACK/usr/share/gpicview/ui/pref-dlg.ui"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/gpicview"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/gpicview" "$STAGE/pkg/opt/gpicview/gpicview"
chmod 0755 "$STAGE/pkg/opt/gpicview/gpicview"
test -x "$STAGE/pkg/opt/gpicview/gpicview"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-gpicview.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/gpicview/gpicview" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
f=r["files"][0]
if f.get("requiredGlibc") != "2.29" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
print("PROBE_PASS requiredGlibc=2.29 requiredGlibcxx=none arch=aarch64")
PY

# Compiled-in data dir must stay on /usr/share/gpicview
mkdir -p "$STAGE/pkg/usr/share/gpicview"
cp -a --remove-destination "$UNPACK/usr/share/gpicview/." "$STAGE/pkg/usr/share/gpicview/"
test -f "$STAGE/pkg/usr/share/gpicview/pixmaps/object-rotate-left.png"
test -f "$STAGE/pkg/usr/share/gpicview/ui/pref-dlg.ui"

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'gpicview.mo')

# Icons (all shipped sizes)
while IFS= read -r ic; do
  rel="${ic#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -a --remove-destination "$ic" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/icons/hicolor" -type f -name 'gpicview.png' -o -type f -name 'gpicview.svg')

if [[ -f "$UNPACK/usr/share/man/man1/gpicview.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/gpicview.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/gpicview.1.gz"
fi

# Upstream docs
for src in copyright changelog.Debian.gz NEWS.gz AUTHORS; do
  if [[ -f "$UNPACK/usr/share/doc/gpicview/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      AUTHORS) dest=AUTHORS.upstream ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/gpicview/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=gpicview %f$|Exec=/usr/bin/gpicview %f|' \
  "$UNPACK/usr/share/applications/gpicview.desktop" \
  > "$STAGE/pkg/usr/share/applications/gpicview.desktop"
grep -q '^Exec=/usr/bin/gpicview %f$' "$STAGE/pkg/usr/share/applications/gpicview.desktop"
grep -q '^Icon=gpicview' "$STAGE/pkg/usr/share/applications/gpicview.desktop"

ln -sf /opt/gpicview/gpicview "$STAGE/pkg/usr/bin/gpicview"
ln -sf gpicview "$STAGE/pkg/usr/bin/kemi-gpicview"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.lxde.org/
Source: https://sourceforge.net/projects/lxde/files/GPicView%20%28image%20Viewer%29/
Homepage: http://www.lxde.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (gpicview_0.2.5-3_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gpicview_0.2.5-3_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/gpicview + /usr/bin/gpicview; compiled-in data
    /usr/share/gpicview/{pixmaps,ui} stays on /usr/share; locales,
    icons, desktop and man stay on standard /usr/share paths.
  * Depends kept for Ubuntu 20.04 (GTK2, libcairo2, libgdk-pixbuf2.0-0,
    libglib2.0-0, libjpeg8, libx11-6, libc6 >= 2.29).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:01:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GPicView ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/gpicview/; launcher /usr/bin/gpicview (symlink to /opt/gpicview/gpicview).
Compiled-in data /usr/share/gpicview/{pixmaps,ui} remains on that path.
Locales, icons, desktop and man remain on standard /usr/share paths.
Probe: aarch64 · requiredGlibc 2.29 (1 ELF) · no GLIBCXX · GTK2 + libjpeg; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.29), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk2.0-0 (>= 2.20.0), libjpeg8 (>= 8c), libx11-6.
Recommends: xdg-utils.
Official Launchpad publication: gpicview 0.2.5-3 in focal arm64 (universe, Release).
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
Depends: libc6 (>= 2.29), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk2.0-0 (>= 2.20.0), libjpeg8 (>= 8c), libx11-6
Recommends: xdg-utils
Conflicts: gpicview
Replaces: gpicview
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.lxde.org/
Description: GPicView lightweight GTK2 image viewer (arm64)
 GPicView ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2/LXDE image viewer. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gpicview-control.txt"
