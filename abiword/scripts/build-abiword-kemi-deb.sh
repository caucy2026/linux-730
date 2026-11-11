#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) abiword
# 3.0.2-10 arm64 plus:
#   * same-source hard-Depends abiword-common (>= 3.0.2-10,
#     arch:all). Official constraint is >= not =; on focal this
#     is the only abiword-common version (same source, same
#     3.0.2-10). Bundled as the named abiword-common data/UI
#     package (orage-data / geany-common / thunar-data pattern).
#   * official Recommends abiword-plugin-grammar, which itself
#     Depends: abiword (= 3.0.2-10). Remmina-plugin pattern:
#     exact-version Depends cannot later be apt-installed next
#     to an unversioned Provides, so the plugin is bundled.
# Official libabiword-3.0 (>= 3.0.2) is same-source but not an
#   exact-version Depends and is a shared library; it stays a
#   system Depends and is not bundled (probe-only: requiredGlibc
#   2.17, GLIBCXX 3.4.26, within 101 ≤2.31 / ≤3.4.28).
# Official binaries: small /usr/bin/abiword stub linking
#   libabiword-3.0.so, plus 44 in-package plugins under
#   /usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/ and the
#   bundled grammar.so in the same directory.
# Probe of the packaged 46 ELF: aarch64 · stub requiredGlibc
#   2.17 no GLIBCXX; plugins requiredGlibc 2.17 (eml.so has no
#   glibc version-need) · max GLIBCXX 3.4.21 · PASS vs 101.
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404). This round is
#   not based on Launchpad librarian.
# libabiword embeds /usr/share/abiword-3.0,
#   /usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/ and
#   /usr/share/icons. Official stub/plugins stay on official
#   paths; /opt/abiword/* are symlinks. Official desktop
#   Icon=abiword (hicolor icons shipped in the binary package).
# Official language-pack split: these debs ship no gettext .mo.
#   Official UI strings live under
#   /usr/share/abiword-3.0/strings (91 files, including
#   zh-CN.strings). Keep the official tree; do not invent or
#   bundle language-packs, UI, or icons.
# Official abiword and grammar changelog.Debian.gz are
#   dangling symlinks to ../libabiword-3.0/changelog.Debian.gz
#   (lib not bundled). kemi changelog.upstream is copied with
#   cp -L from abiword-common's real changelog; dangling
#   official changelogs are not shipped.
# Official D-Bus service already has Exec=/usr/bin/abiword;
#   left unchanged.
# KEMI version 3.0.2-10kemi1 is 13 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-abiword
VER_UP=3.0.2
VER_DEB="${VER_UP}-10kemi1"
ARCH=arm64
PKG=kemi-abiword
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/abiword-3.0.2-focal-unpack}"
UP_DEB="$DL/abiword_3.0.2-10_arm64.deb"
UP_COMMON="$DL/abiword-common_3.0.2-10_all.deb"
UP_GRAMMAR="$DL/abiword-plugin-grammar_3.0.2-10_arm64.deb"
EXPECT_SHA=eea5ebd1926c5d41a61fab8a29ae6e278c9feee60edf03f55aa2759fd5cdffa6
EXPECT_BYTES=1191868
EXPECT_COMMON_SHA=356a34bcff7da84afd143f6cf2f245e9739191a9ec20c5aa0f28b663a9428b63
EXPECT_COMMON_BYTES=1646040
EXPECT_GRAMMAR_SHA=ab41bd36772993f30ad67d065f732beb69799c1fb30817700aeac43eb63666f3
EXPECT_GRAMMAR_BYTES=17372
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_COMMON"
test -f "$UP_GRAMMAR"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
test "$(stat -c%s "$UP_GRAMMAR")" = "$EXPECT_GRAMMAR_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
echo "$EXPECT_GRAMMAR_SHA  $UP_GRAMMAR" | sha256sum -c -
test -x "$UNPACK/usr/bin/abiword"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/opendocument.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/grammar.so"
test -f "$UNPACK/usr/share/applications/abiword.desktop"
test -f "$UNPACK/usr/share/abiword-3.0/ui/ap_UnixDialog_Annotation.ui"
test -d "$UNPACK/usr/share/abiword-3.0/ui"
test -f "$UNPACK/usr/share/abiword-3.0/strings/zh-CN.strings"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/abiword.png"
test -f "$UNPACK/usr/share/dbus-1/services/org.freedesktop.Telepathy.Client.AbiCollab.service"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/locale"
test -L "$UNPACK/usr/share/doc/abiword/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/abiword-common/changelog.Debian.gz"
# compiled prefix is in system libabiword (not bundled); confirm
# official data/plugin paths the library embeds, via the
# probe-only unpack if present. Process substitution, no SIGPIPE.
LIBSO="$ROOT/probe/libabiword-3.0-unpack/usr/lib/aarch64-linux-gnu/libabiword-3.0.so"
if [[ -f "$LIBSO" ]]; then
  grep -qx '/usr/share/abiword-3.0' < <(strings -n 8 "$LIBSO")
  grep -qx '/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/' < <(strings -n 8 "$LIBSO")
  grep -qx '/usr/share/icons' < <(strings -n 8 "$LIBSO")
