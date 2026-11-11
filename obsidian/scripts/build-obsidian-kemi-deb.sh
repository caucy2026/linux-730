#!/usr/bin/env bash
# Wrap official Obsidian 1.15.0 linux-arm64 tarball as kemi-obsidian.
# Drop: obsidian-cli (GLIBC_2.34) + wrong-arch x86_64 btime/get-fonts binding.node
#   (upstream already try/catches both requires).
# Probe after drop: aarch64 · requiredGlibc ≤2.25 · PASS vs 101 ≤2.31
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-keepassxc
VER_UP=1.15.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-obsidian
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/obsidian/obsidian-1.15.0-arm64}"
UP_TAR="$DL/obsidian-1.15.0-arm64.tar.gz"
EXPECT_SHA=7e1bdd82fc65dcc3c03de5b8a85a8d79258f94642ba27987c2d1188b9763e903
EXPECT_BYTES=131553006
mkdir -p "$DL" "$OUT"
test -f "$UP_TAR"
test "$(stat -c%s "$UP_TAR")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_TAR" | sha256sum -c -
test -x "$UNPACK/obsidian"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/Obsidian"

# Hardlink to avoid a second 275MiB copy on a tight disk.
cp -al "$UNPACK/." "$STAGE/pkg/opt/Obsidian/"

# Drop CLI (GLIBC_2.34) and wrong-arch natives (x86_64).
rm -f "$STAGE/pkg/opt/Obsidian/obsidian-cli"
rm -f "$STAGE/pkg/opt/Obsidian/resources/app.asar.unpacked/node_modules/btime/binding.node"
rm -f "$STAGE/pkg/opt/Obsidian/resources/app.asar.unpacked/node_modules/get-fonts/binding.node"
# Break hardlink on files we will chmod so we do not mutate the source tree.
if [[ -f "$STAGE/pkg/opt/Obsidian/chrome-sandbox" ]]; then
  cp -a --remove-destination "$STAGE/pkg/opt/Obsidian/chrome-sandbox" "$STAGE/pkg/opt/Obsidian/chrome-sandbox.tmp"
  mv "$STAGE/pkg/opt/Obsidian/chrome-sandbox.tmp" "$STAGE/pkg/opt/Obsidian/chrome-sandbox"
  chmod 4755 "$STAGE/pkg/opt/Obsidian/chrome-sandbox" || true
fi

test -x "$STAGE/pkg/opt/Obsidian/obsidian"
test ! -e "$STAGE/pkg/opt/Obsidian/obsidian-cli"
test ! -e "$STAGE/pkg/opt/Obsidian/resources/app.asar.unpacked/node_modules/btime/binding.node"
test ! -e "$STAGE/pkg/opt/Obsidian/resources/app.asar.unpacked/node_modules/get-fonts/binding.node"

# Probe all remaining ELFs before packing.
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root=Path("$STAGE/pkg/opt/Obsidian")
for p in sorted(root.rglob("*")):
    if p.is_file() and not p.is_symlink():
        with p.open("rb") as f:
            if f.read(4)==b"\x7fELF":
                print(p)
PY
)
echo "probe_elf_count=${#ELFS[@]}"
test "${#ELFS[@]}" -ge 8
ARGS=()
for e in "${ELFS[@]}"; do ARGS+=(--elf "$e"); done
REPORT="$ROOT/probe/kemi-obsidian.json"
rm -f "$REPORT"
python3 "$PROBE_PY" "${ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
# exit 0 means configuredLimitsSatisfied

if [[ -f "$STAGE/pkg/opt/Obsidian/resources/icon.png" ]]; then
  cp -a "$STAGE/pkg/opt/Obsidian/resources/icon.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps/obsidian.png"
  cp -a "$STAGE/pkg/opt/Obsidian/resources/icon.png" \
    "$STAGE/pkg/usr/share/pixmaps/obsidian.png"
fi

cat > "$STAGE/pkg/usr/share/applications/md.obsidian.Obsidian.desktop" << 'EOT'
[Desktop Entry]
Name=Obsidian
Comment=A second brain, for you, forever
Exec=/usr/bin/obsidian %U
Terminal=false
Type=Application
Icon=obsidian
StartupWMClass=obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
EOT

cat > "$STAGE/pkg/usr/bin/obsidian" << 'EOT'
#!/bin/sh
# Electron root often needs --no-sandbox on locked-down devices
exec /opt/Obsidian/obsidian --no-sandbox "$@"
EOT
chmod 0755 "$STAGE/pkg/usr/bin/obsidian"
ln -sf obsidian "$STAGE/pkg/usr/bin/kemi-obsidian"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://obsidian.md
Homepage: https://obsidian.md
License: see /opt/Obsidian/LICENSE.electron.txt and LICENSES.chromium.html
Official linux arm64 tarball v${VER_UP} repackaged for KEMI as ${PKG}.
Dropped obsidian-cli (GLIBC_2.34) and wrong-arch x86_64 btime/get-fonts natives
(upstream already try/catches both requires).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Obsidian ${VER_UP} — official linux arm64 tarball, KEMI repack.

Installs under /opt/Obsidian/; launcher /usr/bin/obsidian (passes --no-sandbox).
Dropped obsidian-cli (GLIBC_2.34) and wrong-arch x86_64 btime/get-fonts binding.node
(upstream try/catch: btime no-ops on Linux; get-fonts font list degrades).
Probe: aarch64 · requiredGlibc ≤2.25 after drops (Ubuntu 20.04 / glibc 2.31 OK).
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: text
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0, libasound2, libgbm1
Recommends: libappindicator3-1
Conflicts: obsidian
Replaces: obsidian
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://obsidian.md
Description: Obsidian knowledge base (arm64)
 Obsidian ${VER_UP} — local-first Markdown knowledge base.
 Official upstream arm64 tarball; glibc≤2.31 (Ubuntu 20.04) after dropping
 obsidian-cli (GLIBC_2.34) and wrong-arch natives.
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
if [ -f /opt/Obsidian/chrome-sandbox ]; then
  chmod 4755 /opt/Obsidian/chrome-sandbox || true
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
