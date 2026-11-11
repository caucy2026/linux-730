#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main) shotwell
# 0.30.10-0ubuntu0.1 arm64 plus same-source exact-version
# hard-Depends shotwell-common (= 0.30.10-0ubuntu0.1, arch:all)
# as kemi-shotwell (orage-data / geany-common / thunar-data /
# filezilla-common / abiword-common pattern).
# Official shotwell has no Recommends. Official Recommends of
# shotwell-common is shotwell itself and is not a third-party
# plugin. No Remmina-style exact-version plugin to bundle.
# Official binaries: /usr/bin/shotwell, three same-package
#   shared libs under /usr/lib/aarch64-linux-gnu/, three
#   in-package plugins under
#   /usr/lib/aarch64-linux-gnu/shotwell/plugins/builtin/,
#   plus /usr/lib/shotwell/shotwell-video-thumbnailer and
#   the official shell helper shotwell-settings-migrator.
# Probe: aarch64 · 8 ELF · shotwell requiredGlibc 2.29 no
#   GLIBCXX; libs/plugins/thumbnailer requiredGlibc 2.17 no
#   GLIBCXX · PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal-updates main arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   Newer than focal/main 0.30.8-0ubuntu2 and still U20
#   compatible. No librarian URL and no .buildinfo is recorded
#   this run (pool 404). This round is not based on Launchpad
#   librarian.
# The official ELF embeds /usr/lib, /usr/lib/aarch64-linux-gnu
#   and /usr/share/locale and refers to
#   shotwell-video-thumbnailer / shotwell-settings-migrator
#   by name. Official ELF/libs/plugins/helpers stay on
#   official paths; /opt/shotwell/* are symlinks. Official
#   desktop Icon=shotwell (hicolor icons shipped in
#   shotwell-common). Official language-pack split applies:
#   these debs ship no gettext .mo (empty locale-langpack
#   dir only). Official help/C is real; other help locales
#   are official help-langpack symlinks. Keep the official
#   tree; do not invent/bundle language-packs, UI, or icons.
# Official menu command is already /usr/bin/shotwell.
# Official postinst/postrm only call update-menus; kept and
#   extended with desktop/icon/ldconfig helpers (this package
#   ships shlibs). Official schemas ship as XML; glib's
#   dpkg trigger compiles them (official postinst did not
#   call glib-compile-schemas).
# KEMI version 0.30.10-0ubuntu0.1kemi1 is 23 chars (under the
#   mall version_name limit that rejected Remmina's 33-char
#   string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-shotwell
VER_UP=0.30.10
VER_DEB="${VER_UP}-0ubuntu0.1kemi1"
ARCH=arm64
PKG=kemi-shotwell
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/shotwell-0.30.10-focal-updates-unpack}"
UP_DEB="$DL/shotwell_0.30.10-0ubuntu0.1_arm64.deb"
UP_COMMON="$DL/shotwell-common_0.30.10-0ubuntu0.1_all.deb"
EXPECT_SHA=eee76e599af255c9705e864ac206993438751751043ea2e19373fb6401c9aa06
EXPECT_BYTES=1704668
EXPECT_COMMON_SHA=6ffb067397f3afbbc9a49452b675054d11c58ad5e75f7f019a93f8f001340714
EXPECT_COMMON_BYTES=326480
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/bin/shotwell"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libshotwell-plugin-common.so.0.30.10"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/libshotwell-plugin-common.so.0"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/shotwell/plugins/builtin/libshotwell-publishing.so"
test -x "$UNPACK/usr/lib/shotwell/shotwell-video-thumbnailer"
test -f "$UNPACK/usr/lib/shotwell/shotwell-settings-migrator"
test -f "$UNPACK/usr/share/applications/shotwell.desktop"
test -f "$UNPACK/usr/share/applications/shotwell-viewer.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/shotwell.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.yorba.shotwell.gschema.xml"
test -f "$UNPACK/usr/share/help/C/shotwell/index.page"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/locale"
test ! -L "$UNPACK/usr/share/doc/shotwell/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/shotwell-common/changelog.Debian.gz"
# compiled prefix — process substitution, no SIGPIPE
grep -qx '/usr/lib' < <(strings -n 4 "$UNPACK/usr/bin/shotwell")
grep -qx '/usr/lib/aarch64-linux-gnu' < <(strings -n 8 "$UNPACK/usr/bin/shotwell")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/shotwell")
grep -q 'shotwell-video-thumbnailer' < <(strings -n 8 "$UNPACK/usr/bin/shotwell")
grep -q 'shotwell-settings-migrator' < <(strings -n 8 "$UNPACK/usr/bin/shotwell")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/shotwell" \
  "$STAGE/pkg/usr/share/doc/shotwell-common" \
  "$STAGE/pkg/opt/shotwell"