fi
grep -q 'libabiword-3.0.so' < <(strings -n 8 "$UNPACK/usr/bin/abiword")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/abiword" \
  "$STAGE/pkg/usr/share/doc/abiword-common" \
  "$STAGE/pkg/usr/share/doc/abiword-plugin-grammar" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/abiword-3.0" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/usr/share/telepathy/clients" \
  "$STAGE/pkg/opt/abiword"

cp -al "$UNPACK/usr/bin/abiword" "$STAGE/pkg/usr/bin/abiword"
chmod 0755 "$STAGE/pkg/usr/bin/abiword"

# official in-package plugins + bundled grammar.so stay on official path
cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/." \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/"
test -f "$STAGE/pkg/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/grammar.so"
test "$(find "$STAGE/pkg/usr/lib/aarch64-linux-gnu/abiword-3.0/plugins" -name '*.so' | wc -l)" = 45

REPORT="$ROOT/probe/kemi-abiword.json"
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
test "${#ELFS[@]}" = 46
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
if len(files) != 46:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
if "abiword" not in by or "grammar.so" not in by or "opendocument.so" not in by:
    raise SystemExit("PROBE_MISSING_CORE")
max_glibc = None
max_cxx = None

def vkey(s):
    return tuple(int(x) for x in s.split("."))

for f in files:
    name = Path(f["path"]).name
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    g = f.get("requiredGlibc")
    c = f.get("requiredGlibcxx")
    if g and (max_glibc is None or vkey(g) > vkey(max_glibc)):
        max_glibc = g
    if c and (max_cxx is None or vkey(c) > vkey(max_cxx)):
        max_cxx = c
    if g and vkey(g) > (2, 31):
        raise SystemExit(f"PROBE_GLIBC_{name}_{g}")
    if c and vkey(c) > (3, 4, 28):
        raise SystemExit(f"PROBE_GLIBCXX_{name}_{c}")
stub = by["abiword"]
if stub.get("requiredGlibc") != "2.17" or stub.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_STUB")
if "libabiword-3.0.so" not in set(stub.get("neededLibraries") or []):
    raise SystemExit("PROBE_STUB_NEEDED")
if max_glibc != "2.17":
    raise SystemExit(f"PROBE_MAX_GLIBC_{max_glibc}")
if max_cxx != "3.4.21":
    raise SystemExit(f"PROBE_MAX_GLIBCXX_{max_cxx}")
print("PROBE_PASS n_elf=46 stub_glibc=2.17 max_glibc=2.17 max_GLIBCXX=3.4.21")
PY

