#!/usr/bin/env bash
# Wrap official Flameshot 12.1.0 debian-10 arm64 deb as kemi-flameshot.
# Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · GLIBCXX 3.4.21 · Qt_5 · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 Qt 5.12 (libqt5core5a >= 5.10.0).
# Latest official arm64 (v15 Ubuntu 24.04) needs GLIBC_2.38 + Qt6 — SKIP.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-next
VER_UP=12.1.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-flameshot
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/upstream}"
UP_DEB="$DL/flameshot-12.1.0-1.debian-10.arm64.deb"
EXPECT_SHA=840a1615e30e9225b0484ed63e317a46243acb60f20f0ef6dc723f899b0f9048
EXPECT_BYTES=652648
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/flameshot"
test -f "$UNPACK/usr/share/applications/org.flameshot.Flameshot.desktop"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/bash-completion/completions" \
  "$STAGE/pkg/usr/share/dbus-1/interfaces" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d" \
  "$STAGE/pkg/usr/share/flameshot/translations" \
  "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/zsh/site-functions" \
  "$STAGE/pkg/opt/flameshot"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/flameshot" "$STAGE/pkg/opt/flameshot/flameshot"
chmod 0755 "$STAGE/pkg/opt/flameshot/flameshot"
test -x "$STAGE/pkg/opt/flameshot/flameshot"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-flameshot.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/flameshot/flameshot" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"

# Data files (copy, do not mutate upstream via hardlink)
cp -a --remove-destination "$UNPACK/usr/share/flameshot/translations/"*.qm \
  "$STAGE/pkg/usr/share/flameshot/translations/"
for size in 48x48 128x128; do
  cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/${size}/apps/"*.png \
    "$STAGE/pkg/usr/share/icons/hicolor/${size}/apps/"
done
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/"*.svg \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.flameshot.Flameshot.metainfo.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.flameshot.Flameshot.metainfo.xml"
cp -a --remove-destination "$UNPACK/usr/share/bash-completion/completions/flameshot" \
  "$STAGE/pkg/usr/share/bash-completion/completions/flameshot"
cp -a --remove-destination "$UNPACK/usr/share/zsh/site-functions/_flameshot" \
  "$STAGE/pkg/usr/share/zsh/site-functions/_flameshot"
cp -a --remove-destination "$UNPACK/usr/share/fish/vendor_completions.d/flameshot.fish" \
  "$STAGE/pkg/usr/share/fish/vendor_completions.d/flameshot.fish"
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/interfaces/org.flameshot.Flameshot.xml" \
  "$STAGE/pkg/usr/share/dbus-1/interfaces/org.flameshot.Flameshot.xml"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/flameshot.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/flameshot.1.gz"
if [[ -f "$UNPACK/usr/share/doc/flameshot/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/flameshot/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi

# Desktop: keep upstream translations; point Exec at the KEMI launcher path.
sed -e 's|^Exec=/usr/bin/flameshot|Exec=/usr/bin/flameshot|' \
    -e 's|^Exec=flameshot |Exec=/usr/bin/flameshot |' \
    "$UNPACK/usr/share/applications/org.flameshot.Flameshot.desktop" \
  > "$STAGE/pkg/usr/share/applications/org.flameshot.Flameshot.desktop"
# TryExec for menu systems
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/org.flameshot.Flameshot.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/flameshot$/a TryExec=/usr/bin/flameshot' \
    "$STAGE/pkg/usr/share/applications/org.flameshot.Flameshot.desktop"
fi

cat > "$STAGE/pkg/usr/share/dbus-1/services/org.flameshot.Flameshot.service" << 'EOT'
[D-BUS Service]
Name=org.flameshot.Flameshot
Exec=/usr/bin/flameshot
EOT

ln -sf /opt/flameshot/flameshot "$STAGE/pkg/usr/bin/flameshot"
ln -sf flameshot "$STAGE/pkg/usr/bin/kemi-flameshot"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/flameshot-org/flameshot
Homepage: https://flameshot.org/
License: GPL-3.0-or-later (see copyright.upstream)
Official debian-10 arm64 deb v${VER_UP} (flameshot-12.1.0-1.debian-10.arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Flameshot ${VER_UP} — official debian-10 arm64, KEMI repack.

Installs under /opt/flameshot/; launcher /usr/bin/flameshot (symlink to /opt/flameshot/flameshot).
Probe: aarch64 · requiredGlibc 2.17 (1 ELF) · GLIBCXX 3.4.21 · Qt_5; Ubuntu 20.04 / glibc 2.31 OK.
Runtime wants Qt5 (libqt5core5a / gui / widgets / network / dbus / svg). Ubuntu 20.04 Qt 5.12 satisfies official debian-10 Depends.
Latest official arm64 (v15 Ubuntu 24.04) needs GLIBC_2.38 + Qt6 and is not used.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: graphics
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: hicolor-icon-theme, libc6 (>= 2.17), libgcc-s1 (>= 3.0), libstdc++6 (>= 5.2), libqt5core5a (>= 5.10.0), libqt5dbus5 (>= 5.9.0~), libqt5gui5 (>= 5.10.0) | libqt5gui5-gles (>= 5.10.0), libqt5network5 (>= 5.9.0~), libqt5widgets5 (>= 5.11.0~rc1), libqt5svg5 (>= 5.9.0~)
Conflicts: flameshot
Replaces: flameshot
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://flameshot.org/
Description: Flameshot screenshot tool (arm64)
 Flameshot ${VER_UP} — official debian-10 arm64, KEMI repack.
 Powerful yet simple-to-use screenshot software (Qt5). glibc≤2.31 (Ubuntu 20.04).
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
