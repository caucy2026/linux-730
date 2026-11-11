#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) LXTask 0.1.9 arm64 deb as kemi-lxtask.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK2 + GLib · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libglib2.0-0 >= 2.14.0,
# libgtk2.0-0 >= 2.14.0).
# Launchpad: lxtask 0.1.9-1 in focal arm64, universe/Release, Published 2019-10-18.
# arm64 binary was built in eoan and copied unchanged into focal Release.
# Icon=utilities-system-monitor is a freedesktop theme icon; official deb ships no pixmap.
# Locales / desktop / man stay on standard /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-lxtask
VER_UP=0.1.9
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-lxtask
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/lxtask-019-1-focal-unpack}"
UP_DEB="$DL/lxtask_0.1.9-1_arm64.deb"
EXPECT_SHA=e75e5fc36f04c672f17c700ae300acfa779212b6871c330eb75cf14ed560d852
EXPECT_BYTES=58180
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/lxtask"
test -f "$UNPACK/usr/share/applications/lxtask.desktop"
test -f "$UNPACK/usr/share/man/man1/lxtask.1.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/lxtask"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/lxtask" "$STAGE/pkg/opt/lxtask/lxtask"
chmod 0755 "$STAGE/pkg/opt/lxtask/lxtask"
test -x "$STAGE/pkg/opt/lxtask/lxtask"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-lxtask.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/lxtask/lxtask" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
done < <(find "$UNPACK/usr/share/locale" -type f -name 'lxtask.mo')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/lxtask.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/lxtask.1.gz"

# Upstream docs
for src in copyright changelog.Debian.gz TODO; do
  if [[ -f "$UNPACK/usr/share/doc/lxtask/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      TODO) dest=TODO.upstream ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/lxtask/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
# Official Icon=utilities-system-monitor (theme icon); official deb ships no pixmap.
sed -e 's|^Exec=lxtask$|Exec=/usr/bin/lxtask|' \
  "$UNPACK/usr/share/applications/lxtask.desktop" \
  > "$STAGE/pkg/usr/share/applications/lxtask.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/lxtask.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/lxtask$/a TryExec=/usr/bin/lxtask' \
    "$STAGE/pkg/usr/share/applications/lxtask.desktop"
fi
grep -q '^Exec=/usr/bin/lxtask$' "$STAGE/pkg/usr/share/applications/lxtask.desktop"
grep -q '^TryExec=/usr/bin/lxtask$' "$STAGE/pkg/usr/share/applications/lxtask.desktop"
grep -q '^Icon=utilities-system-monitor' "$STAGE/pkg/usr/share/applications/lxtask.desktop"

ln -sf /opt/lxtask/lxtask "$STAGE/pkg/usr/bin/lxtask"
ln -sf lxtask "$STAGE/pkg/usr/bin/kemi-lxtask"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.lxde.org/
Source: https://launchpad.net/ubuntu/+source/lxtask
Homepage: http://www.lxde.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (lxtask_0.1.9-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 lxtask_0.1.9-1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/lxtask + /usr/bin/lxtask; locales, desktop
    and man stay on standard /usr/share paths.
  * Official theme icon utilities-system-monitor (no pixmap in the
    official deb).
  * Depends kept for Ubuntu 20.04 (GTK2, libglib2.0-0, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:36:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
LXTask ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/lxtask/; launcher /usr/bin/lxtask (symlink to /opt/lxtask/lxtask).
Locales, desktop and man remain on standard /usr/share paths.
Official desktop Icon=utilities-system-monitor (freedesktop theme icon); the official deb ships no pixmap.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK2 + GLib; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libglib2.0-0 (>= 2.14.0), libgtk2.0-0 (>= 2.14.0).
Official Launchpad publication: lxtask 0.1.9-1 in focal arm64 (universe, Release).
The arm64 binary was built in eoan and copied unchanged into focal Release.
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
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.14.0), libgtk2.0-0 (>= 2.14.0)
Conflicts: lxtask
Replaces: lxtask
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.lxde.org/
Description: LXDE task manager (arm64)
 LXTask ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2 process and task manager.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-lxtask-control.txt"