# official data / strings / UI / icons / dbus / telepathy / man
cp -a "$UNPACK/usr/share/abiword-3.0/." "$STAGE/pkg/usr/share/abiword-3.0/"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/abiword.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/abiword.1.gz"
cp -a --remove-destination \
  "$UNPACK/usr/share/dbus-1/services/org.freedesktop.Telepathy.Client.AbiCollab.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.freedesktop.Telepathy.Client.AbiCollab.service"
cp -a --remove-destination \
  "$UNPACK/usr/share/telepathy/clients/AbiCollab.client" \
  "$STAGE/pkg/usr/share/telepathy/clients/AbiCollab.client"
if [[ -d "$UNPACK/usr/share/lintian/overrides" ]]; then
  mkdir -p "$STAGE/pkg/usr/share/lintian/overrides"
  cp -a "$UNPACK/usr/share/lintian/overrides/." "$STAGE/pkg/usr/share/lintian/overrides/"
fi
# official docs: skip dangling changelog symlinks to libabiword-3.0
python3 - << PY
import os
from pathlib import Path
src_root = Path("$UNPACK/usr/share/doc")
dst_root = Path("$STAGE/pkg/usr/share/doc")
for pkg in ("abiword", "abiword-common", "abiword-plugin-grammar"):
    src = src_root / pkg
    dst = dst_root / pkg
    dst.mkdir(parents=True, exist_ok=True)
    if not src.exists():
        continue
    for p in src.iterdir():
        if p.is_symlink() and p.name.startswith("changelog"):
            continue
        os.system(f'cp -a --remove-destination "{p}" "{dst / p.name}"')
PY
test ! -e "$STAGE/pkg/usr/share/doc/abiword/changelog.Debian.gz" || \
  test ! -L "$STAGE/pkg/usr/share/doc/abiword/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/abiword-common/changelog.Debian.gz"
test ! -L "$STAGE/pkg/usr/share/doc/abiword-common/changelog.Debian.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg/usr/share/abiword-3.0/strings" -name '*.strings' | wc -l)" = 91
test -f "$STAGE/pkg/usr/share/abiword-3.0/strings/zh-CN.strings"
test -d "$STAGE/pkg/usr/share/abiword-3.0/ui"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/abiword.png"
test ! -d "$STAGE/pkg/usr/share/locale"
grep -qx 'Exec=/usr/bin/abiword' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.freedesktop.Telepathy.Client.AbiCollab.service"

