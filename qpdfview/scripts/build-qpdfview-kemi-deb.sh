#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) qpdfview 0.4.18-1build1 arm64
# plus official arch:all qpdfview-translations and official arm64
# DjVu / PostScript plugins as kemi-qpdfview (bundled).
# Probe: aarch64 · 5 ELF · requiredGlibc 2.17 · requiredGlibcxx 3.4.9
#   (main) / 3.4 (plugins) · Qt5 + CUPS + SyncTeX + Poppler-Qt5
#   (pdf plugin) + (optional) DjVu / libspectre · PASS vs 101 ≤2.31
# Official main Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   Qt 5.12 stack, libpoppler-qt5-1 >= 0.34.0, libcups2, libsynctex2,
#   libgcc-s1, libstdc++6, hicolor-icon-theme, libqt5sql5-sqlite,
#   libqt5svg5).
# Launchpad HTML: qpdfview 0.4.18-1build1 in focal arm64 (universe,
#   Release, Published 2020-03-23 13:23:14 UTC / 2020-03-23 21:23:14
#   Asia/Shanghai). "Copied from ubuntu focal-proposed arm64".
#   Prior 0.4.18-1 was "Superseded on 2020-03-23 by arm64 build of
#   qpdfview 0.4.18-1build1 in ubuntu focal PROPOSED".
# SHA256 + size matched official ports.ubuntu.com pool files and the
#   Ubuntu 20.04 focal universe arm64 Packages stanzas (Aliyun
#   ubuntu-ports mirror of the same index, streamed — not saved as a
#   Packages.gz dump). Launchpad librarian / +files / .buildinfo were
#   retried this run but Launchpad returned 503.
# Layout keeps the official ELF at /usr/bin/qpdfview because the
# binary embeds compiled-in prefixes /usr/lib/qpdfview (plugin
# dir: libqpdfview_{pdf,image,djvu,ps}.so) and /usr/share/qpdfview
# (help + Qt .qm translations). PDF support ships in the main
# official deb as libqpdfview_pdf.so (not a separate package in
# focal). Help, 40 .qm (including zh_CN), 31 help HTML (including
# zh_CN / zh_TW), hicolor svg, desktop, man, metainfo and mime stay
# on those standard paths. /opt/qpdfview/qpdfview is a symlink to
# /usr/bin/qpdfview (KEMI layout marker), not the real ELF.
# Official desktop Exec=qpdfview --unique %F / TryExec=qpdfview /
# Icon=qpdfview (hicolor scalable svg shipped). KEMI desktop uses
# Exec=/usr/bin/qpdfview ... and TryExec=/usr/bin/qpdfview; Icon
# stays qpdfview.
# Official translations include qpdfview_zh_CN.qm and
# help_zh_CN.html / help_zh_TW.html (no zh_TW .qm in this deb).
# DjVu / PS plugins are official Recommends, bundled; their unique
# libs (libdjvulibre21, libspectre1) are Recommends so a PDF-only
# install is not blocked.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-qpdfview
VER_UP='0.4.18'
VER_DEB="${VER_UP}-1build1kemi1"
ARCH=arm64
PKG=kemi-qpdfview
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/qpdfview-0.4.18-1build1-focal-unpack}"
UP_DEB="$DL/qpdfview_0.4.18-1build1_arm64.deb"
TR_DEB="$DL/qpdfview-translations_0.4.18-1build1_all.deb"
DJ_DEB="$DL/qpdfview-djvu-plugin_0.4.18-1build1_arm64.deb"
PS_DEB="$DL/qpdfview-ps-plugin_0.4.18-1build1_arm64.deb"
EXPECT_SHA_MAIN=59f459e6dffc1e9e85be51fe2057f396c9fb73e8af8d0833b84cc548b139e004
EXPECT_BYTES_MAIN=338152
EXPECT_SHA_TR=25382babab7e67d9d1ca4307ade6d3d9ab678c9dbb7d42bd8269725bcb1cff12
EXPECT_BYTES_TR=220988
EXPECT_SHA_DJ=07219c04f2ffd6f678f9f15c25a8495f5d82d53547dba9aeb6164dba6815beb3
EXPECT_BYTES_DJ=24416
EXPECT_SHA_PS=093c14e613459657c6d3263f7a65128bffaa81e0572a2b94d1d83d3eb2d60acb
EXPECT_BYTES_PS=17152
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB" && test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES_MAIN"
echo "$EXPECT_SHA_MAIN  $UP_DEB" | sha256sum -c -
test -f "$TR_DEB" && test "$(stat -c%s "$TR_DEB")" = "$EXPECT_BYTES_TR"
echo "$EXPECT_SHA_TR  $TR_DEB" | sha256sum -c -
test -f "$DJ_DEB" && test "$(stat -c%s "$DJ_DEB")" = "$EXPECT_BYTES_DJ"
echo "$EXPECT_SHA_DJ  $DJ_DEB" | sha256sum -c -
test -f "$PS_DEB" && test "$(stat -c%s "$PS_DEB")" = "$EXPECT_BYTES_PS"
echo "$EXPECT_SHA_PS  $PS_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/qpdfview"
test -f "$UNPACK/usr/lib/qpdfview/libqpdfview_pdf.so"
test -f "$UNPACK/usr/lib/qpdfview/libqpdfview_image.so"
test -f "$UNPACK/usr/lib/qpdfview/libqpdfview_djvu.so"
test -f "$UNPACK/usr/lib/qpdfview/libqpdfview_ps.so"
test -f "$UNPACK/usr/share/applications/qpdfview.desktop"
test -f "$UNPACK/usr/share/man/man1/qpdfview.1.gz"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/qpdfview.svg"
test -f "$UNPACK/usr/share/metainfo/qpdfview.appdata.xml"
test -f "$UNPACK/usr/share/qpdfview/help.html"
test -f "$UNPACK/usr/share/qpdfview/help_zh_CN.html"
test -f "$UNPACK/usr/share/qpdfview/help_zh_TW.html"
test -f "$UNPACK/usr/share/qpdfview/qpdfview_zh_CN.qm"
test -f "$UNPACK/usr/lib/mime/packages/qpdfview"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/qpdfview" \
  "$STAGE/pkg/usr/lib/mime/packages" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/qpdfview" \
  "$STAGE/pkg/opt/qpdfview"

