#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) audacious
# 3.10.1-1build1 arm64 plus same-source exact-version hard-Depends
# libaudcore5 (= 3.10.1-1build1) as kemi-audacious
# (thunar-data / geany-common / remmina-common / filezilla-common
# pattern applied to the exact-version same-source library).
# There is no audacious-data package. Official audacious-plugins
# is a different source and Depends: audacious-plugins (>= 3.10.1),
# not audacious-plugins (= exact); it is not bundled and stays a
# system Depends. Official same-source libaudgui5 / libaudtag3
# and audacious-dev are not Depends of audacious and are not
# bundled (plugins can later apt-install them). Official
# Recommends (unzip) stay Recommends. Different-source
# pidgin-audacious is not bundled.
# Official binaries: /usr/bin/audacious and /usr/bin/audtool;
# bundled libaudcore.so.5.1.0 stays at official
# /usr/lib/aarch64-linux-gnu/. libaudcore embeds compiled
# /usr/bin, /usr/lib/aarch64-linux-gnu/audacious (plugin dir),
# /usr/share/audacious, /usr/share/locale and the official
# desktop/icon paths, so official ELF/lib stay on official
# paths; /opt/audacious/* are symlinks.
# Probe: aarch64 · 3 ELF · audacious/audtool requiredGlibc 2.17
#   no GLIBCXX; libaudcore requiredGlibc 2.27 · GLIBCXX 3.4 ·
#   PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror, streamed). No newer
#   package in focal-updates. No librarian URL and no .buildinfo
#   is recorded this run (pool 404). This round is not based on
#   Launchpad librarian.
# Official language-pack split does not apply: this deb ships
#   45 .mo including zh_CN. Keep the official tree; do not
#   invent/bundle language-packs or UI/icons. Official share
#   data is AUTHORS/COPYING under /usr/share/audacious; skins
#   and codec UI live in audacious-plugins (system Depends).
#   Official desktop Icon=audacious (hicolor 48x48 PNG + SVG
#   and pixmaps shipped). No /usr/share/help and no conffiles.
# Official audacious changelog.Debian.gz is a symlink to
#   libaudcore5; packaged kemi changelog is dereferenced
#   (cp -L) from the libaudcore5 changelog.
# KEMI version 3.10.1-1build1kemi1 is 19 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string;
#   filezilla 3.46.3-1ubuntu0.1kemi1 was 22 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-audacious
VER_UP=3.10.1
VER_DEB="${VER_UP}-1build1kemi1"
ARCH=arm64
PKG=kemi-audacious
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/audacious-3.10.1-focal-unpack}"
UP_DEB="$DL/audacious_3.10.1-1build1_arm64.deb"
UP_LIB="$DL/libaudcore5_3.10.1-1build1_arm64.deb"
EXPECT_SHA=702cf6121886329cc1ee8bb804a4fd09797b83bba87165bee6c706f6e4799f68
EXPECT_BYTES=198456
EXPECT_LIB_SHA=0e621f0afad0c140a38f96e8453363043e22a61406a75cfea8969279db08016e
EXPECT_LIB_BYTES=119804
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_LIB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_LIB")" = "$EXPECT_LIB_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_LIB_SHA  $UP_LIB" | sha256sum -c -
test -x "$UNPACK/usr/bin/audacious"
test -x "$UNPACK/usr/bin/audtool"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5"
test -f "$UNPACK/usr/share/applications/audacious.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/audacious.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/audacious.mo"
test -f "$UNPACK/usr/share/audacious/AUTHORS"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 45
test ! -d "$UNPACK/usr/share/help"
# compiled prefix — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0")
grep -qx '/usr/share/audacious' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0")
grep -qx '/usr/lib/aarch64-linux-gnu/audacious' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0")
grep -qx '/usr/bin' < <(strings -n 8 "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0")
# official audacious changelog is a symlink to libaudcore5
test -L "$UNPACK/usr/share/doc/audacious/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/libaudcore5/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/libaudcore5/changelog.Debian.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/audacious" \
  "$STAGE/pkg/usr/share/doc/libaudcore5" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/audacious" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/opt/audacious"

cp -al "$UNPACK/usr/bin/audacious" "$STAGE/pkg/usr/bin/audacious"
cp -al "$UNPACK/usr/bin/audtool" "$STAGE/pkg/usr/bin/audtool"
chmod 0755 "$STAGE/pkg/usr/bin/audacious" "$STAGE/pkg/usr/bin/audtool"

cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libaudcore.so.5.1.0"
ln -s libaudcore.so.5.1.0 "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libaudcore.so.5"

