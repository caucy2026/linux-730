#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) LXTerminal 0.3.2 arm64 deb as kemi-lxterminal.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + VTE + gdk-pixbuf + pango + GLib · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgdk-pixbuf2.0-0 >= 2.22.0,
# libglib2.0-0 >= 2.28.0, libgtk-3-0 >= 3.3.16, libpango-1.0-0 >= 1.14.0, libvte-2.91-0).
# Launchpad: lxterminal 0.3.2-1 in focal arm64, universe/Release, Published 2019-10-18.
# arm64 binary was built in cosmic and copied unchanged into focal Release.
# Compiled-in paths stay on /usr/share/lxterminal/* and
# /usr/share/icons/hicolor/128x128/apps/lxterminal.png; locales / desktop / man stay
# on standard /usr/share paths. Ubuntu apport hook is omitted.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-lxterminal
VER_UP=0.3.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-lxterminal
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/lxterminal-032-1-focal-unpack}"
UP_DEB="$DL/lxterminal_0.3.2-1_arm64.deb"
EXPECT_SHA=39c2981d3dd275b4deba0e35220546c756815743ab96009715eabe2229f8c1d9
EXPECT_BYTES=87584
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/lxterminal"
test -f "$UNPACK/usr/share/applications/lxterminal.desktop"
test -f "$UNPACK/usr/share/man/man1/lxterminal.1.gz"
test -f "$UNPACK/usr/share/lxterminal/lxterminal.conf"
test -f "$UNPACK/usr/share/lxterminal/menu.ui"
test -f "$UNPACK/usr/share/lxterminal/lxterminal-preferences.ui"
test -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/lxterminal.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/lxterminal" \
  "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps" \
  "$STAGE/pkg/opt/lxterminal"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/lxterminal" "$STAGE/pkg/opt/lxterminal/lxterminal"
chmod 0755 "$STAGE/pkg/opt/lxterminal/lxterminal"
test -x "$STAGE/pkg/opt/lxterminal/lxterminal"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-lxterminal.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/lxterminal/lxterminal" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
done < <(find "$UNPACK/usr/share/locale" -type f -name 'lxterminal.mo')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/lxterminal.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/lxterminal.1.gz"

# Compiled-in data and icon must stay on the paths baked into the ELF.
cp -a --remove-destination "$UNPACK/usr/share/lxterminal/lxterminal.conf" \
  "$STAGE/pkg/usr/share/lxterminal/lxterminal.conf"
cp -a --remove-destination "$UNPACK/usr/share/lxterminal/menu.ui" \
  "$STAGE/pkg/usr/share/lxterminal/menu.ui"
cp -a --remove-destination "$UNPACK/usr/share/lxterminal/lxterminal-preferences.ui" \
  "$STAGE/pkg/usr/share/lxterminal/lxterminal-preferences.ui"
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/128x128/apps/lxterminal.png" \
  "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/lxterminal.png"

# Upstream docs
for src in copyright changelog.Debian.gz; do
  if [[ -f "$UNPACK/usr/share/doc/lxterminal/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/lxterminal/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec/TryExec at the KEMI launcher path.
# Official Icon=lxterminal (hicolor 128x128 pixmap shipped in this deb).
sed -e 's|^Exec=lxterminal$|Exec=/usr/bin/lxterminal|' \
    -e 's|^TryExec=lxterminal$|TryExec=/usr/bin/lxterminal|' \
  "$UNPACK/usr/share/applications/lxterminal.desktop" \
  > "$STAGE/pkg/usr/share/applications/lxterminal.desktop"
grep -q '^Exec=/usr/bin/lxterminal$' "$STAGE/pkg/usr/share/applications/lxterminal.desktop"
grep -q '^TryExec=/usr/bin/lxterminal$' "$STAGE/pkg/usr/share/applications/lxterminal.desktop"
grep -q '^Icon=lxterminal' "$STAGE/pkg/usr/share/applications/lxterminal.desktop"

ln -sf /opt/lxterminal/lxterminal "$STAGE/pkg/usr/bin/lxterminal"
ln -sf lxterminal "$STAGE/pkg/usr/bin/kemi-lxterminal"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.lxde.org/
Source: https://launchpad.net/ubuntu/+source/lxterminal
Homepage: http://www.lxde.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (lxterminal_0.3.2-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 lxterminal_0.3.2-1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/lxterminal + /usr/bin/lxterminal; compiled-in
    /usr/share/lxterminal data and the hicolor 128x128 icon, plus
    locales, desktop and man, stay on standard /usr/share paths.
  * Ubuntu apport hook omitted.
  * Depends kept for Ubuntu 20.04 (GTK3, VTE, gdk-pixbuf, pango,
    libglib2.0-0, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:42:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
LXTerminal ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/lxterminal/; launcher /usr/bin/lxterminal (symlink to /opt/lxterminal/lxterminal).
Compiled-in data stays on /usr/share/lxterminal/; icon on
/usr/share/icons/hicolor/128x128/apps/lxterminal.png; locales, desktop and man
remain on standard /usr/share paths. Official desktop Icon=lxterminal.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + VTE + gdk-pixbuf + pango + GLib; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.28.0), libgtk-3-0 (>= 3.3.16), libpango-1.0-0 (>= 1.14.0), libvte-2.91-0.
Official Launchpad publication: lxterminal 0.3.2-1 in focal arm64 (universe, Release).
The arm64 binary was built in cosmic and copied unchanged into focal Release.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: x11
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.28.0), libgtk-3-0 (>= 3.3.16), libpango-1.0-0 (>= 1.14.0), libvte-2.91-0
Conflicts: lxterminal
Replaces: lxterminal
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.lxde.org/
Description: LXDE terminal emulator (arm64)
 LXTerminal ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight VTE-based GTK3 terminal emulator.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-lxterminal-control.txt"
