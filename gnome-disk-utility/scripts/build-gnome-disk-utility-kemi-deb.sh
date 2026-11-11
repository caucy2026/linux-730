#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) gnome-disk-utility
# 3.36.3-0ubuntu1 arm64 as kemi-gnome-disk-utility.
# No common/data or typelib package.
# Official binaries: gnome-disks, gnome-disk-image-mounter,
#   /usr/libexec/gsd-disk-utility-notify.
# Probe: aarch64 · 3 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
#   gnome-disks: GTK3 + GDK3 + cairo/pango/atk + libcanberra-gtk3
#     + libudisks2 + liblzma + libsecret + libpwquality +
#     libsystemd + GIO/GObject/GLib + pthread + libm + libc
#   gnome-disk-image-mounter: GTK3 + pango + libudisks2 +
#     libsystemd + GIO/GObject/GLib + libc
#   gsd-disk-utility-notify: libnotify + libudisks2 +
#     GIO/GObject/GLib + libc
# Official Depends already match Ubuntu 20.04 (udisks2,
#   dconf-gsettings-backend | gsettings-backend, libatk1.0-0,
#   libc6 >= 2.17, libcairo2, libcanberra-gtk3-0,
#   libgdk-pixbuf2.0-0, libglib2.0-0, libgtk-3-0, liblzma5,
#   libnotify4, libpango-1.0-0, libpangocairo-1.0-0,
#   libpwquality1, libsecret-1-0, libsystemd0, libudisks2-0).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). Newer than focal Release 3.36.1-1ubuntu1; still
#   U20-compatible. No librarian URL is recorded this run.
# Official ELFs embed compiled /usr/share/locale (gettext). UI
#   is GResource under /org/gnome/Disks/ui/ (embedded). Layout
#   therefore keeps official ELFs at /usr/bin and /usr/libexec;
#   /opt/gnome-disk-utility/* are symlinks (HardInfo/Xpad/
#   qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole).
# Official desktop Icon=org.gnome.DiskUtility (icons shipped).
# Official language-pack split: no .mo in this deb (do not
#   invent/bundle language packs). Reuse existing unpacked tree;
#   do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-disk-utility
VER_UP=3.36.3
VER_DEB="${VER_UP}-0ubuntu1kemi1"
ARCH=arm64
PKG=kemi-gnome-disk-utility
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gnome-disk-utility-3.36.3-0ubuntu1-focal-unpack}"
UP_DEB="$DL/gnome-disk-utility_3.36.3-0ubuntu1_arm64.deb"
EXPECT_SHA=bb7ee1bb1d95a856b9a5df548b37ba726c5ec6de40be6ae12667568ef43ebab6
EXPECT_BYTES=172072
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-disks"
test -x "$UNPACK/usr/bin/gnome-disk-image-mounter"
test -x "$UNPACK/usr/libexec/gsd-disk-utility-notify"
test -f "$UNPACK/usr/share/applications/org.gnome.DiskUtility.desktop"
test -f "$UNPACK/usr/share/applications/gnome-disk-image-mounter.desktop"
test -f "$UNPACK/usr/share/applications/gnome-disk-image-writer.desktop"
test -f "$UNPACK/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.DiskUtility.service"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Disks.gschema.xml"
test -f "$UNPACK/usr/share/man/man1/gnome-disks.1.gz"
test -f "$UNPACK/usr/share/man/man1/gnome-disk-image-mounter.1.gz"
test -f "$UNPACK/usr/share/metainfo/org.gnome.DiskUtility.appdata.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.DiskUtility.svg"
# official language-pack split: no .mo in this deb
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/gnome-disks")
grep -q '/org/gnome/Disks/ui/' < <(strings -n 8 "$UNPACK/usr/bin/gnome-disks")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/libexec" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/usr/share/dbus-1/services" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/etc/xdg/autostart" \
  "$STAGE/pkg/opt/gnome-disk-utility"

