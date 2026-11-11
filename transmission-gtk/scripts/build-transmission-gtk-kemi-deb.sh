#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) transmission-gtk
# 2.94-2ubuntu3 arm64 + transmission-common all as
# kemi-transmission-gtk (common bundled).
# Probe: aarch64 · requiredGlibc 2.29 (1 ELF) · no GLIBCXX ·
#   GLib/GIO/GObject + GTK3 + GDK3 + GDK-Pixbuf + Pango +
#   libappindicator3 + libevent-2.1 + libcurl + libcrypto 1.1 +
#   libminiupnpc + libnatpmp + zlib + libm + pthread + libc ·
#   PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.29,
#   libappindicator3-1 >= 0.4.90, libcurl4 >= 7.18.0,
#   libevent-2.1-7 >= 2.1.8-stable, libgdk-pixbuf2.0-0 >= 2.25.2,
#   libglib2.0-0 >= 2.37.3, libgtk-3-0 >= 3.3.16,
#   libminiupnpc17 >= 1.9.20140610, libnatpmp1 >= 20150609,
#   libpango-1.0-0 >= 1.14.0, libssl1.1 >= 1.1.0,
#   zlib1g >= 1:1.1.4). transmission-common (= 2.94-2ubuntu3)
#   is bundled (official arch:all, no runtime Depends).
# Official Recommends (xdg-utils) stay as Recommends and are
#   not bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal main arm64 Packages stanzas
#   (Aliyun ubuntu-ports mirror of the same index, streamed —
#   not saved as a Packages.gz dump). These packages live in
#   main (not universe). There is no newer hexchat-style
#   focal-updates binary; this is the current official focal
#   Release arm64 build. Launchpad HTML/API and
#   packages.ubuntu.com were retried this run but Launchpad
#   timed out and packages.ubuntu.com returned a site error,
#   so no librarian URL is recorded.
# Official desktop Icon=transmission (hicolor PNG + SVG and
#   pixmap shipped in transmission-common). Exec=transmission-gtk
#   %U; Pause/Minimize actions; TryExec=transmission-gtk.
# UI compiled-in as a GResource (.gresource.transmission).
# Locale path compiled in as /usr/share/locale (this official
#   deb ships no .mo; desktop has
#   X-Ubuntu-Gettext-Domain=transmission).
# Web assets from transmission-common stay at the compiled
#   /usr/share/transmission path. Desktop / man / icons /
#   pixmaps / mime stay on standard /usr/share and
#   /usr/lib/mime paths.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-transmission-gtk
VER_UP=2.94
VER_DEB="${VER_UP}-2ubuntu3kemi1"
ARCH=arm64
PKG=kemi-transmission-gtk
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/transmission-gtk-2.94-2ubuntu3-focal-unpack}"
UP_DEB="$DL/transmission-gtk_2.94-2ubuntu3_arm64.deb"
DATA_DEB="$DL/transmission-common_2.94-2ubuntu3_all.deb"
EXPECT_SHA=424a3cffc276ef11172279e105aa2366150b470a2276e6eb7699dd40df10f6c9
EXPECT_BYTES=297004
DATA_SHA=e7afb10bde483400384d4515393eefa652250e3500aba2ac514f1886c722651d
DATA_BYTES=236904
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$DATA_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$DATA_DEB")" = "$DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/transmission-gtk"
test -f "$UNPACK/usr/share/applications/transmission-gtk.desktop"
test -f "$UNPACK/usr/share/man/man1/transmission-gtk.1.gz"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/transmission.svg"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/transmission.png"
test -f "$UNPACK/usr/share/pixmaps/transmission.xpm"
test -f "$UNPACK/usr/share/transmission/web/index.html"
test -f "$UNPACK/usr/lib/mime/packages/transmission-gtk"
test ! -e "$UNPACK/usr/share/locale"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/lib/mime/packages" \
  "$STAGE/pkg/opt/transmission-gtk"

