#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) gnumeric
# 1.12.46-1ubuntu2 arm64 plus same-source exact-version
# hard-Depends gnumeric-common (= 1.12.46-1ubuntu2, arch:all)
# as kemi-gnumeric (orage-data / geany-common / thunar-data /
# filezilla-common / shotwell-common / abiword-common pattern).
# Official Recommends gnumeric-doc (>= 1.12.46), evince and
#   lp-solve stay Recommends (gnumeric-doc is same-source but
#   not an exact-version hard Depends; evince is a different
#   source and is also a low-priority sibling). Official
#   Suggests gnumeric-plugins-extra Depends: gnumeric
#   (= 1.12.46-1ubuntu2) but is only a Suggests and pulls
#   libpython2.7; it is not bundled. This package Provides
#   versioned gnumeric (= 1.12.46-1ubuntu2) so the extra
#   plugins can later be apt-installed next to kemi-gnumeric.
# Official binaries: /usr/bin/gnumeric plus ssconvert, ssdiff,
#   ssindex, ssgrep; main logic in
#   /usr/lib/libspreadsheet-1.12.46.so; in-package plugins
#   under /usr/lib/gnumeric/1.12.46/plugins/ and a goffice
#   plugin under /usr/lib/goffice/0.10/plugins/gnumeric/.
# Probe: aarch64 · 47 ELF · bins requiredGlibc 2.17 no
#   GLIBCXX; libspreadsheet and several plugins requiredGlibc
#   2.29 no GLIBCXX · PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404). This round is
#   not based on Launchpad librarian.
# libspreadsheet embeds /usr/lib/gnumeric/1.12.46,
#   /usr/lib/gnumeric/1.12/plugins, /usr/share/gnumeric/1.12.46
#   and /usr/share/locale. Official ELF/lib/plugins stay on
#   official paths; /opt/gnumeric/* are symlinks. Official
#   desktop Icon=gnumeric (hicolor + pixmaps shipped in
#   gnumeric-common). Official language-pack split does not
#   apply: gnumeric-common ships 122 .mo including zh_CN.
#   Keep the official tree; do not invent/bundle language-packs
#   or UI/icons.
# Official maintainer scripts (debconf preinst/config/templates
#   plus nearly-empty postinst, postrm db_purge, and
#   gnumeric-common preinst) are kept. shlibs retargeted to
#   kemi-gnumeric. Official schemas ship as XML; glib's dpkg
#   trigger compiles them.
# KEMI version 1.12.46-1ubuntu2kemi1 is 21 chars (under the
#   mall version_name limit that rejected Remmina's 33-char
#   string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnumeric
VER_UP=1.12.46
VER_DEB="${VER_UP}-1ubuntu2kemi1"
ARCH=arm64
PKG=kemi-gnumeric
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gnumeric-1.12.46-focal-unpack}"
CTRL="$ROOT/probe/official-control-gnumeric"
CTRL_COMMON="$ROOT/probe/official-control-common"
UP_DEB="$DL/gnumeric_1.12.46-1ubuntu2_arm64.deb"
UP_COMMON="$DL/gnumeric-common_1.12.46-1ubuntu2_all.deb"
EXPECT_SHA=e5572cef03550cb9b73affd8125722b258f0af4c4663072bfa1bde56c78e37ec
EXPECT_BYTES=2142916
EXPECT_COMMON_SHA=c3930f4ba6e4f94909d41100a42aa6cdd6d9a5e81e7edd7000da18554f2af77c
EXPECT_COMMON_BYTES=2664684
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnumeric"
test -x "$UNPACK/usr/bin/ssconvert"
test -f "$UNPACK/usr/lib/libspreadsheet-1.12.46.so"
test -L "$UNPACK/usr/lib/libspreadsheet.so"
test -f "$UNPACK/usr/lib/gnumeric/1.12.46/plugins/excel/excel.so"
test -f "$UNPACK/usr/share/applications/gnumeric.desktop"
test -f "$UNPACK/usr/share/gnumeric/1.12.46/Gnumeric-embed.xml"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/gnumeric.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/gnumeric-1.12.46.mo"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 122
test ! -L "$UNPACK/usr/share/doc/gnumeric/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnumeric-common/changelog.Debian.gz"
# compiled prefix — process substitution, no SIGPIPE
grep -qx '/usr/lib/gnumeric/1.12.46' < <(strings -n 8 "$UNPACK/usr/lib/libspreadsheet-1.12.46.so")
grep -qx '/usr/share/gnumeric/1.12.46' < <(strings -n 8 "$UNPACK/usr/lib/libspreadsheet-1.12.46.so")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/lib/libspreadsheet-1.12.46.so")
grep -q 'libspreadsheet-1.12.46.so' < <(strings -n 8 "$UNPACK/usr/bin/gnumeric")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib" \
  "$STAGE/pkg/usr/share" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnumeric"

for b in gnumeric ssconvert ssdiff ssindex ssgrep; do
  cp -a "$UNPACK/usr/bin/$b" "$STAGE/pkg/usr/bin/$b"
  chmod 0755 "$STAGE/pkg/usr/bin/$b"
