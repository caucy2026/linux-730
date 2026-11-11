#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) thunar
# 1.8.14-0ubuntu1 arm64 plus same-source hard-Depends
# thunar-data (= 1.8.14-0ubuntu1, arch:all) as kemi-thunar
# (orage-data / remmina-common pattern).
# libthunarx-3-0 is same-source but a shared library with
#   unversioned/minimum Depends (not exact-version); it stays a
#   system Depends so official plugins can still apt-install
#   against it. exo-utils, desktop-file-utils and
#   shared-mime-info are different-source system Depends and
#   are not bundled.
# Official Recommends (dbus-session-bus, gvfs, polkit agent,
#   thunar-volman, tumbler, udisks2, xdg-user-dirs,
#   libxfce4panel-2.0-4) and Suggests (thunar-archive-plugin,
#   thunar-media-tags-plugin) stay Recommends/Suggests and are
#   not bundled (those plugins Depend: thunar (>= old version),
#   not thunar (= exact); Provides: thunar so they can later
#   be apt-installed next to kemi-thunar).
# Official binaries: /usr/bin/thunar (ELF) with official
#   /usr/bin/Thunar symlink, /usr/bin/thunar-settings (shell),
#   /usr/lib/aarch64-linux-gnu/Thunar/{ThunarBulkRename,
#   thunar-sendto-email}, and the official in-package panel
#   plugin /usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libthunar-tpa.so.
# Probe: aarch64 · 3 ELF · all requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# ELF embeds /usr/share/locale, /usr/bin, and
#   /usr/share/pixmaps/Thunar/Thunar-about-logo.png. Layout
#   keeps official files at /usr/bin and official helper/plugin
#   dirs; /opt/thunar/* are symlinks (HardInfo/Xpad/qpdfview/
#   Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME
#   System Monitor/GParted/Seahorse/Remmina/dconf-editor/
#   xfce4-terminal). Official desktop Icon=Thunar (PNG + SVG
#   shipped in thunar-data). Official language-pack split does
#   not apply: thunar-data ships 63 .mo including zh_CN. Keep
#   the official tree; do not invent/bundle language-packs or
#   UI/icon files that were not in the official debs. No help
#   directory in these debs.
# Official D-Bus / systemd already Exec=/usr/bin/Thunar;
#   official polkit exec.path is /usr/bin/thunar; official
#   ThunarBulkRename already exec /usr/bin/Thunar. Those
#   absolute official paths are kept.
# KEMI version 1.8.14-0ubuntu1kemi1 is 20 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-thunar
VER_UP=1.8.14
VER_DEB="${VER_UP}-0ubuntu1kemi1"
ARCH=arm64
PKG=kemi-thunar
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/thunar-1.8.14-focal-unpack}"
UP_DEB="$DL/thunar_1.8.14-0ubuntu1_arm64.deb"
UP_DATA="$DL/thunar-data_1.8.14-0ubuntu1_all.deb"
EXPECT_SHA=a6e4f428d385208695861acc81337949a56d6df21d9c220901a3d8fd5723d638
EXPECT_BYTES=270308
EXPECT_DATA_SHA=aac4e598a1d52cae75e2638fc63146250f15ef865c37dcbfc6223d8050d18211
EXPECT_DATA_BYTES=728968
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test -f "$UP_DATA"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_DATA")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_DATA_SHA  $UP_DATA" | sha256sum -c -
test -x "$UNPACK/usr/bin/thunar"
test -L "$UNPACK/usr/bin/Thunar"
test "$(readlink "$UNPACK/usr/bin/Thunar")" = "thunar"
test -x "$UNPACK/usr/bin/thunar-settings"
test -x "$UNPACK/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename"
test -x "$UNPACK/usr/lib/aarch64-linux-gnu/Thunar/thunar-sendto-email"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libthunar-tpa.so"
test -f "$UNPACK/usr/share/applications/thunar.desktop"
test -f "$UNPACK/usr/share/pixmaps/Thunar/Thunar-about-logo.png"
test -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/Thunar.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/thunar.mo"
test -f "$UNPACK/etc/xdg/Thunar/uca.xml"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 63
test ! -d "$UNPACK/usr/share/help"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/thunar")
grep -q '/usr/share/pixmaps/Thunar/Thunar-about-logo.png' < <(strings -n 8 "$UNPACK/usr/bin/thunar")
# official absolute helper / dbus / polkit / systemd
grep -q 'exec /usr/bin/Thunar --bulk-rename' \
  "$UNPACK/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename"
