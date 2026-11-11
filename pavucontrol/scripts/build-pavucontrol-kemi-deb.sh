#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) pavucontrol 4.0-1build1 arm64 deb as kemi-pavucontrol.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · requiredGlibcxx 3.4.21 ·
#   GTKMM3 + GDKMM3 + ATKMM + GIOMM + GLIBMM + sigc++-2.0 + canberra-gtk3 +
#   libcanberra + GTK3 + GObject/GLib + libpulse-mainloop-glib + libpulse +
#   libstdc++ / libgcc_s · PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
# Official Depends already match Ubuntu 20.04 (libatkmm-1.6-1v5 >= 2.24.0,
#   libc6 >= 2.17, libcanberra-gtk3-0 >= 0.25, libcanberra0 >= 0.16,
#   libgcc-s1 >= 3.0, libglib2.0-0 >= 2.16.0, libglibmm-2.4-1v5 >= 2.54.0,
#   libgtk-3-0 >= 3.0.0, libgtkmm-3.0-1v5 >= 3.24.0,
#   libpulse-mainloop-glib0 >= 0.99.1, libpulse0 >= 4.0,
#   libsigc++-2.0-0v5 >= 2.2.0, libstdc++6 >= 5.2).
# Recommends: pulseaudio.
# Launchpad: pavucontrol 4.0-1build1 in focal arm64, universe/Release, Published 2020-03-23.
# arm64 binary was built in ubuntu focal PROPOSED (no-change rebuild for libgcc-s1
# package-name change) and published to Release.
# Official desktop Icon=multimedia-volume-control (theme icon; not shipped in this deb).
# Exec=pavucontrol. Locales / desktop / man / glade UI stay on standard /usr/share paths
# (compiled-in UI path /usr/share/pavucontrol/pavucontrol.glade).
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-pavucontrol
VER_UP=4.0
VER_DEB="${VER_UP}-1build1kemi1"
ARCH=arm64
PKG=kemi-pavucontrol
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/pavucontrol-4.0-1build1-focal-unpack}"
UP_DEB="$DL/pavucontrol_4.0-1build1_arm64.deb"
EXPECT_SHA=4fdb6af636fc3b76299ec5254eb998ccf0f13b218c3a027ca1b641a6fbc77496
EXPECT_BYTES=137328
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/pavucontrol"
test -f "$UNPACK/usr/share/applications/pavucontrol.desktop"
test -f "$UNPACK/usr/share/man/man1/pavucontrol.1.gz"
test -f "$UNPACK/usr/share/pavucontrol/pavucontrol.glade"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/pavucontrol" \
  "$STAGE/pkg/opt/pavucontrol"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/pavucontrol" "$STAGE/pkg/opt/pavucontrol/pavucontrol"
chmod 0755 "$STAGE/pkg/opt/pavucontrol/pavucontrol"
test -x "$STAGE/pkg/opt/pavucontrol/pavucontrol"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-pavucontrol.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/pavucontrol/pavucontrol" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
if f.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libgtkmm-3.0.so.1", "libatkmm-1.6.so.1", "libgdkmm-3.0.so.1",
            "libgiomm-2.4.so.1", "libglibmm-2.4.so.1", "libsigc-2.0.so.0",
            "libcanberra-gtk3.so.0", "libcanberra.so.0", "libgtk-3.so.0",
            "libgobject-2.0.so.0", "libglib-2.0.so.0",
            "libpulse-mainloop-glib.so.0", "libpulse.so.0",
            "libstdc++.so.6", "libgcc_s.so.1"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=3.4.21 arch=aarch64 n_elf=1")
PY

# Locales + compiled-in glade UI — keep standard /usr/share paths.
while IFS= read -r f; do
  rel="${f#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$f" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$f" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'pavucontrol.mo';
         find "$UNPACK/usr/share/pavucontrol" -type f -name 'pavucontrol.glade')

