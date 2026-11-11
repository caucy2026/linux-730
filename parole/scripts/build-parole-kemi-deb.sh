#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) parole 1.0.5-1 arm64 as
# kemi-parole. No common/data package. Same-source parole-dev
# is not a hard Depends and is not bundled.
# Official plugins (mpris2, tray-icon, notify) ship inside the
#   official parole deb and stay at
#   /usr/lib/aarch64-linux-gnu/parole-0/.
# Probe: aarch64 · 4 ELF (parole + 3 plugin .so) ·
#   requiredGlibc 2.17 · no GLIBCXX · PASS vs 101 ≤2.31
#   GTK3 + GDK3 + GStreamer + libxfce4ui-2 + libxfce4util +
#   libxfconf + cairo + dbus + libnotify + taglib-c + X11 +
#   GDK-Pixbuf + GIO/GObject/GLib + pthread + libc
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libgtk-3-0, gstreamer1.0-{alsa|audiosink,libav,plugins-base,
#   plugins-good,x}, libgstreamer1.0-0,
#   libgstreamer-plugins-base1.0-0, libxfce4ui-2-0,
#   libxfce4util7, libxfconf-0-3, libcairo2, libdbus-1-3,
#   libdbus-glib-1-2, libnotify4, libtagc0, libx11-6,
#   libgdk-pixbuf2.0-0, libglib2.0-0).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). No newer focal-updates binary. No librarian URL
#   is recorded this run.
# Official ELFs embed compiled /usr prefixes
#   (/usr/share/locale, /usr/share/parole/pixmaps,
#   /usr/share/parole/parole-plugins-0,
#   /usr/lib/aarch64-linux-gnu/parole-0,
#   /usr/share/applications/org.xfce.Parole.desktop). Layout
#   therefore keeps the official ELF at /usr/bin/parole and
#   /opt/parole/parole is a symlink (HardInfo/Xpad/qpdfview/
#   Pluma/Gedit/XFCE Notes/Xfburn). Data, locales, icons,
#   desktop, man and metainfo stay on standard paths.
# Official desktop Icon=parole (icons shipped). 50 locales
#   including zh_CN / zh_TW. Reuse existing unpacked tree; do
#   not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-parole
VER_UP=1.0.5
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-parole
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/parole-1.0.5-1-focal-unpack}"
UP_DEB="$DL/parole_1.0.5-1_arm64.deb"
EXPECT_SHA=8a752b8218de210ea9dd14e542b439136f20ea320ffdf3a21a4d3d763edb4efe
EXPECT_BYTES=355100
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/parole"
test -f "$UNPACK/usr/share/applications/org.xfce.Parole.desktop"
test -f "$UNPACK/usr/share/parole/pixmaps/no-cover.png"
test -f "$UNPACK/usr/share/parole/parole-plugins-0/mpris2.desktop"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/parole-0/parole-mpris2.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/parole-0/tray-icon.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/parole-0/parole-notify.so"
test -f "$UNPACK/usr/share/man/man1/parole.1.gz"
test -f "$UNPACK/usr/share/metainfo/parole.appdata.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/parole.svg"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/parole.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/parole.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'parole.mo' | wc -l)" = 50
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/parole")
grep -qx '/usr/share/parole/pixmaps' < <(strings -n 8 "$UNPACK/usr/bin/parole")
grep -qx '/usr/lib/aarch64-linux-gnu/parole-0' < <(strings -n 8 "$UNPACK/usr/bin/parole")
grep -qx '/usr/share/parole/parole-plugins-0' < <(strings -n 8 "$UNPACK/usr/bin/parole")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/parole"

cp -al "$UNPACK/usr/bin/parole" "$STAGE/pkg/usr/bin/parole"
chmod 0755 "$STAGE/pkg/usr/bin/parole"
mkdir -p "$STAGE/pkg/usr/lib/aarch64-linux-gnu"
cp -a "$UNPACK/usr/lib/aarch64-linux-gnu/parole-0" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/parole-0"

