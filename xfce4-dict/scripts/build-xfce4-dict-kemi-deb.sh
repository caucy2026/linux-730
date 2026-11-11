#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xfce4-dict 0.8.3-1 arm64 deb as kemi-xfce4-dict.
# Probe: aarch64 · requiredGlibc 2.17 (2 ELF: bin + panel plugin) · no GLIBCXX · GTK3 + GDK3 + Pango + GdkPixbuf + GIO/GObject/GLib + libxfce4ui + libxfce4util + (plugin) libX11 + libxfce4panel · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgdk-pixbuf2.0-0 >= 2.25.2,
# libglib2.0-0 >= 2.37.3, libgtk-3-0 >= 3.19.12, libpango-1.0-0 >= 1.14.0, libx11-6,
# libxfce4panel-2.0-4 >= 4.13.0, libxfce4ui-2-0 >= 4.13.0, libxfce4util7 >= 4.9.0).
# Recommends: aspell | ispell. Provides: dict-client.
# Launchpad: xfce4-dict 0.8.3-1 in focal arm64, universe/Release, Published 2019-10-26.
# arm64 binary was built in ubuntu focal PROPOSED and published to Release.
# Panel plugin .so and .desktop stay on standard XFCE panel paths.
# Locales / icons / desktop / man stay on standard /usr/share paths.
# Official desktop Icon=xfce4-dict (hicolor svg shipped). Exec=xfce4-dict.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xfce4-dict
VER_UP=0.8.3
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xfce4-dict
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xfce4-dict-083-1-focal-unpack}"
UP_DEB="$DL/xfce4-dict_0.8.3-1_arm64.deb"
EXPECT_SHA=f397846d0f4ff27292431b8600003e1e2c904d9d734c98db029f4fd02562625d
EXPECT_BYTES=147964
PLUGIN_SO="usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libxfce4dict.so"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xfce4-dict"
test -f "$UNPACK/$PLUGIN_SO"
test -f "$UNPACK/usr/share/applications/xfce4-dict.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/xfce4-dict.svg"
test -f "$UNPACK/usr/share/xfce4/panel/plugins/xfce4-dict-plugin.desktop"
test -f "$UNPACK/usr/share/man/man1/xfce4-dict.1.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins" \
  "$STAGE/pkg/opt/xfce4-dict"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/xfce4-dict" "$STAGE/pkg/opt/xfce4-dict/xfce4-dict"
chmod 0755 "$STAGE/pkg/opt/xfce4-dict/xfce4-dict"
test -x "$STAGE/pkg/opt/xfce4-dict/xfce4-dict"

# Panel plugin must stay on the standard XFCE search path.
cp -al "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO" 2>/dev/null \
  || cp -a --remove-destination "$UNPACK/$PLUGIN_SO" "$STAGE/pkg/$PLUGIN_SO"
chmod 0644 "$STAGE/pkg/$PLUGIN_SO"

# Probe both staged ELFs before packing.
REPORT="$ROOT/probe/kemi-xfce4-dict.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/opt/xfce4-dict/xfce4-dict" \
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
needed_bin=set((r["files"][0].get("neededLibraries") or []))
needed_so=set((r["files"][1].get("neededLibraries") or []))
for lib in ("libgtk-3.so.0", "libxfce4ui-2.so.0", "libxfce4util.so.7"):
    if lib not in needed_bin:
        raise SystemExit(f"PROBE_MISSING_BIN_{lib}")
for lib in ("libxfce4panel-2.0.so.4", "libX11.so.6", "libgtk-3.so.0"):
    if lib not in needed_so:
        raise SystemExit(f"PROBE_MISSING_SO_{lib}")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=none arch=aarch64 n_elf=2")
PY

# Locales, icons — keep standard /usr/share paths.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'xfce4-dict.mo';
         find "$UNPACK/usr/share/icons/hicolor" -type f -name 'xfce4-dict.svg')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/xfce4-dict.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/xfce4-dict.1.gz"

# Panel plugin desktop stays on the standard XFCE path.
cp -a --remove-destination "$UNPACK/usr/share/xfce4/panel/plugins/xfce4-dict-plugin.desktop" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins/xfce4-dict-plugin.desktop"