cp -a --remove-destination "$UNPACK/usr/share/man/man1/pavucontrol.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/pavucontrol.1.gz"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/pavucontrol/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/pavucontrol/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
# Official Icon=multimedia-volume-control (theme icon; not shipped in this deb).
sed -e 's|^Exec=pavucontrol$|Exec=/usr/bin/pavucontrol|' \
  "$UNPACK/usr/share/applications/pavucontrol.desktop" \
  > "$STAGE/pkg/usr/share/applications/pavucontrol.desktop"
grep -q '^Exec=/usr/bin/pavucontrol$' "$STAGE/pkg/usr/share/applications/pavucontrol.desktop"
grep -q '^Icon=multimedia-volume-control' "$STAGE/pkg/usr/share/applications/pavucontrol.desktop"

ln -sf /opt/pavucontrol/pavucontrol "$STAGE/pkg/usr/bin/pavucontrol"
ln -sf pavucontrol "$STAGE/pkg/usr/bin/kemi-pavucontrol"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://freedesktop.org/software/pulseaudio/pavucontrol/
Source: https://launchpad.net/ubuntu/+source/pavucontrol
Homepage: https://freedesktop.org/software/pulseaudio/pavucontrol/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (pavucontrol_4.0-1build1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 pavucontrol_4.0-1build1_arm64.deb
    repackaged for KEMI as ${PKG}.
  * Layout /opt/pavucontrol + /usr/bin/pavucontrol; locales, desktop,
    man and compiled-in glade UI stay on standard /usr/share paths
    (/usr/share/pavucontrol/pavucontrol.glade). Official desktop
    Icon=multimedia-volume-control (theme icon; not shipped in this deb).
  * Depends kept for Ubuntu 20.04 (GTK3, GTKMM3, ATKMM, GLIBMM, sigc++-2.0,
    libcanberra-gtk3, libpulse / libpulse-mainloop-glib, libgcc-s1,
    libstdc++6, libc6 >= 2.17). Recommends: pulseaudio.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 18:10:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Pavucontrol ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/pavucontrol/; launcher /usr/bin/pavucontrol (symlink to /opt/pavucontrol/pavucontrol).
Locales, desktop, man and compiled-in glade UI remain on standard /usr/share paths
(/usr/share/pavucontrol/pavucontrol.glade).
Official desktop Icon=multimedia-volume-control (theme icon; not shipped in this deb).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · requiredGlibcxx 3.4.21 · GTKMM3 + GDKMM3 + ATKMM + GIOMM + GLIBMM + sigc++-2.0 + canberra-gtk3 + libcanberra + GTK3 + GObject/GLib + libpulse-mainloop-glib + libpulse + libstdc++ / libgcc_s; Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Runtime: libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.17), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.16), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.16.0), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.0.0), libgtkmm-3.0-1v5 (>= 3.24.0), libpulse-mainloop-glib0 (>= 0.99.1), libpulse0 (>= 4.0), libsigc++-2.0-0v5 (>= 2.2.0), libstdc++6 (>= 5.2).
Recommends: pulseaudio.
Official Launchpad publication: pavucontrol 4.0-1build1 in focal arm64 (universe, Release).
The arm64 binary was built in ubuntu focal PROPOSED (no-change rebuild for libgcc-s1 package-name change) and published to Release.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: sound
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.17), libcanberra-gtk3-0 (>= 0.25), libcanberra0 (>= 0.16), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.16.0), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.0.0), libgtkmm-3.0-1v5 (>= 3.24.0), libpulse-mainloop-glib0 (>= 0.99.1), libpulse0 (>= 4.0), libsigc++-2.0-0v5 (>= 2.2.0), libstdc++6 (>= 5.2)
Recommends: pulseaudio
Conflicts: pavucontrol
Replaces: pavucontrol
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://freedesktop.org/software/pulseaudio/pavucontrol/
Description: PulseAudio Volume Control (arm64)
 Pavucontrol ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 PulseAudio volume control (mixer).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-pavucontrol-control.txt"
