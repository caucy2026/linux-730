#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) FeatherPad 0.12.1 arm64 deb as kemi-featherpad.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · GLIBCXX 3.4.21 · Qt_5 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17, libqt5core5a >= 5.12.2,
# libhunspell-1.7-0, libqt5x11extras5, …).
# Official GitHub tsujan/FeatherPad releases are source-only (no linux aarch64).
# Debian bullseye official arm64 0.17.1 needs libqt5core5a >= 5.15.1 — not used.
# Xournal++ official jammy aarch64 was SKIP (GLIBC 2.35 / GLIBCXX 3.4.30).
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xournalpp
VER_UP=0.12.1
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-featherpad
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/featherpad-0121-focal-unpack}"
UP_DEB="$DL/featherpad_0.12.1-1build1_arm64.deb"
EXPECT_SHA=bdc80323103f2bb7bec995877bf3e1d85fa825871a78f2829b237838a6a6d582
EXPECT_BYTES=359060
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/featherpad"
test -f "$UNPACK/usr/share/applications/featherpad.desktop"
test -f "$UNPACK/usr/share/featherpad/help"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/featherpad.svg"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/featherpad" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/opt/featherpad"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/featherpad" "$STAGE/pkg/opt/featherpad/featherpad"
chmod 0755 "$STAGE/pkg/opt/featherpad/featherpad"
test -x "$STAGE/pkg/opt/featherpad/featherpad"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-featherpad.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/featherpad/featherpad" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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

# Data files stay on standard /usr/share paths (binary looks up /featherpad/help under GenericDataLocation).
cp -a --remove-destination "$UNPACK/usr/share/featherpad/help" \
  "$STAGE/pkg/usr/share/featherpad/help"
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/featherpad.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/featherpad.svg"
if [[ -f "$UNPACK/usr/share/doc/featherpad/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/featherpad/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/featherpad/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/featherpad/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=featherpad |Exec=/usr/bin/featherpad |' \
    -e 's|^Exec=featherpad$|Exec=/usr/bin/featherpad|' \
  "$UNPACK/usr/share/applications/featherpad.desktop" \
  > "$STAGE/pkg/usr/share/applications/featherpad.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/featherpad.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/featherpad %F$/a TryExec=/usr/bin/featherpad' \
    "$STAGE/pkg/usr/share/applications/featherpad.desktop"
fi
grep -q '^Exec=/usr/bin/featherpad %F' "$STAGE/pkg/usr/share/applications/featherpad.desktop"
grep -q '^Exec=/usr/bin/featherpad --win' "$STAGE/pkg/usr/share/applications/featherpad.desktop"

ln -sf /opt/featherpad/featherpad "$STAGE/pkg/usr/bin/featherpad"
ln -sf featherpad "$STAGE/pkg/usr/bin/fpad"
ln -sf featherpad "$STAGE/pkg/usr/bin/kemi-featherpad"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/tsujan/FeatherPad
Homepage: https://github.com/tsujan/FeatherPad
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP} (featherpad_0.12.1-1build1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 featherpad_0.12.1-1build1_arm64.deb repackaged
    for KEMI as ${PKG}.
  * Layout /opt/featherpad + /usr/bin/featherpad (and fpad).
  * Depends kept for Ubuntu 20.04 (Qt5 5.12, libhunspell-1.7-0, libc6 >= 2.17).
  * Xournal++ official jammy aarch64 not used (GLIBC 2.35).
  * Debian bullseye official FeatherPad 0.17.1 not used (Qt >= 5.15.1).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:40:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
FeatherPad ${VER_UP} — official Ubuntu 20.04 (focal) arm64, KEMI repack.

Installs under /opt/featherpad/; launcher /usr/bin/featherpad (symlink to /opt/featherpad/featherpad); also /usr/bin/fpad.
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · GLIBCXX 3.4.21 · Qt_5; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libqt5core5a (>= 5.12.2), libqt5gui5, libqt5widgets5, libqt5network5, libqt5printsupport5, libqt5svg5, libqt5x11extras5, libhunspell-1.7-0, libx11-6.
Official GitHub releases are source-only; Debian bullseye 0.17.1 needs Qt 5.15.1 and is not used.
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
Depends: libc6 (>= 2.17), libgcc-s1 (>= 3.0), libhunspell-1.7-0, libqt5core5a (>= 5.12.2), libqt5gui5 (>= 5.12.2) | libqt5gui5-gles (>= 5.12.2), libqt5network5 (>= 5.0.2), libqt5printsupport5 (>= 5.0.2), libqt5svg5 (>= 5.6.0~beta), libqt5widgets5 (>= 5.11.0~rc1), libqt5x11extras5 (>= 5.6.0), libstdc++6 (>= 5.2), libx11-6
Recommends: featherpad-l10n, libglib2.0-bin
Conflicts: featherpad
Replaces: featherpad
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/tsujan/FeatherPad
Description: FeatherPad lightweight Qt5 text editor (arm64)
 FeatherPad ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight Qt5 plain-text editor. glibc≤2.31 (Ubuntu 20.04).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-featherpad-control.txt"
