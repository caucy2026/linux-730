#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) blueman
# 2.1.2-1ubuntu0.3 arm64 as kemi-blueman.
# Release (focal universe) has older 2.1.2-1; this run uses the
#   newer still-U20-compatible focal-updates package (LP #1877524
#   plus prior focal-security CVE-2020-15238 / polkit fixes).
# There is no same-source common/data package and no exact-version
#   hard Depends to bundle. libbluetooth3, libglib2.0-0, Python 3,
#   typelibs (gir1.2-gtk-3.0 etc.), bluez, dbus and icon-theme
#   alternatives are different-source / system Depends and are
#   not bundled. Official Recommends (policykit-1,
#   pulseaudio-module-bluetooth) stay Recommends.
# Official package is Architecture: arm64 (not arch:all): one
#   native extension _blueman.cpython-38-aarch64-linux-gnu.so
#   plus Python 3 scripts (#! /usr/bin/python3). Official
#   Depends: python3 (>= 3.8~), python3 (<< 3.9) — matches
#   Ubuntu 20.04 Python 3.8. No PEP 585 list[T]/dict[T]
#   constructs were found in the official .py tree. No wrong-arch
#   (x86_64/i386) natives are shipped.
# Probe: aarch64 · 1 ELF (the cpython-38 extension) ·
#   requiredGlibc 2.17 · no GLIBCXX · PASS vs 101 ≤2.31 /
#   GLIBCXX ≤3.4.28. Launchers are Python scripts, not ELF.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No librarian URL and no .buildinfo is recorded this run
#   (pool 404). This round is not based on Launchpad librarian.
# blueman.Constants hard-codes PREFIX=/usr, BIN_DIR=/usr/bin,
#   PKGDATA_DIR=/usr/share/blueman, LOCALEDIR=/usr/share/locale,
#   UI_PATH=/usr/share/blueman/ui, RFCOMM_WATCHER_PATH=
#   /usr/lib/blueman/blueman-rfcomm-watcher. Official scripts,
#   the aarch64 extension, UI and helpers stay on official
#   paths; /opt/blueman/* are symlinks. Official D-Bus and
#   systemd Exec paths are already absolute /usr/... and are
#   kept. Official desktop Icon=blueman / blueman-device
#   (hicolor icons and pixmaps shipped). Official language-pack
#   split does not apply: this deb ships 56 .mo including
#   zh_CN. Keep the official tree; do not invent/bundle
#   language-packs or UI/icons. Official UI stays under
#   /usr/share/blueman/ui. No /usr/share/help directory.
# Official conffiles: /etc/dbus-1/system.d/org.blueman.Mechanism.conf
#   and /etc/xdg/autostart/blueman.desktop (kept; autostart
#   Exec rewritten to /usr/bin/blueman-applet). Packaged
#   changelog is dereferenced from official changelog.Debian.gz
#   (cp -L). Official maintainer scripts (systemd helper +
#   py3compile/py3clean) are kept, with the dpkg package name
#   changed to kemi-blueman.
# KEMI version 2.1.2-1ubuntu0.3kemi1 is 21 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string;
#   filezilla 3.46.3-1ubuntu0.1kemi1 was 22 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-blueman
VER_UP=2.1.2
VER_DEB="${VER_UP}-1ubuntu0.3kemi1"
ARCH=arm64
PKG=kemi-blueman
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/blueman-2.1.2-focal-unpack}"
UP_DEB="$DL/blueman_2.1.2-1ubuntu0.3_arm64.deb"
EXPECT_SHA=4d1d51c8314061953d8a3ba94f307e745da615679e935c8d24bdf237fa743eb1
EXPECT_BYTES=648492
SO_REL=usr/lib/python3/dist-packages/_blueman.cpython-38-aarch64-linux-gnu.so
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/blueman-manager"
test -x "$UNPACK/usr/bin/blueman-applet"
test -f "$UNPACK/$SO_REL"
test -f "$UNPACK/usr/share/applications/blueman-manager.desktop"
test -f "$UNPACK/usr/share/blueman/ui/manager-main.ui"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/blueman.mo"
test -f "$UNPACK/usr/lib/python3/dist-packages/blueman/Constants.py"
test -f "$UNPACK/lib/systemd/system/blueman-mechanism.service"
test -f "$UNPACK/etc/dbus-1/system.d/org.blueman.Mechanism.conf"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 56
test ! -d "$UNPACK/usr/share/help"
# compiled /usr prefix in Constants.py — process substitution, no SIGPIPE
grep -qx 'PREFIX = "/usr"' < <(cat "$UNPACK/usr/lib/python3/dist-packages/blueman/Constants.py")
grep -qx 'BIN_DIR = "/usr/bin"' < <(cat "$UNPACK/usr/lib/python3/dist-packages/blueman/Constants.py")
grep -qx 'PKGDATA_DIR = "/usr/share/blueman"' < <(cat "$UNPACK/usr/lib/python3/dist-packages/blueman/Constants.py")
grep -q 'RFCOMM_WATCHER_PATH = "/usr/lib/blueman/blueman-rfcomm-watcher"' \
  < <(cat "$UNPACK/usr/lib/python3/dist-packages/blueman/Constants.py")
