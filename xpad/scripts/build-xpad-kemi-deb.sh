#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xpad 5.4.0-1 arm64 deb as kemi-xpad.
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   libSM + libICE + GTK3 + GDK3 + Pango + GIO + GObject + GLib +
#   GtkSourceView 3 + libpthread + libc · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libglib2.0-0 >= 2.56, libgtk-3-0 >= 3.22,
#   libgtksourceview-3.0-1 >= 3.22, libice6 >= 1:1.0.0,
#   libpango-1.0-0 >= 1.14.0, libsm6).
# Launchpad: xpad 5.4.0-1 in focal arm64, universe/Release,
#   Focal release on 2019-10-18 (source publishing history).
# arm64 binary was built in ubuntu eoan PROPOSED (build 17381069,
#   Successfully built 2019-08-07 13:15:10 Asia/Shanghai on
#   bos02-arm64-042; duration 3m49.9s) and published to focal
#   Release (Launchpad HTML: "arm64 build of xpad 5.4.0-1 in
#   ubuntu eoan PROPOSED").
# Layout keeps the official ELF at /usr/bin/xpad because the
# binary embeds binreloc (br_extract_prefix, %s/share/applications)
# plus compiled-in prefixes /usr/share/xpad/help,
# /usr/share/locale and /usr/share/icons. Help, locales, hicolor
# icon, desktop, man and metainfo stay on those standard paths.
# /opt/xpad/xpad is a symlink to /usr/bin/xpad (KEMI layout marker),
# not the real ELF.
# Official desktop Exec=xpad / TryExec=xpad / Icon=xpad
# (hicolor scalable svg shipped). KEMI desktop uses
# Exec=/usr/bin/xpad and TryExec=/usr/bin/xpad; Icon stays xpad.
# Official locales include zh_CN and zh_TW.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xpad
VER_UP='5.4.0'
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xpad
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xpad-5.4.0-1-focal-unpack}"
UP_DEB="$DL/xpad_5.4.0-1_arm64.deb"
EXPECT_SHA=8e6c27741b886779a110b9489f3064dcc61d09a84d7bc5f3642f75ece161f181
EXPECT_BYTES=88092
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xpad"
test -f "$UNPACK/usr/share/applications/xpad.desktop"
test -f "$UNPACK/usr/share/man/man1/xpad.1.gz"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/xpad.svg"
test -f "$UNPACK/usr/share/xpad/help/xpad-user-help.txt"
test -f "$UNPACK/usr/share/metainfo/xpad.appdata.xml"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/xpad.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/xpad.mo"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/xpad"

