#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) pcmanfm
# 1.3.1-1 arm64 as kemi-pcmanfm. There is no same-source
# common/data/typelib package (single official binary).
# Official same-source pcmanfm-dbg is a debug package
#   (Depends: pcmanfm (= 1.3.1-1)) and is not bundled.
# pcmanfm-qt is a different source and is not this package.
# libfm-gtk4, libfm4, GTK2 and shared-mime-info are
#   different-source system Depends and are not bundled.
# Official Recommends (gvfs-backends, gvfs-fuse, lxpolkit or
#   other polkit agent, icon themes) stay Recommends and are
#   not bundled.
# Official binary: /usr/bin/pcmanfm.
# Official empty plugin dir /usr/lib/aarch64-linux-gnu/pcmanfm
#   is kept because the ELF embeds that path.
# Official UI files stay at /usr/share/pcmanfm/ui/*.ui (do not
#   invent additional UI or icons).
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# ELF embeds /usr/share/locale, /usr/lib/aarch64-linux-gnu/pcmanfm
#   and /usr/share/pcmanfm/ui/*.ui. Layout keeps official files
#   at /usr/bin; /opt/pcmanfm/* are symlinks (HardInfo/Xpad/
#   qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/
#   GNOME System Monitor/GParted/Seahorse/Remmina/dconf-editor/
#   xfce4-terminal/thunar). Official desktop Icon=system-file-manager
#   and Icon=user-desktop (theme icons; this deb ships no icons —
#   do not invent any). Official language-pack split does not
#   apply here: this deb ships 54 .mo including zh_CN. Keep the
#   official tree; do not invent/bundle language-packs. No help
#   directory in this deb.
# KEMI version 1.3.1-1kemi1 is 12 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-pcmanfm
VER_UP=1.3.1
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-pcmanfm
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/pcmanfm-1.3.1-focal-unpack}"
UP_DEB="$DL/pcmanfm_1.3.1-1_arm64.deb"
EXPECT_SHA=2a8f7fb398f73ecbf4f7355f1f2266669b90bc1f0c585a876be50de2c67092c1
EXPECT_BYTES=267124
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/pcmanfm"
test -d "$UNPACK/usr/lib/aarch64-linux-gnu/pcmanfm"
test -f "$UNPACK/usr/share/applications/pcmanfm.desktop"
test -f "$UNPACK/usr/share/applications/pcmanfm-desktop-pref.desktop"
test -f "$UNPACK/usr/share/pcmanfm/ui/about.ui"
test -f "$UNPACK/usr/share/pcmanfm/ui/pref.ui"
test -f "$UNPACK/etc/xdg/pcmanfm/default/pcmanfm.conf"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/pcmanfm.mo"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 54
test ! -d "$UNPACK/usr/share/help"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/pcmanfm")
grep -qx '/usr/lib/aarch64-linux-gnu/pcmanfm' < <(strings -n 8 "$UNPACK/usr/bin/pcmanfm")
grep -qx '/usr/share/pcmanfm/ui/about.ui' < <(strings -n 8 "$UNPACK/usr/bin/pcmanfm")
test ! -L "$UNPACK/usr/share/doc/pcmanfm/changelog.Debian.gz"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pcmanfm" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/pcmanfm/ui" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/etc/xdg/pcmanfm/default" \
  "$STAGE/pkg/opt/pcmanfm"

cp -al "$UNPACK/usr/bin/pcmanfm" "$STAGE/pkg/usr/bin/pcmanfm"
chmod 0755 "$STAGE/pkg/usr/bin/pcmanfm"

REPORT="$ROOT/probe/kemi-pcmanfm.json"
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
test "${#ELFS[@]}" = 1
python3 "$PROBE_PY" --elf "${ELFS[0]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
if Path(f["path"]).name != "pcmanfm":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libfm-gtk.so.4", "libfm.so.4", "libgtk-x11-2.0.so.0",
            "libgdk-x11-2.0.so.0", "libX11.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=1")
PY

# official locales, UI, conffile, man — keep official tree
cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
cp -a "$UNPACK/usr/share/pcmanfm/ui/." "$STAGE/pkg/usr/share/pcmanfm/ui/"
cp -a --remove-destination \
  "$UNPACK/etc/xdg/pcmanfm/default/pcmanfm.conf" \
  "$STAGE/pkg/etc/xdg/pcmanfm/default/pcmanfm.conf"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/pcmanfm.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/pcmanfm.1.gz"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 54
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/pcmanfm.mo"
test -f "$STAGE/pkg/usr/share/pcmanfm/ui/about.ui"
test -f "$STAGE/pkg/usr/share/pcmanfm/ui/pref.ui"
test -f "$STAGE/pkg/usr/share/pcmanfm/ui/desktop-pref.ui"
test -f "$STAGE/pkg/usr/share/pcmanfm/ui/autorun.ui"
test -f "$STAGE/pkg/usr/share/pcmanfm/ui/connect.ui"
test -d "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pcmanfm"
# official package ships no icons and no help
test "$(find "$STAGE/pkg" \( -name '*.png' -o -name '*.svg' \) | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"