test ! -L "$UNPACK/usr/share/doc/blueman/changelog.Debian.gz"
# no wrong-arch natives
python3 - << PY
from pathlib import Path
root = Path("$UNPACK")
magic = bytes([0x7F]) + b"ELF"
elves = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elves.append(p)
if len(elves) != 1:
    raise SystemExit(f"UNEXPECTED_ELF_COUNT {len(elves)}")
rel = elves[0].relative_to(root).as_posix()
if rel != "$SO_REL":
    raise SystemExit(f"UNEXPECTED_ELF {rel}")
name = elves[0].name
if "aarch64" not in name or "cpython-38" not in name:
    raise SystemExit(f"UNEXPECTED_SO_NAME {name}")
if "x86_64" in name or "i386" in name or "amd64" in name:
    raise SystemExit(f"WRONG_ARCH {name}")
print("official_elf_ok", rel)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg"
# keep official tree (scripts, extension, UI, icons, dbus, systemd, polkit, conffiles, locales)
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/blueman"

# only the official aarch64 cpython-38 extension plus Python scripts
REPORT="$ROOT/probe/kemi-blueman.json"
rm -f "$REPORT"
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    # skip anything that will live under DEBIAN (none expected)
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PY
)
test "${#ELFS[@]}" = 1
test "${ELFS[0]##*/}" = "_blueman.cpython-38-aarch64-linux-gnu.so"
PROBE_ARGS=(--elf "${ELFS[0]}")
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f = files[0]
name = Path(f["path"]).name
if name != "_blueman.cpython-38-aarch64-linux-gnu.so":
    raise SystemExit(f"PROBE_NAME {name}")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for n in ("libbluetooth.so.3", "libglib-2.0.so.0", "libc.so.6"):
    if n not in needed:
        raise SystemExit(f"PROBE_MISSING_{n}")
print("PROBE_PASS n_elf=1 so=_blueman.cpython-38-aarch64-linux-gnu.so glibc=2.17 no_GLIBCXX")
PY

# official locales / UI already copied; re-assert
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 56
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/blueman.mo"
test -f "$STAGE/pkg/usr/share/blueman/ui/manager-main.ui"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/blueman.png" || test -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/blueman.png"
test ! -d "$STAGE/pkg/usr/share/help"
# no dangling or wrong-arch leftovers
python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
for p in root.rglob("*"):
    if p.is_symlink() and not p.exists():
        raise SystemExit(f"DANGLING {p}")
    n = p.name
    if "x86_64" in n or "amd64" in n or "i386" in n or "cpython-39" in n or "cpython-310" in n or "cpython-37" in n:
        raise SystemExit(f"WRONG_NATIVE {p}")
print("no_dangling_no_wrong_arch")
PY

# kemi changelog from official changelog (dereference)
cp --remove-destination -L "$UNPACK/usr/share/doc/blueman/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L "$UNPACK/usr/share/doc/blueman/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -s "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