# Official ELF stays at /usr/bin/qpdfview (compiled /usr/lib/qpdfview
# and /usr/share/qpdfview prefixes). Hardlink so packing does not
# double disk use.
cp -al "$UNPACK/usr/bin/qpdfview" "$STAGE/pkg/usr/bin/qpdfview"
chmod 0755 "$STAGE/pkg/usr/bin/qpdfview"
test -x "$STAGE/pkg/usr/bin/qpdfview"
for so in libqpdfview_pdf.so libqpdfview_image.so libqpdfview_djvu.so libqpdfview_ps.so; do
  cp -al "$UNPACK/usr/lib/qpdfview/$so" "$STAGE/pkg/usr/lib/qpdfview/$so"
  chmod 0644 "$STAGE/pkg/usr/lib/qpdfview/$so"
done

# Probe the staged ELFs before packing.
REPORT="$ROOT/probe/kemi-qpdfview.json"
rm -f "$REPORT"
python3 "$PROBE_PY" \
  --elf "$STAGE/pkg/usr/bin/qpdfview" \
  --elf "$STAGE/pkg/usr/lib/qpdfview/libqpdfview_pdf.so" \
  --elf "$STAGE/pkg/usr/lib/qpdfview/libqpdfview_image.so" \
  --elf "$STAGE/pkg/usr/lib/qpdfview/libqpdfview_djvu.so" \
  --elf "$STAGE/pkg/usr/lib/qpdfview/libqpdfview_ps.so" \
  --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files=r.get("files") or []
if len(files) != 5:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by={Path(f["path"]).name: f for f in files}
main=by.get("qpdfview")
if not main or main.get("requiredGlibc") != "2.17" or main.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_MAIN")
if main.get("requiredGlibcxx") != "3.4.9":
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX")
needed=set(main.get("neededLibraries") or [])
for lib in ("libcups.so.2", "libsynctex.so.2", "libQt5PrintSupport.so.5",
            "libQt5Widgets.so.5", "libQt5Gui.so.5", "libQt5Concurrent.so.5",
            "libQt5Sql.so.5", "libQt5DBus.so.5", "libQt5Core.so.5",
            "libpthread.so.0", "libstdc++.so.6", "libgcc_s.so.1", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
pdf=by.get("libqpdfview_pdf.so")
if not pdf or pdf.get("requiredGlibc") != "2.17" or pdf.get("requiredGlibcxx") != "3.4" or pdf.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_PDF")
if "libpoppler-qt5.so.1" not in set(pdf.get("neededLibraries") or []):
    raise SystemExit("PROBE_MISSING_POPPLER")
img=by.get("libqpdfview_image.so")
if not img or img.get("requiredGlibc") != "2.17" or img.get("architecture") != "aarch64":
    raise SystemExit("PROBE_UNEXPECTED_IMAGE")
dj=by.get("libqpdfview_djvu.so")
if not dj or dj.get("requiredGlibc") != "2.17" or "libdjvulibre.so.21" not in set(dj.get("neededLibraries") or []):
    raise SystemExit("PROBE_UNEXPECTED_DJVU")
ps=by.get("libqpdfview_ps.so")
if not ps or ps.get("requiredGlibc") != "2.17" or "libspectre.so.1" not in set(ps.get("neededLibraries") or []):
    raise SystemExit("PROBE_UNEXPECTED_PS")
print("PROBE_PASS requiredGlibc=2.17 requiredGlibcxx=3.4.9 arch=aarch64 n_elf=5")
PY

# Help / translations / icons / metainfo / mime stay on compiled-in paths.
cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/qpdfview.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/qpdfview.svg" 2>/dev/null || {
  mkdir -p "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps"
  cp -a --remove-destination "$UNPACK/usr/share/icons/hicolor/scalable/apps/qpdfview.svg" \
    "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/qpdfview.svg"
}
mkdir -p "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/qpdfview.svg"

