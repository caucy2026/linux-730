#!/usr/bin/env bash
# Wrap official Orca (orca-ide) arm64.deb as kemi-orca.
# gork.bot协助开发 · 验证 ≠ 编译
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UP=1.4.277
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-orca
DL="${DL:-$ROOT/../../dl}"
OUT="${OUT:-$ROOT/../../debs}"
UP_DEB="$DL/orca-ide_${VER_UP}_arm64.deb"
EXPECT_SHA=abc65fe8f7f3f7b7be69f1ca0ec45b2cc6c622b7e8422e3e5c1811e7aa844e54
EXPECT_BYTES=211887948
EXPECT_SHA512_B64='78T7D+oHgmTy00AQQnHvwiaDa8B8WPzrVQOVGfEVdT00lwCTAhksBV1g86ufQiEtWTRLH4EtYA0/wVLDv+y1Ug=='
URL="https://github.com/stablyai/orca/releases/download/v${VER_UP}/orca-ide_${VER_UP}_arm64.deb"
mkdir -p "$DL" "$OUT"
if [[ ! -f "$UP_DEB" ]]; then
  curl -fL --retry 3 --retry-delay 2 -o "$UP_DEB" "$URL"
fi
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/root" "$STAGE/pkg/DEBIAN" "$STAGE/pkg/opt" "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/icons/hicolor"
dpkg-deb -x "$UP_DEB" "$STAGE/root"
cp -a "$STAGE/root/opt/Orca" "$STAGE/pkg/opt/"
cp -a "$STAGE/root/usr/share/applications/orca-ide.desktop" "$STAGE/pkg/usr/share/applications/"
cp -a "$STAGE/root/usr/share/icons/hicolor/." "$STAGE/pkg/usr/share/icons/hicolor/"
TGT="$STAGE/pkg/opt/Orca/resources/orcad-template/targets"
for d in darwin-arm64 darwin-x64 linux-arm64-musl linux-x64-glibc linux-x64-glibc217 linux-x64-musl win32-arm64 win32-x64; do
  rm -rf "$TGT/$d"
done
RG="$STAGE/pkg/opt/Orca/resources/ripgrep"
for d in darwin-arm64 darwin-x64 linux-x64 win32-arm64 win32-x64; do
  rm -rf "$RG/$d"
done
cat > "$STAGE/pkg/usr/bin/orca-ide" << 'EOT'
#!/bin/sh
exec /opt/Orca/orca-ide "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/orca-ide"
ln -s orca-ide "$STAGE/pkg/usr/bin/kemi-orca"
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/stablyai/orca
Official site: https://orca.dev
License: MIT (see upstream)
Official arm64 .deb v${VER_UP} (orca-ide) repackaged for KEMI Linux as ${PKG}.
Foreign-arch orcad-template / ripgrep trees omitted; linux-arm64-glibc kept.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Orca ${VER_UP} (official linux arm64 desktop / orca-ide).
Installs under /opt/Orca/; launcher /usr/bin/orca-ide (not /usr/bin/orca).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
sandbox=/opt/Orca/chrome-sandbox
if [ -f "$sandbox" ]; then
  chmod 4755 "$sandbox" || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
if [[ -f "$STAGE/pkg/opt/Orca/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/Orca/chrome-sandbox" || true
fi
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, dbus-bin | dbus, libglib2.0-bin, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2t64 | libasound2, libgbm1, python3, python3-gi, gir1.2-atspi-2.0, at-spi2-core, xdotool, xclip, xvfb
Recommends: libappindicator3-1
Provides: orca-ide
Conflicts: orca-ide
Replaces: orca-ide
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://orca.dev
Description: Orca desktop for parallel agentic development (arm64)
 Official Orca ${VER_UP} linux arm64, repackaged for KEMI Linux 101.
 Launch with orca-ide. User supplies agent subscriptions.
 gork.bot协助开发.
EOT
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