cp -al "$UNPACK/usr/bin/gnome-disks" "$STAGE/pkg/usr/bin/gnome-disks"
cp -al "$UNPACK/usr/bin/gnome-disk-image-mounter" "$STAGE/pkg/usr/bin/gnome-disk-image-mounter"
cp -al "$UNPACK/usr/libexec/gsd-disk-utility-notify" "$STAGE/pkg/usr/libexec/gsd-disk-utility-notify"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-disks" \
  "$STAGE/pkg/usr/bin/gnome-disk-image-mounter" \
  "$STAGE/pkg/usr/libexec/gsd-disk-utility-notify"

REPORT="$ROOT/probe/kemi-gnome-disk-utility.json"
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
for e in "${ELFS[@]}"; do PROBE_ARGS+=(--elf "$e"); done
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
for name in ("gnome-disks", "gnome-disk-image-mounter", "gsd-disk-utility-notify"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["gnome-disks"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libcanberra-gtk3.so.0",
            "libudisks2.so.0", "liblzma.so.5", "libsecret-1.so.0",
            "libpwquality.so.1", "libsystemd.so.0", "libpangocairo-1.0.so.0",
            "libpango-1.0.so.0", "libatk-1.0.so.0", "libcairo.so.2",
            "libgdk_pixbuf-2.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0", "libpthread.so.0", "libm.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
notify_needed = set(by["gsd-disk-utility-notify"].get("neededLibraries") or [])
if "libnotify.so.4" not in notify_needed:
    raise SystemExit("PROBE_MISSING_libnotify")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=3")
PY

mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/gnome-disks.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gnome-disks.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/gnome-disk-image-mounter.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gnome-disk-image-mounter.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.gnome.DiskUtility.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.gnome.DiskUtility.appdata.xml"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Disks.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.Disks.gschema.xml"
cp -a --remove-destination "$UNPACK/usr/share/dbus-1/services/org.gnome.DiskUtility.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.DiskUtility.service"
# official autostart already has absolute Exec; keep as conffile
cp -a --remove-destination \
  "$UNPACK/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop" \
  "$STAGE/pkg/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.DiskUtility.svg"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
grep -q 'Exec=/usr/bin/gnome-disks --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.DiskUtility.service"
grep -q '^Exec=/usr/libexec/gsd-disk-utility-notify$' \
  "$STAGE/pkg/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop"
grep -q '^OnlyShowIn=GNOME;$' \
  "$STAGE/pkg/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop"
grep -q '^NoDisplay=true$' \
  "$STAGE/pkg/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop"

if [[ -f "$UNPACK/usr/share/doc/gnome-disk-utility/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gnome-disk-utility/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/gnome-disk-utility/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gnome-disk-utility/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src: Path, dst: Path, binary: str, icon: str, must_execs):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(rf"^Exec={re.escape(binary)}\b", f"Exec=/usr/bin/{binary}", text, flags=re.M)
    text2 = re.sub(rf"^TryExec={re.escape(binary)}$", f"TryExec=/usr/bin/{binary}", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(
            rf"^(Exec=/usr/bin/{re.escape(binary)}(?:\s.*)?)$",
            rf"\1\nTryExec=/usr/bin/{binary}",
            text2, count=1, flags=re.M,
        )
    if re.search(rf"^Exec={re.escape(binary)}(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {src}")
    if f"TryExec=/usr/bin/{binary}" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC {src}")
    if not re.search(rf"^Icon={re.escape(icon)}$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON {src}")
    for needle in must_execs:
        if needle not in text2:
            raise SystemExit(f"MISSING_{needle}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

base = Path("$UNPACK/usr/share/applications")
out = Path("$STAGE/pkg/usr/share/applications")
rewrite(base / "org.gnome.DiskUtility.desktop",
        out / "org.gnome.DiskUtility.desktop",
        "gnome-disks", "org.gnome.DiskUtility",
        ["Exec=/usr/bin/gnome-disks"])
rewrite(base / "gnome-disk-image-writer.desktop",
        out / "gnome-disk-image-writer.desktop",
        "gnome-disks", "drive-removable-media",
        ["Exec=/usr/bin/gnome-disks --restore-disk-image %U"])
rewrite(base / "gnome-disk-image-mounter.desktop",
        out / "gnome-disk-image-mounter.desktop",
        "gnome-disk-image-mounter", "drive-removable-media",
        ["Exec=/usr/bin/gnome-disk-image-mounter %U"])
PY

ln -sf /usr/bin/gnome-disks "$STAGE/pkg/opt/gnome-disk-utility/gnome-disks"
ln -sf /usr/bin/gnome-disk-image-mounter "$STAGE/pkg/opt/gnome-disk-utility/gnome-disk-image-mounter"
ln -sf /usr/libexec/gsd-disk-utility-notify "$STAGE/pkg/opt/gnome-disk-utility/gsd-disk-utility-notify"
ln -sf gnome-disks "$STAGE/pkg/usr/bin/kemi-gnome-disks"
ln -sf gnome-disks "$STAGE/pkg/usr/bin/kemi-gnome-disk-utility"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Disks
Source: https://launchpad.net/ubuntu/+source/gnome-disk-utility
Homepage: https://wiki.gnome.org/Apps/Disks
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(gnome-disk-utility_3.36.3-0ubuntu1_arm64.deb) repackaged for
KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-disk-utility_3.36.3-0ubuntu1_arm64.deb
    (focal-updates main; newer than Release 3.36.1-1ubuntu1)
    repackaged for KEMI as ${PKG}.
  * Official ELFs stay at /usr/bin/gnome-disks,
    /usr/bin/gnome-disk-image-mounter and
    /usr/libexec/gsd-disk-utility-notify because they embed
    compiled /usr/share/locale (UI is GResource). 
    /opt/gnome-disk-utility/* are symlinks.
  * Desktop, D-Bus service, official autostart conffile
    (OnlyShowIn=GNOME; NoDisplay=true), gschema, man, metainfo
    and icons stay on standard paths. Official desktop
    Icon=org.gnome.DiskUtility (icons shipped). Official
    language-pack split: no .mo in this deb.
  * Conflicts/Replaces gnome-disk-utility. Breaks
    gnome-settings-daemon (<< 3.24) kept.
  * Depends kept for Ubuntu 20.04 (udisks2, GTK3,
    libcanberra-gtk3, pango, cairo, libnotify, libsecret,
    libpwquality, liblzma, libsystemd, libudisks2, dconf
    gsettings backend, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:32:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Disks ${VER_UP}-0ubuntu1 — official Ubuntu 20.04
(focal-updates) arm64, KEMI repack.

Official ELFs stay at /usr/bin/gnome-disks,
/usr/bin/gnome-disk-image-mounter and
/usr/libexec/gsd-disk-utility-notify (compiled
/usr/share/locale; UI is GResource).
/opt/gnome-disk-utility/* are symlinks.
Desktop, D-Bus, official autostart conffile, gschema, man,
metainfo and icons remain on standard paths.
Official desktop Icon=org.gnome.DiskUtility (icons shipped).
Official language-pack split: no .mo in this deb.
Probe: aarch64 · 3 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + udisks2 + libcanberra-gtk3; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (udisks2, GTK3, libcanberra-gtk3,
pango, cairo, libnotify, libsecret, libpwquality, liblzma,
libsystemd, libudisks2, dconf gsettings backend, libc6 >= 2.17).
Official publication: Ubuntu 20.04 focal-updates main arm64
gnome-disk-utility 3.36.3-0ubuntu1 (newer than Release
3.36.1-1ubuntu1; still U20-compatible). Official SHA256 + size
matched ports.ubuntu.com pool files and focal-updates main
arm64 Packages stanzas.
合主线：gork.bot协助开发
EOT

printf '%s\n' '/etc/xdg/autostart/org.gnome.SettingsDaemon.DiskUtilityNotify.desktop' \
  > "$STAGE/pkg/DEBIAN/conffiles"

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: udisks2 (>= 2.7.6), dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libcanberra-gtk3-0 (>= 0.25), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.2), libgtk-3-0 (>= 3.21.5), liblzma5 (>= 5.1.1alpha+20120614), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libpwquality1 (>= 1.1.0), libsecret-1-0 (>= 0.7), libsystemd0 (>= 209), libudisks2-0 (>= 2.7.6)
Breaks: gnome-settings-daemon (<< 3.24)
Conflicts: gnome-disk-utility
Replaces: gnome-disk-utility
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Disks
Description: manage and configure disk drives and media (arm64)
 GNOME Disks ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Manage and configure disk drives and media (udisks).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
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
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-disk-utility-control.txt"
