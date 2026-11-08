#!/usr/bin/env bash
# Wrap official Standard Notes linux-arm64 deb as kemi-standard-notes.
# Drop wrong-arch microtime prebuilds (linux-arm / linux-x64).
# Probe after drop: aarch64 · requiredGlibc ≤2.25 · PASS vs 101 ≤2.31
# Notesnook skipped (better_sqlite3.node needs GLIBC_2.34).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-notesnook
VER_UP=3.202.11
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-standard-notes
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UP_DEB="$DL/standard-notes-3.202.11-linux-arm64.deb"
EXPECT_SHA=9127e397cf442d3a8d04e13ce2688acef472e2503d7d1dad7020009f5b45f632
EXPECT_BYTES=119951816
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/extract"
dpkg-deb -x "$UP_DEB" "$STAGE/extract"
test -x "$STAGE/extract/opt/Standard Notes/standard-notes"

# Drop wrong-arch microtime prebuilds (armv7 + x86_64)
rm -rf \
  "$STAGE/extract/opt/Standard Notes/resources/app.asar.unpacked/node_modules/microtime/prebuilds/linux-arm" \
  "$STAGE/extract/opt/Standard Notes/resources/app.asar.unpacked/node_modules/microtime/prebuilds/linux-x64" \
  || true
# Drop musl natives (unused on glibc 101)
rm -f \
  "$STAGE/extract/opt/Standard Notes/resources/app.asar.unpacked/node_modules/@cbor-extract/cbor-extract-linux-arm64/"*.musl.node \
  || true

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/Standard Notes"

cp -a "$STAGE/extract/opt/Standard Notes/." "$STAGE/pkg/opt/Standard Notes/"

if [[ -f "$STAGE/extract/usr/share/applications/standard-notes.desktop" ]]; then
  cp -a "$STAGE/extract/usr/share/applications/standard-notes.desktop" \
    "$STAGE/pkg/usr/share/applications/standard-notes.desktop"
fi
if [[ -f "$STAGE/extract/usr/share/icons/hicolor/512x512/apps/standard-notes.png" ]]; then
  cp -a "$STAGE/extract/usr/share/icons/hicolor/512x512/apps/standard-notes.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps/standard-notes.png"
fi
# copy any other hicolor icons if present
if [[ -d "$STAGE/extract/usr/share/icons" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/icons"
  cp -a "$STAGE/extract/usr/share/icons/." "$STAGE/pkg/usr/share/icons/" || true
fi

# Patch desktop Exec to wrapper (avoid spaces in Exec)
if [[ -f "$STAGE/pkg/usr/share/applications/standard-notes.desktop" ]]; then
  sed -i 's|^Exec=.*|Exec=/usr/bin/standard-notes %U|' \
    "$STAGE/pkg/usr/share/applications/standard-notes.desktop" || true
fi

cat > "$STAGE/pkg/usr/bin/standard-notes" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec "/opt/Standard Notes/standard-notes" --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/standard-notes"
ln -sf standard-notes "$STAGE/pkg/usr/bin/kemi-standard-notes"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/standardnotes/app
Homepage: https://standardnotes.com
License: see "/opt/Standard Notes/LICENSE.electron.txt" and LICENSES.chromium.html
Official linux arm64 deb v${VER_UP} repackaged for KEMI as ${PKG}.
Dropped wrong-arch microtime prebuilds (linux-arm / linux-x64) and musl cbor-extract.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Standard Notes ${VER_UP} — official linux arm64, KEMI repack.

Installs under "/opt/Standard Notes/"; launcher /usr/bin/standard-notes (passes --no-sandbox).
Probe: aarch64 · requiredGlibc ≤2.25 after dropping wrong-arch natives (Ubuntu 20.04 / glibc 2.31 OK).
Fallthrough from Notesnook (better_sqlite3.node GLIBC_2.34).
合主线：gork.bot协助开发
EOT

if [[ -f "$STAGE/pkg/opt/Standard Notes/chrome-sandbox" ]]; then
  chmod 4755 "$STAGE/pkg/opt/Standard Notes/chrome-sandbox" || true
fi

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: office
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2, libgbm1
Recommends: libappindicator3-1
Conflicts: standard-notes
Replaces: standard-notes
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://standardnotes.com
Description: Standard Notes end-to-end encrypted notes (arm64)
 Standard Notes ${VER_UP} — E2E encrypted notes for digitalists.
 Official upstream arm64; glibc≤2.31 (Ubuntu 20.04) after wrong-arch drop.
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
if [ -f "/opt/Standard Notes/chrome-sandbox" ]; then
  chmod 4755 "/opt/Standard Notes/chrome-sandbox" || true
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
