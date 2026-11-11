#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) Gigolo 0.5.1 arm64 deb as kemi-gigolo.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + GDK3 + GIO/GVfs + GLib + libX11 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libglib2.0-0 >= 2.37.3,
# libgtk-3-0 >= 3.21.5, libx11-6).
# Launchpad: gigolo 0.5.1-1 in focal arm64, universe/Release, Published 2020-03-21.
# arm64 binary was built in ubuntu focal PROPOSED and published to Release.
# Locale path compiled in as /usr/share/locale; no /usr/share/gigolo data dir.
# Official desktop Icon=gtk-network (GTK stock; this deb ships no pixmap).
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gigolo
VER_UP=0.5.1
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-gigolo
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gigolo-051-1-focal-unpack}"
UP_DEB="$DL/gigolo_0.5.1-1_arm64.deb"
EXPECT_SHA=0ddf9f86fcbe8bca2621d43cab97b47dd64e5aa2d3696c64b5a7f825104d3bf4
EXPECT_BYTES=138980
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gigolo"
test -f "$UNPACK/usr/share/applications/gigolo.desktop"
test -f "$UNPACK/usr/share/man/man1/gigolo.1.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/gigolo"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/gigolo" "$STAGE/pkg/opt/gigolo/gigolo"
chmod 0755 "$STAGE/pkg/opt/gigolo/gigolo"
test -x "$STAGE/pkg/opt/gigolo/gigolo"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-gigolo.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/gigolo/gigolo" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
done < <(find "$UNPACK/usr/share/locale" -type f -name 'gigolo.mo')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/gigolo.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gigolo.1.gz"

# Upstream docs
for src in copyright changelog.Debian.gz NEWS.gz README TODO; do
  if [[ -f "$UNPACK/usr/share/doc/gigolo/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/gigolo/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
# Official Icon=gtk-network (GTK stock; no pixmap shipped in this deb).
sed -e 's|^Exec=gigolo$|Exec=/usr/bin/gigolo|' \
  "$UNPACK/usr/share/applications/gigolo.desktop" \
  > "$STAGE/pkg/usr/share/applications/gigolo.desktop"
grep -q '^Exec=/usr/bin/gigolo$' "$STAGE/pkg/usr/share/applications/gigolo.desktop"
grep -q '^Icon=gtk-network' "$STAGE/pkg/usr/share/applications/gigolo.desktop"

ln -sf /opt/gigolo/gigolo "$STAGE/pkg/usr/bin/gigolo"
ln -sf gigolo "$STAGE/pkg/usr/bin/kemi-gigolo"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.uvena.de/gigolo/
Source: https://launchpad.net/ubuntu/+source/gigolo
Homepage: https://www.uvena.de/gigolo/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (gigolo_0.5.1-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gigolo_0.5.1-1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/gigolo + /usr/bin/gigolo; locales, desktop and
    man stay on standard /usr/share paths. Official desktop
    Icon=gtk-network (GTK stock; no pixmap in this deb).
  * Depends kept for Ubuntu 20.04 (GTK3, GLib, libX11, libc6 >= 2.17).
  * Recommends libglib2.0-bin kept from official package.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:46:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gigolo ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/gigolo/; launcher /usr/bin/gigolo (symlink to /opt/gigolo/gigolo).
Locales, desktop and man remain on standard /usr/share paths.
Official desktop Icon=gtk-network (GTK stock; this deb ships no pixmap).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 + GDK3 + GIO/GVfs + GLib + libX11; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libx11-6.
Official Launchpad publication: gigolo 0.5.1-1 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu focal PROPOSED and published to Release.
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
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libx11-6
Recommends: libglib2.0-bin
Conflicts: gigolo
Replaces: gigolo
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.uvena.de/gigolo/
Description: GIO/GVfs remote filesystem frontend (arm64)
 Gigolo ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 frontend to mount remote filesystems via GIO/GVfs.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gigolo-control.txt"