mkdir -p "$STAGE/pkg/usr/share/metainfo"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/qpdfview.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/qpdfview.appdata.xml"

cp -a --remove-destination "$UNPACK/usr/lib/mime/packages/qpdfview" \
  "$STAGE/pkg/usr/lib/mime/packages/qpdfview"

# Official help HTML + Qt .qm translations (including zh_CN).
n_qm=0
n_help=0
while IFS= read -r -d '' f; do
  base=$(basename "$f")
  cp -a --remove-destination "$f" "$STAGE/pkg/usr/share/qpdfview/$base"
  case "$base" in
    *.qm) n_qm=$((n_qm+1)) ;;
    help*.html) n_help=$((n_help+1)) ;;
  esac
done < <(find "$UNPACK/usr/share/qpdfview" -maxdepth 1 -type f -print0)
test "$n_qm" -eq 40
test "$n_help" -eq 31
test -f "$STAGE/pkg/usr/share/qpdfview/qpdfview_zh_CN.qm"
test -f "$STAGE/pkg/usr/share/qpdfview/help_zh_CN.html"
test -f "$STAGE/pkg/usr/share/qpdfview/help_zh_TW.html"
test -f "$STAGE/pkg/usr/share/qpdfview/help.html"

cp -a --remove-destination "$UNPACK/usr/share/man/man1/qpdfview.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/qpdfview.1.gz"

# Official desktop Exec=qpdfview ... / TryExec=qpdfview / Icon=qpdfview.
# Rewrite Exec/TryExec to absolute /usr/bin/qpdfview; keep Icon=qpdfview.
sed -e 's|^Exec=qpdfview|Exec=/usr/bin/qpdfview|' \
    -e 's|^TryExec=qpdfview$|TryExec=/usr/bin/qpdfview|' \
    "$UNPACK/usr/share/applications/qpdfview.desktop" \
    > "$STAGE/pkg/usr/share/applications/qpdfview.desktop"
grep -q '^Exec=/usr/bin/qpdfview --unique %F$' "$STAGE/pkg/usr/share/applications/qpdfview.desktop"
grep -q '^TryExec=/usr/bin/qpdfview$' "$STAGE/pkg/usr/share/applications/qpdfview.desktop"
grep -q '^Exec=/usr/bin/qpdfview --unique --choose-instance %F$' "$STAGE/pkg/usr/share/applications/qpdfview.desktop"
grep -q '^Exec=/usr/bin/qpdfview %F$' "$STAGE/pkg/usr/share/applications/qpdfview.desktop"
grep -q '^Icon=qpdfview$' "$STAGE/pkg/usr/share/applications/qpdfview.desktop"