# kemi changelog from official abiword-common changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/abiword-common/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/abiword-common/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/abiword.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/abiword.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=abiword(\s.*)?$", r"Exec=/usr/bin/abiword\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=abiword$", "TryExec=/usr/bin/abiword", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/abiword(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/abiword", text2, count=1, flags=re.M)
if re.search(r"^Exec=abiword(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/abiword %U" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/abiword" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=abiword$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=AbiWord" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/abiword "$STAGE/pkg/opt/abiword/abiword"
ln -sf abiword "$STAGE/pkg/usr/bin/kemi-abiword"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.abisource.com/
Source: https://launchpad.net/ubuntu/+source/abiword
Homepage: http://www.abisource.com/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(abiword_3.0.2-10_arm64.deb + bundled same-source
abiword-common_3.0.2-10_all.deb + official Recommends
abiword-plugin-grammar_3.0.2-10_arm64.deb, which Depends
abiword (= 3.0.2-10)) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 abiword_3.0.2-10_arm64.deb
    (focal universe; no newer package in focal-updates)
    plus same-source hard-Depends abiword-common
    (>= 3.0.2-10, arch:all; only focal version is 3.0.2-10)
    and official Recommends abiword-plugin-grammar
    (Depends: abiword (= 3.0.2-10); Remmina-plugin pattern)
    bundled for KEMI as ${PKG}.
  * Official stub stays at /usr/bin/abiword; 45 plugins stay
    under /usr/lib/aarch64-linux-gnu/abiword-3.0/plugins/.
    /opt/abiword/* are symlinks. libabiword-3.0 is not
    bundled (system Depends).
  * Official data, 91 string files (including zh-CN.strings),
    UI, icons, man, D-Bus and Telepathy files stay on
    standard paths. No official gettext .mo; official
    language-pack split is kept (do not invent language-packs).
    Desktop Exec=abiword rewritten to /usr/bin/abiword;
    Icon=abiword (icons shipped). Official D-Bus Exec already
    absolute and left unchanged.
  * Official abiword/grammar changelog.Debian.gz were dangling
    symlinks to libabiword-3.0; kemi changelog.upstream is
    copied with cp -L from abiword-common.
  * Conflicts/Replaces/Provides abiword, abiword-common and
    abiword-plugin-grammar. Official Depends kept for Ubuntu
    20.04 except bundled common/grammar (libabiword-3.0,
    liblink-grammar5, GTK3, libc6 >= 2.17). Official
    Recommends aspell-en | aspell-dictionary, fonts-liberation
    and poppler-utils kept as Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:50:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
AbiWord ${VER_UP}-10 — official Ubuntu 20.04 (focal)
universe arm64, KEMI repack, with bundled official
abiword-common and abiword-plugin-grammar.

Official stub stays at /usr/bin/abiword; plugins stay
on the official /usr/lib path. /opt/abiword/* are
symlinks. libabiword-3.0 stays a system Depends.
Desktop, man, official strings (91 files including
zh-CN.strings; no gettext .mo), UI, icons, D-Bus and
Telepathy files remain on standard paths.
Official desktop Icon=abiword (hicolor icons shipped).
Official language-pack split: these debs ship no .mo.
Probe: aarch64 · 46 ELF · stub requiredGlibc 2.17 no
GLIBCXX; packaged plugins max GLIBCXX 3.4.21;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled abiword-common
and abiword-plugin-grammar (libabiword-3.0,
liblink-grammar5, GTK3, libc6 >= 2.17). Official
Recommends (except the bundled grammar plugin) kept
as Recommends.
Official publication: Ubuntu 20.04 focal universe arm64
abiword 3.0.2-10 + arch:all abiword-common + arm64
abiword-plugin-grammar. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: editors
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gsfonts, libabiword-3.0 (>= 3.0.2), libc6 (>= 2.17), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.78), libgcc-s1 (>= 3.0), libgcrypt20 (>= 1.8.0), libglib2.0-0 (>= 2.16.0), libgnutls30 (>= 3.6.6), libgoffice-0.10-10 (>= 0.10.2), libgsf-1-114 (>= 1.14.9), libgtk-3-0 (>= 3.0.0), libjpeg8 (>= 8c), liblink-grammar5 (>= 5.7.0), libloudmouth1-0 (>= 1.3.3), libots0 (>= 0.5.0), libpng16-16 (>= 1.6.2-1), librdf0 (>= 1.0.17), libreadline8 (>= 6.0), librevenge-0.0-0, libsoup2.4-1 (>= 2.4.0), libstdc++6 (>= 5.2), libtelepathy-glib0 (>= 0.13.0), libtidy5deb1 (>= 1:5.2.0), libwmf0.2-7 (>= 0.2.8.4), libwpd-0.10-10, libwpg-0.3-3, libxml2 (>= 2.7.4), zlib1g (>= 1:1.1.4)
Recommends: aspell-en | aspell-dictionary, fonts-liberation, poppler-utils
Provides: abiword, abiword-common, abiword-plugin-grammar
Conflicts: abiword, abiword-common, abiword-plugin-grammar
Replaces: abiword, abiword-common, abiword-plugin-grammar
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.abisource.com/
Description: efficient word processor (arm64)
 AbiWord ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official abiword-common and
 abiword-plugin-grammar.
 A full-featured, efficient word processing application.
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
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-abiword-control.txt"