if [[ -f "$UNPACK/usr/share/doc/pcmanfm/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/pcmanfm/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/pcmanfm/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/pcmanfm/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src, dst, expect_exec, icon, name):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=pcmanfm(\s.*)?$", r"Exec=/usr/bin/pcmanfm\1", text, flags=re.M)
    text2 = re.sub(r"^TryExec=pcmanfm$", "TryExec=/usr/bin/pcmanfm", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^(Exec=/usr/bin/pcmanfm(?:\s.*)?)$",
                       r"\1\nTryExec=/usr/bin/pcmanfm", text2, count=1, flags=re.M)
    if re.search(r"^Exec=pcmanfm(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC:{src.name}")
    if expect_exec not in text2:
        raise SystemExit(f"MISSING_EXEC:{src.name}")
    if "TryExec=/usr/bin/pcmanfm" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC:{src.name}")
    if not re.search(rf"^Icon={re.escape(icon)}$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON:{src.name}")
    if name not in text2:
        raise SystemExit(f"MISSING_NAME:{src.name}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

base = Path("$UNPACK/usr/share/applications")
out = Path("$STAGE/pkg/usr/share/applications")
rewrite(base / "pcmanfm.desktop", out / "pcmanfm.desktop",
        "Exec=/usr/bin/pcmanfm %U", "system-file-manager",
        "Name=File Manager PCManFM")
rewrite(base / "pcmanfm-desktop-pref.desktop", out / "pcmanfm-desktop-pref.desktop",
        "Exec=/usr/bin/pcmanfm --desktop-pref", "user-desktop",
        "Name=Desktop Preferences")
PY

ln -sf /usr/bin/pcmanfm "$STAGE/pkg/opt/pcmanfm/pcmanfm"
ln -sf pcmanfm "$STAGE/pkg/usr/bin/kemi-pcmanfm"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://pcmanfm.sourceforge.net/
Source: https://launchpad.net/ubuntu/+source/pcmanfm
Homepage: http://pcmanfm.sourceforge.net/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(pcmanfm_1.3.1-1_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 pcmanfm_1.3.1-1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. No same-source
    common/data/typelib package. pcmanfm-dbg and the
    different-source pcmanfm-qt are not bundled.
  * Official ELF stays at /usr/bin/pcmanfm (compiled
    /usr/share/locale, /usr/share/pcmanfm/ui and
    /usr/lib/aarch64-linux-gnu/pcmanfm). /opt/pcmanfm/*
    are symlinks.
  * Desktop, man, official 54 .mo (including zh_CN),
    official UI files and /etc/xdg/pcmanfm/default/pcmanfm.conf
    stay on standard paths. Official desktop Exec=pcmanfm
    rewritten to /usr/bin/pcmanfm; Icon=system-file-manager
    and Icon=user-desktop (theme icons; this deb ships no
    icons). Official empty plugin dir is kept.
  * Conflicts/Replaces pcmanfm. Official Depends kept for
    Ubuntu 20.04 (GTK2, libfm-gtk4, libfm4, libc6 >= 2.17).
    Official Recommends gvfs / polkit agent / icon themes
    kept as Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:25:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
PCMan File Manager ${VER_UP}-1 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack.

Official ELF stays at /usr/bin/pcmanfm (compiled
/usr/share/locale, /usr/share/pcmanfm/ui and
/usr/lib/aarch64-linux-gnu/pcmanfm). /opt/pcmanfm/*
are symlinks.
Desktop, man, official locales, official UI and the
default conffile remain on standard paths.
Official desktop Icon=system-file-manager /
Icon=user-desktop (theme icons; no icons shipped in
this deb — do not invent any).
Official language-pack split does not apply: this deb
ships 54 .mo including zh_CN.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GTK2, libfm-gtk4, libfm4,
libc6 >= 2.17). Official Recommends gvfs / polkit /
icon themes kept as Recommends.
Official publication: Ubuntu 20.04 focal universe arm64
pcmanfm 1.3.1-1. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libfm-gtk4 (>= 1.2.0), libfm4 (>= 1.2.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk2.0-0 (>= 2.24.0), libpango-1.0-0 (>= 1.20.0), libpangocairo-1.0-0 (>= 1.14.0), libx11-6, shared-mime-info
Recommends: gvfs-backends, gvfs-fuse, lxpolkit | polkit-1-auth-agent | policykit-1-gnome, lxde-icon-theme | gnome-icon-theme | oxygen-icon-theme | tango-icon-theme
Conflicts: pcmanfm
Replaces: pcmanfm
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://pcmanfm.sourceforge.net/
Description: extremely fast and lightweight file manager (arm64)
 PCMan File Manager ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 GTK+ 2 file manager with tabbed browsing.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

printf '%s\n' '/etc/xdg/pcmanfm/default/pcmanfm.conf' > "$STAGE/pkg/DEBIAN/conffiles"

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
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
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-pcmanfm-control.txt"
