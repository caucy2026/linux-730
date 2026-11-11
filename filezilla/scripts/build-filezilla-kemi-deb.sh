#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) filezilla
# 3.46.3-1ubuntu0.1 arm64 plus same-source hard-Depends
# filezilla-common (= 3.46.3-1ubuntu0.1, arch:all) as kemi-filezilla
# (orage-data / remmina-common / thunar-data / geany-common pattern).
# Release (focal universe) has older 3.46.3-1build1; this run uses
#   the newer still-U20-compatible focal-updates / focal-security
#   package (CVE-2023-48795 Terrapin).
# libfilezilla0 (>= 0.19.3) is a different source (libfilezilla)
#   with a minimum, not exact-version, Depends and stays a system
#   Depends. wxWidgets, GTK3, pugixml, sqlite and dbus are also
#   different-source system Depends and are not bundled.
# Official Recommends (xdg-utils) stay Recommends and are not
#   bundled. Official Breaks libfilezilla (<< 0.18.2-2) is kept.
# Official binaries: /usr/bin/filezilla plus bundled SFTP helpers
#   /usr/bin/fzputtygen and /usr/bin/fzsftp (looked up next to the
#   main ELF). No in-package shared libraries.
# Probe: aarch64 · 3 ELF · all requiredGlibc 2.28; filezilla
#   GLIBCXX 3.4.21; helpers no GLIBCXX · PASS vs 101 ≤2.31 /
#   GLIBCXX ≤3.4.28
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No librarian URL and no .buildinfo is recorded this run
#   (pool 404). This round is not based on Launchpad librarian.
# filezilla looks up share/filezilla relative to a /usr prefix
#   (binary in /usr/bin) and FZ_DATADIR; official ELF stays at
#   /usr/bin; /opt/filezilla/* are symlinks. Official desktop
#   Icon=filezilla (hicolor icons and pixmaps shipped in
#   filezilla-common). Official language-pack split does not
#   apply: filezilla-common ships 58 .mo including zh_CN. Keep
#   the official tree; do not invent/bundle language-packs or
#   UI/icons. Official XRC UI stays under
#   /usr/share/filezilla/resources. No /usr/share/help directory.
# Official filezilla-common NEWS.gz is a dangling symlink to
#   missing changelog.gz and is not shipped. Packaged changelog
#   is dereferenced from official changelog.Debian.gz (cp -L).
# KEMI version 3.46.3-1ubuntu0.1kemi1 is 22 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-filezilla
VER_UP=3.46.3
VER_DEB="${VER_UP}-1ubuntu0.1kemi1"
ARCH=arm64
PKG=kemi-filezilla
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/filezilla-3.46.3-focal-unpack}"
UP_DEB="$DL/filezilla_3.46.3-1ubuntu0.1_arm64.deb"
UP_COMMON="$DL/filezilla-common_3.46.3-1ubuntu0.1_all.deb"
EXPECT_SHA=9ca33769706464d74e5986d0928c64e4636fb9e5bc9d7ba8c834b09b8233b585
EXPECT_BYTES=1651532
EXPECT_COMMON_SHA=90b520e9351b3c4644146b14bbc4fd4050b13ea41ef32328919484f96067e7b8
EXPECT_COMMON_BYTES=2265788
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/bin/filezilla"
test -x "$UNPACK/usr/bin/fzputtygen"
test -x "$UNPACK/usr/bin/fzsftp"
test -f "$UNPACK/usr/share/applications/filezilla.desktop"
test -f "$UNPACK/usr/share/filezilla/resources/xrc/dialogs.xrc"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/filezilla.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/filezilla.mo"
test -f "$UNPACK/usr/share/pixmaps/filezilla.png"
test -f "$UNPACK/usr/share/man/man1/filezilla.1.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 58
test ! -d "$UNPACK/usr/share/help"
# compiled prefix — process substitution, no SIGPIPE
grep -q 'share/filezilla/fzdefaults.xml' < <(strings -n 8 "$UNPACK/usr/bin/filezilla")
grep -q 'FZ_DATADIR' < <(strings -n 8 "$UNPACK/usr/bin/filezilla")
grep -q '/etc/filezilla/fzdefaults.xml' < <(strings -n 8 "$UNPACK/usr/bin/filezilla")
test ! -L "$UNPACK/usr/share/doc/filezilla-common/changelog.Debian.gz"
# official NEWS.gz is a dangling symlink to missing changelog.gz
if [[ -L "$UNPACK/usr/share/doc/filezilla-common/NEWS.gz" ]]; then
  test ! -e "$UNPACK/usr/share/doc/filezilla-common/NEWS.gz"