# Upstream docs
for src in copyright changelog.Debian.gz NEWS.Debian.gz; do
  if [[ -f "$UNPACK/usr/share/doc/xfce4-dict/$src" ]]; then
    case "$src" in
      copyright) dest=copyright.upstream ;;
      changelog.Debian.gz) dest=changelog.upstream.gz ;;
      NEWS.Debian.gz) dest=NEWS.Debian.upstream.gz ;;
      *) dest="$src" ;;
    esac
    cp -a --remove-destination "$UNPACK/usr/share/doc/xfce4-dict/$src" \
      "$STAGE/pkg/usr/share/doc/$PKG/$dest"
  fi
done

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
# Official Icon=xfce4-dict (hicolor svg shipped in this deb).
sed -e 's|^Exec=xfce4-dict$|Exec=/usr/bin/xfce4-dict|' \
  "$UNPACK/usr/share/applications/xfce4-dict.desktop" \
  > "$STAGE/pkg/usr/share/applications/xfce4-dict.desktop"
grep -q '^Exec=/usr/bin/xfce4-dict$' "$STAGE/pkg/usr/share/applications/xfce4-dict.desktop"
grep -q '^Icon=xfce4-dict' "$STAGE/pkg/usr/share/applications/xfce4-dict.desktop"

ln -sf /opt/xfce4-dict/xfce4-dict "$STAGE/pkg/usr/bin/xfce4-dict"
ln -sf xfce4-dict "$STAGE/pkg/usr/bin/kemi-xfce4-dict"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://goodies.xfce.org/projects/applications/xfce4-dict
Source: https://launchpad.net/ubuntu/+source/xfce4-dict
Homepage: https://goodies.xfce.org/projects/applications/xfce4-dict
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (xfce4-dict_0.8.3-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xfce4-dict_0.8.3-1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/xfce4-dict + /usr/bin/xfce4-dict; XFCE panel plugin
    stays on standard /usr/lib/aarch64-linux-gnu/xfce4/panel/plugins
    and /usr/share/xfce4/panel/plugins paths; locales, desktop, man
    and hicolor icon stay on standard /usr/share paths. Official
    desktop Icon=xfce4-dict.
  * Depends kept for Ubuntu 20.04 (GTK3, libgdk-pixbuf2.0-0,
    libglib2.0-0, libpango-1.0-0, libx11-6, libxfce4panel-2.0-4,
    libxfce4ui-2-0, libxfce4util7, libc6 >= 2.17).
  * Recommends: aspell | ispell. Provides: dict-client.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 17:58:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xfce4 Dict ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/xfce4-dict/; launcher /usr/bin/xfce4-dict (symlink to /opt/xfce4-dict/xfce4-dict).
XFCE panel plugin remains on the standard panel search path
(/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libxfce4dict.so
and /usr/share/xfce4/panel/plugins/xfce4-dict-plugin.desktop).
Locales, desktop, man and hicolor icon remain on standard /usr/share paths.
Official desktop Icon=xfce4-dict (scalable svg shipped).
Probe: aarch64 · requiredGlibc 2.17 (2 ELF) · no GLIBCXX · GTK3 + GDK3 + Pango + GdkPixbuf + GIO/GObject/GLib + libxfce4ui + libxfce4util + (plugin) libX11 + libxfce4panel; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.19.12), libpango-1.0-0 (>= 1.14.0), libx11-6, libxfce4panel-2.0-4 (>= 4.13.0), libxfce4ui-2-0 (>= 4.13.0), libxfce4util7 (>= 4.9.0).
Recommends: aspell | ispell. Provides: dict-client.
Official Launchpad publication: xfce4-dict 0.8.3-1 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu focal PROPOSED and published to Release.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: xfce
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.19.12), libpango-1.0-0 (>= 1.14.0), libx11-6, libxfce4panel-2.0-4 (>= 4.13.0), libxfce4ui-2-0 (>= 4.13.0), libxfce4util7 (>= 4.9.0)
Recommends: aspell | ispell
Provides: dict-client
Conflicts: xfce4-dict
Replaces: xfce4-dict
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://goodies.xfce.org/projects/applications/xfce4-dict
Description: Dictionary client and Xfce panel plugin (arm64)
 Xfce4 Dict ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 dictionary client (Dict/RFC 2229, web, aspell).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xfce4-dict-control.txt"
