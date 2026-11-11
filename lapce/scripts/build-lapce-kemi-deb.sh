#!/usr/bin/env bash
# Wrap official Lapce 0.4.6 debian bullseye arm64 deb as kemi-lapce.
# Probe: aarch64 · requiredGlibc 2.30 (1 ELF) · PASS vs 101 ≤2.31
# Official Depends: libc6 (>= 2.30), libgcc-s1, libssl1.1, zlib1g (U20.04 OK).
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-lapce
VER_UP=0.4.6
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-lapce
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/upstream}"
UP_DEB="$DL/lapce.debian.bullseye.arm64.deb"
EXPECT_SHA=c9080bfb36a60ae5d5737432d49d73000d56a73a11a9e88884b066ce34a5704d
EXPECT_BYTES=13602888
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/lapce"
test -f "$UNPACK/usr/share/applications/dev.lapce.lapce.desktop"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/1024x1024/apps" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/lapce"

# Hardlink the ~49MiB binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/lapce" "$STAGE/pkg/opt/lapce/lapce"
chmod 0755 "$STAGE/pkg/opt/lapce/lapce"
test -x "$STAGE/pkg/opt/lapce/lapce"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-lapce.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/lapce/lapce" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"

# Icons / metainfo (copy, do not mutate upstream via hardlink)
if [[ -f "$UNPACK/usr/share/pixmaps/dev.lapce.lapce.png" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/pixmaps/dev.lapce.lapce.png" \
    "$STAGE/pkg/usr/share/pixmaps/dev.lapce.lapce.png"
  cp -a --remove-destination "$UNPACK/usr/share/pixmaps/dev.lapce.lapce.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/1024x1024/apps/dev.lapce.lapce.png"
fi
if [[ -f "$UNPACK/usr/share/metainfo/dev.lapce.lapce.metainfo.xml" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/metainfo/dev.lapce.lapce.metainfo.xml" \
    "$STAGE/pkg/usr/share/metainfo/dev.lapce.lapce.metainfo.xml"
fi

cat > "$STAGE/pkg/usr/share/applications/dev.lapce.lapce.desktop" << 'EOT'
[Desktop Entry]
Version=1.0
Type=Application
Name=Lapce
Comment=Lightning-fast and powerful code editor written in Rust
Categories=Development;IDE;
GenericName=Code Editor
StartupWMClass=lapce
Icon=dev.lapce.lapce
TryExec=/usr/bin/lapce
Exec=/usr/bin/lapce %F
Terminal=false
MimeType=text/plain;inode/directory;
Actions=new-window;
StartupNotify=true

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/lapce --new %F
Icon=dev.lapce.lapce
EOT

ln -sf /opt/lapce/lapce "$STAGE/pkg/usr/bin/lapce"
ln -sf lapce "$STAGE/pkg/usr/bin/kemi-lapce"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/lapce/lapce
Homepage: https://lapce.dev
License: Apache-2.0 (see https://github.com/lapce/lapce)
Official debian bullseye arm64 deb v${VER_UP} (lapce.debian.bullseye.arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Lapce ${VER_UP} — official debian bullseye arm64, KEMI repack.

Installs under /opt/lapce/; launcher /usr/bin/lapce (symlink to /opt/lapce/lapce).
Probe: aarch64 · requiredGlibc 2.30 (1 ELF; Ubuntu 20.04 / glibc 2.31 OK).
Runtime also wants libssl1.1 (OpenSSL 1.1) and zlib.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.30), libgcc-s1 (>= 4.2), libssl1.1 (>= 1.1.1), zlib1g (>= 1:1.1.4)
Conflicts: lapce, lapce-nightly
Replaces: lapce, lapce-nightly
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://lapce.dev
Description: Lapce lightning-fast code editor (arm64)
 Lapce ${VER_UP} — official debian bullseye arm64, KEMI repack.
 Lightning-fast Rust code editor (Floem / wgpu). glibc≤2.31 (Ubuntu 20.04).
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
