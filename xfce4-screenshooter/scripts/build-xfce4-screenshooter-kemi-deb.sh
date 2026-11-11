#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xfce4-screenshooter 1.9.7 arm64 deb as kemi-xfce4-screenshooter.
# Probe: aarch64 · requiredGlibc 2.17 (2 ELF: bin + panel plugin) · no GLIBCXX · GTK3 + libxfce4* · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libcairo2, libexo-2-0, libgdk-pixbuf2.0-0,
# libglib2.0-0, libgtk-3-0, libsoup2.4-1, libx11-6, libxext6, libxfce4ui-2-0, libxfce4util7, libxfixes3, libxml2).
# Recommends: libxfce4panel-2.0-4 (optional XFCE panel plugin).
# Launchpad: xfce4-screenshooter 1.9.7-1 in focal arm64, universe/Release, Published 2019-12-26.
# Panel plugin .so and .desktop stay on standard XFCE panel paths.
# Locales / icons / desktop / man / AppStream stay on standard /usr/share paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-screenshooter
VER_UP=1.9.7
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xfce4-screenshooter
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xfce4-screenshooter-197-1-focal-unpack}"
UP_DEB="$DL/xfce4-screenshooter_1.9.7-1_arm64.deb"
EXPECT_SHA=a81a3cd6266613b59fbf9adb8bb5018ea90e39de2f2bba7f0cc1ce4e20f09856
EXPECT_BYTES=130612
PLUGIN_SO="usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libscreenshooterplugin.so"
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xfce4-screenshooter"
test -f "$UNPACK/$PLUGIN_SO"
test -f "$UNPACK/usr/share/applications/xfce4-screenshooter.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/applets-screenshooter.png"
test -f "$UNPACK/usr/share/xfce4/panel/plugins/screenshooter.desktop"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins" \
  "$STAGE/pkg/opt/xfce4-screenshooter"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/xfce4-screenshooter" "$STAGE/pkg/opt/xfce4-screenshooter/xfce4-screenshooter"
chmod 0755 "$STAGE/pkg/opt/xfce4-screenshooter/xfce4-screenshooter"
test -x "$STAGE/pkg/opt/xfce4-screenshooter/xfce4-screenshooter"

# Panel plugin must stay on the standard XFCE search path.
cp -al "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO" 2>/dev/null \
  || cp -a --remove-destination "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO"
chmod 0644 "$STAGE/pkg/$PLUGIN_SO"

# Probe both staged ELFs before packing.
REPORT="$ROOT/probe/kemi-xfce4-screenshooter.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/opt/xfce4-screenshooter/xfce4-screenshooter" \
  --elf "$STAGE/pkg/$PLUGIN_SO" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 2:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
for f in r["files"]:
    if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_UNEXPECTED")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=none arch=aarch64 n_elf=2")
PY

# Locales
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'xfce4-screenshooter.mo')

# Icons (png + svg)
while IFS= read -r ic; do
  rel="${ic#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -a --remove-destination "$ic" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/icons/hicolor" -type f \( -name 'applets-screenshooter.png' -o -name 'applets-screenshooter.svg' \))

