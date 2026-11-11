#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) dia
# 0.97.3+git20160930-9 arm64 as kemi-dia, bundling same-source
# exact-version hard Depends dia-common (= 0.97.3+git20160930-9)
# (orage-data / gnumeric-common / shotwell-common / pidgin-data
# pattern).
# Official Recommends gsfonts-x11 (different source) and
# dia-shapes (different source, Depends: dia unversioned, not
# exact) stay Recommends and are not bundled. Different-source
# dia-rib-network (source gnomediaicons, Depends: dia
# unversioned, not a Recommends) is not bundled. Versioned
# Provides: dia (= 0.97.3+git20160930-9) and
# dia-common (= 0.97.3+git20160930-9) let later apt-install
# of dia-shapes work.
# Official binary: /usr/bin/dia plus official plugins and
# libdia.so under /usr/lib/aarch64-linux-gnu/dia/. The ELF
# embeds /usr/lib/aarch64-linux-gnu/dia, /usr/share/dia,
# /usr/share/locale and /usr/share/doc/dia/html, so official
# files stay on official paths; /opt/dia/* are symlinks
# (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/
# GNOME Disks/GNOME System Monitor/GParted/Seahorse/Remmina/
# dconf-editor/xfce4-terminal/thunar/pcmanfm/geany/filezilla/
# blueman/audacious/abiword/shotwell/gnumeric/claws-mail/pidgin).
# Official dia-common ships 66 .mo including zh_CN, hicolor
# icons, /usr/share/dia (shapes, sheets, ui, xslt, samples),
# XML DTDs, man, mime-info, thumbnailer, doc-base and official
# HTML/PDF manuals under /usr/share/doc/dia/. Keep the official
# tree; do not invent/bundle language-packs or extra UI/icons.
# No /usr/share/help directory in these official debs (help
# lives under /usr/share/doc/dia/html).
# Official changelogs are real files (not dangling). Official
# dia-common xml-catalog maintainer scripts are kept and
# retargeted from --package dia-common to --package kemi-dia.
# Official dia preinst (remove historical alternatives) is kept.
# Probe: aarch64 · 36 packaged ELF · most requiredGlibc 2.17 ·
#   /usr/bin/dia and libcairo_filter.so requiredGlibc 2.29 ·
#   no GLIBCXX · PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# KEMI version 0.97.3+git20160930-9kemi1 is 25 chars (under
#   the mall version_name limit that rejected Remmina's
#   33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-dia
VER_UP=0.97.3+git20160930
VER_DEB="${VER_UP}-9kemi1"
ARCH=arm64
PKG=kemi-dia
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/dia-0.97.3-focal-unpack}"
DATA_UNPACK="${DATA_UNPACK:-$ROOT/probe/dia-common-0.97.3-focal-unpack}"
UP_DEB="$DL/dia_0.97.3+git20160930-9_arm64.deb"
DATA_DEB="$DL/dia-common_0.97.3+git20160930-9_all.deb"
EXPECT_SHA=bee1791eaae700523932da8ae3ef63f6cffff3c53cd2808991aa97d72de48396
EXPECT_BYTES=804100
EXPECT_DATA_SHA=f9bc80ab8051ee32e63442952ac404bb0ca12ceeee33fe9e80c7676a820e3297
EXPECT_DATA_BYTES=7159412
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$DATA_DEB"
test "$(stat -c%s "$DATA_DEB")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/dia"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/dia/libdia.so"
test -f "$DATA_UNPACK/usr/share/applications/dia.desktop"
test -f "$DATA_UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/dia.mo"
test "$(find "$DATA_UNPACK" -name '*.mo' | wc -l)" = 66
test -f "$DATA_UNPACK/usr/share/icons/hicolor/48x48/apps/dia.png"
test -d "$DATA_UNPACK/usr/share/dia/ui"
test -d "$DATA_UNPACK/usr/share/dia/shapes"
test -f "$DATA_UNPACK/usr/share/xml/dia/diagram.dtd"
test -f "$DATA_UNPACK/usr/share/man/man1/dia.1.gz"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/dia/changelog.Debian.gz"
test ! -L "$DATA_UNPACK/usr/share/doc/dia-common/changelog.Debian.gz"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/dia")
grep -qx '/usr/lib/aarch64-linux-gnu/dia' < <(strings -n 8 "$UNPACK/usr/bin/dia")
grep -qx '/usr/share/dia' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/dia/libdia.so")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/dia/libdia.so")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/dia" \
  "$STAGE/pkg/usr/lib/mime/packages" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/dia" \
  "$STAGE/pkg/usr/share/doc/dia-common" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/dia" \
  "$STAGE/pkg/usr/share/xml/dia" \
  "$STAGE/pkg/usr/share/mime-info" \
  "$STAGE/pkg/usr/share/thumbnailers" \
  "$STAGE/pkg/usr/share/doc-base" \
  "$STAGE/pkg/usr/share/lintian/overrides" \
  "$STAGE/pkg/opt/dia"

