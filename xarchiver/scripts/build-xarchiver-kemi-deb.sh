#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xarchiver 0.5.4.14 arm64 deb as kemi-xarchiver.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgdk-pixbuf2.0-0,
# libglib2.0-0, libgtk-3-0). Recommends: bzip2, p7zip-full, unzip, xdg-utils, xz-utils.
# Launchpad: xarchiver 1:0.5.4.14-1 in focal arm64, universe/Release, Published 2019-10-18.
# Compiled-in help /usr/share/doc/xarchiver/index.html and pixmaps /usr/share/pixmaps/xarchiver
# MUST stay on those paths. Thunar .tap and mailcap stay on standard plugin/mime paths.
# Locales / icons / desktop / man stay on standard /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xarchiver
VER_UP=0.5.4.14
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xarchiver
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xarchiver-05414-1-focal-unpack}"
UP_DEB="$DL/xarchiver_0.5.4.14-1_arm64.deb"
EXPECT_SHA=208c1f99b453ef3e0e706c93bf666d161cee7aebbb855b03f91643263a043c70
EXPECT_BYTES=439360
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xarchiver"
test -f "$UNPACK/usr/share/applications/xarchiver.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/xarchiver.png"
test -d "$UNPACK/usr/share/pixmaps/xarchiver"
test -f "$UNPACK/usr/share/doc/xarchiver/index.html"
test -f "$UNPACK/usr/lib/thunar-archive-plugin/xarchiver.tap"
test -f "$UNPACK/usr/lib/mime/packages/xarchiver"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/lib/thunar-archive-plugin" \
  "$STAGE/pkg/usr/lib/mime/packages" \
  "$STAGE/pkg/opt/xarchiver"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/xarchiver" "$STAGE/pkg/opt/xarchiver/xarchiver"
chmod 0755 "$STAGE/pkg/opt/xarchiver/xarchiver"
test -x "$STAGE/pkg/opt/xarchiver/xarchiver"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-xarchiver.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/xarchiver/xarchiver" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=none arch=aarch64 n_elf=1")
PY

# Compiled-in help must stay on /usr/share/doc/xarchiver
mkdir -p "$STAGE/pkg/usr/share/doc/xarchiver"
cp -a --remove-destination "$UNPACK/usr/share/doc/xarchiver/." "$STAGE/pkg/usr/share/doc/xarchiver/"
test -f "$STAGE/pkg/usr/share/doc/xarchiver/index.html"

# Compiled-in toolbar pixmaps
mkdir -p "$STAGE/pkg/usr/share/pixmaps/xarchiver"
cp -a --remove-destination "$UNPACK/usr/share/pixmaps/xarchiver/." "$STAGE/pkg/usr/share/pixmaps/xarchiver/"
test -f "$STAGE/pkg/usr/share/pixmaps/xarchiver/xarchiver-extract.png"

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'xarchiver.mo')

# Icons (png + svg)
while IFS= read -r ic; do
  rel="${ic#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -a --remove-destination "$ic" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/icons/hicolor" -type f \( -name 'xarchiver.png' -o -name 'xarchiver.svg' \))

if [[ -f "$UNPACK/usr/share/man/man1/xarchiver.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/xarchiver.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/xarchiver.1.gz"
fi

# Thunar archive plugin wrapper stays on the standard search path.
cp -a --remove-destination "$UNPACK/usr/lib/thunar-archive-plugin/xarchiver.tap" \
  "$STAGE/pkg/usr/lib/thunar-archive-plugin/xarchiver.tap"
chmod 0755 "$STAGE/pkg/usr/lib/thunar-archive-plugin/xarchiver.tap"

# mailcap helper stays on the standard mime packages path (points at /usr/bin/xarchiver).
cp -a --remove-destination "$UNPACK/usr/lib/mime/packages/xarchiver" \
  "$STAGE/pkg/usr/lib/mime/packages/xarchiver"

# doc-base (indexes compiled-in HTML help)
if [[ -f "$UNPACK/usr/share/doc-base/xarchiver" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/doc-base"
  cp -a --remove-destination "$UNPACK/usr/share/doc-base/xarchiver" \
    "$STAGE/pkg/usr/share/doc-base/xarchiver"
fi

# Also keep copies of upstream legal docs under the KEMI doc dir.
for src in copyright changelog.Debian.gz; do
  if [[ -f "$UNPACK/usr/share/doc/xarchiver/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/xarchiver/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=xarchiver %f$|Exec=/usr/bin/xarchiver %f|' \
  "$UNPACK/usr/share/applications/xarchiver.desktop" \
  > "$STAGE/pkg/usr/share/applications/xarchiver.desktop"
grep -q '^Exec=/usr/bin/xarchiver %f$' "$STAGE/pkg/usr/share/applications/xarchiver.desktop"
grep -q '^Icon=xarchiver' "$STAGE/pkg/usr/share/applications/xarchiver.desktop"

ln -sf /opt/xarchiver/xarchiver "$STAGE/pkg/usr/bin/xarchiver"
ln -sf xarchiver "$STAGE/pkg/usr/bin/kemi-xarchiver"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/ib/xarchiver
Homepage: https://github.com/ib/xarchiver
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (xarchiver_0.5.4.14-1_arm64.deb, upstream version 1:0.5.4.14-1) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xarchiver_0.5.4.14-1_arm64.deb
    (upstream 1:0.5.4.14-1) repackaged for KEMI as ${PKG}.
  * Layout /opt/xarchiver + /usr/bin/xarchiver; compiled-in help
    /usr/share/doc/xarchiver/index.html and pixmaps
    /usr/share/pixmaps/xarchiver stay on those paths; Thunar
    archive plugin and mailcap stay on standard plugin/mime
    paths; locales, icons, desktop and man stay on standard
    /usr/share paths.
  * Depends kept for Ubuntu 20.04 (GTK3, libgdk-pixbuf2.0-0,
    libglib2.0-0, libc6 >= 2.17). Recommends: bzip2, p7zip-full,
    unzip, xdg-utils, xz-utils.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:12:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xarchiver ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/xarchiver/; launcher /usr/bin/xarchiver
(symlink to /opt/xarchiver/xarchiver).
Compiled-in help /usr/share/doc/xarchiver/index.html and toolbar
pixmaps /usr/share/pixmaps/xarchiver remain on those paths.
Thunar archive plugin remains at
/usr/lib/thunar-archive-plugin/xarchiver.tap; mailcap helper remains
at /usr/lib/mime/packages/xarchiver.
Locales, icons, desktop and man remain on standard /usr/share paths.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.9), libgtk-3-0 (>= 3.0.0).
Recommends: bzip2, p7zip-full, unzip, xdg-utils, xz-utils.
Official Launchpad publication: xarchiver 1:0.5.4.14-1 in focal arm64 (universe, Release).
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
Depends: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.9), libgtk-3-0 (>= 3.0.0)
Recommends: bzip2, p7zip-full, unzip, xdg-utils, xz-utils
Conflicts: xarchiver
Replaces: xarchiver
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/ib/xarchiver
Description: Xarchiver lightweight GTK+ archive manager (arm64)
 Xarchiver ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 archive manager. glibc≤2.31 (Ubuntu 20.04).
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
if command -v update-mime >/dev/null 2>&1; then
  update-mime || true
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
if command -v update-mime >/dev/null 2>&1; then
  update-mime || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xarchiver-control.txt"
