#!/usr/bin/env bash
# Wrap official Zed 1.27.0 linux aarch64 tarball as kemi-zed.
# Official docs claim aarch64 glibc >= 2.35; probe of this artifact is
# requiredGlibc 2.30 (11 ELFs, all aarch64) — PASS vs 101 ≤2.31.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-zed
VER_UP=1.27.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-zed
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/zed/zed.app}"
UP_TAR="$DL/zed-linux-aarch64.tar.gz"
EXPECT_SHA=9e4f8b182f41d4cd434cbbc6d1562329a33ef048d65a39bae0665465d0a638bb
EXPECT_BYTES=85696089
mkdir -p "$DL" "$OUT"
test -f "$UP_TAR"
test "$(stat -c%s "$UP_TAR")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_TAR" | sha256sum -c -
test -x "$UNPACK/bin/zed"
test -x "$UNPACK/libexec/zed-editor"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/1024x1024/apps" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/zed.app"

# Hardlink to avoid a second ~189MiB copy on a tight disk.
cp -al "$UNPACK/." "$STAGE/pkg/opt/zed.app/"

test -x "$STAGE/pkg/opt/zed.app/bin/zed"
test -x "$STAGE/pkg/opt/zed.app/libexec/zed-editor"
test -d "$STAGE/pkg/opt/zed.app/lib"

# Probe all staged ELFs before packing.
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root=Path("$STAGE/pkg/opt/zed.app")
for p in sorted(root.rglob("*")):
    if p.is_file() and not p.is_symlink():
        with p.open("rb") as f:
            if f.read(4)==b"\x7fELF":
                print(p)
PY
)
echo "probe_elf_count=${#ELFS[@]}"
test "${#ELFS[@]}" -eq 11
ARGS=()
for e in "${ELFS[@]}"; do ARGS+=(--elf "$e"); done
REPORT="$ROOT/probe/kemi-zed.json"
rm -f "$REPORT"
python3 "$PROBE_PY" "${ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
# exit 0 means configuredLimitsSatisfied

# Icons (break hardlink when installing into share so we do not mutate source)
if [[ -f "$STAGE/pkg/opt/zed.app/share/icons/hicolor/512x512/apps/zed.png" ]]; then
  cp -a --remove-destination "$STAGE/pkg/opt/zed.app/share/icons/hicolor/512x512/apps/zed.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/512x512/apps/zed.png"
  cp -a --remove-destination "$STAGE/pkg/opt/zed.app/share/icons/hicolor/512x512/apps/zed.png" \
    "$STAGE/pkg/usr/share/pixmaps/zed.png"
fi
if [[ -f "$STAGE/pkg/opt/zed.app/share/icons/hicolor/1024x1024/apps/zed.png" ]]; then
  cp -a --remove-destination "$STAGE/pkg/opt/zed.app/share/icons/hicolor/1024x1024/apps/zed.png" \
    "$STAGE/pkg/usr/share/icons/hicolor/1024x1024/apps/zed.png"
fi

# Desktop: absolute Exec/TryExec; keep Actions
cat > "$STAGE/pkg/usr/share/applications/dev.zed.Zed.desktop" << 'EOT'
[Desktop Entry]
Version=1.0
Type=Application
Name=Zed
GenericName=Text Editor
Comment=A high-performance, multiplayer code editor.
TryExec=/usr/bin/zed
StartupNotify=true
Exec=/usr/bin/zed %U
Icon=zed
Categories=Utility;TextEditor;Development;IDE;
Keywords=zed;
MimeType=text/plain;application/x-zerosize;x-scheme-handler/zed;
Actions=NewWorkspace;
StartupWMClass=dev.zed.Zed

[Desktop Action NewWorkspace]
Exec=/usr/bin/zed --new %U
Name=Open a new workspace
EOT

# Symlink: bin/zed resolves ../libexec/zed-editor and $ORIGIN/../lib from its real path.
ln -sf /opt/zed.app/bin/zed "$STAGE/pkg/usr/bin/zed"
ln -sf zed "$STAGE/pkg/usr/bin/kemi-zed"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://zed.dev
Homepage: https://zed.dev
License: see /opt/zed.app/licenses.md and https://github.com/zed-industries/zed
Official linux aarch64 tarball v${VER_UP} (zed-linux-aarch64.tar.gz) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Zed ${VER_UP} — official linux aarch64 tarball, KEMI repack.

Installs under /opt/zed.app/; launcher /usr/bin/zed (symlink to /opt/zed.app/bin/zed).
The CLI finds ../libexec/zed-editor and uses RPATH \$ORIGIN/../lib.
Probe: aarch64 · requiredGlibc 2.30 (11 ELFs). Official Linux docs mention
aarch64 glibc >= 2.35, but this 1.27.0 artifact's version-needs are 2.30
(Ubuntu 20.04 / glibc 2.31 OK). Runtime also wants Vulkan/Mesa.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: editors
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6, libgcc-s1 | libgcc1, libglib2.0-0, libasound2
Recommends: libvulkan1, mesa-vulkan-drivers
Conflicts: zed, zed-editor
Replaces: zed, zed-editor
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://zed.dev
Description: Zed high-performance code editor (arm64)
 Zed ${VER_UP} — official upstream linux aarch64 tarball, KEMI repack.
 Probe requiredGlibc 2.30 (11 ELFs), suitable for Ubuntu 20.04 / glibc 2.31.
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
