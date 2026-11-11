#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) hexchat
# 2.14.3-3ubuntu0.20.04.2 arm64 + hexchat-common all as kemi-hexchat
# (common bundled).
# Probe: aarch64 · requiredGlibc 2.28 (1 ELF) · no GLIBCXX ·
#   GLib/GIO/GObject/GModule + GTK2 + GDK2 + GDK-Pixbuf + Pango +
#   X11 + libnotify + OpenSSL 1.1 / libcrypto + libproxy +
#   libcanberra + libdbus-glib + pthread + libc · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.28,
#   libcanberra0 >= 0.2, libdbus-glib-1-2 >= 0.88,
#   libgdk-pixbuf2.0-0 >= 2.25.2, libglib2.0-0 >= 2.51.0,
#   libgtk2.0-0 >= 2.24.0, libnotify4 >= 0.7.0,
#   libpango-1.0-0 >= 1.44.3, libproxy1v5 >= 0.4.14,
#   libssl1.1 >= 1.1.0, libx11-6). hexchat-common
#   (= 2.14.3-3ubuntu0.20.04.2) is bundled (official arch:all,
#   no runtime Depends). Official Recommends (hexchat-perl,
#   hexchat-plugins, hexchat-python3, libglib2.0-bin) stay as
#   Recommends and are not bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror of the same
#   index, streamed — not saved as a Packages.gz dump).
#   Launchpad getPublishedBinaries / getPublishedSources and
#   packages.ubuntu.com HTML were retried this run but binaries
#   API timed out and packages.ubuntu.com returned a site error,
#   so no librarian URL is recorded.
# The focal Release pocket still has 2.14.3-3 (pango Depends
#   >= 1.29.4); this package is the current official
#   focal-updates arm64 build (LP: #1920974 font-height with
#   Pango >= 1.44; also carries 20.04.1 Libera.Chat default
#   server, LP: #1933681).
# Official desktop Icon=hexchat (hicolor PNG + SVG shipped in
#   hexchat-common). Exec=hexchat --existing %U; SafeMode
#   Exec=hexchat --no-auto --no-plugins (no TryExec upstream).
# UI compiled-in as a GResource (.gresource.hexchat).
# Locale path compiled in as /usr/share/locale (53 locales
#   including zh_CN / zh_TW shipped in hexchat-common).
# Plugin search path compiled in as
#   /usr/lib/aarch64-linux-gnu/hexchat/plugins (optional
#   plugin packages not bundled).
# Desktop / man / icons / metainfo / locales / D-Bus service
#   stay on standard /usr/share paths. Official D-Bus service
#   already Exec=/usr/bin/hexchat.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-hexchat
VER_UP=2.14.3
VER_DEB="${VER_UP}-3ubuntu0.20.04.2kemi1"
ARCH=arm64
PKG=kemi-hexchat
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/hexchat-2.14.3-3ubuntu0.20.04.2-focal-unpack}"
UP_DEB="$DL/hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb"
DATA_DEB="$DL/hexchat-common_2.14.3-3ubuntu0.20.04.2_all.deb"
EXPECT_SHA=f4ffa3993e584bf3da3de14f9999309043bcc6a4759e89a57e6c97ae25268c2e
EXPECT_BYTES=297544
DATA_SHA=563b4b5225b5c54128a1c2cb060b4daddd1cf08fb021dfa704332af2d04d48de
DATA_BYTES=748712
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$DATA_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$DATA_DEB")" = "$DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/hexchat"
test -f "$UNPACK/usr/share/applications/io.github.Hexchat.desktop"
test -f "$UNPACK/usr/share/man/man1/hexchat.1.gz"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/hexchat.svg"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/hexchat.png"
test -f "$UNPACK/usr/share/metainfo/io.github.Hexchat.appdata.xml"
test -f "$UNPACK/usr/share/dbus-1/services/org.hexchat.service.service"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/hexchat.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/hexchat.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'hexchat.mo' | wc -l)" = 53
grep -q '^Exec=/usr/bin/hexchat$' "$UNPACK/usr/share/dbus-1/services/org.hexchat.service.service"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/opt/hexchat"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/hexchat" "$STAGE/pkg/opt/hexchat/hexchat"
chmod 0755 "$STAGE/pkg/opt/hexchat/hexchat"
test -x "$STAGE/pkg/opt/hexchat/hexchat"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-hexchat.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/hexchat/hexchat" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f=r["files"][0]
if f.get("requiredGlibc") != "2.28" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libglib-2.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libgmodule-2.0.so.0", "libgtk-x11-2.0.so.0", "libgdk-x11-2.0.so.0",
            "libgdk_pixbuf-2.0.so.0", "libpango-1.0.so.0", "libX11.so.6",
            "libnotify.so.4", "libssl.so.1.1", "libcrypto.so.1.1",
            "libproxy.so.1", "libcanberra.so.0", "libdbus-glib-1.so.2",
            "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.28 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Locales / icons stay on standard /usr/share paths.
cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/hexchat.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'hexchat.mo' | wc -l)" = 53

cp -a --remove-destination "$UNPACK/usr/share/man/man1/hexchat.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/hexchat.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/io.github.Hexchat.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/io.github.Hexchat.appdata.xml"
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/org.hexchat.service.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.hexchat.service.service"
grep -q '^Exec=/usr/bin/hexchat$' "$STAGE/pkg/usr/share/dbus-1/services/org.hexchat.service.service"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/hexchat/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hexchat/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/hexchat/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hexchat/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/hexchat-common/plugins.txt.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hexchat-common/plugins.txt.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/plugins.txt.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/hexchat-common/readme.md" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/hexchat-common/readme.md" \
    "$STAGE/pkg/usr/share/doc/$PKG/readme.upstream.md"