# Official ELF stays at /usr/bin/xpad (binreloc + compiled /usr prefixes).
# Hardlink so packing does not double disk use.
cp -al "$UNPACK/usr/bin/xpad" "$STAGE/pkg/usr/bin/xpad"
chmod 0755 "$STAGE/pkg/usr/bin/xpad"
test -x "$STAGE/pkg/usr/bin/xpad"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-xpad.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/usr/bin/xpad" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files=r.get("files") or []
if len(files) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
main=files[0]
if main.get("requiredGlibc") != "2.17" or main.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_MAIN")
if main.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(main.get("neededLibraries") or [])
for lib in ("libSM.so.6", "libICE.so.6", "libgtk-3.so.0", "libgdk-3.so.0",
            "libpango-1.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0", "libgtksourceview-3.0.so.1", "libpthread.so.0",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Help / icons / locales / metainfo stay on compiled-in /usr/share paths.
mkdir -p "$STAGE/pkg/usr/share/xpad"
cp -a "$UNPACK/usr/share/xpad/help" "$STAGE/pkg/usr/share/xpad/help"
test -f "$STAGE/pkg/usr/share/xpad/help/xpad-user-help.txt"

mkdir -p "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps"
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/xpad.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/xpad.svg"

mkdir -p "$STAGE/pkg/usr/share/metainfo"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/xpad.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/xpad.appdata.xml"

# Official locales (including zh_CN / zh_TW).
n_mo=0
while IFS= read -r -d '' mo; do
  rel="${mo#"$UNPACK/usr/share/locale/"}"
  mkdir -p "$STAGE/pkg/usr/share/locale/$(dirname "$rel")"
  cp -a --remove-destination "$mo" "$STAGE/pkg/usr/share/locale/$rel"
  n_mo=$((n_mo+1))
done < <(find "$UNPACK/usr/share/locale" -name 'xpad.mo' -print0)
test "$n_mo" -ge 28
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/xpad.mo"
test -f "$STAGE/pkg/usr/share/locale/zh_TW/LC_MESSAGES/xpad.mo"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/xpad.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/xpad.1.gz"

# Official desktop Exec=xpad / TryExec=xpad / Icon=xpad (svg shipped).
# Rewrite Exec/TryExec to absolute /usr/bin/xpad; keep Icon=xpad.
sed -e 's|^Exec=xpad$|Exec=/usr/bin/xpad|' \
    -e 's|^TryExec=xpad$|TryExec=/usr/bin/xpad|' \
    "$UNPACK/usr/share/applications/xpad.desktop" \
    > "$STAGE/pkg/usr/share/applications/xpad.desktop"
grep -q '^Exec=/usr/bin/xpad$' "$STAGE/pkg/usr/share/applications/xpad.desktop"
grep -q '^TryExec=/usr/bin/xpad$' "$STAGE/pkg/usr/share/applications/xpad.desktop"
grep -q '^Icon=xpad$' "$STAGE/pkg/usr/share/applications/xpad.desktop"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/xpad/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/xpad/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/xpad/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/xpad/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/xpad/README" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/xpad/README" \
    "$STAGE/pkg/usr/share/doc/$PKG/README.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/xpad/xpad-user-help.txt" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/xpad/xpad-user-help.txt" \
    "$STAGE/pkg/usr/share/doc/$PKG/xpad-user-help.txt"
fi

ln -sf /usr/bin/xpad "$STAGE/pkg/opt/xpad/xpad"
ln -sf xpad "$STAGE/pkg/usr/bin/kemi-xpad"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://launchpad.net/xpad
Source: https://launchpad.net/ubuntu/+source/xpad
Homepage: https://launchpad.net/xpad
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-1 (xpad_5.4.0-1_arm64.deb)
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xpad_5.4.0-1_arm64.deb repackaged for KEMI
    as ${PKG}.
  * Official ELF stays at /usr/bin/xpad because the binary embeds
    binreloc (br_extract_prefix) plus compiled-in prefixes
    /usr/share/xpad/help, /usr/share/locale and /usr/share/icons.
    Help, locales, hicolor icon, desktop, man and metainfo stay on
    those standard paths. /opt/xpad/xpad is a symlink to
    /usr/bin/xpad.
  * Desktop Exec=/usr/bin/xpad; TryExec=/usr/bin/xpad; Icon=xpad
    (hicolor scalable svg shipped). Official locales include zh_CN
    and zh_TW.
  * Conflicts/Replaces xpad.
  * Depends kept for Ubuntu 20.04 (GTK3, GtkSourceView 3, GLib,
    Pango, libSM, libICE, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:05:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xpad ${VER_UP}-1 — official Ubuntu 20.04 (focal) arm64, KEMI repack.

The official ELF stays at /usr/bin/xpad (binreloc uses br_extract_prefix;
compiled prefixes are /usr/share/xpad/help, /usr/share/locale and
/usr/share/icons).
/opt/xpad/xpad is a symlink to /usr/bin/xpad.
Help, locales, hicolor icon, desktop, man and metainfo remain on
standard /usr/share paths.
Official desktop Icon=xpad (hicolor scalable svg shipped).
Official locales include zh_CN and zh_TW.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + GtkSourceView 3 + GLib + Pango + libSM + libICE;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.17), libglib2.0-0 (>= 2.56),
libgtk-3-0 (>= 3.22), libgtksourceview-3.0-1 (>= 3.22),
libice6 (>= 1:1.0.0), libpango-1.0-0 (>= 1.14.0), libsm6.
Official Launchpad publication: xpad 5.4.0-1 in focal arm64
(universe, Release, Focal release on 2019-10-18). The arm64
binary was built in ubuntu eoan PROPOSED (build 17381069,
Successfully built 2019-08-07 13:15:10 Asia/Shanghai) and
published to focal Release.
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
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.56), libgtk-3-0 (>= 3.22), libgtksourceview-3.0-1 (>= 3.22), libice6 (>= 1:1.0.0), libpango-1.0-0 (>= 1.14.0), libsm6
Conflicts: xpad
Replaces: xpad
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://launchpad.net/xpad
Description: Sticky note application for X (arm64)
 Xpad ${VER_UP}-1 — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 sticky-note / post-it app.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
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
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xpad-control.txt"
