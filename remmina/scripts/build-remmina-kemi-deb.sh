#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) remmina
# 1.4.25+dfsg-0ubuntu0.20.04.1 arm64 as kemi-remmina,
# bundling same-source hard-Depends remmina-common and
# official Recommends plugins rdp/vnc/secret (same-source;
# required for advertised RDP/VNC + secret storage; official
# plugin debs Depends remmina (= exact version) and cannot
# later be apt-installed next to kemi-remmina). Official
# Suggests exec/kwallet/spice/www are not bundled.
# Official binaries: /usr/bin/remmina (ELF) and
#   /usr/bin/remmina-file-wrapper (bash). Plugins live at
#   /usr/lib/aarch64-linux-gnu/remmina/plugins/.
# Probe: aarch64 · 4 ELF · all requiredGlibc 2.17 · no
#   GLIBCXX · PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal-updates main arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   Newer than focal Release 1.4.2+dfsg-1ubuntu1 and still
#   U20-compatible (libc6 >= 2.17). No librarian URL.
# ELF embeds /usr/share/locale, /usr/lib/.../remmina/plugins,
#   /usr/share/remmina/{theme,ui,external_tools}. Wrapper
#   hardcodes /usr/bin/remmina. Layout keeps official files
#   at /usr; /opt/remmina/* are symlinks (HardInfo/Xpad/
#   qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/
#   GNOME System Monitor/GParted/Seahorse). Official desktop
#   Icon=org.remmina.Remmina (PNG+SVG shipped). Official
#   language-pack split: no .mo / no help in these debs.
#   Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-remmina
VER_UP=1.4.25
VER_DEB="${VER_UP}+dfsg-20.04.1kemi1"
ARCH=arm64
PKG=kemi-remmina
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/remmina-1.4.25-focal-updates-unpack}"
UP_DEB="$DL/remmina_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb"
UP_COMMON="$DL/remmina-common_1.4.25+dfsg-0ubuntu0.20.04.1_all.deb"
UP_RDP="$DL/remmina-plugin-rdp_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb"
UP_VNC="$DL/remmina-plugin-vnc_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb"
UP_SECRET="$DL/remmina-plugin-secret_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"

check() { # file sha bytes
  test -f "$1"
  test "$(stat -c%s "$1")" = "$3"
  echo "$2  $1" | sha256sum -c -
}
check "$UP_DEB"    6ebacf89c9ef9113b34bc12d4f55b82cfdc2faf4ba14585167249747fb6d01da 187640
check "$UP_COMMON" d34f873d1e56942126cd36f0ad0f31d298ab757253cec6a356d62fcedc96590a 129772
check "$UP_RDP"    0969ce732292053f35f3b6ab5595b23c8676ce85b898e3807055f50b129aa691 45732
check "$UP_VNC"    a77988b272ea292a397384d47cea431e09de4df40a4eb792baa7795916dd0d8d 18504
check "$UP_SECRET" 8d272040af63331662a1cb1bb9b3b56465761cfe9ffca96aa40732a3a31a6aa9 6196

test -x "$UNPACK/usr/bin/remmina"
test -x "$UNPACK/usr/bin/remmina-file-wrapper"
head -n 1 "$UNPACK/usr/bin/remmina-file-wrapper" | grep -qx '#!/usr/bin/env bash'
grep -q 'REMMINA="/usr/bin/remmina"' "$UNPACK/usr/bin/remmina-file-wrapper"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/remmina/plugins/remmina-plugin-rdp.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/remmina/plugins/remmina-plugin-vnc.so"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/remmina/plugins/remmina-plugin-secret.so"
test -f "$UNPACK/usr/share/applications/org.remmina.Remmina.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.remmina.Remmina.svg"
test -f "$UNPACK/usr/share/mime/packages/remmina-mime.xml"
test ! -d "$UNPACK/usr/share/remmina/ui"
test ! -d "$UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/remmina")
grep -qx '/usr/lib/aarch64-linux-gnu/remmina/plugins' < <(strings -n 8 "$UNPACK/usr/bin/remmina")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/remmina/plugins" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/remmina"

cp -al "$UNPACK/usr/bin/remmina" "$STAGE/pkg/usr/bin/remmina"
cp -a --remove-destination "$UNPACK/usr/bin/remmina-file-wrapper" \
  "$STAGE/pkg/usr/bin/remmina-file-wrapper"
chmod 0755 "$STAGE/pkg/usr/bin/remmina" "$STAGE/pkg/usr/bin/remmina-file-wrapper"
grep -q 'REMMINA="/usr/bin/remmina"' "$STAGE/pkg/usr/bin/remmina-file-wrapper"
for plug in remmina-plugin-rdp.so remmina-plugin-vnc.so remmina-plugin-secret.so; do
  cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/remmina/plugins/$plug" \
    "$STAGE/pkg/usr/lib/aarch64-linux-gnu/remmina/plugins/$plug"