fi

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/filezilla-common" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/man/man5" \
  "$STAGE/pkg/usr/share/filezilla" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/filezilla"

cp -al "$UNPACK/usr/bin/filezilla" "$STAGE/pkg/usr/bin/filezilla"
cp -al "$UNPACK/usr/bin/fzputtygen" "$STAGE/pkg/usr/bin/fzputtygen"
cp -al "$UNPACK/usr/bin/fzsftp" "$STAGE/pkg/usr/bin/fzsftp"
chmod 0755 "$STAGE/pkg/usr/bin/filezilla" \
  "$STAGE/pkg/usr/bin/fzputtygen" \
  "$STAGE/pkg/usr/bin/fzsftp"

REPORT="$ROOT/probe/kemi-filezilla.json"
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
for name in ("filezilla", "fzputtygen", "fzsftp"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.28":
        raise SystemExit(f"PROBE_GLIBC_{name}")
main = by["filezilla"]
if main.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_MAIN_GLIBCXX")
needed = set(main.get("neededLibraries") or [])
for n in ("libfilezilla.so.3", "libwx_gtk3u_core-3.0.so.0", "libgtk-3.so.0",
          "libstdc++.so.6", "libc.so.6"):
    if n not in needed:
        raise SystemExit(f"PROBE_MISSING_{n}")
for name in ("fzputtygen", "fzsftp"):
    if by[name].get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
print("PROBE_PASS n_elf=3 filezilla_glibc=2.28 GLIBCXX=3.4.21 helpers_glibc=2.28")
PY

# official data / locales / icons / pixmaps / docs / man / metainfo
cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/filezilla/." "$STAGE/pkg/usr/share/filezilla/"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a "$UNPACK/usr/share/pixmaps/." "$STAGE/pkg/usr/share/pixmaps/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/filezilla.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/filezilla.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/fzputtygen.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/fzputtygen.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/fzsftp.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/fzsftp.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man5/fzdefaults.xml.5.gz" \
  "$STAGE/pkg/usr/share/man/man5/fzdefaults.xml.5.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/filezilla.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/filezilla.appdata.xml"
# official doc tree at /usr/share/doc/filezilla-common; skip dangling NEWS.gz
for f in changelog.Debian.gz copyright AUTHORS README; do
  cp --remove-destination -L "$UNPACK/usr/share/doc/filezilla-common/$f" \
    "$STAGE/pkg/usr/share/doc/filezilla-common/$f"
done
if [[ -d "$UNPACK/usr/share/doc/filezilla-common/examples" ]]; then
  cp -a "$UNPACK/usr/share/doc/filezilla-common/examples" \
    "$STAGE/pkg/usr/share/doc/filezilla-common/examples"
fi
# official symlink /usr/share/doc/filezilla -> filezilla-common
ln -s filezilla-common "$STAGE/pkg/usr/share/doc/filezilla"
# do not ship official dangling NEWS.gz
test ! -e "$STAGE/pkg/usr/share/doc/filezilla-common/NEWS.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 58
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/filezilla.mo"
test -f "$STAGE/pkg/usr/share/filezilla/resources/xrc/dialogs.xrc"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/filezilla.png"
test -L "$STAGE/pkg/usr/share/pixmaps/filezilla.svg"
test ! -d "$STAGE/pkg/usr/share/help"

# kemi changelog from official changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/filezilla-common/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/filezilla-common/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -s "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/filezilla.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/filezilla.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=filezilla(\s.*)?$", r"Exec=/usr/bin/filezilla\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=filezilla$", "TryExec=/usr/bin/filezilla", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/filezilla(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/filezilla", text2, count=1, flags=re.M)
if re.search(r"^Exec=filezilla(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/bin/filezilla" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/filezilla" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=filezilla$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=FileZilla" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/filezilla "$STAGE/pkg/opt/filezilla/filezilla"
ln -sf filezilla "$STAGE/pkg/usr/bin/kemi-filezilla"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://filezilla-project.org/
Source: https://launchpad.net/ubuntu/+source/filezilla
Homepage: https://filezilla-project.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(filezilla_3.46.3-1ubuntu0.1_arm64.deb + bundled same-source
filezilla-common_3.46.3-1ubuntu0.1_all.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 filezilla_3.46.3-1ubuntu0.1_arm64.deb
    (focal-updates universe; newer than Release 3.46.3-1build1
    and still U20-compatible; focal-security Terrapin fix
    CVE-2023-48795) plus same-source hard-Depends
    filezilla-common (= 3.46.3-1ubuntu0.1, arch:all) bundled
    for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/filezilla; SFTP helpers
    fzputtygen and fzsftp stay at /usr/bin. /opt/filezilla/*
    are symlinks.
  * Official data, 58 .mo (including zh_CN), icons, pixmaps,
    man, metainfo, XRC UI and examples stay on standard paths.
    Desktop Exec=filezilla rewritten to /usr/bin/filezilla;
    Icon=filezilla (icons shipped). Official dangling NEWS.gz
    is not shipped.
  * Conflicts/Replaces/Provides filezilla and filezilla-common.
    Official Depends kept for Ubuntu 20.04 except bundled
    filezilla-common (libfilezilla0, wxGTK3, GTK3, libc6 >= 2.28).
    Official Recommends xdg-utils kept as Recommends.
    Different-source libfilezilla0 is not bundled
    (Depends: libfilezilla0 (>= 0.19.3), not exact version).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
FileZilla ${VER_UP}-1ubuntu0.1 — official Ubuntu 20.04
(focal-updates) universe arm64, KEMI repack, with bundled
official filezilla-common.

Official ELF stays at /usr/bin/filezilla; SFTP helpers
fzputtygen and fzsftp stay at /usr/bin.
/opt/filezilla/* are symlinks.
Desktop, man, official locales, data (XRC UI and theme
resources), icons, pixmaps, metainfo and examples remain
on standard paths.
Official desktop Icon=filezilla (hicolor icons and pixmaps
shipped in filezilla-common).
Official language-pack split does not apply: this
common package ships 58 .mo including zh_CN.
Probe: aarch64 · 3 ELF · requiredGlibc 2.28; filezilla
GLIBCXX 3.4.21; helpers no GLIBCXX; Ubuntu 20.04 /
glibc 2.31 OK.
Runtime: official Depends minus bundled filezilla-common
(libfilezilla0, wxGTK3, GTK3, libc6 >= 2.28). Official
Recommends xdg-utils kept as Recommends. libfilezilla is
a different source and is not bundled.
Official publication: Ubuntu 20.04 focal-updates universe
arm64 filezilla 3.46.3-1ubuntu0.1 + arch:all
filezilla-common. Official SHA256 + size matched
ports.ubuntu.com pool files and focal-updates universe
arm64 Packages stanzas. No librarian URL this run.
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
Depends: libc6 (>= 2.28), libdbus-1-3 (>= 1.9.14), libfilezilla0 (>= 0.19.3), libgcc-s1 (>= 3.0), libgtk-3-0 (>= 3.0.0), libpugixml1v5 (>= 1.7), libsqlite3-0 (>= 3.5.9), libstdc++6 (>= 5.2), libwxbase3.0-0v5 (>= 3.0.4+dfsg), libwxgtk3.0-gtk3-0v5 (>= 3.0.4+dfsg-10~)
Recommends: xdg-utils
Breaks: libfilezilla (<< 0.18.2-2)
Provides: filezilla, filezilla-common
Conflicts: filezilla, filezilla-common
Replaces: filezilla, filezilla-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://filezilla-project.org/
Description: Full-featured graphical FTP/FTPS/SFTP client (arm64)
 FileZilla ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack, with bundled official filezilla-common.
 A full-featured FTP/FTPS/SFTP client using wxWidgets.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-filezilla-control.txt"
