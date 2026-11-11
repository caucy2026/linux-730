#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) gparted 1.0.0-0.1build1 arm64
# as kemi-gparted, bundling same-source hard-Depends
# gparted-common 1.0.0-0.1build1 (arch:all, exact version).
# Official launcher is /usr/sbin/gparted (POSIX shell wrapper);
# the ELF is /usr/sbin/gpartedbin.
# Probe: aarch64 · 1 ELF (gpartedbin) · requiredGlibc 2.17 ·
#   GLIBCXX 3.4.21 · PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
#   GTK3 + gtkmm-3.0 + atkmm + gdkmm + giomm + pangomm +
#   glibmm + cairomm + sigc++ + libparted + libparted-fs-resize
#   + libuuid + libstdc++ + libgcc_s + pthread + libc
# Official Depends already match Ubuntu 20.04 except
#   gparted-common, which is bundled (libc6 >= 2.17, GTK3,
#   gtkmm, glibmm, libparted, policykit-1, libstdc++6).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). No newer focal-updates binary. No librarian URL
#   is recorded this run.
# Wrapper hardcodes /usr/sbin/gpartedbin and pkexec
#   /usr/sbin/gparted; ELF embeds /usr/share/locale. Layout
#   therefore keeps official files at /usr/sbin; /opt/gparted/*
#   are symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/
#   Xfburn/Parole/GNOME Disks/GNOME System Monitor).
# Official desktop Icon=gparted (icons shipped). Official
#   language-pack split: no .mo in these debs; desktop includes
#   zh_CN / zh_TW strings. Reuse existing unpacked tree; do not
#   re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gparted
VER_UP=1.0.0
VER_DEB="${VER_UP}-0.1build1kemi1"
ARCH=arm64
PKG=kemi-gparted
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gparted-1.0.0-0.1build1-focal-unpack}"
UP_DEB="$DL/gparted_1.0.0-0.1build1_arm64.deb"
UP_COMMON="$DL/gparted-common_1.0.0-0.1build1_all.deb"
EXPECT_SHA=0b4f4190b1add58463e75c7b7a7d575fc826a01c05ded39a4aa989e890435514
EXPECT_BYTES=343672
EXPECT_COMMON_SHA=4328f648fd01cd2de485740b202bf754d4262ac493e2f06ea1c0542414af7897
EXPECT_COMMON_BYTES=80776
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB" && test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/sbin/gparted"
test -x "$UNPACK/usr/sbin/gpartedbin"
head -n 1 "$UNPACK/usr/sbin/gparted" | grep -qx '#!/bin/sh'
grep -q 'BASE_CMD="/usr/sbin/gpartedbin \$\*"' "$UNPACK/usr/sbin/gparted"
grep -q "pkexec --disable-internal-agent '/usr/sbin/gparted'" "$UNPACK/usr/sbin/gparted"
test -f "$UNPACK/usr/share/applications/gparted.desktop"
test -f "$UNPACK/usr/share/polkit-1/actions/org.gnome.gparted.policy"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/gparted.svg"
test -f "$UNPACK/usr/share/man/man8/gparted.8.gz"
test -f "$UNPACK/usr/share/metainfo/gparted.appdata.xml"
test -f "$UNPACK/usr/share/help/C/gparted/index.docbook"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test "$(find "$UNPACK/usr/share/help/C/gparted" -type f ! -type l | wc -l)" = 2
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/sbin/gpartedbin")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/sbin" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man8" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/gparted"

cp -a --remove-destination "$UNPACK/usr/sbin/gparted" "$STAGE/pkg/usr/sbin/gparted"
cp -al "$UNPACK/usr/sbin/gpartedbin" "$STAGE/pkg/usr/sbin/gpartedbin"
chmod 0755 "$STAGE/pkg/usr/sbin/gparted" "$STAGE/pkg/usr/sbin/gpartedbin"
# official wrapper paths must stay
grep -q 'BASE_CMD="/usr/sbin/gpartedbin \$\*"' "$STAGE/pkg/usr/sbin/gparted"
grep -q "pkexec --disable-internal-agent '/usr/sbin/gparted'" "$STAGE/pkg/usr/sbin/gparted"

REPORT="$ROOT/probe/kemi-gparted.json"
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
if Path(f["path"]).name != "gpartedbin":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libgtkmm-3.0.so.1",
            "libatkmm-1.6.so.1", "libgdkmm-3.0.so.1", "libgiomm-2.4.so.1",
            "libpangomm-1.4.so.1", "libglibmm-2.4.so.1", "libcairomm-1.0.so.1",
            "libsigc-2.0.so.0", "libparted-fs-resize.so.0", "libparted.so.2",
            "libuuid.so.1", "libstdc++.so.6", "libgcc_s.so.1",
            "libgobject-2.0.so.0", "libglib-2.0.so.0", "libpthread.so.0",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 GLIBCXX=3.4.21 arch=aarch64 n_elf=1")
PY

# official help tree (C real; other locales official help-langpack symlinks)
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/polkit-1/actions"
cp -a --remove-destination "$UNPACK/usr/share/polkit-1/actions/org.gnome.gparted.policy" \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.gparted.policy"
cp -a --remove-destination "$UNPACK/usr/share/man/man8/gparted.8.gz" \
  "$STAGE/pkg/usr/share/man/man8/gparted.8.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/gparted.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/gparted.appdata.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/gparted.svg"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg/usr/share/help/C/gparted" -type f ! -type l | wc -l)" = 2
