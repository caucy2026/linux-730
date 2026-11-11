#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) Mousepad 0.4.2 arm64 deb as kemi-mousepad.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libgtk-3-0 >= 3.16.2,
# libgtksourceview-3.0-1, libglib2.0-0, libpango-1.0-0, libxfconf-0-3, gsettings backend).
# Launchpad: mousepad 0.4.2-1 in focal arm64, universe, Published 2019-10-18.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-mousepad
VER_UP=0.4.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-mousepad
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/mousepad-0421-focal-unpack}"
UP_DEB="$DL/mousepad_0.4.2-1_arm64.deb"
EXPECT_SHA=9196953da1f1a9fc6dceebaea005d5b2456ef155d39f55d9182eed7a5e5af6bf
EXPECT_BYTES=262616
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/mousepad"
test -f "$UNPACK/usr/share/applications/mousepad.desktop"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.xfce.mousepad.gschema.xml"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/polkit-1/actions" \
  "$STAGE/pkg/opt/mousepad"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/mousepad" "$STAGE/pkg/opt/mousepad/mousepad"
chmod 0755 "$STAGE/pkg/opt/mousepad/mousepad"
test -x "$STAGE/pkg/opt/mousepad/mousepad"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-mousepad.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/mousepad/mousepad" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
f=r["files"][0]
if f.get("requiredGlibc") != "2.17" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
print("PROBE_PASS requiredGlibc=2.17 arch=aarch64 glibcxx="+str(f.get("requiredGlibcxx")))
PY

# Data files stay on standard /usr/share paths (gschema, locales, desktop, man, polkit).
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.xfce.mousepad.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.xfce.mousepad.gschema.xml"
while IFS= read -r mo; do
  rel="${mo#"$UNPACK"/}"
  mkdir -p "$STAGE/pkg/$(dirname "$rel")"
  cp -al "$mo" "$STAGE/pkg/$rel" 2>/dev/null || cp -a --remove-destination "$mo" "$STAGE/pkg/$rel"
done < <(find "$UNPACK/usr/share/locale" -type f -name 'mousepad.mo')
if [[ -f "$UNPACK/usr/share/man/man1/mousepad.1.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/man/man1/mousepad.1.gz" \
    "$STAGE/pkg/usr/share/man/man1/mousepad.1.gz"
fi
if [[ -f "$UNPACK/usr/share/polkit-1/actions/org.xfce.mousepad.policy" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/polkit-1/actions/org.xfce.mousepad.policy" \
    "$STAGE/pkg/usr/share/polkit-1/actions/org.xfce.mousepad.policy"
fi
if [[ -f "$UNPACK/usr/share/doc/mousepad/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/mousepad/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/mousepad/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/mousepad/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/mousepad/README" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/mousepad/README" \
    "$STAGE/pkg/usr/share/doc/$PKG/README.upstream"
fi

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=mousepad |Exec=/usr/bin/mousepad |' \
    -e 's|^Exec=mousepad$|Exec=/usr/bin/mousepad|' \
  "$UNPACK/usr/share/applications/mousepad.desktop" \
  > "$STAGE/pkg/usr/share/applications/mousepad.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/mousepad.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/mousepad %F$/a TryExec=/usr/bin/mousepad' \
    "$STAGE/pkg/usr/share/applications/mousepad.desktop"
fi
grep -q '^Exec=/usr/bin/mousepad %F' "$STAGE/pkg/usr/share/applications/mousepad.desktop"
grep -q '^TryExec=/usr/bin/mousepad' "$STAGE/pkg/usr/share/applications/mousepad.desktop"
grep -q '^Icon=accessories-text-editor' "$STAGE/pkg/usr/share/applications/mousepad.desktop"

ln -sf /opt/mousepad/mousepad "$STAGE/pkg/usr/bin/mousepad"
ln -sf mousepad "$STAGE/pkg/usr/bin/kemi-mousepad"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gitlab.xfce.org/apps/mousepad
Homepage: https://docs.xfce.org/apps/mousepad/start
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (mousepad_0.4.2-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 mousepad_0.4.2-1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/mousepad + /usr/bin/mousepad.
  * Depends kept for Ubuntu 20.04 (GTK3, GtkSourceView 3, libxfconf-0-3, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:45:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Mousepad ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/mousepad/; launcher /usr/bin/mousepad (symlink to /opt/mousepad/mousepad).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · no GLIBCXX · GTK3; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libgtk-3-0 (>= 3.16.2), libgtksourceview-3.0-1 (>= 2.91.4), libglib2.0-0 (>= 2.41.1), libpango-1.0-0 (>= 1.14.0), libxfconf-0-3 (>= 4.6.0), dconf-gsettings-backend | gsettings-backend.
Official Launchpad publication: mousepad 0.4.2-1 in focal arm64 (universe).
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: editors
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libglib2.0-0 (>= 2.41.1), libgtk-3-0 (>= 3.16.2), libgtksourceview-3.0-1 (>= 2.91.4), libpango-1.0-0 (>= 1.14.0), libxfconf-0-3 (>= 4.6.0)
Conflicts: mousepad
Replaces: mousepad
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gitlab.xfce.org/apps/mousepad
Description: Mousepad simple Xfce GTK3 text editor (arm64)
 Mousepad ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight Xfce-oriented GTK3 plain-text editor. glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
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
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-mousepad-control.txt"