if [[ -f "$UNPACK/usr/share/man/man1/xfce4-screenshooter.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/xfce4-screenshooter.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/xfce4-screenshooter.1.gz"
fi

if [[ -f "$UNPACK/usr/share/metainfo/xfce4-screenshooter.appdata.xml" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/metainfo/xfce4-screenshooter.appdata.xml" \
    "$STAGE/pkg/usr/share/metainfo/xfce4-screenshooter.appdata.xml"
fi

# Panel plugin desktop stays on the standard XFCE path.
cp -a --remove-destination "$UNPACK/usr/share/xfce4/panel/plugins/screenshooter.desktop" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins/screenshooter.desktop"

# Upstream docs
for src in copyright changelog.Debian.gz NEWS.gz README AUTHORS TODO; do
  if [[ -f "$UNPACK/usr/share/doc/xfce4-screenshooter/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      NEWS.gz) dest=NEWS.upstream.gz ;;
      README) dest=README.upstream ;;
      AUTHORS) dest=AUTHORS.upstream ;;
      TODO) dest=TODO.upstream ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/xfce4-screenshooter/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=xfce4-screenshooter$|Exec=/usr/bin/xfce4-screenshooter|' \
  "$UNPACK/usr/share/applications/xfce4-screenshooter.desktop" \
  > "$STAGE/pkg/usr/share/applications/xfce4-screenshooter.desktop"
grep -q '^Exec=/usr/bin/xfce4-screenshooter$' "$STAGE/pkg/usr/share/applications/xfce4-screenshooter.desktop"
grep -q '^Icon=applets-screenshooter' "$STAGE/pkg/usr/share/applications/xfce4-screenshooter.desktop"

ln -sf /opt/xfce4-screenshooter/xfce4-screenshooter "$STAGE/pkg/usr/bin/xfce4-screenshooter"
ln -sf xfce4-screenshooter "$STAGE/pkg/usr/bin/kemi-xfce4-screenshooter"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://goodies.xfce.org/projects/applications/xfce4-screenshooter
Homepage: https://docs.xfce.org/apps/xfce4-screenshooter/start
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (xfce4-screenshooter_1.9.7-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xfce4-screenshooter_1.9.7-1_arm64.deb
    repackaged for KEMI as ${PKG}.
  * Layout /opt/xfce4-screenshooter + /usr/bin/xfce4-screenshooter;
    XFCE panel plugin stays on standard
    /usr/lib/aarch64-linux-gnu/xfce4/panel/plugins and
    /usr/share/xfce4/panel/plugins paths; locales, icons, desktop,
    man and AppStream stay on standard /usr/share paths.
  * Depends kept for Ubuntu 20.04 (GTK3, libexo-2-0, libxfce4ui-2-0,
    libxfce4util7, libsoup2.4-1, libxml2, libx11-6, libxext6,
    libxfixes3, libcairo2, libgdk-pixbuf2.0-0, libglib2.0-0,
    libc6 >= 2.17). Recommends: libxfce4panel-2.0-4.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:08:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xfce4 Screenshooter ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/xfce4-screenshooter/; launcher /usr/bin/xfce4-screenshooter
(symlink to /opt/xfce4-screenshooter/xfce4-screenshooter).
XFCE panel plugin remains on the standard panel search path
(/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libscreenshooterplugin.so
and /usr/share/xfce4/panel/plugins/screenshooter.desktop).
Locales, icons, desktop, man and AppStream remain on standard /usr/share paths.
Probe: aarch64 · requiredGlibc 2.17 (2 ELF) · no GLIBCXX · GTK3 + libxfce4*; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libcairo2 (>= 1.10.0), libexo-2-0 (>= 0.11.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.4), libsoup2.4-1 (>= 2.41.90), libx11-6, libxext6, libxfce4ui-2-0 (>= 4.13.5), libxfce4util7 (>= 4.9.0), libxfixes3, libxml2 (>= 2.7.4).
Recommends: libxfce4panel-2.0-4 (>= 4.13.0) for the optional XFCE panel plugin.
Official Launchpad publication: xfce4-screenshooter 1.9.7-1 in focal arm64 (universe, Release).
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.10.0), libexo-2-0 (>= 0.11.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.4), libsoup2.4-1 (>= 2.41.90), libx11-6, libxext6, libxfce4ui-2-0 (>= 4.13.5), libxfce4util7 (>= 4.9.0), libxfixes3, libxml2 (>= 2.7.4)
Recommends: libxfce4panel-2.0-4 (>= 4.13.0)
Conflicts: xfce4-screenshooter
Replaces: xfce4-screenshooter
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://docs.xfce.org/apps/xfce4-screenshooter/start
Description: Xfce4 Screenshooter lightweight XFCE screenshot tool (arm64)
 Xfce4 Screenshooter ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3/XFCE screenshot utility. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xfce4-screenshooter-control.txt"
