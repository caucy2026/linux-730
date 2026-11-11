#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) Galculator 2.1.4 arm64 deb as kemi-galculator.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgtk-3-0 >= 3.3.16,
# libglib2.0-0, libpango-1.0-0).
# Launchpad: galculator 2.1.4-1build1 in focal arm64, universe, Published 2019-10-18.
# UI paths are compiled in as /usr/share/galculator/ui/*.ui — keep those on standard paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-galculator
VER_UP=2.1.4
VER_DEB="${VER_UP}-1build1kemi1"
ARCH=arm64
PKG=kemi-galculator
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/galculator-2141-focal-unpack}"
UP_DEB="$DL/galculator_2.1.4-1build1_arm64.deb"
EXPECT_SHA=79f10042654a049fc77c523bef6c645a2fdba2f5f91d1ad5fd11a265ea9c1f9b
EXPECT_BYTES=144124
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/galculator"
test -f "$UNPACK/usr/share/applications/galculator.desktop"
test -f "$UNPACK/usr/share/galculator/ui/main_frame.ui"
test -f "$UNPACK/usr/share/galculator/ui/basic_buttons_gtk3.ui"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/galculator.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/appdata" \
  "$STAGE/pkg/usr/share/menu" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/opt/galculator"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/galculator" "$STAGE/pkg/opt/galculator/galculator"
chmod 0755 "$STAGE/pkg/opt/galculator/galculator"
test -x "$STAGE/pkg/opt/galculator/galculator"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-galculator.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/galculator/galculator" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
print("PROBE_PASS requiredGlibc=2.17 arch=aarch64 glibcxx="+str(f.get("requiredGlibcxx")))
PY

# UI + data must stay on compiled-in /usr/share/galculator paths.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/galculator" -type f)

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'galculator.mo')

# Icons, pixmaps, man, appdata, menu
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/48x48/apps/galculator.png" \
  "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/galculator.png"
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/galculator.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/galculator.svg"
cp -a --remove-destination "$UNPACK/usr/share/pixmaps/galculator.xpm" \
  "$STAGE/pkg/usr/share/pixmaps/galculator.xpm"
if [[ -f "$UNPACK/usr/share/man/man1/galculator.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/galculator.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/galculator.1.gz"
fi
if [[ -f "$UNPACK/usr/share/appdata/galculator.appdata.xml" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/appdata/galculator.appdata.xml" \
    "$STAGE/pkg/usr/share/appdata/galculator.appdata.xml"
fi
if [[ -f "$UNPACK/usr/share/menu/galculator" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/menu/galculator" \
    "$STAGE/pkg/usr/share/menu/galculator"
fi

# Upstream docs
for src in copyright changelog.Debian.gz README.gz NEWS.gz AUTHORS shortcuts; do
  if [[ -f "$UNPACK/usr/share/doc/galculator/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      README.gz) dest=README.upstream.gz ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/galculator/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=galculator$|Exec=/usr/bin/galculator|' \
  "$UNPACK/usr/share/applications/galculator.desktop" \
  > "$STAGE/pkg/usr/share/applications/galculator.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/galculator.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/galculator$/a TryExec=/usr/bin/galculator' \
    "$STAGE/pkg/usr/share/applications/galculator.desktop"
fi
grep -q '^Exec=/usr/bin/galculator$' "$STAGE/pkg/usr/share/applications/galculator.desktop"
grep -q '^TryExec=/usr/bin/galculator$' "$STAGE/pkg/usr/share/applications/galculator.desktop"
grep -q '^Icon=galculator' "$STAGE/pkg/usr/share/applications/galculator.desktop"

ln -sf /opt/galculator/galculator "$STAGE/pkg/usr/bin/galculator"
ln -sf galculator "$STAGE/pkg/usr/bin/kemi-galculator"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://galculator.mnim.org/
Homepage: http://galculator.mnim.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (galculator_2.1.4-1build1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 galculator_2.1.4-1build1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/galculator + /usr/bin/galculator; UI stays at
    /usr/share/galculator/ui (compiled-in paths).
  * Depends kept for Ubuntu 20.04 (GTK3, libglib2.0-0, libpango-1.0-0, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:50:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Galculator ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/galculator/; launcher /usr/bin/galculator (symlink to /opt/galculator/galculator).
UI files remain at /usr/share/galculator/ui (paths compiled into the binary).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgtk-3-0 (>= 3.3.16), libglib2.0-0 (>= 2.16.0), libpango-1.0-0 (>= 1.14.0).
Official Launchpad publication: galculator 2.1.4-1build1 in focal arm64 (universe).
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: math
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.16.0), libgtk-3-0 (>= 3.3.16), libpango-1.0-0 (>= 1.14.0)
Conflicts: galculator
Replaces: galculator
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://galculator.mnim.org/
Description: Galculator scientific GTK3 calculator (arm64)
 Galculator ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight scientific GTK3 calculator. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-galculator-control.txt"
