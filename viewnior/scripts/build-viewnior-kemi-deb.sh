#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) Viewnior 1.6 arm64 deb as kemi-viewnior.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · requiredGlibcxx 3.4.21 · GTK2 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgtk2.0-0, libexiv2-27,
# libgdk-pixbuf2.0-0, libglib2.0-0, libstdc++6, libgcc-s1).
# Launchpad: viewnior 1.6-1build2 in focal arm64, universe, Published 2020-02-13.
# UI / pixmap paths are compiled in as /usr/share/viewnior/* — keep those on standard paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-viewnior
VER_UP=1.6
VER_DEB="${VER_UP}-1build2kemi1"
ARCH=arm64
PKG=kemi-viewnior
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/viewnior-161build2-focal-unpack}"
UP_DEB="$DL/viewnior_1.6-1build2_arm64.deb"
EXPECT_SHA=d6fd4aa6b5572b1364e4c1aa03ac67852d858d7f34bef2eed44d3af7db9b8e9f
EXPECT_BYTES=115732
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/viewnior"
test -f "$UNPACK/usr/share/applications/viewnior.desktop"
test -f "$UNPACK/usr/share/viewnior/vnr-crop-dialog.ui"
test -f "$UNPACK/usr/share/viewnior/vnr-preferences-dialog.ui"
test -f "$UNPACK/usr/share/viewnior/pixmaps/object-rotate-left.png"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/viewnior.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/opt/viewnior"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/viewnior" "$STAGE/pkg/opt/viewnior/viewnior"
chmod 0755 "$STAGE/pkg/opt/viewnior/viewnior"
test -x "$STAGE/pkg/opt/viewnior/viewnior"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-viewnior.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/viewnior/viewnior" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=3.4.21 arch=aarch64")
PY

# UI + pixmaps must stay on compiled-in /usr/share/viewnior paths.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/viewnior" -type f)

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'viewnior.mo')

# Icons (all shipped sizes) + pixmap + man
while IFS= read -r ic; do
  rel="${ic#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -a --remove-destination "$ic" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/icons/hicolor" -type f -name 'viewnior.png' -o -type f -name 'viewnior.svg')
cp -a --remove-destination "$UNPACK/usr/share/pixmaps/viewnior.xpm" \
  "$STAGE/pkg/usr/share/pixmaps/viewnior.xpm"
if [[ -f "$UNPACK/usr/share/man/man1/viewnior.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/viewnior.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/viewnior.1.gz"
fi

# Upstream docs
for src in copyright changelog.Debian.gz README NEWS.gz TODO; do
  if [[ -f "$UNPACK/usr/share/doc/viewnior/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      README) dest=README.upstream ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/viewnior/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec/TryExec at the KEMI launcher path.
sed -e 's|^Exec=viewnior %F$|Exec=/usr/bin/viewnior %F|' \
    -e 's|^TryExec=viewnior$|TryExec=/usr/bin/viewnior|' \
  "$UNPACK/usr/share/applications/viewnior.desktop" \
  > "$STAGE/pkg/usr/share/applications/viewnior.desktop"
grep -q '^Exec=/usr/bin/viewnior %F$' "$STAGE/pkg/usr/share/applications/viewnior.desktop"
grep -q '^TryExec=/usr/bin/viewnior$' "$STAGE/pkg/usr/share/applications/viewnior.desktop"
grep -q '^Icon=viewnior' "$STAGE/pkg/usr/share/applications/viewnior.desktop"

ln -sf /opt/viewnior/viewnior "$STAGE/pkg/usr/bin/viewnior"
ln -sf viewnior "$STAGE/pkg/usr/bin/kemi-viewnior"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://xsisqox.github.io/Viewnior/
Homepage: http://xsisqox.github.io/Viewnior/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (viewnior_1.6-1build2_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 viewnior_1.6-1build2_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/viewnior + /usr/bin/viewnior; UI/pixmaps stay at
    /usr/share/viewnior (compiled-in paths).
  * Depends kept for Ubuntu 20.04 (GTK2, libexiv2-27, libgdk-pixbuf2.0-0,
    libglib2.0-0, libstdc++6, libgcc-s1, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:55:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Viewnior ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/viewnior/; launcher /usr/bin/viewnior (symlink to /opt/viewnior/viewnior).
UI and pixmaps remain at /usr/share/viewnior (paths compiled into the binary).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · requiredGlibcxx 3.4.21 · GTK2; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgtk2.0-0 (>= 2.20.0), libexiv2-27 (>= 0.27.2), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libstdc++6 (>= 5.2), libgcc-s1 (>= 3.0).
Official Launchpad publication: viewnior 1.6-1build2 in focal arm64 (universe).
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
Depends: libc6 (>= 2.17), libexiv2-27 (>= 0.27.2), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk2.0-0 (>= 2.20.0), libstdc++6 (>= 5.2)
Conflicts: viewnior
Replaces: viewnior
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://xsisqox.github.io/Viewnior/
Description: Viewnior simple GTK2 image viewer (arm64)
 Viewnior ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2 image viewer. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-viewnior-control.txt"
