#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) pidgin
# 1:2.13.0-2.2ubuntu4 arm64 as kemi-pidgin, bundling same-source
# pidgin-data_2.13.0-2.2ubuntu4_all.deb. Official Depends is
#   pidgin-data (>= 1:2.13.0), pidgin-data (<< 1:2.13.0-z)
#   (tight same-series range, not a single Equals, but this is
#   the named same-source data package and the only focal
#   version is 1:2.13.0-2.2ubuntu4; bundle on the
#   orage-data / gnumeric-common / shotwell-common /
#   abiword-common pattern).
# Same-source libpurple0 Depends is '>= 2.13.0' (not exact =)
#   and is left as a system Depends (libabiword / libfilezilla0
#   pattern). It was probe-only: aarch64, max requiredGlibc 2.29,
#   no GLIBCXX, PASS vs 101.
# Official Recommends (gstreamer plugins and pidgin-libnotify)
#   stay Recommends and are not bundled. pidgin-libnotify is
#   not present in Ubuntu 20.04 focal arm64/all Packages
#   indexes (leftover Recommends); it is still listed as an
#   official Recommends and is not invented or bundled.
# Official Suggests stay Suggests and are not bundled.
# Third-party / different-source pidgin-* plugin packages are
#   not official Recommends of this exact version and are not
#   bundled. finch, libpurple-bin, *-dev, pidgin-themes
#   (source gaim-themes) are not bundled. Versioned
#   Provides: pidgin (= 1:2.13.0-2.2ubuntu4) and
#   pidgin-data (= 1:2.13.0-2.2ubuntu4) let later apt-install
#   of those plugins work.
# Official binary: /usr/bin/pidgin plus official GTK plugins
#   under /usr/lib/pidgin/. The ELF embeds /usr/lib/pidgin/,
#   /usr/share/locale and /usr/share/pixmaps/pidgin/tray, so
#   official files stay on official paths; /opt/pidgin/* are
#   symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/
#   Xfburn/Parole/GNOME Disks/GNOME System Monitor/GParted/
#   Seahorse/Remmina/dconf-editor/xfce4-terminal/thunar/
#   pcmanfm/geany/filezilla/blueman/audacious/abiword/
#   shotwell/gnumeric/claws-mail).
# Official pidgin-data ships 94 .mo including zh_CN, hicolor
#   icons, pixmaps, sounds and /etc/purple/prefs.xml (conffile).
#   Keep the official tree; do not invent/bundle language-packs
#   or extra UI/icons. No help directory in these official debs.
# Official pidgin changelog.Debian.gz is a dangling symlink
#   to ../libpurple0/changelog.Debian.gz and is not shipped;
#   kemi changelog.upstream.gz is cp -L from pidgin-data.
# Probe: aarch64 · 24 packaged ELF · most requiredGlibc 2.17 ·
#   vvconfig.so requiredGlibc 2.29 · iconaway.so has no libc
#   version-need · no GLIBCXX · PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# KEMI dpkg Version keeps the official epoch:
#   1:2.13.0-2.2ubuntu4kemi1. Filename and mall version_name
#   omit the epoch: 2.13.0-2.2ubuntu4kemi1 is 22 chars (under
#   the mall version_name limit that rejected Remmina's
#   33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-pidgin
VER_UP=2.13.0
VER_DEB="${VER_UP}-2.2ubuntu4kemi1"
VER_DPKG="1:${VER_DEB}"
ARCH=arm64
PKG=kemi-pidgin
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/pidgin-2.13.0-focal-unpack}"
DATA_UNPACK="${DATA_UNPACK:-$ROOT/probe/pidgin-data-2.13.0-focal-unpack}"
UP_DEB="$DL/pidgin_2.13.0-2.2ubuntu4_arm64.deb"
DATA_DEB="$DL/pidgin-data_2.13.0-2.2ubuntu4_all.deb"
EXPECT_SHA=a55080abdbce8a247008576abdf3d628a1a124e6028105ce583132d8569d90bf
EXPECT_BYTES=449616
EXPECT_DATA_SHA=1c8cf445f4366000e72089154e77ca42eb055b850663c2935288c0de0443c8a6
EXPECT_DATA_BYTES=4294488
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$DATA_DEB"
test "$(stat -c%s "$DATA_DEB")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/pidgin"
test -d "$UNPACK/usr/lib/pidgin"
test -f "$UNPACK/usr/share/applications/pidgin.desktop"
test -f "$UNPACK/usr/share/appdata/pidgin.appdata.xml"
test -f "$UNPACK/usr/share/indicators/messages/applications/pidgin"
test -f "$UNPACK/usr/share/man/man1/pidgin.1.gz"
test -f "$DATA_UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/pidgin.mo"
test "$(find "$DATA_UNPACK" -name '*.mo' | wc -l)" = 94
test -f "$DATA_UNPACK/usr/share/icons/hicolor/48x48/apps/pidgin.png"
test -f "$DATA_UNPACK/etc/purple/prefs.xml"
test -d "$DATA_UNPACK/usr/share/pixmaps/pidgin"
test -d "$DATA_UNPACK/usr/share/sounds/purple"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
# official pidgin changelog is a dangling symlink to libpurple0
test -L "$UNPACK/usr/share/doc/pidgin/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/pidgin/changelog.Debian.gz"
test ! -L "$DATA_UNPACK/usr/share/doc/pidgin-data/changelog.Debian.gz"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/pidgin")
grep -qx '/usr/lib/pidgin/' < <(strings -n 8 "$UNPACK/usr/bin/pidgin")
grep -qx '/usr/share/pixmaps/pidgin/tray' < <(strings -n 8 "$UNPACK/usr/bin/pidgin")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/pidgin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/appdata" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/man/man3" \
  "$STAGE/pkg/usr/share/indicators/messages/applications" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/sounds" \
  "$STAGE/pkg/etc/purple" \
  "$STAGE/pkg/opt/pidgin"

