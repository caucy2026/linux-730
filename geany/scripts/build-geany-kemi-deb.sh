#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) geany
# 1.36-1build1 arm64 plus same-source hard-Depends
# geany-common (= 1.36-1build1, arch:all) as kemi-geany
# (orage-data / remmina-common / thunar-data pattern).
# Official geany-plugins is a different source and is not a
#   Depends/Recommends of geany; individual plugins
#   Depends: geany and geany-abi-18432 (not geany (= exact)).
#   They are not bundled. This package Provides geany,
#   geany-common, geany-abi-18432 and geany-api-239 so they
#   can later be apt-installed next to kemi-geany.
# Official Suggests (libvte9, doc-base) stay Suggests.
# Official binaries: small /usr/bin/geany stub, official
#   /usr/lib/aarch64-linux-gnu/libgeany.so.0, and six
#   in-package plugins under /usr/lib/aarch64-linux-gnu/geany/.
# Probe: aarch64 · 8 ELF · stub+plugins requiredGlibc 2.17 no
#   GLIBCXX; libgeany requiredGlibc 2.27 · GLIBCXX 3.4.21 ·
#   PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# libgeany embeds /usr/share/locale, /usr/lib/aarch64-linux-gnu,
#   /usr/share/doc/geany and /usr/share/geany data (geany.glade).
#   Official ELF/lib/plugins stay on official paths;
#   /opt/geany/* are symlinks. Official desktop Icon=geany
#   (hicolor + Tango icons and pixmaps/geany.xpm shipped in
#   geany-common). Official language-pack split does not apply:
#   geany-common ships 46 .mo including zh_CN. Keep the official
#   tree; do not invent/bundle language-packs or UI/icons.
#   Official HTML manual stays at /usr/share/doc/geany (compiled
#   path). No /usr/share/help directory.
# KEMI version 1.36-1build1kemi1 is 17 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-geany
VER_UP=1.36
VER_DEB="${VER_UP}-1build1kemi1"
ARCH=arm64
PKG=kemi-geany
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/geany-1.36-focal-unpack}"
UP_DEB="$DL/geany_1.36-1build1_arm64.deb"
UP_COMMON="$DL/geany-common_1.36-1build1_all.deb"
EXPECT_SHA=915009321a71c1e59571163b3f507b112c46629e360915b6b39dc2f73bbaf194
EXPECT_BYTES=1010124
EXPECT_COMMON_SHA=7f666e3ad70930501e2ca1cdb2c4db3fc9cf1ca33c790068b7a57c64b470f594
EXPECT_COMMON_BYTES=1843484
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/bin/geany"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/geany/filebrowser.so"
test -f "$UNPACK/usr/share/applications/geany.desktop"
test -f "$UNPACK/usr/share/geany/geany.glade"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/geany.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/geany.mo"
test -d "$UNPACK/usr/share/doc/geany/html"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 46
test ! -d "$UNPACK/usr/share/help"
# compiled prefix — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0")
grep -qx '/usr/lib/aarch64-linux-gnu' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0")
grep -q 'geany.glade' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0")
test ! -L "$UNPACK/usr/share/doc/geany/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/geany-common/changelog.Debian.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/geany" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/geany" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/geany" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/opt/geany"

cp -al "$UNPACK/usr/bin/geany" "$STAGE/pkg/usr/bin/geany"
chmod 0755 "$STAGE/pkg/usr/bin/geany"

# official libgeany and in-package plugins stay on official paths
cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libgeany.so.0.0.0"
ln -s libgeany.so.0.0.0 "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libgeany.so.0"
ln -s libgeany.so.0.0.0 "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libgeany.so"
for plug in classbuilder export filebrowser htmlchars saveactions splitwindow; do
  cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/geany/${plug}.so" \
    "$STAGE/pkg/usr/lib/aarch64-linux-gnu/geany/${plug}.so"
done