done

REPORT="$ROOT/probe/kemi-remmina.json"
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
test "${#ELFS[@]}" = 4
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
if len(files) != 4:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
expect = {"remmina", "remmina-plugin-rdp.so", "remmina-plugin-vnc.so", "remmina-plugin-secret.so"}
if set(by) != expect:
    raise SystemExit(f"PROBE_UNEXPECTED_NAMES {sorted(by)}")
for name in expect:
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["remmina"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libpango-1.0.so.0", "libcairo.so.2",
            "libgobject-2.0.so.0", "libglib-2.0.so.0", "libgio-2.0.so.0",
            "libssh.so.4", "libgcrypt.so.20", "libavahi-client.so.3",
            "libavahi-ui-gtk3.so.0", "libvte-2.91.so.0", "libsodium.so.23",
            "libappindicator3.so.1", "libjson-glib-1.0.so.0", "libsoup-2.4.so.1",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
rdp = set(by["remmina-plugin-rdp.so"].get("neededLibraries") or [])
for lib in ("libfreerdp2.so.2", "libfreerdp-client2.so.2", "libwinpr2.so.2", "libcups.so.2"):
    if lib not in rdp:
        raise SystemExit(f"PROBE_MISSING_RDP_{lib}")
if "libvncclient.so.1" not in set(by["remmina-plugin-vnc.so"].get("neededLibraries") or []):
    raise SystemExit("PROBE_MISSING_VNC")
if "libsecret-1.so.0" not in set(by["remmina-plugin-secret.so"].get("neededLibraries") or []):
    raise SystemExit("PROBE_MISSING_SECRET")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=4")
PY

cp -a "$UNPACK/usr/share/remmina" "$STAGE/pkg/usr/share/remmina"
test ! -d "$STAGE/pkg/usr/share/remmina/ui"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/mime/packages"
cp -a --remove-destination "$UNPACK/usr/share/mime/packages/remmina-mime.xml" \
  "$STAGE/pkg/usr/share/mime/packages/remmina-mime.xml"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/remmina.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/remmina.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/remmina-file-wrapper.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/remmina-file-wrapper.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.remmina.Remmina.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.remmina.Remmina.appdata.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.remmina.Remmina.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0

if [[ -f "$UNPACK/usr/share/doc/remmina/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/remmina/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/remmina/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/remmina/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/remmina/README.md" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/remmina/README.md" \
    "$STAGE/pkg/usr/share/doc/$PKG/README.upstream.md"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src_dir = Path("$UNPACK/usr/share/applications")
dst_dir = Path("$STAGE/pkg/usr/share/applications")
for src in sorted(src_dir.glob("*.desktop")):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=remmina-file-wrapper(\s.*)?$",
                   r"Exec=/usr/bin/remmina-file-wrapper\1", text, flags=re.M)
    text2 = re.sub(r"^TryExec=remmina-file-wrapper$",
                   "TryExec=/usr/bin/remmina-file-wrapper", text2, flags=re.M)
    if re.search(r"^Exec=remmina-file-wrapper(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {src.name}")
    if re.search(r"^TryExec=remmina-file-wrapper$", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_TRYEXEC {src.name}")
    if "Icon=org.remmina.Remmina" not in text2:
        raise SystemExit(f"MISSING_ICON {src.name}")
    dst_dir.joinpath(src.name).write_text(text2, encoding="utf-8")
    print("desktop_rewritten", src.name)
main = (dst_dir / "org.remmina.Remmina.desktop").read_text(encoding="utf-8")
if "Exec=/usr/bin/remmina-file-wrapper %U" not in main:
    raise SystemExit("MISSING_MAIN_EXEC")
if "TryExec=/usr/bin/remmina-file-wrapper" not in main:
    raise SystemExit("MISSING_MAIN_TRYEXEC")
if "Name[zh_CN]=Remmina" not in main:
    raise SystemExit("MISSING_ZH_CN")
if "GenericName[zh_CN]=远程桌面客户端" not in main:
    raise SystemExit("MISSING_ZH_CN_GENERIC")
file_d = (dst_dir / "org.remmina.Remmina-file.desktop").read_text(encoding="utf-8")
if "Exec=/usr/bin/remmina-file-wrapper -c %U" not in file_d:
    raise SystemExit("MISSING_FILE_EXEC")
if "TryExec=/usr/bin/remmina" not in file_d:
    raise SystemExit("MISSING_FILE_TRYEXEC")
PY

ln -sf /usr/bin/remmina "$STAGE/pkg/opt/remmina/remmina"
ln -sf /usr/bin/remmina-file-wrapper "$STAGE/pkg/opt/remmina/remmina-file-wrapper"
ln -sf remmina "$STAGE/pkg/usr/bin/kemi-remmina"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.remmina.org/
Source: https://launchpad.net/ubuntu/+source/remmina
Homepage: https://www.remmina.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(remmina_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb + bundled
same-source remmina-common and official Recommends plugins
rdp/vnc/secret) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 remmina_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb
    (focal-updates main; newer than Release 1.4.2+dfsg-1ubuntu1,
    still U20-compatible) plus bundled same-source hard-Depends
    remmina-common and official Recommends plugins rdp/vnc/secret
    repackaged for KEMI as ${PKG}. Official Suggests
    exec/kwallet/spice/www not bundled.
  * Official ELF stays at /usr/bin/remmina, wrapper at
    /usr/bin/remmina-file-wrapper, plugins at
    /usr/lib/aarch64-linux-gnu/remmina/plugins/. /opt/remmina/*
    are symlinks.
  * Desktop, official MIME, man, metainfo, icons, themes and
    external_tools stay on standard paths. Official desktop
    Icon=org.remmina.Remmina (PNG+SVG shipped). Official
    language-pack split: no .mo and no help in these debs;
    desktop includes zh_CN strings. Official debs ship no
    /usr/share/remmina/ui (UI is compiled into the ELF).
  * Conflicts/Replaces remmina, remmina-common and the bundled
    plugins. Official Breaks remmina-plugin-gnome kept.
  * Depends kept for Ubuntu 20.04, including plugin runtimes
    (libfreerdp2, libvncclient, libsecret, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:55:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Remmina ${VER_UP}+dfsg-0ubuntu0.20.04.1 — official Ubuntu 20.04
(focal-updates) arm64, KEMI repack, bundling official
remmina-common and Recommends plugins rdp/vnc/secret.

Official ELF stays at /usr/bin/remmina, wrapper at
/usr/bin/remmina-file-wrapper, plugins at
/usr/lib/aarch64-linux-gnu/remmina/plugins/. /opt/remmina/*
are symlinks. Desktop, MIME, man, metainfo, icons, themes
and external_tools remain on standard paths.
Official desktop Icon=org.remmina.Remmina (PNG+SVG shipped).
Official language-pack split: no .mo / no help in these debs.
Probe: aarch64 · 4 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends minus bundled remmina-common, plus
plugin runtimes (libfreerdp2, libvncclient, libsecret).
Official Suggests exec/kwallet/spice/www kept as Suggests.
Official publication: Ubuntu 20.04 focal-updates main arm64
remmina 1.4.25+dfsg-0ubuntu0.20.04.1. Official SHA256 + size
matched ports.ubuntu.com pool files and focal-updates main
arm64 Packages stanzas.
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
Depends: default-dbus-session-bus | dbus-session-bus, libappindicator3-1 (>= 0.4.90), libavahi-client3 (>= 0.6.16), libavahi-common3 (>= 0.6.16), libavahi-ui-gtk3-0 (>= 0.6.30), libc6 (>= 2.17), libcairo2 (>= 1.6.0), libcups2 (>= 1.6.0), libfreerdp-client2-2 (>= 2.0.0~git20160317.1.75ae3f5+dfsg1), libfreerdp2-2 (>= 2.3.0+dfsg1), libgcrypt20 (>= 1.8.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.61.2), libgtk-3-0 (>= 3.21.5), libjson-glib-1.0-0 (>= 1.2.0), libpango-1.0-0 (>= 1.14.0), libsecret-1-0 (>= 0.7), libsodium23 (>= 1.0.10), libsoup2.4-1 (>= 2.30.0), libssh-4 (>= 0.8.1), libvncclient1 (>= 0.9.10), libvte-2.91-0 (>= 0.51.90), libwinpr2-2 (>= 2.1.0+dfsg1), libx11-6
Suggests: remmina-plugin-exec, remmina-plugin-kwallet, remmina-plugin-spice, remmina-plugin-www
Breaks: remmina-plugin-gnome
Conflicts: remmina, remmina-common, remmina-plugin-rdp, remmina-plugin-vnc, remmina-plugin-secret, remmina-plugin-gnome
Replaces: remmina, remmina-common, remmina-plugin-rdp, remmina-plugin-vnc, remmina-plugin-secret, remmina-plugin-gnome
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.remmina.org/
Description: GTK+ remote desktop client (arm64)
 Remmina ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack
 with remmina-common and RDP/VNC/secret plugins.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
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
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-remmina-control.txt"