REPORT="$ROOT/probe/kemi-parole.json"
rm -f "$REPORT"
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PY
)
test "${#ELFS[@]}" = 4
PROBE_ARGS=()
for e in "${ELFS[@]}"; do PROBE_ARGS+=(--elf "$e"); done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 4:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
for name in ("parole", "parole-mpris2.so", "tray-icon.so", "parole-notify.so"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["parole"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libgstreamer-1.0.so.0",
            "libgstvideo-1.0.so.0", "libgstaudio-1.0.so.0",
            "libgstpbutils-1.0.so.0", "libgsttag-1.0.so.0",
            "libxfce4ui-2.so.0", "libxfce4util.so.7", "libxfconf-0.so.3",
            "libcairo.so.2", "libdbus-1.so.3", "libdbus-glib-1.so.2",
            "libtag_c.so.0", "libX11.so.6", "libgdk_pixbuf-2.0.so.0",
            "libgio-2.0.so.0", "libgobject-2.0.so.0", "libglib-2.0.so.0",
            "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
notify_needed = set(by["parole-notify.so"].get("neededLibraries") or [])
if "libnotify.so.4" not in notify_needed:
    raise SystemExit("PROBE_MISSING_libnotify")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=4")
PY

cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/parole" "$STAGE/pkg/usr/share/parole"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/parole.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/parole.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/parole.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/parole.appdata.xml"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/parole.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'parole.mo' | wc -l)" = 50
test -f "$STAGE/pkg/usr/share/parole/pixmaps/no-cover.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/parole.svg"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/parole-0/parole-mpris2.so"

if [[ -f "$UNPACK/usr/share/doc/parole/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/parole/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/parole/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/parole/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/org.xfce.Parole.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.xfce.Parole.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=parole\b", "Exec=/usr/bin/parole", text, flags=re.M)
text2 = re.sub(r"^TryExec=parole$", "TryExec=/usr/bin/parole", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/parole(?:\s.*)?)$", r"\1\nTryExec=/usr/bin/parole", text2, count=1, flags=re.M)
if re.search(r"^Exec=parole(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if text2.count("Exec=/usr/bin/parole") < 4:
    raise SystemExit(f"MISSING_EXEC count={text2.count('Exec=/usr/bin/parole')}")
if "TryExec=/usr/bin/parole" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=parole$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
for needle in ("Exec=/usr/bin/parole %F", "Exec=/usr/bin/parole --play",
               "Exec=/usr/bin/parole --previous", "Exec=/usr/bin/parole --next"):
    if needle not in text2:
        raise SystemExit(f"MISSING_{needle}")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/parole "$STAGE/pkg/opt/parole/parole"
ln -sf parole "$STAGE/pkg/usr/bin/kemi-parole"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://goodies.xfce.org/projects/applications/parole
Source: https://launchpad.net/ubuntu/+source/parole
Homepage: https://goodies.xfce.org/projects/applications/parole
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(parole_1.0.5-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 parole_1.0.5-1_arm64.deb (focal
    universe) repackaged for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/parole because it embeds
    compiled /usr prefixes (/usr/share/locale,
    /usr/share/parole/pixmaps, /usr/share/parole/parole-plugins-0,
    /usr/lib/aarch64-linux-gnu/parole-0). /opt/parole/parole is a
    symlink. Official plugins stay at the official lib path.
  * Desktop, man, metainfo, icons, pixmaps and 50 locales
    including zh_CN / zh_TW stay on standard paths. Official
    desktop Icon=parole (icons shipped).
  * Same-source parole-dev is not a hard Depends and is not
    bundled. Official GStreamer plugin packages stay as Depends.
  * Conflicts/Replaces parole.
  * Depends kept for Ubuntu 20.04 (GTK3, GStreamer, libxfce4ui-2,
    libxfce4util7, libxfconf, cairo, dbus, libnotify, libtagc0,
    libx11, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:25:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Parole ${VER_UP}-1 — official Ubuntu 20.04 (focal) arm64,
KEMI repack.

The official ELF stays at /usr/bin/parole (compiled /usr
prefixes). /opt/parole/parole is a symlink to /usr/bin/parole.
Plugins stay at /usr/lib/aarch64-linux-gnu/parole-0. Desktop,
man, metainfo, icons, pixmaps and 50 locales including zh_CN /
zh_TW remain on standard /usr/share paths.
Official desktop Icon=parole (icons shipped under hicolor apps).
Probe: aarch64 · 4 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + GStreamer + libxfce4ui-2; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GStreamer plugins and libs, GTK3,
libxfce4ui-2, libxfce4util7, libxfconf, cairo, dbus, libnotify,
libtagc0, libx11, libc6 >= 2.17).
Official publication: Ubuntu 20.04 focal universe arm64
parole 1.0.5-1 (current official U20 package; no newer
focal-updates binary). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64 Packages
stanzas.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: xfce
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gstreamer1.0-alsa | gstreamer1.0-audiosink, gstreamer1.0-libav, gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, gstreamer1.0-x, libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.88), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.41.1), libgstreamer-plugins-base1.0-0 (>= 1.0.0), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.21.5), libnotify4 (>= 0.7.0), libtagc0 (>= 1.5), libx11-6, libxfce4ui-2-0 (>= 4.11.1), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.6.0)
Suggests: gstreamer1.0-plugins-bad, gstreamer1.0-plugins-ugly
Conflicts: parole
Replaces: parole
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://goodies.xfce.org/projects/applications/parole
Description: media player based on GStreamer framework (arm64)
 Parole ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Xfce media player based on the GStreamer framework.
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
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
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
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
# write basename-form sha256 for later recipe copy; keep a copy next to the deb
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-parole-control.txt"