grep -q 'Exec=/usr/bin/Thunar --gapplication-service' \
  "$UNPACK/usr/share/dbus-1/services/org.xfce.Thunar.service"
grep -q 'ExecStart=/usr/bin/Thunar --daemon' \
  "$UNPACK/usr/lib/systemd/user/thunar.service"
grep -q 'org.freedesktop.policykit.exec.path">/usr/bin/thunar<' \
  "$UNPACK/usr/share/polkit-1/actions/org.xfce.thunar.policy"
# official thunar changelog is a dangling symlink to libthunarx-3-0;
# thunar-data ships the real changelog.
test -L "$UNPACK/usr/share/doc/thunar/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/thunar-data/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/thunar-data/changelog.Debian.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins" \
  "$STAGE/pkg/usr/lib/systemd/user" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/Thunar" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/usr/share/polkit-1/actions" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins" \
  "$STAGE/pkg/etc/xdg/Thunar" \
  "$STAGE/pkg/opt/thunar"

cp -al "$UNPACK/usr/bin/thunar" "$STAGE/pkg/usr/bin/thunar"
chmod 0755 "$STAGE/pkg/usr/bin/thunar"
ln -s thunar "$STAGE/pkg/usr/bin/Thunar"
cp -a --remove-destination "$UNPACK/usr/bin/thunar-settings" \
  "$STAGE/pkg/usr/bin/thunar-settings"
chmod 0755 "$STAGE/pkg/usr/bin/thunar-settings"
# official helpers stay at compiled / official paths
cp -a --remove-destination \
  "$UNPACK/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename"
cp -al \
  "$UNPACK/usr/lib/aarch64-linux-gnu/Thunar/thunar-sendto-email" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar/thunar-sendto-email"
chmod 0755 "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar/thunar-sendto-email"
grep -q 'exec /usr/bin/Thunar --bulk-rename' \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename"
cp -al \
  "$UNPACK/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libthunar-tpa.so" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libthunar-tpa.so"

