#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) hardinfo 0.5.1+git20180227-2 arm64 deb
# as kemi-hardinfo.
# Probe: aarch64 · 5 ELF (hardinfo requiredGlibc 2.27; 4 modules 2.17) ·
#   no GLIBCXX · main: GTK2 (libgtk-x11-2.0 / libgdk-x11-2.0) +
#   GDK-Pixbuf + Pango + GObject + GModule + GLib + libm + libc ·
#   PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (pciutils >= 1:2.1.11-10,
#   zlib1g-dev, libc6 >= 2.27, libgdk-pixbuf2.0-0 >= 2.22.0,
#   libglib2.0-0 >= 2.43.2, libgtk2.0-0 >= 2.18.0,
#   libpango-1.0-0 >= 1.14.0). Recommends: lm-sensors. Suggests: mesa-utils.
# Launchpad: hardinfo 0.5.1+git20180227-2 in focal arm64, universe/Release,
#   Published 2019-10-18 17:15:30 Asia/Shanghai (binarypub 131879191);
#   copied from ubuntu disco-proposed arm64.
# arm64 binary was built in ubuntu disco PROPOSED (build 16201624,
#   Successfully built 2018-12-25 03:14:59 Asia/Shanghai) and published
#   to focal Release (Launchpad HTML: "arm64 build of hardinfo
#   0.5.1+git20180227-2 in ubuntu disco PROPOSED").
# Layout keeps the official ELF at /usr/bin/hardinfo because the binary
# embeds binreloc (/proc/self/exe, /proc/self/maps) plus compiled-in
# prefixes /usr/lib/aarch64-linux-gnu/hardinfo, /usr/share/hardinfo and
# /usr/share/locale. Modules, pixmaps, benchmark data, help and locales
# stay on those standard paths. /opt/hardinfo/hardinfo is a symlink to
# /usr/bin/hardinfo (KEMI layout marker), not the real ELF.
# Official desktop Exec=/usr/bin/hardinfo
# Official Icon=/usr/share/hardinfo/pixmaps/logo.png (pixmap shipped).
# Official locales: de, es, fr, ru (no zh .mo in this deb).
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-hardinfo
VER_UP='0.5.1+git20180227'
VER_DEB="${VER_UP}-2kemi1"
ARCH=arm64
PKG=kemi-hardinfo
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/hardinfo-0.5.1+git20180227-2-focal-unpack}"
UP_DEB="$DL/hardinfo_0.5.1+git20180227-2_arm64.deb"
EXPECT_SHA=2c176cff53480e177cfcdf4c7a8e6de9ec3ae990bb2ed3f9bd5c7fc823de5a5b
EXPECT_BYTES=308068
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/hardinfo"
test -f "$UNPACK/usr/share/applications/hardinfo.desktop"
test -f "$UNPACK/usr/share/man/man1/hardinfo.1.gz"
test -f "$UNPACK/usr/share/hardinfo/pixmaps/logo.png"
test -f "$UNPACK/usr/share/hardinfo/benchmark.conf"
test -f "$UNPACK/usr/share/hardinfo/benchmark.data"
test -f "$UNPACK/usr/share/hardinfo/doc/index.hlp"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/hardinfo/modules/benchmark.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/hardinfo/modules/computer.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/hardinfo/modules/devices.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/hardinfo/modules/network.so"
test -f "$UNPACK/usr/share/locale/de/LC_MESSAGES/hardinfo.mo"
test -f "$UNPACK/usr/share/locale/es/LC_MESSAGES/hardinfo.mo"
test -f "$UNPACK/usr/share/locale/fr/LC_MESSAGES/hardinfo.mo"
test -f "$UNPACK/usr/share/locale/ru/LC_MESSAGES/hardinfo.mo"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/hardinfo"

# Official ELF stays at /usr/bin/hardinfo (binreloc + compiled /usr prefixes).
# Hardlink so packing does not double disk use.
cp -al "$UNPACK/usr/bin/hardinfo" "$STAGE/pkg/usr/bin/hardinfo"
chmod 0755 "$STAGE/pkg/usr/bin/hardinfo"
test -x "$STAGE/pkg/usr/bin/hardinfo"

# Modules must remain at the compiled-in library prefix.
cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/hardinfo" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo"
chmod 0755 "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo/modules/"*.so

# Probe all 5 staged ELFs before packing.
REPORT="$ROOT/probe/kemi-hardinfo.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/usr/bin/hardinfo" \
  --elf "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo/modules/benchmark.so" \
  --elf "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo/modules/computer.so" \
  --elf "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo/modules/devices.so" \
  --elf "$STAGE/pkg/usr/lib/aarch64-linux-gnu/hardinfo/modules/network.so" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files=r.get("files") or []