cp -al "$UNPACK/usr/bin/pidgin" "$STAGE/pkg/usr/bin/pidgin"
chmod 0755 "$STAGE/pkg/usr/bin/pidgin"
# official GTK plugins + perl helper stay on official paths
cp -a "$UNPACK/usr/lib/pidgin/." "$STAGE/pkg/usr/lib/pidgin/"

REPORT="$ROOT/probe/kemi-pidgin.json"
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
test "${#ELFS[@]}" = 24
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
if len(files) != 24:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by = {Path(f["path"]).name: f for f in files}
if "pidgin" not in by:
    raise SystemExit("PROBE_MISSING_MAIN")
for name, f in by.items():
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH:{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX:{name}")
    glibc = f.get("requiredGlibc")
    if glibc not in (None, "2.17", "2.29"):
        raise SystemExit(f"PROBE_GLIBC:{name}:{glibc}")
if by["pidgin"].get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_MAIN_GLIBC")
if by["vvconfig.so"].get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_VVCONFIG_GLIBC")
if by["iconaway.so"].get("requiredGlibc") is not None:
    raise SystemExit("PROBE_ICONAWAY_GLIBC")
needed = set(by["pidgin"].get("neededLibraries") or [])
for lib in ("libpurple.so.0", "libgtk-x11-2.0.so.0",
            "libgdk-x11-2.0.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=24 main_glibc=2.17 vvconfig=2.29 iconaway=none noGLIBCXX arch=aarch64")
PY

# official data: locales, icons, pixmaps, sounds, conffile
cp -a "$DATA_UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$DATA_UNPACK/usr/share/icons/." "$STAGE/pkg/usr/share/icons/"
cp -a "$DATA_UNPACK/usr/share/pixmaps/." "$STAGE/pkg/usr/share/pixmaps/"
cp -a "$DATA_UNPACK/usr/share/sounds/." "$STAGE/pkg/usr/share/sounds/"
cp -a --remove-destination \
  "$DATA_UNPACK/etc/purple/prefs.xml" \
  "$STAGE/pkg/etc/purple/prefs.xml"
# official man, appdata, messaging indicator
cp -a --remove-destination "$UNPACK/usr/share/man/man1/pidgin.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/pidgin.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man3/Pidgin.3pm.gz" \
  "$STAGE/pkg/usr/share/man/man3/Pidgin.3pm.gz"
cp -a --remove-destination "$UNPACK/usr/share/appdata/pidgin.appdata.xml" \
  "$STAGE/pkg/usr/share/appdata/pidgin.appdata.xml"
cp -a --remove-destination \
  "$UNPACK/usr/share/indicators/messages/applications/pidgin" \
  "$STAGE/pkg/usr/share/indicators/messages/applications/pidgin"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 94
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/pidgin.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/pidgin.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/pidgin.svg"
test -d "$STAGE/pkg/usr/share/pixmaps/pidgin"
test -d "$STAGE/pkg/usr/share/sounds/purple"
test -f "$STAGE/pkg/etc/purple/prefs.xml"
test ! -d "$STAGE/pkg/usr/share/help"
test -f "$STAGE/pkg/usr/lib/pidgin/unity.so"
test -f "$STAGE/pkg/usr/lib/pidgin/perl/Pidgin.pm"

# official pidgin changelog is dangling; take pidgin-data's real changelog
cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/pidgin-data/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$DATA_UNPACK/usr/share/doc/pidgin-data/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/pidgin.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/pidgin.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=pidgin(\s.*)?$", r"Exec=/usr/bin/pidgin\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=pidgin$", "TryExec=/usr/bin/pidgin", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/pidgin(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/pidgin", text2, count=1, flags=re.M)
if re.search(r"^Exec=pidgin(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/pidgin", "TryExec=/usr/bin/pidgin"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=pidgin$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Pidgin Internet Messenger" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
# official indicator already uses an absolute desktop path
ind = Path("$STAGE/pkg/usr/share/indicators/messages/applications/pidgin")
ind_text = ind.read_text(encoding="utf-8").strip()
if ind_text != "/usr/share/applications/pidgin.desktop":
    raise SystemExit(f"UNEXPECTED_INDICATOR:{ind_text!r}")
print("indicator_ok", ind_text)
PY

ln -sf /usr/bin/pidgin "$STAGE/pkg/opt/pidgin/pidgin"
ln -sf pidgin "$STAGE/pkg/usr/bin/kemi-pidgin"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.pidgin.im
Source: https://launchpad.net/ubuntu/+source/pidgin
Homepage: http://www.pidgin.im
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v1:${VER_UP}-2.2ubuntu4
(pidgin_2.13.0-2.2ubuntu4_arm64.deb) plus bundled same-source
pidgin-data_2.13.0-2.2ubuntu4_all.deb, repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DPKG}) kemi; urgency=medium

  * Official Ubuntu 20.04 pidgin_2.13.0-2.2ubuntu4_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    pidgin-data_2.13.0-2.2ubuntu4_all.deb (hard Depends
    pidgin-data (>= 1:2.13.0) and (<< 1:2.13.0-z); only
    focal version is 1:2.13.0-2.2ubuntu4).
  * Same-source libpurple0 (>= 2.13.0) is not exact and is
    left as a system Depends (probe-only: max requiredGlibc
    2.29, no GLIBCXX). Official Recommends gstreamer plugins
    and pidgin-libnotify stay Recommends; pidgin-libnotify is
    not in focal arm64/all indexes and is not bundled.
    Official Suggests stay Suggests. Different-source plugins
    are not bundled. Versioned Provides: pidgin (=
    1:2.13.0-2.2ubuntu4) and pidgin-data (= 1:2.13.0-2.2ubuntu4).
  * Official ELF stays at /usr/bin/pidgin and official GTK
    plugins stay under /usr/lib/pidgin/ (compiled /usr prefix:
    /usr/lib/pidgin/, /usr/share/locale,
    /usr/share/pixmaps/pidgin/tray). /opt/pidgin/* are
    symlinks.
  * Desktop, man, appdata, messaging indicator, official 94
    .mo (including zh_CN), hicolor icons, pixmaps, sounds and
    /etc/purple/prefs.xml stay on standard paths. Official
    desktop Exec=pidgin rewritten to /usr/bin/pidgin;
    Icon=pidgin. Official pidgin changelog was a dangling
    symlink to libpurple0 and is not shipped; upstream
    changelog is cp -L from pidgin-data.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:19:46 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Pidgin ${VER_UP}-2.2ubuntu4 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source pidgin-data.

Official ELF stays at /usr/bin/pidgin and official GTK
plugins stay under /usr/lib/pidgin/ (compiled /usr
prefix). /opt/pidgin/* are symlinks.
Desktop, man, appdata, indicator, official 94 .mo
(including zh_CN), icons, pixmaps, sounds and the
prefs conffile remain on standard paths.
libpurple0 is a same-source non-exact Depends and is
not bundled. Official Recommends including
pidgin-libnotify (absent from focal arm64/all indexes)
stay Recommends.
Probe: aarch64 · 24 packaged ELF · most requiredGlibc
2.17 · vvconfig.so requiredGlibc 2.29 · iconaway.so
has no libc version-need · no GLIBCXX; Ubuntu 20.04 /
glibc 2.31 OK. Unbundled libpurple0 probe-only: 30 ELF,
max requiredGlibc 2.29, no GLIBCXX.
Official publication: Ubuntu 20.04 focal universe arm64
pidgin 1:2.13.0-2.2ubuntu4 plus pidgin-data. Official
SHA256 + size matched ports.ubuntu.com pool files and
focal universe arm64 Packages stanzas. No librarian URL
this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DPKG
Section: net
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.2.4), libdbus-1-3 (>= 1.9.14), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.9), libgstreamer1.0-0 (>= 1.0.0), libgtk2.0-0 (>= 2.24.0), libgtkspell0 (>= 2.0.10), libice6 (>= 1:1.0.0), libmessaging-menu0 (>= 12.10.0), libpango-1.0-0 (>= 1.18.0), libpurple0 (>= 2.13.0), libsm6, libunity9 (>= 3.4.6), libx11-6, libxss1, perl-base (>= 5.30.0-9), perlapi-5.30.0
Recommends: gstreamer1.0-alsa | gstreamer1.0-pulseaudio, gstreamer1.0-libav, gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, pidgin-libnotify
Suggests: gnome-panel (>= 2.1) | kdebase-workspace-bin | docker, evolution-data-server (>= 1.10.0), libsqlite3-0 (>= 3.5.9)
Breaks: pidgin-facebookchat (<< 1.69-2)
Replaces: pidgin, pidgin-data, pidgin-facebookchat (<< 1.69-2)
Conflicts: pidgin, pidgin-data
Provides: pidgin (= 1:2.13.0-2.2ubuntu4), pidgin-data (= 1:2.13.0-2.2ubuntu4)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.pidgin.im
Description: graphical multi-protocol instant messaging client (arm64)
 Pidgin ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled pidgin-data.
 Graphical, modular instant messaging client for AIM,
 IRC, Jabber/XMPP/Google Talk and more.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

printf '%s\n' '/etc/purple/prefs.xml' > "$STAGE/pkg/DEBIAN/conffiles"

cat > "$STAGE/pkg/DEBIAN/preinst" << 'EOT'
#!/bin/sh
set -e
# Official pidgin preinst: remove a stale /usr/share/doc/pidgin
# symlink left by upgrades from versions older than 2.1.1-2.
# Also apply the same cleanup to /usr/share/doc/kemi-pidgin.
case "$1" in
    install|upgrade)
        if dpkg --compare-versions "$2" lt 2.1.1-2; then
            if [ -h /usr/share/doc/pidgin ]; then
                rm /usr/share/doc/pidgin
            fi
            if [ -h /usr/share/doc/kemi-pidgin ]; then
                rm /usr/share/doc/kemi-pidgin
            fi
        fi
    ;;
    abort-upgrade)
    ;;
    *)
        echo "preinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/preinst"

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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-pidgin-control.txt"