# Hardlink the binary so packing does not double disk use.
cp -al "$UNPACK/usr/bin/transmission-gtk" "$STAGE/pkg/opt/transmission-gtk/transmission-gtk"
chmod 0755 "$STAGE/pkg/opt/transmission-gtk/transmission-gtk"
test -x "$STAGE/pkg/opt/transmission-gtk/transmission-gtk"

# Probe the staged ELF before packing.
REPORT="$ROOT/probe/kemi-transmission-gtk.json"
rm -f "$REPORT"
python3 "$PROBE_PY" --elf "$STAGE/pkg/opt/transmission-gtk/transmission-gtk" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f=r["files"][0]
if f.get("requiredGlibc") != "2.29" or f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(f.get("neededLibraries") or [])
for lib in ("libglib-2.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libgtk-3.so.0", "libgdk-3.so.0", "libgdk_pixbuf-2.0.so.0",
            "libpango-1.0.so.0", "libappindicator3.so.1",
            "libevent-2.1.so.7", "libcurl.so.4", "libcrypto.so.1.1",
            "libminiupnpc.so.17", "libnatpmp.so.1", "libz.so.1",
            "libm.so.6", "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.29 no-GLIBCXX arch=aarch64 n_elf=1")
PY

# Icons, pixmaps and web assets stay on standard /usr/share paths.
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/pixmaps" "$STAGE/pkg/usr/share/pixmaps"
cp -a "$UNPACK/usr/share/transmission" "$STAGE/pkg/usr/share/transmission"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/transmission.svg"
test -f "$STAGE/pkg/usr/share/transmission/web/index.html"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/transmission-gtk.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/transmission-gtk.1.gz"
cp -a --remove-destination "$UNPACK/usr/lib/mime/packages/transmission-gtk" \
  "$STAGE/pkg/usr/lib/mime/packages/transmission-gtk"

