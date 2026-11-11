#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) homebank
# 5.3.2-1 arm64 as kemi-homebank, bundling same-source
# homebank-data_5.3.2-1_all.deb. Official Depends is
#   homebank-data (>= 5.3.2-1) (minimum version, not a single
#   Equals), but this is the named same-source data package
#   and the only focal version is 5.3.2-1; bundle on the
#   orage-data / gnumeric-common / shotwell-common /
#   abiword-common / pidgin-data pattern.
# Official Recommends librsvg2-common (different source) stays
#   Recommends and is not bundled. There are no official
#   Suggests. Versioned Provides: homebank (= 5.3.2-1) and
#   homebank-data (= 5.3.2-1).
# Official binary: /usr/bin/homebank. The ELF embeds
#   /usr/share/homebank (gettext bindtextdomain; official .mo
#   live under /usr/share/locale). Official files stay on
#   official paths; /opt/homebank/* are symlinks
#   (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/
#   Parole/GNOME Disks/GNOME System Monitor/GParted/Seahorse/
#   Remmina/dconf-editor/xfce4-terminal/thunar/pcmanfm/geany/
#   filezilla/blueman/audacious/abiword/shotwell/gnumeric/
#   claws-mail/pidgin/dia).
# Official homebank-data ships 55 .mo including zh_CN, example
#   data, splash and official HTML help under
#   /usr/share/doc/homebank-data/help. Official homebank ships
#   the desktop, man, hicolor app icons (16/22/24/32/48/256),
#   pixmap, in-app icons under /usr/share/homebank/icons,
#   mime and application-registry. Keep the official tree;
#   do not invent/bundle language-packs or extra UI/icons.
# Official homebank-data ships
#   /usr/share/homebank/images/homebank.svg as a symlink to
#   ../../pixmaps/homebank.xpm (in the binary package). After
#   bundling both, the symlink resolves; do not invent an SVG.
# Official Description still says “based on GTK2”, but the
#   focal binary Depends / DT_NEEDED is GTK3 (libgtk-3-0 /
#   libgtk-3.so.0). Document the actual Depends.
# No /usr/share/help directory (help lives under
#   /usr/share/doc/homebank-data/help). Official changelogs
#   are real files. No official maintainer scripts.
# Probe: aarch64 · 1 ELF · requiredGlibc 2.29 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# KEMI version 5.3.2-1kemi1 is 12 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-homebank
VER_UP=5.3.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-homebank
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/homebank-5.3.2-focal-unpack}"
DATA_UNPACK="${DATA_UNPACK:-$ROOT/probe/homebank-data-5.3.2-focal-unpack}"
UP_DEB="$DL/homebank_5.3.2-1_arm64.deb"
DATA_DEB="$DL/homebank-data_5.3.2-1_all.deb"
EXPECT_SHA=f290285d04ac2240a378c43593c71da0e711e70eb4af3856b6f0aa5d9b08efa9
EXPECT_BYTES=337244
EXPECT_DATA_SHA=9d3f257d7e7f52dda0067b58f0089adeed56a26a474b84bf7adfb2ccf5061031
EXPECT_DATA_BYTES=1347556
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$DATA_DEB"
test "$(stat -c%s "$DATA_DEB")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/homebank"
test -f "$UNPACK/usr/share/applications/homebank.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/homebank.png"
test -f "$UNPACK/usr/share/pixmaps/homebank.xpm"
test -f "$UNPACK/usr/share/man/man1/homebank.1.gz"
test -f "$DATA_UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/homebank.mo"
test "$(find "$DATA_UNPACK" -name '*.mo' | wc -l)" = 55
test -f "$DATA_UNPACK/usr/share/homebank/datas/example.xhb"
test -f "$DATA_UNPACK/usr/share/doc/homebank-data/help/index.html"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/homebank/changelog.Debian.gz"
test ! -L "$DATA_UNPACK/usr/share/doc/homebank-data/changelog.Debian.gz"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/homebank' < <(strings -n 8 "$UNPACK/usr/bin/homebank")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/homebank" \
  "$STAGE/pkg/usr/share/doc/homebank-data" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/homebank" \
  "$STAGE/pkg/usr/share/mime/packages" \
  "$STAGE/pkg/usr/share/mime-info" \
  "$STAGE/pkg/usr/share/application-registry" \
  "$STAGE/pkg/usr/share/doc-base" \
  "$STAGE/pkg/opt/homebank"

cp -al "$UNPACK/usr/bin/homebank" "$STAGE/pkg/usr/bin/homebank"
chmod 0755 "$STAGE/pkg/usr/bin/homebank"

REPORT="$ROOT/probe/kemi-homebank.json"
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
test "${#ELFS[@]}" = 1
PROBE_ARGS=(--target-arch arm64 --max-glibc 2.31 --report "$REPORT")
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 1:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
f = files[0]
if Path(f["path"]).name != "homebank":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.29":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libofx.so.7", "libsoup-2.4.so.1", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=1 arch=aarch64 requiredGlibc=2.29 noGLIBCXX")
PY

# official data, icons, docs — keep official trees; no overlap under share/homebank
cp -a "$UNPACK/usr/share/homebank/." "$STAGE/pkg/usr/share/homebank/"
cp -a "$DATA_UNPACK/usr/share/homebank/." "$STAGE/pkg/usr/share/homebank/"
cp -a "$DATA_UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/icons/." "$STAGE/pkg/usr/share/icons/"
cp -a --remove-destination "$UNPACK/usr/share/pixmaps/homebank.xpm" \
  "$STAGE/pkg/usr/share/pixmaps/homebank.xpm"