done
cp -a "$UNPACK/usr/lib/." "$STAGE/pkg/usr/lib/"
# official data / locales / icons / schemas / man / pixmaps / lintian
cp -a "$UNPACK/usr/share/applications" "$STAGE/pkg/usr/share/applications"
cp -a "$UNPACK/usr/share/gnumeric" "$STAGE/pkg/usr/share/gnumeric"
cp -a "$UNPACK/usr/share/icons" "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/pixmaps" "$STAGE/pkg/usr/share/pixmaps"
cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/glib-2.0" "$STAGE/pkg/usr/share/glib-2.0"
cp -a "$UNPACK/usr/share/man" "$STAGE/pkg/usr/share/man"
cp -a "$UNPACK/usr/share/doc/gnumeric" "$STAGE/pkg/usr/share/doc/gnumeric"
cp -a "$UNPACK/usr/share/doc/gnumeric-common" "$STAGE/pkg/usr/share/doc/gnumeric-common"
if [[ -d "$UNPACK/usr/share/lintian" ]]; then
  cp -a "$UNPACK/usr/share/lintian" "$STAGE/pkg/usr/share/lintian"
fi

REPORT="$ROOT/probe/kemi-gnumeric.json"
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
test "${#ELFS[@]}" = 47
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
if len(files) != 47:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")

def vkey(s):
    return tuple(int(x) for x in s.split("."))

by = {}
max_glibc = None
for f in files:
    name = Path(f["path"]).name
    by.setdefault(name, []).append(f)
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
    g = f.get("requiredGlibc")
    if g and (max_glibc is None or vkey(g) > vkey(max_glibc)):
        max_glibc = g
    if g and vkey(g) > (2, 31):
        raise SystemExit(f"PROBE_GLIBC_{name}_{g}")
stub = by["gnumeric"][0]
if stub.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_STUB_GLIBC")
if "libspreadsheet-1.12.46.so" not in set(stub.get("neededLibraries") or []):
    raise SystemExit("PROBE_STUB_NEEDED")
lib = by["libspreadsheet-1.12.46.so"][0]
if lib.get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_LIB_GLIBC")
if max_glibc != "2.29":
    raise SystemExit(f"PROBE_MAX_GLIBC_{max_glibc}")
print("PROBE_PASS n_elf=47 stub_glibc=2.17 libspreadsheet_glibc=2.29 no_GLIBCXX")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 122
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/gnumeric-1.12.46.mo"
test -f "$STAGE/pkg/usr/share/gnumeric/1.12.46/Gnumeric-embed.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/gnumeric.png"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.gnumeric.gschema.xml"
test ! -d "$STAGE/pkg/usr/share/help"