fi

# Desktop: keep upstream fields; point Exec/TryExec at the KEMI launcher path.
# Official Icon=hexchat (hicolor PNG + SVG shipped). No TryExec upstream.
# Two Exec lines: main and SafeMode action.
sed -e 's|^Exec=hexchat |Exec=/usr/bin/hexchat |' \
    -e 's|^Exec=hexchat$|Exec=/usr/bin/hexchat|' \
    -e 's|^TryExec=hexchat$|TryExec=/usr/bin/hexchat|' \
  "$UNPACK/usr/share/applications/io.github.Hexchat.desktop" \
  > "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/hexchat --existing %U$/a TryExec=/usr/bin/hexchat' \
    "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
fi
grep -q '^Exec=/usr/bin/hexchat --existing %U$' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
grep -q '^Exec=/usr/bin/hexchat --no-auto --no-plugins$' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
grep -q '^TryExec=/usr/bin/hexchat$' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
grep -q '^Icon=hexchat$' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"
# no leftover relative Exec
if grep -E '^Exec=hexchat( |$)' "$STAGE/pkg/usr/share/applications/io.github.Hexchat.desktop"; then
  raise_fail=1
  echo "LEFTOVER_RELATIVE_EXEC" >&2
  exit 1
fi

ln -sf /opt/hexchat/hexchat "$STAGE/pkg/usr/bin/hexchat"
ln -sf hexchat "$STAGE/pkg/usr/bin/kemi-hexchat"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://hexchat.github.io
Source: https://launchpad.net/ubuntu/+source/hexchat
Homepage: https://hexchat.github.io
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb) plus official
arch:all hexchat-common_2.14.3-3ubuntu0.20.04.2_all.deb
repackaged for KEMI as ${PKG} (common bundled).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04
    hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb (focal-updates)
    plus official hexchat-common_2.14.3-3ubuntu0.20.04.2_all.deb
    repackaged for KEMI as ${PKG} (common bundled).
  * Layout /opt/hexchat + /usr/bin/hexchat; desktop, man,
    hicolor icons, metainfo, locales and D-Bus service stay on
    standard /usr/share paths. Official desktop Icon=hexchat
    (hicolor PNG + SVG shipped in hexchat-common). UI
    compiled-in as a GResource.
  * 53 locales including zh_CN / zh_TW are bundled from
    hexchat-common. Official plugin packages remain Recommends
    (not bundled). Official D-Bus service already
    Exec=/usr/bin/hexchat.
  * Conflicts/Replaces hexchat, hexchat-common.
  * Depends kept for Ubuntu 20.04 (GTK2, GLib, GDK-Pixbuf,
    Pango, libnotify, libssl1.1, libproxy, libcanberra,
    libdbus-glib, libx11, libc6 >= 2.28).
    Recommends: hexchat-perl, hexchat-plugins, hexchat-python3,
    libglib2.0-bin.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:36:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
HexChat ${VER_UP}-3ubuntu0.20.04.2 — official Ubuntu 20.04
(focal-updates) arm64, KEMI repack (hexchat-common bundled).

Installs under /opt/hexchat/; launcher /usr/bin/hexchat
(symlink into /opt/hexchat).
Desktop, man, hicolor icons, metainfo, locales and the D-Bus
service remain on standard /usr/share paths.
Official desktop Icon=hexchat (hicolor PNG + SVG shipped).
UI is compiled-in as a GResource (.gresource.hexchat).
53 locales including zh_CN / zh_TW are bundled (compiled locale
path is /usr/share/locale).
Plugin search path is /usr/lib/aarch64-linux-gnu/hexchat/plugins;
optional official plugin packages are Recommends, not bundled.
Probe: aarch64 · requiredGlibc 2.28 (1 ELF) · no GLIBCXX ·
GTK2 + GDK2 + GLib/GIO/GObject/GModule + Pango + GDK-Pixbuf +
X11 + libnotify + OpenSSL 1.1 + libproxy + libcanberra +
libdbus-glib; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.28), libcanberra0 (>= 0.2),
libdbus-glib-1-2 (>= 0.88), libgdk-pixbuf2.0-0 (>= 2.25.2),
libglib2.0-0 (>= 2.51.0), libgtk2.0-0 (>= 2.24.0),
libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.44.3),
libproxy1v5 (>= 0.4.14), libssl1.1 (>= 1.1.0), libx11-6.
Recommends: hexchat-perl, hexchat-plugins, hexchat-python3,
libglib2.0-bin.
Official publication: Ubuntu 20.04 focal-updates universe arm64
hexchat 2.14.3-3ubuntu0.20.04.2 (current official U20 package;
Release pocket still has 2.14.3-3). Official SHA256 + size
matched ports.ubuntu.com pool files and focal-updates universe
arm64 Packages stanzas.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.28), libcanberra0 (>= 0.2), libdbus-glib-1-2 (>= 0.88), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.51.0), libgtk2.0-0 (>= 2.24.0), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.44.3), libproxy1v5 (>= 0.4.14), libssl1.1 (>= 1.1.0), libx11-6
Recommends: hexchat-perl, hexchat-plugins, hexchat-python3, libglib2.0-bin
Conflicts: hexchat, hexchat-common
Replaces: hexchat, hexchat-common
Provides: irc
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://hexchat.github.io
Description: IRC client for X based on X-Chat 2 (arm64)
 HexChat ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK2 IRC client (hexchat-common bundled).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-hexchat-control.txt"