if len(files) != 5:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by= {Path(f["path"]).name: f for f in files}
main=by["hardinfo"]
if main.get("requiredGlibc") != "2.27" or main.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_MAIN")
if main.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(main.get("neededLibraries") or [])
for lib in ("libgtk-x11-2.0.so.0", "libgdk-x11-2.0.so.0", "libgdk_pixbuf-2.0.so.0",
            "libpango-1.0.so.0", "libgobject-2.0.so.0", "libgmodule-2.0.so.0",
            "libglib-2.0.so.0", "libm.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
for name in ("benchmark.so", "computer.so", "devices.so", "network.so"):
    f=by[name]
    if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_UNEXPECTED_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX_{name}")
print("PROBE_PASS requiredGlibc=2.27 (main) / 2.17 (4 modules) no-GLIBCXX arch=aarch64 n_elf=5")
PY

# Data / pixmaps / locales stay on compiled-in /usr/share paths.
cp -a "$UNPACK/usr/share/hardinfo" "$STAGE/pkg/usr/share/hardinfo"
test -f "$STAGE/pkg/usr/share/hardinfo/pixmaps/logo.png"
test -f "$STAGE/pkg/usr/share/hardinfo/benchmark.conf"
test -f "$STAGE/pkg/usr/share/hardinfo/doc/index.hlp"
mkdir -p "$STAGE/pkg/usr/share/locale/de/LC_MESSAGES" \
  "$STAGE/pkg/usr/share/locale/es/LC_MESSAGES" \
  "$STAGE/pkg/usr/share/locale/fr/LC_MESSAGES" \
  "$STAGE/pkg/usr/share/locale/ru/LC_MESSAGES"
cp -a --remove-destination "$UNPACK/usr/share/locale/de/LC_MESSAGES/hardinfo.mo" \
  "$STAGE/pkg/usr/share/locale/de/LC_MESSAGES/hardinfo.mo"
cp -a --remove-destination "$UNPACK/usr/share/locale/es/LC_MESSAGES/hardinfo.mo" \
  "$STAGE/pkg/usr/share/locale/es/LC_MESSAGES/hardinfo.mo"
cp -a --remove-destination "$UNPACK/usr/share/locale/fr/LC_MESSAGES/hardinfo.mo" \
  "$STAGE/pkg/usr/share/locale/fr/LC_MESSAGES/hardinfo.mo"
cp -a --remove-destination "$UNPACK/usr/share/locale/ru/LC_MESSAGES/hardinfo.mo" \
  "$STAGE/pkg/usr/share/locale/ru/LC_MESSAGES/hardinfo.mo"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/hardinfo.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/hardinfo.1.gz"

# Official desktop already uses Exec=/usr/bin/hardinfo and the shipped logo pixmap.
cp -a --remove-destination "$UNPACK/usr/share/applications/hardinfo.desktop" \
  "$STAGE/pkg/usr/share/applications/hardinfo.desktop"
grep -q '^Exec=/usr/bin/hardinfo$' "$STAGE/pkg/usr/share/applications/hardinfo.desktop"
grep -q '^Icon=/usr/share/hardinfo/pixmaps/logo.png$' "$STAGE/pkg/usr/share/applications/hardinfo.desktop"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/hardinfo/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hardinfo/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/hardinfo/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hardinfo/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi

ln -sf /usr/bin/hardinfo "$STAGE/pkg/opt/hardinfo/hardinfo"
ln -sf hardinfo "$STAGE/pkg/usr/bin/kemi-hardinfo"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/lpereira/hardinfo
Source: https://launchpad.net/ubuntu/+source/hardinfo
Homepage: http://hardinfo.org
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-2 (hardinfo_0.5.1+git20180227-2_arm64.deb)
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 hardinfo_0.5.1+git20180227-2_arm64.deb
    repackaged for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/hardinfo because the binary embeds
    binreloc (/proc/self/exe) plus compiled-in prefixes
    /usr/lib/aarch64-linux-gnu/hardinfo, /usr/share/hardinfo and
    /usr/share/locale. Modules, pixmaps, benchmark data, help and
    locales stay on those standard paths. /opt/hardinfo/hardinfo is a
    symlink to /usr/bin/hardinfo.
  * Official desktop Exec=/usr/bin/hardinfo;
    Icon=/usr/share/hardinfo/pixmaps/logo.png (pixmap shipped).
    Official locales: de, es, fr, ru (no zh .mo in this deb).
  * Conflicts/Replaces hardinfo.
  * Depends kept for Ubuntu 20.04 (GTK2, GLib, GDK-Pixbuf, Pango,
    libc6 >= 2.27, pciutils, zlib1g-dev). Recommends: lm-sensors.
    Suggests: mesa-utils.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:55:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
HardInfo ${VER_UP}-2 — official Ubuntu 20.04 (focal) arm64, KEMI repack.

The official ELF stays at /usr/bin/hardinfo (binreloc uses /proc/self/exe;
compiled prefixes are /usr/lib/aarch64-linux-gnu/hardinfo,
/usr/share/hardinfo and /usr/share/locale).
/opt/hardinfo/hardinfo is a symlink to /usr/bin/hardinfo.
Modules, pixmaps, benchmark data, help, locales, desktop and man remain
on standard /usr paths.
Official desktop Icon=/usr/share/hardinfo/pixmaps/logo.png (pixmap shipped).
Official locales: de, es, fr, ru (this deb ships no zh .mo).
Probe: aarch64 · 5 ELF · requiredGlibc 2.27 (main) / 2.17 (4 modules) ·
no GLIBCXX · GTK2 + GDK-Pixbuf + Pango + GLib; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: pciutils (>= 1:2.1.11-10), zlib1g-dev, libc6 (>= 2.27),
libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.2),
libgtk2.0-0 (>= 2.18.0), libpango-1.0-0 (>= 1.14.0).
Recommends: lm-sensors. Suggests: mesa-utils.
Official Launchpad publication: hardinfo 0.5.1+git20180227-2 in focal
arm64 (universe, Release). The arm64 binary was built in ubuntu disco
PROPOSED (build 16201624) and published to focal Release (copied from
ubuntu disco-proposed arm64).
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
Depends: pciutils (>= 1:2.1.11-10), zlib1g-dev, libc6 (>= 2.27), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.2), libgtk2.0-0 (>= 2.18.0), libpango-1.0-0 (>= 1.14.0)
Recommends: lm-sensors
Suggests: mesa-utils
Conflicts: hardinfo
Replaces: hardinfo
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://hardinfo.org
Description: System profiler and benchmark (arm64)
 HardInfo ${VER_UP}-2 — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2 system information and benchmark tool.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-hardinfo-control.txt"