# kemi changelog from official gnumeric changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/gnumeric/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/gnumeric/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
if [[ -f "$UNPACK/usr/share/doc/gnumeric/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gnumeric/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/gnumeric.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/gnumeric.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnumeric(\s.*)?$", r"Exec=/usr/bin/gnumeric\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=gnumeric$", "TryExec=/usr/bin/gnumeric", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gnumeric(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/gnumeric", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnumeric(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/gnumeric %U" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/gnumeric" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=gnumeric$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if not re.search(r"^Name=Gnumeric$", text2, flags=re.M):
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/gnumeric "$STAGE/pkg/opt/gnumeric/gnumeric"
ln -sf gnumeric "$STAGE/pkg/usr/bin/kemi-gnumeric"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.gnumeric.org/
Source: https://launchpad.net/ubuntu/+source/gnumeric
Homepage: http://www.gnumeric.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(gnumeric_1.12.46-1ubuntu2_arm64.deb + bundled same-source
exact-version hard-Depends
gnumeric-common_1.12.46-1ubuntu2_all.deb) repackaged for
KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnumeric_1.12.46-1ubuntu2_arm64.deb
    (focal universe; no newer package in focal-updates)
    plus same-source exact-version hard-Depends
    gnumeric-common (= 1.12.46-1ubuntu2, arch:all) bundled
    for KEMI as ${PKG}.
  * Official binaries stay at /usr/bin/gnumeric and the
    official ssconvert/ssdiff/ssindex/ssgrep tools;
    libspreadsheet and in-package plugins stay on official
    /usr/lib paths. /opt/gnumeric/* are symlinks.
  * Official data, 122 .mo (including zh_CN), icons, pixmaps,
    schemas, man and mime files stay on standard paths.
    Official language-pack split does not apply (do not
    invent language-packs). Desktop Exec=gnumeric rewritten
    to /usr/bin/gnumeric; Icon=gnumeric (icons shipped).
  * Conflicts/Replaces/Provides gnumeric and gnumeric-common
    (versioned Provides so official Suggests
    gnumeric-plugins-extra can later be apt-installed).
    Official Depends kept for Ubuntu 20.04 except bundled
    gnumeric-common (plus common's dconf-gsettings-backend |
    gsettings-backend; libc6 >= 2.29, GTK3, libgoffice).
    Official Recommends gnumeric-doc / evince / lp-solve
    kept as Recommends. Official Suggests
    gnumeric-plugins-extra kept as Suggests (not bundled).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:08:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gnumeric ${VER_UP}-1ubuntu2 — official Ubuntu 20.04 (focal)
universe arm64, KEMI repack, with bundled official
gnumeric-common.

Official binaries stay at /usr/bin/gnumeric and the
official ss* tools; libspreadsheet and in-package
plugins stay on official /usr/lib paths.
/opt/gnumeric/* are symlinks.
Desktop, man, official 122 .mo (including zh_CN),
data (templates, autoformat), icons, pixmaps and
GSettings schemas remain on standard paths.
Official desktop Icon=gnumeric (hicolor icons and
pixmaps shipped in gnumeric-common).
Official language-pack split does not apply: this
common package ships 122 .mo including zh_CN.
Probe: aarch64 · 47 ELF · bins requiredGlibc 2.17 no
GLIBCXX; libspreadsheet requiredGlibc 2.29 no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled gnumeric-common
(plus common's dconf-gsettings-backend | gsettings-backend;
libc6 >= 2.29, GTK3, libgoffice). Official Recommends
and Suggests kept. gnumeric-plugins-extra is a Suggests
and is not bundled.
Official publication: Ubuntu 20.04 focal universe arm64
gnumeric 1.12.46-1ubuntu2 + arch:all gnumeric-common.
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanzas. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: math
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Pre-Depends: debconf
Depends: debconf (>= 0.5) | debconf-2.0, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.10.0), libgdk-pixbuf2.0-0 (>= 2.25.2), libglib2.0-0 (>= 2.39.4), libgoffice-0.10-10 (>= 0.10.46), libgsf-1-114 (>= 1.14.27), libgtk-3-0 (>= 3.13.7), libpango-1.0-0 (>= 1.29.4), libpangocairo-1.0-0 (>= 1.14.0), libxml2 (>= 2.7.4), pxlib1, zlib1g (>= 1:1.1.4), gsfonts, procps, dconf-gsettings-backend | gsettings-backend
Recommends: gnumeric-doc (>= 1.12.46), evince, lp-solve
Suggests: gnumeric-plugins-extra, fonts-liberation | ttf-mscorefonts-installer, libgsf-1-dev
Provides: gnumeric (= 1.12.46-1ubuntu2), gnumeric-common (= 1.12.46-1ubuntu2)
Conflicts: gnumeric, gnumeric-common
Replaces: gnumeric, gnumeric-common
Breaks: gnumeric-doc (<< 1.12.46)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.gnumeric.org/
Description: spreadsheet application for GNOME (arm64)
 Gnumeric ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official gnumeric-common.
 A spreadsheet application that interoperates well with
 other spreadsheets.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official debconf scripts + templates; shlibs retargeted
cp -a "$CTRL/preinst" "$STAGE/pkg/DEBIAN/preinst"
cp -a "$CTRL/config" "$STAGE/pkg/DEBIAN/config"
cp -a "$CTRL/templates" "$STAGE/pkg/DEBIAN/templates"
chmod 0755 "$STAGE/pkg/DEBIAN/preinst" "$STAGE/pkg/DEBIAN/config"
# common preinst as a hook appended? Official common preinst only
# removes a stale /usr/share/doc/gnumeric-common symlink. Fold it
# into the gnumeric preinst by running it first via a combined script.
python3 - << PY
from pathlib import Path
pre = Path("$CTRL/preinst").read_text()
common = Path("$CTRL_COMMON/preinst").read_text()
# drop the trailing exit 0 from common and splice before gnumeric body
common_body = common.replace("#! /bin/sh", "").replace("#!/bin/sh", "")
common_body = common_body.replace("set -e", "", 1)
# write combined: shebang + set -e + common symlink cleanup + official preinst body
official_body = pre
# official already has shebang+set -e; insert common cleanup after set -e
text = official_body
needle = "set -e\n"
idx = text.find(needle)
if idx < 0:
    raise SystemExit("PREINST_NO_SET_E")
insert = needle + "\n# from official gnumeric-common preinst\n" + common_body.strip() + "\n\n"
text = text[:idx] + insert + text[idx+len(needle):]
Path("$STAGE/pkg/DEBIAN/preinst").write_text(text)
print("preinst_combined")
PY
chmod 0755 "$STAGE/pkg/DEBIAN/preinst"

printf '%s\n' 'libspreadsheet 1.12.46 kemi-gnumeric (>= 1.12.46)' > "$STAGE/pkg/DEBIAN/shlibs"
printf '%s\n' 'activate-noawait ldconfig' > "$STAGE/pkg/DEBIAN/triggers"

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#! /bin/sh
set -e
. /usr/share/debconf/confmodule
if [ "$1" = "configure" ]; then
  ldconfig || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
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
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  ldconfig || true
fi
# Automatically added by dh_installdebconf/12.9ubuntu1
if [ "$1" = purge ] && [ -e /usr/share/debconf/confmodule ]; then
	. /usr/share/debconf/confmodule
	db_purge
fi
# End automatically added section
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v update-mime >/dev/null 2>&1; then
  update-mime || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnumeric-control.txt"