REPORT="$ROOT/probe/kemi-geany.json"
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
for name in ("geany", "libgeany.so.0.0.0", "classbuilder.so", "export.so",
             "filebrowser.so", "htmlchars.so", "saveactions.so", "splitwindow.so"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibcxx") is not None and name != "libgeany.so.0.0.0":
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
stub = by["geany"]
if stub.get("requiredGlibc") != "2.17" or stub.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_STUB")
if "libgeany.so.0" not in set(stub.get("neededLibraries") or []):
    raise SystemExit("PROBE_STUB_NEEDED")
lib = by["libgeany.so.0.0.0"]
if lib.get("requiredGlibc") != "2.27":
    raise SystemExit("PROBE_LIB_GLIBC")
if lib.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_LIB_GLIBCXX")
needed = set(lib.get("neededLibraries") or [])
for n in ("libgtk-3.so.0", "libstdc++.so.6", "libc.so.6"):
    if n not in needed:
        raise SystemExit(f"PROBE_MISSING_{n}")
print("PROBE_PASS n_elf=8 stub_glibc=2.17 libgeany_glibc=2.27 GLIBCXX=3.4.21")
PY

# official data / locales / icons / pixmaps / docs (compiled /usr/share/doc/geany)
cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/geany/." "$STAGE/pkg/usr/share/geany/"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a "$UNPACK/usr/share/icons/Tango" "$STAGE/pkg/usr/share/icons/Tango"
cp -a --remove-destination "$UNPACK/usr/share/pixmaps/geany.xpm" \
  "$STAGE/pkg/usr/share/pixmaps/geany.xpm"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/geany.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/geany.1.gz"
# official HTML manual and docs stay at compiled /usr/share/doc/geany
cp -a "$UNPACK/usr/share/doc/geany/." "$STAGE/pkg/usr/share/doc/geany/"
if [[ -f "$UNPACK/usr/share/doc-base/geany" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/doc-base"
  cp -a --remove-destination "$UNPACK/usr/share/doc-base/geany" \
    "$STAGE/pkg/usr/share/doc-base/geany"
fi
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 46
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/geany.mo"
test -f "$STAGE/pkg/usr/share/geany/geany.glade"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/geany.png"
test -f "$STAGE/pkg/usr/share/doc/geany/html/index.html"
test ! -d "$STAGE/pkg/usr/share/help"

# kemi changelog from official geany changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/geany/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/geany/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
if [[ -f "$UNPACK/usr/share/doc/geany/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/geany/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/geany.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/geany.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=geany(\s.*)?$", r"Exec=/usr/bin/geany\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=geany$", "TryExec=/usr/bin/geany", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/geany(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/geany", text2, count=1, flags=re.M)
if re.search(r"^Exec=geany(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/geany %F" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/geany" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=geany$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Geany" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/geany "$STAGE/pkg/opt/geany/geany"
ln -sf geany "$STAGE/pkg/usr/bin/kemi-geany"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.geany.org
Source: https://launchpad.net/ubuntu/+source/geany
Homepage: http://www.geany.org
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(geany_1.36-1build1_arm64.deb + bundled same-source
geany-common_1.36-1build1_all.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 geany_1.36-1build1_arm64.deb
    (focal universe; no newer package in focal-updates)
    plus same-source hard-Depends geany-common
    (= 1.36-1build1, arch:all) bundled for KEMI as ${PKG}.
  * Official stub stays at /usr/bin/geany; libgeany and the
    six in-package plugins stay under
    /usr/lib/aarch64-linux-gnu/. /opt/geany/* are symlinks.
  * Official data, 46 .mo (including zh_CN), icons, pixmaps,
    man, official HTML manual at /usr/share/doc/geany and
    geany.glade stay on standard paths. Desktop Exec=geany
    rewritten to /usr/bin/geany; Icon=geany (icons shipped).
  * Conflicts/Replaces/Provides geany and geany-common.
    Also Provides geany-abi-18432 and geany-api-239 so
    official geany-plugins can later be apt-installed.
    Official Depends kept for Ubuntu 20.04 except bundled
    geany-common (GTK3, libstdc++6, libc6 >= 2.27).
    Official Suggests libvte9 / doc-base kept as Suggests.
    Different-source geany-plugins are not bundled.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Geany ${VER_UP}-1build1 — official Ubuntu 20.04 (focal)
universe arm64, KEMI repack, with bundled official
geany-common.

Official stub stays at /usr/bin/geany; libgeany and
in-package plugins stay on official /usr/lib paths.
/opt/geany/* are symlinks.
Desktop, man, official locales, data (geany.glade,
filetypes, templates), icons and the official HTML
manual at /usr/share/doc/geany remain on standard paths.
Official desktop Icon=geany (hicolor + Tango icons and
geany.xpm shipped in geany-common).
Official language-pack split does not apply: this
common package ships 46 .mo including zh_CN.
Probe: aarch64 · 8 ELF · stub/plugins requiredGlibc 2.17
no GLIBCXX; libgeany requiredGlibc 2.27 · GLIBCXX 3.4.21;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled geany-common
(GTK3, libstdc++6, libc6 >= 2.27). Official Suggests
kept as Suggests. geany-plugins is a different source
and is not bundled.
Official publication: Ubuntu 20.04 focal universe arm64
geany 1.36-1build1 + arch:all geany-common. Official
SHA256 + size matched ports.ubuntu.com pool files and
focal universe arm64 Packages stanzas. No librarian URL
this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.27), libcairo2 (>= 1.8.0), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.41.1), libgtk-3-0 (>= 3.21.5), libpango-1.0-0 (>= 1.20.0), libpangocairo-1.0-0 (>= 1.14.0), libstdc++6 (>= 5.2)
Suggests: libvte9, doc-base
Provides: geany, geany-common, geany-abi-18432, geany-api-239
Conflicts: geany, geany-common
Replaces: geany, geany-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.geany.org
Description: fast and lightweight IDE (arm64)
 Geany ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official geany-common.
 A small and fast IDE using GTK+.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

printf '%s\n' 'libgeany 0 kemi-geany' > "$STAGE/pkg/DEBIAN/shlibs"
printf '%s\n' 'activate-noawait ldconfig' > "$STAGE/pkg/DEBIAN/triggers"

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
  ldconfig || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/Tango >/dev/null 2>&1 || true
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
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/Tango >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-geany-control.txt"