rewrites = {
    Path("$STAGE/pkg/usr/share/applications/blueman-manager.desktop"):
        ("blueman-manager", "/usr/bin/blueman-manager", "Name=Bluetooth Manager"),
    Path("$STAGE/pkg/usr/share/applications/blueman-adapters.desktop"):
        ("blueman-adapters", "/usr/bin/blueman-adapters", "Name=Bluetooth Adapters"),
    Path("$STAGE/pkg/etc/xdg/autostart/blueman.desktop"):
        ("blueman-applet", "/usr/bin/blueman-applet", "Name=Blueman Applet"),
    Path("$STAGE/pkg/usr/share/Thunar/sendto/thunar-sendto-blueman.desktop"):
        ("blueman-sendto", "/usr/bin/blueman-sendto", "Name=Bluetooth Device"),
}
for dst, (cmd, abs_cmd, name_line) in rewrites.items():
    text = dst.read_text(encoding="utf-8")
    text2 = re.sub(rf"^Exec={re.escape(cmd)}(\s.*)?$", rf"Exec={abs_cmd}\1", text, flags=re.M)
    text2 = re.sub(rf"^TryExec={re.escape(cmd)}$", f"TryExec={abs_cmd}", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(rf"^(Exec={re.escape(abs_cmd)}(?:\s.*)?)$",
                       rf"\1\nTryExec={abs_cmd}", text2, count=1, flags=re.M)
    if re.search(rf"^Exec={re.escape(cmd)}(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {dst}")
    if f"Exec={abs_cmd}" not in text2:
        raise SystemExit(f"MISSING_EXEC {dst}")
    if f"TryExec={abs_cmd}" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC {dst}")
    if name_line not in text2:
        raise SystemExit(f"MISSING_NAME {dst}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)
# already-absolute D-Bus / systemd Exec must stay
for p, needle in [
    (Path("$STAGE/pkg/usr/share/dbus-1/services/org.blueman.Applet.service"), "Exec=/usr/bin/blueman-applet"),
    (Path("$STAGE/pkg/usr/share/dbus-1/system-services/org.blueman.Mechanism.service"), "Exec=/usr/lib/blueman/blueman-mechanism"),
    (Path("$STAGE/pkg/lib/systemd/system/blueman-mechanism.service"), "ExecStart=/usr/lib/blueman/blueman-mechanism"),
    (Path("$STAGE/pkg/usr/lib/systemd/user/blueman-applet.service"), "ExecStart=/usr/bin/blueman-applet"),
]:
    t = p.read_text(encoding="utf-8")
    if needle not in t:
        raise SystemExit(f"MISSING_ABS_EXEC {p} {needle}")
print("dbus_systemd_absolute_ok")
PY

ln -sf /usr/bin/blueman-manager "$STAGE/pkg/opt/blueman/blueman"
ln -sf blueman-manager "$STAGE/pkg/usr/bin/kemi-blueman"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/blueman-project/blueman
Source: https://launchpad.net/ubuntu/+source/blueman
Homepage: https://github.com/blueman-project/blueman
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(blueman_2.1.2-1ubuntu0.3_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 blueman_2.1.2-1ubuntu0.3_arm64.deb
    (focal-updates universe; newer than Release 2.1.2-1 and
    still U20-compatible; includes LP #1877524 and prior
    focal-security CVE-2020-15238 / polkit fixes) repackaged
    for KEMI as ${PKG}. No same-source common/data package.
  * Official Python launchers stay at /usr/bin; the aarch64
    Python 3.8 extension stays at
    /usr/lib/python3/dist-packages/_blueman.cpython-38-aarch64-linux-gnu.so;
    helpers stay at /usr/lib/blueman. /opt/blueman/* are
    symlinks.
  * Official data, 56 .mo (including zh_CN), icons, pixmaps,
    man, UI, D-Bus, systemd, polkit and conffiles stay on
    standard paths. Desktop Exec rewritten to /usr/bin/...;
    already-absolute D-Bus/systemd Exec kept. Official
    Icon=blueman / blueman-device (icons shipped).
  * Conflicts/Replaces/Provides blueman. Official Depends
    kept for Ubuntu 20.04 (python3 >= 3.8~ and << 3.9,
    typelibs, bluez, libbluetooth3, libc6 >= 2.17). Official
    Recommends policykit-1 / pulseaudio-module-bluetooth kept
    as Recommends. No PEP 585 constructs in the official
    Python tree.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:40:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Blueman ${VER_UP}-1ubuntu0.3 — official Ubuntu 20.04
(focal-updates) universe arm64, KEMI repack.

Official Python launchers stay at /usr/bin; the aarch64
cpython-38 extension and /usr/lib/blueman helpers stay on
official /usr paths. /opt/blueman/* are symlinks.
Desktop, man, official locales, UI, icons, pixmaps, D-Bus,
systemd, polkit and conffiles remain on standard paths.
Official desktop Icon=blueman / blueman-device (hicolor
icons and pixmaps shipped).
Official language-pack split does not apply: this package
ships 56 .mo including zh_CN.
Probe: aarch64 · 1 ELF
(_blueman.cpython-38-aarch64-linux-gnu.so) · requiredGlibc
2.17 · no GLIBCXX; launchers are Python 3.8 scripts;
Ubuntu 20.04 / glibc 2.31 OK. No PEP 585 constructs.
Runtime: official Depends (python3 >= 3.8~ and << 3.9,
typelibs, bluez, libbluetooth3, libc6 >= 2.17). Official
Recommends kept as Recommends. No common/data bundle.
Official publication: Ubuntu 20.04 focal-updates universe
arm64 blueman 2.1.2-1ubuntu0.3. Official SHA256 + size
matched ports.ubuntu.com pool files and focal-updates
universe arm64 Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" --exclude=DEBIAN | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: x11
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libbluetooth3 (>= 4.91), libc6 (>= 2.17), libglib2.0-0 (>= 2.31.8), dconf-gsettings-backend | gsettings-backend, python3 (<< 3.9), python3 (>= 3.8~), python3:any, dbus, default-dbus-session-bus | dbus-session-bus, bluez (>= 5), bluez-obexd, python3-gi (>= 3.27.2), notification-daemon, librsvg2-common, gnome-icon-theme | mate-icon-theme | elementary-xfce-icon-theme | adwaita-icon-theme | papirus-icon-theme, libpulse-mainloop-glib0, gir1.2-gtk-3.0, gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-pango-1.0, python3-cairo, python3-gi-cairo, gir1.2-appindicator3-0.1, gir1.2-nm-1.0
Recommends: policykit-1, pulseaudio-module-bluetooth
Provides: blueman
Conflicts: blueman
Replaces: blueman
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://github.com/blueman-project/blueman
Description: Graphical bluetooth manager (arm64)
 Blueman ${VER_UP} — official Ubuntu 20.04 arm64, KEMI
 repack.
 A GTK+ Bluetooth manager using the BlueZ D-Bus backend.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official conffiles kept
cp --remove-destination -L "$ROOT/probe/official-control/conffiles" \
  "$STAGE/pkg/DEBIAN/conffiles"

# official maintainer scripts, with dpkg package name updated for py3compile
sed 's/py3compile -p blueman/py3compile -p kemi-blueman/g; s/pypy3compile -p blueman/pypy3compile -p kemi-blueman/g' \
  "$ROOT/probe/official-control/postinst" > "$STAGE/pkg/DEBIAN/postinst"
# append desktop / icon / schema refreshes
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
exit 0
EOT
# official postinst has no trailing exit; we added one. Ensure shebang/exec
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

sed 's/py3clean -p blueman/py3clean -p kemi-blueman/g; s/dpkg -L blueman/dpkg -L kemi-blueman/g' \
  "$ROOT/probe/official-control/prerm" > "$STAGE/pkg/DEBIAN/prerm"
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cp --remove-destination -L "$ROOT/probe/official-control/postrm" \
  "$STAGE/pkg/DEBIAN/postrm"
# append cache refreshes before any existing exit
python3 - << PY
from pathlib import Path
p = Path("$STAGE/pkg/DEBIAN/postrm")
text = p.read_text(encoding="utf-8")
extra = '''
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
'''
if text.rstrip().endswith("exit 0"):
    text = text.rstrip()[:-len("exit 0")] + extra + "\nexit 0\n"
else:
    text = text.rstrip() + "\n" + extra
p.write_text(text, encoding="utf-8")
PY
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

# sanity: scripts mention kemi-blueman for python helpers
grep -q 'py3compile -p kemi-blueman' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-blueman' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'blueman-mechanism.service' "$STAGE/pkg/DEBIAN/postinst"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-blueman-control.txt"