# Upstream docs
if [[ -f "$UNPACK/usr/share/doc/qpdfview/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/qpdfview/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/qpdfview/changelog.Debian.gz" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/qpdfview/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/qpdfview-translations/copyright" ]]; then
  cp -a --remove-destination "$UNPACK/usr/share/doc/qpdfview-translations/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.translations"
fi

ln -sf /usr/bin/qpdfview "$STAGE/pkg/opt/qpdfview/qpdfview"
ln -sf qpdfview "$STAGE/pkg/usr/bin/kemi-qpdfview"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://launchpad.net/qpdfview
Source: https://launchpad.net/ubuntu/+source/qpdfview
Homepage: https://launchpad.net/qpdfview
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-1build1
(qpdfview_0.4.18-1build1_arm64.deb) plus official arch:all
qpdfview-translations_0.4.18-1build1_all.deb and official arm64
qpdfview-djvu-plugin / qpdfview-ps-plugin, repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 qpdfview_0.4.18-1build1_arm64.deb plus
    official qpdfview-translations_0.4.18-1build1_all.deb and
    official arm64 DjVu / PostScript plugins, repackaged for KEMI
    as ${PKG}.
  * Official ELF stays at /usr/bin/qpdfview because the binary
    embeds compiled-in prefixes /usr/lib/qpdfview and
    /usr/share/qpdfview. PDF plugin (libqpdfview_pdf.so) and
    image plugin ship in the official main deb; DjVu / PS plugins
    and translations are bundled. Help, .qm, hicolor icon,
    desktop, man, metainfo and mime stay on those standard paths.
    /opt/qpdfview/qpdfview is a symlink to /usr/bin/qpdfview.
  * Desktop Exec=/usr/bin/qpdfview --unique %F;
    TryExec=/usr/bin/qpdfview; Icon=qpdfview (hicolor scalable
    svg shipped). Official translations include zh_CN .qm and
    zh_CN / zh_TW help.
  * Conflicts/Replaces qpdfview, qpdfview-translations,
    qpdfview-djvu-plugin, qpdfview-ps-plugin, qpdfview-languages.
  * Depends kept for Ubuntu 20.04 (Qt 5.12, Poppler-Qt5, CUPS,
    SyncTeX, libc6 >= 2.17). Plugin-only libs libdjvulibre21 and
    libspectre1 are Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:20:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
qpdfview ${VER_UP}-1build1 — official Ubuntu 20.04 (focal) arm64
plus translations and DjVu / PS plugins, KEMI repack.

The official ELF stays at /usr/bin/qpdfview (compiled prefixes
are /usr/lib/qpdfview and /usr/share/qpdfview).
/opt/qpdfview/qpdfview is a symlink to /usr/bin/qpdfview.
PDF support is libqpdfview_pdf.so in the official main deb
(focal does not split a separate pdf-poppler plugin package).
Help, 40 .qm (including zh_CN), help HTML (including zh_CN /
zh_TW), hicolor icon, desktop, man, metainfo and mime remain
on standard /usr/share and /usr/lib paths.
Official desktop Icon=qpdfview (hicolor scalable svg shipped).
Probe: aarch64 · 5 ELF · requiredGlibc 2.17 · requiredGlibcxx
3.4.9 (main) / 3.4 (plugins) · Qt5 + CUPS + SyncTeX +
Poppler-Qt5; Ubuntu 20.04 / glibc 2.31 OK.
Runtime Depends: libc6 (>= 2.17), libcups2 (>= 1.4.0),
libgcc-s1 (>= 3.0), libpoppler-qt5-1 (>= 0.34.0),
libqt5concurrent5 (>= 5.6.0~rc), libqt5core5a (>= 5.12.2),
libqt5dbus5 (>= 5.0.2), libqt5gui5 (>= 5.7.0) | libqt5gui5-gles (>= 5.7.0),
libqt5printsupport5 (>= 5.0.2), libqt5sql5 (>= 5.0.2),
libqt5sql5-sqlite, libqt5svg5, libqt5widgets5 (>= 5.11.0~rc1),
libqt5xml5 (>= 5.0.2), libstdc++6 (>= 5), libsynctex2,
hicolor-icon-theme.
Recommends: libdjvulibre21 (>= 3.5.27.1), libspectre1 (>= 0.2.3).
Launchpad publication (HTML): qpdfview 0.4.18-1build1 in focal
arm64 (universe, Release, Published 2020-03-23 21:23:14
Asia/Shanghai; copied from ubuntu focal-proposed arm64). The
arm64 binary is the "arm64 build of qpdfview 0.4.18-1build1
in ubuntu focal PROPOSED" published to focal Release.
Official SHA256 + size matched ports.ubuntu.com pool files and
focal universe arm64 Packages stanzas.
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
Depends: hicolor-icon-theme, libqt5sql5-sqlite, libqt5svg5, libc6 (>= 2.17), libcups2 (>= 1.4.0), libgcc-s1 (>= 3.0), libpoppler-qt5-1 (>= 0.34.0), libqt5concurrent5 (>= 5.6.0~rc), libqt5core5a (>= 5.12.2), libqt5dbus5 (>= 5.0.2), libqt5gui5 (>= 5.7.0) | libqt5gui5-gles (>= 5.7.0), libqt5printsupport5 (>= 5.0.2), libqt5sql5 (>= 5.0.2), libqt5widgets5 (>= 5.11.0~rc1), libqt5xml5 (>= 5.0.2), libstdc++6 (>= 5), libsynctex2
Recommends: libdjvulibre21 (>= 3.5.27.1), libspectre1 (>= 0.2.3)
Provides: pdf-viewer, djvu-viewer, postscript-viewer
Conflicts: qpdfview, qpdfview-translations, qpdfview-djvu-plugin, qpdfview-ps-plugin, qpdfview-languages
Replaces: qpdfview, qpdfview-translations, qpdfview-djvu-plugin, qpdfview-ps-plugin, qpdfview-languages
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://launchpad.net/qpdfview
Description: tabbed document viewer (arm64)
 qpdfview ${VER_UP}-1build1 — official Ubuntu 20.04 arm64, KEMI repack.
 Lightweight Qt5 tabbed PDF / document viewer (Poppler).
 Translations and DjVu / PS plugins bundled.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-qpdfview-control.txt"