# official ELF, libs, plugins and helpers stay on official paths
cp -a "$UNPACK/usr/bin/shotwell" "$STAGE/pkg/usr/bin/shotwell"
chmod 0755 "$STAGE/pkg/usr/bin/shotwell"
cp -a "$UNPACK/usr/lib/." "$STAGE/pkg/usr/lib/"
chmod 0755 "$STAGE/pkg/usr/lib/shotwell/shotwell-video-thumbnailer"
chmod 0755 "$STAGE/pkg/usr/lib/shotwell/shotwell-settings-migrator"

REPORT="$ROOT/probe/kemi-shotwell.json"
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
test "${#ELFS[@]}" = 8
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 8:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
need = (
    "shotwell",
    "libshotwell-plugin-dev-1.0.so.0.30.10",
    "libshotwell-plugin-common.so.0.30.10",
    "libshotwell-authenticator.so.0.30.10",
    "libshotwell-transitions.so",
    "libshotwell-publishing-extras.so",
    "libshotwell-publishing.so",
    "shotwell-video-thumbnailer",
)
for name in need:
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
main = by["shotwell"]
if main.get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_MAIN_GLIBC")
for name in need:
    if name == "shotwell":
        continue
    if by[name].get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
print("PROBE_PASS n_elf=8 shotwell_glibc=2.29 others_glibc=2.17 no_GLIBCXX")
PY

# official data / help / icons / schemas / menu / metainfo / man / bug
cp -a "$UNPACK/usr/share/applications/." "$STAGE/pkg/usr/share/applications/"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/glib-2.0" "$STAGE/pkg/usr/share/glib-2.0"
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
cp -a "$UNPACK/usr/share/man" "$STAGE/pkg/usr/share/man"
cp -a "$UNPACK/usr/share/menu" "$STAGE/pkg/usr/share/menu"
cp -a "$UNPACK/usr/share/metainfo" "$STAGE/pkg/usr/share/metainfo"
cp -a "$UNPACK/usr/share/bug" "$STAGE/pkg/usr/share/bug"
cp -a "$UNPACK/usr/share/lintian" "$STAGE/pkg/usr/share/lintian"
if [[ -d "$UNPACK/usr/share/gnome" ]]; then
  cp -a "$UNPACK/usr/share/gnome" "$STAGE/pkg/usr/share/gnome"
fi
if [[ -d "$UNPACK/usr/share/locale-langpack" ]]; then
  cp -a "$UNPACK/usr/share/locale-langpack" "$STAGE/pkg/usr/share/locale-langpack"
fi
cp -a "$UNPACK/usr/share/doc/shotwell/." "$STAGE/pkg/usr/share/doc/shotwell/"
cp -a "$UNPACK/usr/share/doc/shotwell-common/." "$STAGE/pkg/usr/share/doc/shotwell-common/"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/locale"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/shotwell.png"
test -f "$STAGE/pkg/usr/share/help/C/shotwell/index.page"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.yorba.shotwell.gschema.xml"
test -f "$STAGE/pkg/usr/share/menu/shotwell"
grep -q 'command="/usr/bin/shotwell"' "$STAGE/pkg/usr/share/menu/shotwell"

