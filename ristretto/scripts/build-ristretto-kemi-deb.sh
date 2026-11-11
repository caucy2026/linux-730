#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) Ristretto 0.10.0 arm64 deb as kemi-ristretto.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + libxfce4* · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgtk-3-0, libcairo2,
# libexif12, libgdk-pixbuf2.0-0, libglib2.0-0, libmagic1, libpango-1.0-0,
# libpangocairo-1.0-0, libx11-6, libxfce4ui-2-0, libxfce4util7, libxfconf-0-3).
# Launchpad: ristretto 0.10.0-1ubuntu0.1 in focal arm64, universe/updates, Published 2023-09-22.
# No compiled-in /usr/share/ristretto data dir; locales/icons/desktop/man/metainfo stay on /usr/share.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-ristretto
VER_UP=0.10.0
VER_DEB="${VER_UP}-1ubuntu0.1kemi1"
ARCH=arm64
PKG=kemi-ristretto
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/ristretto-0100-1ubuntu0.1-focal-unpack}"
UP_DEB="$DL/ristretto_0.10.0-1ubuntu0.1_arm64.deb"
EXPECT_SHA=874af2033f122bfdb01b7e78d723610cf0059e57c7b7b45dba38d5b7f86f58c9
EXPECT_BYTES=221604
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/ristretto"
test -f "$UNPACK/usr/share/applications/ristretto.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/ristretto.png"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/ristretto.svg"
test -f "$UNPACK/usr/share/metainfo/ristretto.appdata.xml"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/ristretto"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/ristretto" "$STAGE/pkg/opt/ristretto/ristretto"
chmod 0755 "$STAGE/pkg/opt/ristretto/ristretto"
test -x "$STAGE/pkg/opt/ristretto/ristretto"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-ristretto.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/ristretto/ristretto" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
done < <(find "$UNPACK/usr/share/locale" -type f -name 'ristretto.mo')

# Icons (all shipped sizes)
while IFS= read -r ic; do
  rel="${ic#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -a --remove-destination "$ic" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/icons/hicolor" -type f -name 'ristretto.png' -o -type f -name 'ristretto.svg')

if [[ -f "$UNPACK/usr/share/man/man1/ristretto.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/ristretto.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/ristretto.1.gz"
fi
if [[ -f "$UNPACK/usr/share/metainfo/ristretto.appdata.xml" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/metainfo/ristretto.appdata.xml" \
    "$STAGE/pkg/usr/share/metainfo/ristretto.appdata.xml"
fi

# Upstream docs
for src in copyright changelog.Debian.gz NEWS.gz AUTHORS; do
  if [[ -f "$UNPACK/usr/share/doc/ristretto/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      AUTHORS) dest=AUTHORS.upstream ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/ristretto/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=ristretto %F$|Exec=/usr/bin/ristretto %F|' \
  "$UNPACK/usr/share/applications/ristretto.desktop" \
  > "$STAGE/pkg/usr/share/applications/ristretto.desktop"
grep -q '^Exec=/usr/bin/ristretto %F$' "$STAGE/pkg/usr/share/applications/ristretto.desktop"
grep -q '^Icon=ristretto' "$STAGE/pkg/usr/share/applications/ristretto.desktop"

ln -sf /opt/ristretto/ristretto "$STAGE/pkg/usr/bin/ristretto"
ln -sf ristretto "$STAGE/pkg/usr/bin/kemi-ristretto"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://docs.xfce.org/apps/ristretto/start
Source: https://archive.xfce.org/src/apps/ristretto/
Homepage: https://docs.xfce.org/apps/ristretto/start
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (ristretto_0.10.0-1ubuntu0.1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 ristretto_0.10.0-1ubuntu0.1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/ristretto + /usr/bin/ristretto; locales, icons, desktop,
    man and metainfo stay on standard /usr/share paths.
  * Depends kept for Ubuntu 20.04 (GTK3, libexif12, libgdk-pixbuf2.0-0,
    libglib2.0-0, libcairo2, libmagic1, libpango-1.0-0, libpangocairo-1.0-0,
    libx11-6, libxfce4ui-2-0, libxfce4util7, libxfconf-0-3, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:56:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Ristretto ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/ristretto/; launcher /usr/bin/ristretto (symlink to /opt/ristretto/ristretto).
Locales, icons, desktop, man and AppStream metainfo remain on standard /usr/share paths.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + libxfce4*; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libexif12 (>= 0.6.21-1~), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libmagic1 (>= 5.12), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libx11-6, libxfce4ui-2-0 (>= 4.11.0), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.12.1).
Recommends: tumbler.
Official Launchpad publication: ristretto 0.10.0-1ubuntu0.1 in focal arm64 (universe, updates).
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libexif12 (>= 0.6.21-1~), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libmagic1 (>= 5.12), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libx11-6, libxfce4ui-2-0 (>= 4.11.0), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.12.1)
Recommends: tumbler
Conflicts: ristretto
Replaces: ristretto
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://docs.xfce.org/apps/ristretto/start
Description: Ristretto lightweight XFCE image viewer (arm64)
 Ristretto ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3/XFCE image viewer. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-ristretto-control.txt"