REPORT="$ROOT/probe/kemi-thunar.json"
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
for name in ("thunar", "thunar-sendto-email", "libthunar-tpa.so"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["thunar"].get("neededLibraries") or [])
for lib in ("libthunarx-3.so.0", "libexo-2.so.0", "libgtk-3.so.0",
            "libxfce4ui-2.so.0", "libgudev-1.0.so.0", "libnotify.so.4",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=3")
PY

# official data / icons / locales / pixmaps / sendto / panel desktop
cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a "$UNPACK/usr/share/pixmaps/Thunar" "$STAGE/pkg/usr/share/pixmaps/Thunar"
cp -a "$UNPACK/usr/share/Thunar/." "$STAGE/pkg/usr/share/Thunar/"
cp -a --remove-destination \
  "$UNPACK/usr/share/xfce4/panel/plugins/thunar-tpa.desktop" \
  "$STAGE/pkg/usr/share/xfce4/panel/plugins/thunar-tpa.desktop"
cp -a --remove-destination \
  "$UNPACK/etc/xdg/Thunar/uca.xml" \
  "$STAGE/pkg/etc/xdg/Thunar/uca.xml"
# official D-Bus / systemd / polkit already use absolute /usr/bin/Thunar or /usr/bin/thunar
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/." \
  "$STAGE/pkg/usr/share/dbus-1/services/"
cp -a --remove-destination "$UNPACK/usr/lib/systemd/user/thunar.service" \
  "$STAGE/pkg/usr/lib/systemd/user/thunar.service"
cp -a --remove-destination \
  "$UNPACK/usr/share/polkit-1/actions/org.xfce.thunar.policy" \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.xfce.thunar.policy"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/org.xfce.thunar.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.xfce.thunar.appdata.xml"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/Thunar.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/Thunar.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/thunar-settings.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/thunar-settings.1.gz"
ln -s Thunar.1.gz "$STAGE/pkg/usr/share/man/man1/thunar.1.gz"

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 63
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/thunar.mo"
test -f "$STAGE/pkg/usr/share/pixmaps/Thunar/Thunar-about-logo.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/Thunar.png"
grep -q 'Exec=/usr/bin/Thunar --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.xfce.Thunar.service"
grep -q 'Exec=/usr/bin/Thunar --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.xfce.FileManager.service"
grep -q 'Exec=/usr/bin/Thunar --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.xfce.Thunar.FileManager1.service"
grep -q 'ExecStart=/usr/bin/Thunar --daemon' \
  "$STAGE/pkg/usr/lib/systemd/user/thunar.service"
grep -q 'org.freedesktop.policykit.exec.path">/usr/bin/thunar<' \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.xfce.thunar.policy"

# changelog from thunar-data (dereference; official thunar changelog is dangling)
cp --remove-destination -L "$UNPACK/usr/share/doc/thunar-data/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/thunar-data/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
if [[ -f "$UNPACK/usr/share/doc/thunar-data/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/thunar-data/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
import shutil

src_dir = Path("$UNPACK/usr/share/applications")
dst_dir = Path("$STAGE/pkg/usr/share/applications")

def rewrite_rel(src, dst, binary, expect_exec, icon=None, name=None):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(rf"^Exec={re.escape(binary)}(\s.*)?$",
                   rf"Exec=/usr/bin/{binary}\1", text, flags=re.M)
    text2 = re.sub(rf"^TryExec={re.escape(binary)}$",
                   f"TryExec=/usr/bin/{binary}", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(rf"^(Exec=/usr/bin/{re.escape(binary)}(?:\s.*)?)$",
                       rf"\1\nTryExec=/usr/bin/{binary}", text2, count=1, flags=re.M)
    if re.search(rf"^Exec={re.escape(binary)}(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC:{src.name}")
    if expect_exec not in text2:
        raise SystemExit(f"MISSING_EXEC:{src.name}")
    if f"TryExec=/usr/bin/{binary}" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC:{src.name}")
    if icon and not re.search(rf"^Icon={re.escape(icon)}$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON:{src.name}")
    if name and name not in text2:
        raise SystemExit(f"MISSING_NAME:{src.name}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

rewrite_rel(src_dir / "thunar.desktop", dst_dir / "thunar.desktop",
            "thunar", "Exec=/usr/bin/thunar %F", icon="Thunar",
            name="Name=Thunar File Manager")
rewrite_rel(src_dir / "thunar-settings.desktop", dst_dir / "thunar-settings.desktop",
            "thunar-settings", "Exec=/usr/bin/thunar-settings",
            icon="system-file-manager", name="Name=File Manager Settings")

# already-absolute official Exec: copy as-is, require official path
bulk_src = src_dir / "thunar-bulk-rename.desktop"
bulk_dst = dst_dir / "thunar-bulk-rename.desktop"
bulk = bulk_src.read_text(encoding="utf-8")
if "Exec=/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename %F" not in bulk:
    raise SystemExit("BULK_EXEC_NOT_ABSOLUTE")
if "Icon=Thunar" not in bulk:
    raise SystemExit("BULK_ICON")
if not re.search(r"^TryExec=", bulk, flags=re.M):
    bulk = re.sub(r"^(Exec=/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename %F)$",
                  r"\1\nTryExec=/usr/lib/aarch64-linux-gnu/Thunar/ThunarBulkRename",
                  bulk, count=1, flags=re.M)
bulk_dst.write_text(bulk, encoding="utf-8")
print("desktop_kept_absolute", bulk_dst)

# sendto desktops: official email Exec is already absolute; optional
# bluetooth/obex helpers keep official TryExec of system tools
send_src = Path("$UNPACK/usr/share/Thunar/sendto/thunar-sendto-email.desktop")
send_txt = send_src.read_text(encoding="utf-8")
if "Exec=/usr/lib/aarch64-linux-gnu/Thunar/thunar-sendto-email %F" not in send_txt:
    raise SystemExit("SENDTO_EXEC_NOT_ABSOLUTE")
print("sendto_email_absolute_ok")
PY

ln -sf /usr/bin/thunar "$STAGE/pkg/opt/thunar/thunar"
ln -sf /usr/bin/Thunar "$STAGE/pkg/opt/thunar/Thunar"
ln -sf /usr/bin/thunar-settings "$STAGE/pkg/opt/thunar/thunar-settings"
ln -sf thunar "$STAGE/pkg/usr/bin/kemi-thunar"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://docs.xfce.org/xfce/thunar/start
Source: https://launchpad.net/ubuntu/+source/thunar
Homepage: https://docs.xfce.org/xfce/thunar/start
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(thunar_1.8.14-0ubuntu1_arm64.deb + bundled same-source
thunar-data_1.8.14-0ubuntu1_all.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 thunar_1.8.14-0ubuntu1_arm64.deb
    (focal universe; no newer package in focal-updates)
    plus same-source hard-Depends thunar-data
    (= 1.8.14-0ubuntu1, arch:all) bundled for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/thunar (compiled
    /usr/share/locale and /usr/share/pixmaps/Thunar). Official
    /usr/bin/Thunar symlink, helpers under
    /usr/lib/aarch64-linux-gnu/Thunar/ and the in-package
    panel plugin stay on official paths. /opt/thunar/* are
    symlinks.
  * Official D-Bus/systemd Exec=/usr/bin/Thunar and polkit
    exec.path=/usr/bin/thunar are kept. Desktop Exec=thunar
    and Exec=thunar-settings rewritten to /usr/bin; already-
    absolute bulk-rename and sendto-email Exec kept.
    Official desktop Icon=Thunar (PNG + SVG shipped).
  * Conflicts/Replaces/Provides thunar and thunar-data.
    Official Depends kept for Ubuntu 20.04 except bundled
    thunar-data (GTK3, libthunarx-3-0, exo-utils, libc6 >= 2.17).
    Official Recommends/Suggests (including thunar-volman and
    archive/media-tags plugins) kept as Recommends/Suggests.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:20:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Thunar File Manager ${VER_UP}-0ubuntu1 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled official
thunar-data.

Official ELF stays at /usr/bin/thunar (compiled
/usr/share/locale and /usr/share/pixmaps/Thunar). Official
/usr/bin/Thunar symlink and helper/plugin paths stay official.
/opt/thunar/* are symlinks.
Desktop, official D-Bus, systemd user unit, polkit, man,
metainfo, icons, pixmaps, 63 .mo (including zh_CN), sendto
helpers, panel plugin and /etc/xdg/Thunar/uca.xml remain on
standard paths.
Official desktop Icon=Thunar (PNG + SVG shipped in
thunar-data). No help directory in the official debs.
Probe: aarch64 · 3 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled thunar-data (GTK3,
libthunarx-3-0, exo-utils, libc6 >= 2.17). Official
Recommends/Suggests kept as Recommends/Suggests.
Official publication: Ubuntu 20.04 focal universe arm64
thunar 1.8.14-0ubuntu1 + arch:all thunar-data. Official
SHA256 + size matched ports.ubuntu.com pool files and
focal universe arm64 Packages stanzas. No librarian URL
this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: xfce
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: desktop-file-utils, exo-utils, shared-mime-info, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.6.0), libexo-2-0 (>= 0.11.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.39.90), libgtk-3-0 (>= 3.21.5), libgudev-1.0-0 (>= 146), libice6 (>= 1:1.0.0), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.44.6), libsm6, libthunarx-3-0 (>= 1.7.0), libxfce4ui-2-0 (>= 4.13.0), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.6.0)
Recommends: default-dbus-session-bus | dbus-session-bus, gvfs, policykit-1-gnome | polkit-1-auth-agent, thunar-volman, tumbler, udisks2, xdg-user-dirs, libxfce4panel-2.0-4 (>= 4.13.0)
Suggests: thunar-archive-plugin, thunar-media-tags-plugin
Provides: thunar, thunar-data
Conflicts: thunar, thunar-data
Replaces: thunar, thunar-data
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://docs.xfce.org/xfce/thunar/start
Description: File Manager for Xfce (arm64)
 Thunar File Manager ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled official thunar-data.
 The default file manager for the Xfce desktop.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

printf '%s\n' '/etc/xdg/Thunar/uca.xml' > "$STAGE/pkg/DEBIAN/conffiles"

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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-thunar-control.txt"