REPORT="$ROOT/probe/kemi-audacious.json"
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
test "${#ELFS[@]}" = 3
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
if len(files) != 3:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
for name in ("audacious", "audtool", "libaudcore.so.5.1.0"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
for name in ("audacious", "audtool"):
    f = by[name]
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
if "libaudcore.so.5" not in set(by["audacious"].get("neededLibraries") or []):
    raise SystemExit("PROBE_AUDACIOUS_NEEDED")
lib = by["libaudcore.so.5.1.0"]
if lib.get("requiredGlibc") != "2.27":
    raise SystemExit("PROBE_LIB_GLIBC")
# official probe reports GLIBCXX 3.4 (base), within 101 ≤3.4.28
cxx = lib.get("requiredGlibcxx")
if cxx not in ("3.4", "3.4.0"):
    raise SystemExit(f"PROBE_LIB_GLIBCXX {cxx}")
needed = set(lib.get("neededLibraries") or [])
for n in ("libglib-2.0.so.0", "libstdc++.so.6", "libc.so.6"):
    if n not in needed:
        raise SystemExit(f"PROBE_MISSING_{n}")
print("PROBE_PASS n_elf=3 audacious_glibc=2.17 libaudcore_glibc=2.27 GLIBCXX=3.4")
PY

cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/audacious/." "$STAGE/pkg/usr/share/audacious/"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a "$UNPACK/usr/share/pixmaps/." "$STAGE/pkg/usr/share/pixmaps/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/audacious.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/audacious.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/audtool.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/audtool.1.gz"
# official docs: keep libaudcore5 changelog/copyright; dereference audacious changelog
cp --remove-destination -L "$UNPACK/usr/share/doc/libaudcore5/copyright" \
  "$STAGE/pkg/usr/share/doc/libaudcore5/copyright"
cp --remove-destination -L "$UNPACK/usr/share/doc/libaudcore5/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/libaudcore5/changelog.Debian.gz"
cp --remove-destination -L "$UNPACK/usr/share/doc/audacious/copyright" \
  "$STAGE/pkg/usr/share/doc/audacious/copyright"
ln -s ../libaudcore5/changelog.Debian.gz \
  "$STAGE/pkg/usr/share/doc/audacious/changelog.Debian.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 45
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/audacious.mo"
test -f "$STAGE/pkg/usr/share/audacious/AUTHORS"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/audacious.png"
test ! -d "$STAGE/pkg/usr/share/help"

# kemi changelog from official libaudcore5 changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/libaudcore5/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/libaudcore5/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -s "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/audacious.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/audacious.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=audacious(\s.*)?$", r"Exec=/usr/bin/audacious\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=audacious$", "TryExec=/usr/bin/audacious", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/audacious(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/audacious", text2, count=1, flags=re.M)
if re.search(r"^Exec=audacious(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/audacious %U" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/audacious" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=audacious$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Audacious" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/audacious "$STAGE/pkg/opt/audacious/audacious"
ln -sf audacious "$STAGE/pkg/usr/bin/kemi-audacious"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.audacious-media-player.org/
Source: https://launchpad.net/ubuntu/+source/audacious
Homepage: http://www.audacious-media-player.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(audacious_3.10.1-1build1_arm64.deb + bundled same-source
libaudcore5_3.10.1-1build1_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 audacious_3.10.1-1build1_arm64.deb
    (focal universe; no newer package in focal-updates) plus
    same-source exact-version hard-Depends libaudcore5
    (= 3.10.1-1build1) bundled for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/audacious and audtool;
    libaudcore stays under /usr/lib/aarch64-linux-gnu/.
    /opt/audacious/* are symlinks.
  * Official data, 45 .mo (including zh_CN), icons, pixmaps,
    man and AUTHORS/COPYING stay on standard paths. Desktop
    Exec=audacious rewritten to /usr/bin/audacious; Icon=audacious
    (icons shipped). No official UI/skins in this package
    (they live in different-source audacious-plugins).
  * Conflicts/Replaces/Provides audacious and libaudcore5.
    Official Depends kept for Ubuntu 20.04 except bundled
    libaudcore5 (audacious-plugins >= 3.10.1, dbus, GTK2
    engines, libc6 >= 2.17). Official Recommends unzip kept
    as Recommends. Different-source audacious-plugins is not
    bundled (Depends is >=, not exact version).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:45:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Audacious ${VER_UP}-1build1 — official Ubuntu 20.04 (focal)
universe arm64, KEMI repack, with bundled official
libaudcore5.

Official ELF stays at /usr/bin/audacious and audtool;
libaudcore stays on the official /usr/lib path.
/opt/audacious/* are symlinks.
Desktop, man, official locales, AUTHORS/COPYING, icons
and pixmaps remain on standard paths.
Official desktop Icon=audacious (hicolor 48x48 PNG + SVG
and pixmaps shipped).
Official language-pack split does not apply: this
package ships 45 .mo including zh_CN.
Probe: aarch64 · 3 ELF · audacious/audtool requiredGlibc
2.17 no GLIBCXX; libaudcore requiredGlibc 2.27 ·
GLIBCXX 3.4; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled libaudcore5
(audacious-plugins >= 3.10.1, dbus, GTK2 engines,
libc6 >= 2.17). Official Recommends unzip kept as
Recommends. audacious-plugins is a different source
and is not bundled.
Official publication: Ubuntu 20.04 focal universe arm64
audacious 3.10.1-1build1 + libaudcore5. Official SHA256
+ size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" --exclude=DEBIAN | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: sound
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: audacious-plugins (>= 3.10.1), dbus, default-dbus-session-bus | dbus-session-bus | dbus-x11, gtk2-engines-pixbuf, libc6 (>= 2.17), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.37.3), libstdc++6 (>= 4.1.1)
Recommends: unzip
Provides: audacious, libaudcore5
Conflicts: audacious, libaudcore5
Replaces: audacious, libaudcore5
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.audacious-media-player.org/
Description: small and fast audio player which supports lots of formats (arm64)
 Audacious ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official libaudcore5.
 A small and fast audio player which supports lots of formats.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

printf '%s\n' 'libaudcore 5 kemi-audacious' > "$STAGE/pkg/DEBIAN/shlibs"
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-audacious-control.txt"