# kemi changelog from official shotwell changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/shotwell/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/shotwell/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
if [[ -f "$UNPACK/usr/share/doc/shotwell/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/shotwell/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
pairs = [
    ("shotwell.desktop", "Exec=/usr/bin/shotwell %U", "Name=Shotwell"),
    ("shotwell-viewer.desktop", "Exec=/usr/bin/shotwell %f", "Name=Shotwell Viewer"),
]
for name, expect_exec, expect_name in pairs:
    src = Path("$UNPACK/usr/share/applications") / name
    dst = Path("$STAGE/pkg/usr/share/applications") / name
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=shotwell(\s.*)?$", r"Exec=/usr/bin/shotwell\1", text, flags=re.M)
    text2 = re.sub(r"^TryExec=shotwell$", "TryExec=/usr/bin/shotwell", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^(Exec=/usr/bin/shotwell(?:\s.*)?)$",
                       r"\1\nTryExec=/usr/bin/shotwell", text2, count=1, flags=re.M)
    if re.search(r"^Exec=shotwell(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC_{name}")
    if expect_exec not in text2:
        raise SystemExit(f"MISSING_EXEC_{name}")
    if "TryExec=/usr/bin/shotwell" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC_{name}")
    if not re.search(r"^Icon=shotwell$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON_{name}")
    if expect_name not in text2:
        raise SystemExit(f"MISSING_NAME_{name}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/shotwell "$STAGE/pkg/opt/shotwell/shotwell"
ln -sf shotwell "$STAGE/pkg/usr/bin/kemi-shotwell"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Shotwell
Source: https://launchpad.net/ubuntu/+source/shotwell
Homepage: https://wiki.gnome.org/Apps/Shotwell
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(shotwell_0.30.10-0ubuntu0.1_arm64.deb + bundled same-source
exact-version hard-Depends
shotwell-common_0.30.10-0ubuntu0.1_all.deb) repackaged for
KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 shotwell_0.30.10-0ubuntu0.1_arm64.deb
    (focal-updates main; newer than focal 0.30.8-0ubuntu2 and
    still U20 compatible) plus same-source exact-version
    hard-Depends shotwell-common (= 0.30.10-0ubuntu0.1,
    arch:all) bundled for KEMI as ${PKG}.
  * Official binary stays at /usr/bin/shotwell; same-package
    libs, in-package plugins and helpers stay on official
    /usr/lib paths. /opt/shotwell/* are symlinks.
  * Official data, help/C, official help-langpack symlinks,
    icons, schemas, menu, metainfo, man and bug files stay on
    standard paths. No official gettext .mo; official
    language-pack split is kept (do not invent language-packs).
    Desktop Exec=shotwell rewritten to /usr/bin/shotwell on
    both official launchers; Icon=shotwell (icons shipped).
    Official menu command already absolute and left unchanged.
  * Conflicts/Replaces/Provides shotwell and shotwell-common.
    Official Depends kept for Ubuntu 20.04 except bundled
    shotwell-common (plus common's dconf-gsettings-backend |
    gsettings-backend; libc6 >= 2.29, GTK3, webkit2gtk).
    Official shotwell has no Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:58:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Shotwell ${VER_UP}-0ubuntu0.1 — official Ubuntu 20.04
(focal-updates) main arm64, KEMI repack, with bundled
official shotwell-common.

Official binary stays at /usr/bin/shotwell; libs, plugins
and helpers stay on official /usr/lib paths.
/opt/shotwell/* are symlinks.
Desktop, man, official help/C, official help-langpack
symlinks, schemas, icons, menu and metainfo remain on
standard paths.
Official desktop Icon=shotwell (hicolor icons shipped in
shotwell-common).
Official language-pack split applies: these debs ship no
gettext .mo (empty locale-langpack dir only).
Probe: aarch64 · 8 ELF · shotwell requiredGlibc 2.29 no
GLIBCXX; other ELFs requiredGlibc 2.17 no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled shotwell-common
(plus common's dconf-gsettings-backend | gsettings-backend;
libc6 >= 2.29, GTK3, webkit2gtk). Official shotwell has
no Recommends.
Official publication: Ubuntu 20.04 focal-updates main
arm64 shotwell 0.30.10-0ubuntu0.1 + arch:all
shotwell-common. Official SHA256 + size matched
ports.ubuntu.com pool files and focal-updates main arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: gnome
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.29), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.2.4), libexif12 (>= 0.6.21-1~), libgcr-base-3-1 (>= 3.8.0), libgcr-ui-3-1 (>= 3.8.0), libgdata22 (>= 0.15.0), libgdk-pixbuf2.0-0 (>= 2.25.2), libgee-0.8-2 (>= 0.10.1), libgexiv2-2 (>= 0.10.4), libglib2.0-0 (>= 2.49.5), libgphoto2-6 (>= 2.5.10), libgphoto2-port12 (>= 2.5.10), libgstreamer-plugins-base1.0-0 (>= 1.0.0), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.22), libgudev-1.0-0 (>= 146), libjson-glib-1.0-0 (>= 1.2.0), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libraw19 (>= 0.16.0), libsoup2.4-1 (>= 2.41.90), libsqlite3-0 (>= 3.5.9), libwebkit2gtk-4.0-37 (>= 2.15.90), libxml2 (>= 2.7.4), dconf-cli, default-dbus-session-bus | dbus-session-bus, librsvg2-common, dconf-gsettings-backend | gsettings-backend
Provides: shotwell, shotwell-common
Conflicts: shotwell, shotwell-common
Replaces: shotwell, shotwell-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Shotwell
Description: digital photo organizer (arm64)
 Shotwell ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official shotwell-common.
 A digital photo organizer designed for the GNOME desktop.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libshotwell-authenticator 0 kemi-shotwell
libshotwell-plugin-common 0 kemi-shotwell
libshotwell-plugin-dev-1.0 0 kemi-shotwell
EOT
printf '%s\n' 'activate-noawait ldconfig' > "$STAGE/pkg/DEBIAN/triggers"

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
  ldconfig || true
fi
if [ "$1" = "configure" ] && [ -x "`which update-menus 2>/dev/null`" ]; then
  update-menus
fi
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
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  ldconfig || true
fi
if [ -x "`which update-menus 2>/dev/null`" ]; then update-menus ; fi
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
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-shotwell-control.txt"