# Upstream docs (gtk doc dir is an official symlink into common)
if [[ -f "$UNPACK/usr/share/doc/transmission-common/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/transmission-common/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/transmission-common/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/transmission-common/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/transmission-common/README" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/transmission-common/README" \
    "$STAGE/pkg/usr/share/doc/$PKG/README.upstream"
fi

# Desktop: keep upstream fields; point Exec/TryExec at the KEMI launcher path.
# Official Icon=transmission (hicolor PNG + SVG shipped). TryExec present.
sed -e 's|^Exec=transmission-gtk|Exec=/usr/bin/transmission-gtk|' \
    -e 's|^TryExec=transmission-gtk$|TryExec=/usr/bin/transmission-gtk|' \
  "$UNPACK/usr/share/applications/transmission-gtk.desktop" \
  > "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/transmission-gtk %U$/a TryExec=/usr/bin/transmission-gtk' \
    "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
fi
grep -q '^Exec=/usr/bin/transmission-gtk %U$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
grep -q '^Exec=/usr/bin/transmission-gtk --paused$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
grep -q '^Exec=/usr/bin/transmission-gtk --minimized$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
grep -q '^TryExec=/usr/bin/transmission-gtk$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
grep -q '^Icon=transmission$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"
if grep -E '^Exec=transmission-gtk( |$)' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"; then
  echo "LEFTOVER_RELATIVE_EXEC" >&2
  exit 1
fi
if grep -E '^TryExec=transmission-gtk$' "$STAGE/pkg/usr/share/applications/transmission-gtk.desktop"; then
  echo "LEFTOVER_RELATIVE_TRYEXEC" >&2
  exit 1
fi

ln -sf /opt/transmission-gtk/transmission-gtk "$STAGE/pkg/usr/bin/transmission-gtk"
ln -sf transmission-gtk "$STAGE/pkg/usr/bin/kemi-transmission-gtk"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://transmissionbt.com/
Source: https://launchpad.net/ubuntu/+source/transmission
Homepage: https://transmissionbt.com/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(transmission-gtk_2.94-2ubuntu3_arm64.deb) plus official
arch:all transmission-common_2.94-2ubuntu3_all.deb
repackaged for KEMI as ${PKG} (common bundled).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04
    transmission-gtk_2.94-2ubuntu3_arm64.deb (focal main)
    plus official transmission-common_2.94-2ubuntu3_all.deb
    repackaged for KEMI as ${PKG} (common bundled).
  * Layout /opt/transmission-gtk + /usr/bin/transmission-gtk;
    desktop, man, hicolor icons, pixmaps, mime and web assets
    stay on standard /usr/share and /usr/lib/mime paths.
    Official desktop Icon=transmission (hicolor PNG + SVG
    shipped in transmission-common). UI compiled-in as a
    GResource.
  * Official debs ship no locale .mo (compiled locale path is
    /usr/share/locale; desktop has
    X-Ubuntu-Gettext-Domain=transmission). Web UI assets from
    transmission-common stay at /usr/share/transmission.
  * Conflicts/Replaces transmission-gtk, transmission-common.
  * Depends kept for Ubuntu 20.04 (GTK3, GLib, GDK-Pixbuf,
    Pango, libappindicator3, libevent, libcurl, libssl1.1,
    libminiupnpc, libnatpmp, zlib, libc6 >= 2.29).
    Recommends: xdg-utils.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:45:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Transmission GTK ${VER_UP}-2ubuntu3 — official Ubuntu 20.04
(focal) arm64, KEMI repack (transmission-common bundled).

Installs under /opt/transmission-gtk/; launcher
/usr/bin/transmission-gtk (symlink into /opt/transmission-gtk).
Desktop, man, hicolor icons, pixmaps, mime and web assets
remain on standard /usr/share and /usr/lib/mime paths.
Official desktop Icon=transmission (hicolor PNG + SVG shipped).
UI is compiled-in as a GResource (.gresource.transmission).
This official deb ships no locale .mo (compiled locale path is
/usr/share/locale; desktop has X-Ubuntu-Gettext-Domain=transmission).
Web UI assets from transmission-common stay at
/usr/share/transmission.
Probe: aarch64 · requiredGlibc 2.29 (1 ELF) · no GLIBCXX ·
GTK3 + GDK3 + GLib/GIO/GObject + Pango + GDK-Pixbuf +
libappindicator3 + libevent + libcurl + OpenSSL crypto 1.1 +
libminiupnpc + libnatpmp; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.29), libappindicator3-1 (>= 0.4.90),
libcurl4 (>= 7.18.0), libevent-2.1-7 (>= 2.1.8-stable),
libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.37.3),
libgtk-3-0 (>= 3.3.16), libminiupnpc17 (>= 1.9.20140610),
libnatpmp1 (>= 20150609), libpango-1.0-0 (>= 1.14.0),
libssl1.1 (>= 1.1.0), zlib1g (>= 1:1.1.4).
Recommends: xdg-utils.
Official publication: Ubuntu 20.04 focal main arm64
transmission-gtk 2.94-2ubuntu3 (current official U20 package;
no newer focal-updates binary). Official SHA256 + size
matched ports.ubuntu.com pool files and focal main arm64
Packages stanzas.
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
Depends: libappindicator3-1 (>= 0.4.90), libc6 (>= 2.29), libcurl4 (>= 7.18.0), libevent-2.1-7 (>= 2.1.8-stable), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.3.16), libminiupnpc17 (>= 1.9.20140610), libnatpmp1 (>= 20150609), libpango-1.0-0 (>= 1.14.0), libssl1.1 (>= 1.1.0), zlib1g (>= 1:1.1.4)
Recommends: xdg-utils
Conflicts: transmission-gtk, transmission-common
Replaces: transmission-gtk, transmission-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://transmissionbt.com/
Description: lightweight BitTorrent client (GTK+ interface, arm64)
 Transmission ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight GTK3 BitTorrent client (transmission-common bundled).
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
if command -v update-mime >/dev/null 2>&1; then
  update-mime || true
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
if command -v update-mime >/dev/null 2>&1; then
  update-mime || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-transmission-gtk-control.txt"