grep -q 'org.freedesktop.policykit.exec.path">/usr/sbin/gparted<' \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.gparted.policy"

if [[ -f "$UNPACK/usr/share/doc/gparted/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gparted/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/gparted/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gparted/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/gparted.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/gparted.desktop")
text = src.read_text(encoding="utf-8")
# official Exec is already /usr/sbin/gparted %f
text2 = re.sub(r"^Exec=gparted\b", "Exec=/usr/sbin/gparted", text, flags=re.M)
text2 = re.sub(r"^TryExec=gparted$", "TryExec=/usr/sbin/gparted", text2, flags=re.M)
text2 = re.sub(r"^TryExec=/usr/sbin/gparted$", "TryExec=/usr/sbin/gparted", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/sbin/gparted(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/sbin/gparted", text2, count=1, flags=re.M)
if re.search(r"^Exec=gparted(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if "Exec=/usr/sbin/gparted %f" not in text2:
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/sbin/gparted" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=gparted$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name[zh_CN]=GParted" not in text2:
    raise SystemExit("MISSING_ZH_CN")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/sbin/gparted "$STAGE/pkg/opt/gparted/gparted"
ln -sf /usr/sbin/gpartedbin "$STAGE/pkg/opt/gparted/gpartedbin"
ln -sf /usr/sbin/gparted "$STAGE/pkg/usr/bin/kemi-gparted"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gparted.org
Source: https://launchpad.net/ubuntu/+source/gparted
Homepage: https://gparted.org
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(gparted_1.0.0-0.1build1_arm64.deb + bundled same-source
gparted-common_1.0.0-0.1build1_all.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gparted_1.0.0-0.1build1_arm64.deb
    (focal main; no newer focal-updates binary) plus bundled
    same-source hard-Depends gparted-common_1.0.0-0.1build1_all.deb
    repackaged for KEMI as ${PKG}.
  * Official wrapper stays at /usr/sbin/gparted and the ELF at
    /usr/sbin/gpartedbin (wrapper hardcodes those /usr/sbin
    paths; ELF embeds /usr/share/locale). /opt/gparted/* are
    symlinks.
  * Desktop, polkit policy, official help tree, man, metainfo
    and icons stay on standard paths. Official desktop already
    Exec=/usr/sbin/gparted %f; Icon=gparted (icons shipped).
    Official language-pack split: no .mo in these debs; desktop
    includes zh_CN / zh_TW strings; C help is real; other help
    locales are official help-langpack symlinks.
  * Conflicts/Replaces gparted and gparted-common. Official
    Breaks udisks2 (<< 2.1.5) kept.
  * Depends kept for Ubuntu 20.04 (GTK3, gtkmm, glibmm,
    libparted, policykit-1, libc6 >= 2.17, libstdc++6). Official
    Suggests filesystem tools kept as Suggests, not bundled.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:45:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GParted ${VER_UP}-0.1build1 — official Ubuntu 20.04 (focal)
arm64, KEMI repack, bundling official gparted-common.

Official wrapper stays at /usr/sbin/gparted and the ELF at
/usr/sbin/gpartedbin (compiled /usr/share/locale; wrapper
hardcodes /usr/sbin paths). /opt/gparted/* are symlinks.
Desktop, polkit, official help tree, man, metainfo and icons
remain on standard paths.
Official desktop Icon=gparted (icons shipped).
Official language-pack split: no .mo in these debs.
Probe: aarch64 · 1 ELF (gpartedbin) · requiredGlibc 2.17 ·
GLIBCXX 3.4.21 · GTK3 + gtkmm + libparted;
Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Runtime: official Depends minus bundled gparted-common
(GTK3, gtkmm, glibmm, libparted, policykit-1, libc6 >= 2.17,
libstdc++6).
Official publication: Ubuntu 20.04 focal main arm64 gparted
1.0.0-0.1build1 (no newer focal-updates binary) +
gparted-common 1.0.0-0.1build1. Official SHA256 + size
matched ports.ubuntu.com pool files and focal main arm64
Packages stanzas.
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
Depends: libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.17), libcairomm-1.0-1v5 (>= 1.12.0), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.16.0), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.0.0), libgtkmm-3.0-1v5 (>= 3.24.0), libpangomm-1.4-1v5 (>= 2.42.0), libparted-fs-resize0 (>= 3.1), libparted2 (>= 3.1), libsigc++-2.0-0v5 (>= 2.8.0), libstdc++6 (>= 5.2), libuuid1 (>= 2.16), policykit-1
Suggests: dmraid, dmsetup, dosfstools, e2fsprogs, gpart, jfsutils, kpartx, mtools, ntfs-3g, reiser4progs, reiserfsprogs, udftools, xfsprogs, yelp
Breaks: udisks2 (<< 2.1.5)
Conflicts: gparted, gparted-common
Replaces: gparted, gparted-common
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gparted.org
Description: GNOME partition editor (arm64)
 GParted ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Create, reorganize, and delete partitions (libparted).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gparted-control.txt"