cp -al "$UNPACK/usr/bin/dia" "$STAGE/pkg/usr/bin/dia"
chmod 0755 "$STAGE/pkg/usr/bin/dia"
cp -a "$UNPACK/usr/lib/aarch64-linux-gnu/dia/." "$STAGE/pkg/usr/lib/aarch64-linux-gnu/dia/"

REPORT="$ROOT/probe/kemi-dia.json"
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
test "${#ELFS[@]}" = 36
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
if len(files) != 36:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by = {Path(f["path"]).name: f for f in files}
if "dia" not in by or "libdia.so" not in by:
    raise SystemExit("PROBE_MISSING_MAIN")
for name, f in by.items():
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH:{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX:{name}")
    glibc = f.get("requiredGlibc")
    if glibc not in ("2.17", "2.29"):
        raise SystemExit(f"PROBE_GLIBC:{name}:{glibc}")
if by["dia"].get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_MAIN_GLIBC")
if by["libcairo_filter.so"].get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_CAIRO_GLIBC")
if by["libdia.so"].get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_LIBDIA_GLIBC")
needed = set(by["dia"].get("neededLibraries") or [])
for lib in ("libdia.so", "libgtk-x11-2.0.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=36 main_glibc=2.29 cairo_filter=2.29 libdia=2.17 noGLIBCXX arch=aarch64")
PY

# official data and docs — keep official trees
cp -a "$DATA_UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$DATA_UNPACK/usr/share/icons/." "$STAGE/pkg/usr/share/icons/"
cp -a "$DATA_UNPACK/usr/share/dia/." "$STAGE/pkg/usr/share/dia/"
cp -a "$DATA_UNPACK/usr/share/xml/dia/." "$STAGE/pkg/usr/share/xml/dia/"
cp -a "$DATA_UNPACK/usr/share/doc/dia/." "$STAGE/pkg/usr/share/doc/dia/"
cp -a "$UNPACK/usr/share/doc/dia/." "$STAGE/pkg/usr/share/doc/dia/"
cp -a "$DATA_UNPACK/usr/share/doc/dia-common/." "$STAGE/pkg/usr/share/doc/dia-common/"
if [[ -d "$DATA_UNPACK/usr/share/man/fr" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/man/fr/man1"
  cp -a "$DATA_UNPACK/usr/share/man/fr/." "$STAGE/pkg/usr/share/man/fr/"
fi
cp -a --remove-destination "$DATA_UNPACK/usr/share/man/man1/dia.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/dia.1.gz"
cp -a --remove-destination "$DATA_UNPACK/usr/share/doc-base/dia-manual" \
  "$STAGE/pkg/usr/share/doc-base/dia-manual"
# lintian overrides retargeted
python3 - << PY
from pathlib import Path
src = Path("$UNPACK/usr/share/lintian/overrides/dia")
dst = Path("$STAGE/pkg/usr/share/lintian/overrides/kemi-dia")
text = src.read_text(encoding="utf-8")
text2 = text.replace("dia:", "kemi-dia:")
dst.write_text(text2, encoding="utf-8")
src2 = Path("$DATA_UNPACK/usr/share/lintian/overrides/dia-common")
# bundled: command now lives in the same package; still ship a
# retargeted official override rather than invent a new one
dst2 = Path("$STAGE/pkg/usr/share/lintian/overrides/kemi-dia-common")
t = src2.read_text(encoding="utf-8").replace("dia-common:", "kemi-dia:")
dst2.write_text(t, encoding="utf-8")
print("lintian_overrides_rewritten")
PY
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 66
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/dia.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/dia.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/dia.svg"
test -f "$STAGE/pkg/usr/share/dia/ui/toolbox-ui.xml"
test -f "$STAGE/pkg/usr/share/xml/dia/diagram.dtd"
test -f "$STAGE/pkg/usr/share/doc/dia/html/en/index.html"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/dia/libdia.so"
test ! -d "$STAGE/pkg/usr/share/help"

cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/dia-common/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/dia-common/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

# desktop
src = Path("$DATA_UNPACK/usr/share/applications/dia.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/dia.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=dia(\s.*)?$", r"Exec=/usr/bin/dia\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=dia$", "TryExec=/usr/bin/dia", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/dia(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/dia", text2, count=1, flags=re.M)
if re.search(r"^Exec=dia(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/dia %F", "TryExec=/usr/bin/dia"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=dia$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Dia" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)

# thumbnailer
th_src = Path("$DATA_UNPACK/usr/share/thumbnailers/dia.thumbnailer")
th_dst = Path("$STAGE/pkg/usr/share/thumbnailers/dia.thumbnailer")
th = th_src.read_text(encoding="utf-8")
th2 = re.sub(r"^TryExec=dia$", "TryExec=/usr/bin/dia", th, flags=re.M)
th2 = re.sub(r"^Exec=dia(\s.*)?$", r"Exec=/usr/bin/dia\1", th2, flags=re.M)
if "TryExec=/usr/bin/dia" not in th2 or "Exec=/usr/bin/dia -t png" not in th2:
    raise SystemExit("THUMBNAILER_REWRITE")
if re.search(r"^(Exec|TryExec)=dia(\s|$)", th2, flags=re.M):
    raise SystemExit("THUMBNAILER_LEFTOVER")
th_dst.write_text(th2, encoding="utf-8")
print("thumbnailer_rewritten")

# mailcap mime package
mime_src = Path("$UNPACK/usr/lib/mime/packages/dia")
mime_dst = Path("$STAGE/pkg/usr/lib/mime/packages/dia")
mt = mime_src.read_text(encoding="utf-8")
mt2 = mt.replace("; dia '%s';", "; /usr/bin/dia '%s';")
if "/usr/bin/dia '%s'" not in mt2:
    raise SystemExit("MIME_PACKAGE_REWRITE")
mime_dst.write_text(mt2, encoding="utf-8")
print("mime_package_rewritten")

# gnome mime-info keys
keys_src = Path("$DATA_UNPACK/usr/share/mime-info/dia.keys")
keys_dst = Path("$STAGE/pkg/usr/share/mime-info/dia.keys")
kt = keys_src.read_text(encoding="utf-8")
kt2 = kt.replace("open=dia %f", "open=/usr/bin/dia %f").replace("view=dia %f", "view=/usr/bin/dia %f")
if "open=/usr/bin/dia %f" not in kt2 or "view=/usr/bin/dia %f" not in kt2:
    raise SystemExit("MIME_KEYS_REWRITE")
keys_dst.write_text(kt2, encoding="utf-8")
# mime types file is path-free
mime2_src = Path("$DATA_UNPACK/usr/share/mime-info/dia.mime")
mime2_dst = Path("$STAGE/pkg/usr/share/mime-info/dia.mime")
mime2_dst.write_text(mime2_src.read_text(encoding="utf-8"), encoding="utf-8")
print("mime_info_rewritten")
PY

ln -sf /usr/bin/dia "$STAGE/pkg/opt/dia/dia"
ln -sf dia "$STAGE/pkg/usr/bin/kemi-dia"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Dia/
Source: https://launchpad.net/ubuntu/+source/dia
Homepage: https://wiki.gnome.org/Apps/Dia/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-9
(dia_0.97.3+git20160930-9_arm64.deb) plus bundled same-source
exact-version dia-common_0.97.3+git20160930-9_all.deb,
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 dia_0.97.3+git20160930-9_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    exact-version hard Depends dia-common
    (= 0.97.3+git20160930-9).
  * Official Recommends gsfonts-x11 and dia-shapes (different
    source, Depends: dia unversioned) stay Recommends and are
    not bundled. dia-rib-network is a different source and is
    not bundled. Versioned Provides: dia (=
    0.97.3+git20160930-9) and dia-common (=
    0.97.3+git20160930-9).
  * Official ELF stays at /usr/bin/dia and official plugins
    plus libdia.so stay under /usr/lib/aarch64-linux-gnu/dia/
    (compiled /usr prefix: /usr/lib/aarch64-linux-gnu/dia,
    /usr/share/dia, /usr/share/locale, /usr/share/doc/dia/html).
    /opt/dia/* are symlinks.
  * Desktop, man, official 66 .mo (including zh_CN), hicolor
    icons, /usr/share/dia data, XML DTDs, mime, thumbnailer,
    doc-base and official HTML/PDF manuals stay on standard
    paths. Official desktop Exec=dia rewritten to /usr/bin/dia;
    Icon=dia. Official xml-catalog scripts retargeted to
    package kemi-dia. Official preinst historical-alternatives
    cleanup kept. Official changelogs are real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:26:10 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Dia ${VER_UP}-9 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source exact-version dia-common.

Official ELF stays at /usr/bin/dia and official plugins
plus libdia.so stay under /usr/lib/aarch64-linux-gnu/dia/
(compiled /usr prefix). /opt/dia/* are symlinks.
Desktop, man, official 66 .mo (including zh_CN), icons,
/usr/share/dia data, XML DTDs, mime, thumbnailer and
official manuals remain on standard paths.
Official Recommends gsfonts-x11 / dia-shapes stay
Recommends (dia-shapes is a different source with
unversioned Depends).
Probe: aarch64 · 36 packaged ELF · most requiredGlibc
2.17 · /usr/bin/dia and libcairo_filter.so requiredGlibc
2.29 · no GLIBCXX; Ubuntu 20.04 / glibc 2.31 OK.
Official publication: Ubuntu 20.04 focal universe arm64
dia 0.97.3+git20160930-9 plus dia-common. Official SHA256
+ size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: graphics
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libart-2.0-2 (>= 2.3.19), libc6 (>= 2.29), libcairo2 (>= 1.12.0), libfreetype6 (>= 2.2.1), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk2.0-0 (>= 2.24.0), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libpangoft2-1.0-0 (>= 1.14.0), libpng16-16 (>= 1.6.2-1), libxml2 (>= 2.7.4), libxslt1.1 (>= 1.1.25), zlib1g (>= 1:1.1.4), xml-core (>= 0.14)
Recommends: gsfonts-x11, dia-shapes
Breaks: dia-libs (<< 0.97.3+git20160904-1~)
Replaces: dia, dia-common, dia-libs (<< 0.97.3+git20160904-1~)
Conflicts: dia, dia-common
Provides: dia (= 0.97.3+git20160930-9), dia-common (= 0.97.3+git20160930-9)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Dia/
Description: Diagram editor (arm64)
 Dia ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled dia-common.
 Editor for diagrams, graphs and charts (UML, ER,
 network and more).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official dia preinst: drop historical alternatives
cat > "$STAGE/pkg/DEBIAN/preinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-alternatives >/dev/null 2>&1; then
  update-alternatives --remove dia /usr/bin/dia-normal || true
  update-alternatives --remove dia /usr/bin/dia-normal-integrated || true
  update-alternatives --remove dia /usr/bin/dia-gnome || true
  update-alternatives --remove dia /usr/bin/dia-gnome-integrated || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/preinst"

# official dia-common xml catalogs, retargeted to kemi-dia
cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
  if command -v update-xmlcatalog >/dev/null 2>&1; then
    update-xmlcatalog --sort --add --type system --id "http://www.lysator.liu.se/~alla/dia/" --package kemi-dia --local /usr/share/xml/dia/diagram.dtd
    update-xmlcatalog --sort --add --type system --id "http://www.lysator.liu.se/~alla/dia/dia-sheet-ns" --package kemi-dia --local /usr/share/xml/dia/sheet.dtd
    update-xmlcatalog --sort --add --type system --id "http://www.daa.com.au/~james/dia-shape-ns" --package kemi-dia --local /usr/share/xml/dia/shape.dtd
    update-xmlcatalog --sort --add --type system --id "http://www.lysator.liu.se/~alla/dia/" --package kemi-dia --root
    update-xmlcatalog --sort --add --type system --id "http://www.lysator.liu.se/~alla/dia/dia-sheet-ns" --package kemi-dia --root
    update-xmlcatalog --sort --add --type system --id "http://www.daa.com.au/~james/dia-shape-ns" --package kemi-dia --root
  fi
fi
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

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "remove" ] || [ "$1" = "upgrade" ]; then
  if command -v update-xmlcatalog >/dev/null 2>&1; then
    update-xmlcatalog --del --type system --id "http://www.lysator.liu.se/~alla/dia/" --root || true
    update-xmlcatalog --del --type system --id "http://www.lysator.liu.se/~alla/dia/dia-sheet-ns" --root || true
    update-xmlcatalog --del --type system --id "http://www.daa.com.au/~james/dia-shape-ns" --root || true
    update-xmlcatalog --del --type system --id "http://www.lysator.liu.se/~alla/dia/" --package kemi-dia || true
    update-xmlcatalog --del --type system --id "http://www.lysator.liu.se/~alla/dia/dia-sheet-ns" --package kemi-dia || true
    update-xmlcatalog --del --type system --id "http://www.daa.com.au/~james/dia-shape-ns" --package kemi-dia || true
  fi
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "purge" ]; then
  rm -f /etc/xml/kemi-dia.xml /etc/xml/kemi-dia.xml.old
fi
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-dia-control.txt"