cp -a "$UNPACK/usr/share/doc/homebank/." "$STAGE/pkg/usr/share/doc/homebank/"
cp -a "$DATA_UNPACK/usr/share/doc/homebank-data/." "$STAGE/pkg/usr/share/doc/homebank-data/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/homebank.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/homebank.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/mime/packages/homebank.xml" \
  "$STAGE/pkg/usr/share/mime/packages/homebank.xml"
cp -a --remove-destination "$DATA_UNPACK/usr/share/doc-base/homebank" \
  "$STAGE/pkg/usr/share/doc-base/homebank"
# official data symlink to binary-package pixmap must resolve after bundling
test -e "$STAGE/pkg/usr/share/homebank/images/homebank.svg"
test -f "$STAGE/pkg/usr/share/pixmaps/homebank.xpm"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 55
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/homebank.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/homebank.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/homebank.png"
test -f "$STAGE/pkg/usr/share/homebank/datas/example.xhb"
test -f "$STAGE/pkg/usr/share/doc/homebank-data/help/index.html"
test ! -d "$STAGE/pkg/usr/share/help"

cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/homebank-data/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/homebank-data/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/homebank.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/homebank.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=homebank(\s.*)?$", r"Exec=/usr/bin/homebank\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=homebank$", "TryExec=/usr/bin/homebank", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/homebank(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/homebank", text2, count=1, flags=re.M)
if re.search(r"^Exec=homebank(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/homebank %f", "TryExec=/usr/bin/homebank"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=homebank$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=HomeBank" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)

keys_src = Path("$UNPACK/usr/share/mime-info/homebank.keys")
keys_dst = Path("$STAGE/pkg/usr/share/mime-info/homebank.keys")
kt = keys_src.read_text(encoding="utf-8")
kt2 = kt.replace("open=homebank %f", "open=/usr/bin/homebank %f")
if "open=/usr/bin/homebank %f" not in kt2:
    raise SystemExit("MIME_KEYS_REWRITE")
keys_dst.write_text(kt2, encoding="utf-8")
Path("$STAGE/pkg/usr/share/mime-info/homebank.mime").write_text(
    Path("$UNPACK/usr/share/mime-info/homebank.mime").read_text(encoding="utf-8"),
    encoding="utf-8")
print("mime_info_rewritten")

app_src = Path("$UNPACK/usr/share/application-registry/homebank.applications")
app_dst = Path("$STAGE/pkg/usr/share/application-registry/homebank.applications")
at = app_src.read_text(encoding="utf-8")
at2 = at.replace("command=homebank", "command=/usr/bin/homebank")
if "command=/usr/bin/homebank" not in at2:
    raise SystemExit("APP_REGISTRY_REWRITE")
app_dst.write_text(at2, encoding="utf-8")
print("application_registry_rewritten")
PY

ln -sf /usr/bin/homebank "$STAGE/pkg/opt/homebank/homebank"
ln -sf homebank "$STAGE/pkg/usr/bin/kemi-homebank"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://homebank.free.fr/
Source: https://launchpad.net/ubuntu/+source/homebank
Homepage: http://homebank.free.fr/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-1
(homebank_5.3.2-1_arm64.deb) plus bundled same-source
homebank-data_5.3.2-1_all.deb, repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 homebank_5.3.2-1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    homebank-data_5.3.2-1_all.deb (Depends: homebank-data
    (>= 5.3.2-1); only focal version is 5.3.2-1).
  * Official Recommends librsvg2-common stays Recommends
    and is not bundled. Versioned Provides: homebank (=
    5.3.2-1) and homebank-data (= 5.3.2-1).
  * Official ELF stays at /usr/bin/homebank (compiled
    /usr/share/homebank). /opt/homebank/* are symlinks.
  * Desktop, man, official 55 .mo (including zh_CN),
    hicolor icons, pixmap, /usr/share/homebank data, mime
    and official HTML help stay on standard paths. Official
    desktop Exec=homebank rewritten to /usr/bin/homebank;
    Icon=homebank. Official Description still mentions GTK2,
    but the focal binary is GTK3. Official changelogs are
    real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:33:35 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
HomeBank ${VER_UP}-1 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source homebank-data.

Official ELF stays at /usr/bin/homebank (compiled
/usr/share/homebank). /opt/homebank/* are symlinks.
Desktop, man, official 55 .mo (including zh_CN),
icons, data and official HTML help remain on standard
paths. Official Description still says GTK2; the
focal binary Depends / DT_NEEDED is GTK3.
Official Recommends librsvg2-common stays Recommends.
Probe: aarch64 · 1 ELF · requiredGlibc 2.29 · no
GLIBCXX; Ubuntu 20.04 / glibc 2.31 OK.
Official publication: Ubuntu 20.04 focal universe arm64
homebank 5.3.2-1 plus homebank-data. Official SHA256 +
size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanzas. No librarian URL this
run.
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
Depends: libc6 (>= 2.29), libcairo2 (>= 1.4.10), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.51.0), libgtk-3-0 (>= 3.21.5), libofx7 (>= 0.9.14), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libsoup2.4-1 (>= 2.41.90)
Recommends: librsvg2-common
Replaces: homebank, homebank-data
Conflicts: homebank, homebank-data
Provides: homebank (= 5.3.2-1), homebank-data (= 5.3.2-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://homebank.free.fr/
Description: Manage your personal accounts at home (arm64)
 HomeBank ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled homebank-data.
 Fast, simple personal accounting (GTK3).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
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
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-homebank-control.txt"
