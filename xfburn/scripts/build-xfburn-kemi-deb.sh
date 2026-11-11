#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xfburn 0.6.2-1 arm64 as
# kemi-xfburn. No common/data package.
# Probe: aarch64 · 1 ELF (xfburn) · requiredGlibc 2.17 ·
#   no GLIBCXX · PASS vs 101 ≤2.31
#   GTK3 + GDK3 + libexo-2 + libxfce4ui-2 + libxfce4util +
#   libburn + libisofs + GStreamer / gstpbutils + libgudev +
#   GDK-Pixbuf + GIO/GObject/GLib + pthread + libc
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libgtk-3-0, libexo-2-0, libxfce4ui-2-0, libxfce4util7,
#   libburn4, libisofs6, libgstreamer1.0-0,
#   libgstreamer-plugins-base1.0-0, libgudev-1.0-0,
#   libgdk-pixbuf2.0-0, libglib2.0-0).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). No newer focal-updates binary. No librarian URL
#   is recorded this run.
# Official ELF embeds compiled /usr prefixes (/usr/share/locale;
#   UI as xfburn/xfburn.ui under /usr/share). Layout therefore
#   keeps the official ELF at /usr/bin/xfburn and
#   /opt/xfburn/xfburn is a symlink (HardInfo/Xpad/qpdfview/
#   Pluma/Gedit/XFCE Notes). Data, locales, icons, desktop,
#   Thunar sendto, man and metainfo stay on standard paths.
# Official desktop Icon=stock_xfburn (icons shipped). 57 locales
#   including zh_CN / zh_TW. Reuse existing unpacked tree; do
#   not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xfburn
VER_UP=0.6.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xfburn
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xfburn-0.6.2-1-focal-unpack}"
UP_DEB="$DL/xfburn_0.6.2-1_arm64.deb"
EXPECT_SHA=dc56ae4b5db13e99434a5f4989956198e8089cd79d5f64bcfa229dcf14a8c61c
EXPECT_BYTES=419576
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xfburn"
test -f "$UNPACK/usr/share/applications/xfburn.desktop"
test -f "$UNPACK/usr/share/Thunar/sendto/thunar-sendto-xfburn.desktop"
test -f "$UNPACK/usr/share/xfburn/xfburn.ui"
test -f "$UNPACK/usr/share/man/man1/xfburn.1.gz"
test -f "$UNPACK/usr/share/metainfo/org.xfce.xfburn.appdata.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/stock/media/stock_xfburn.svg"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/xfburn.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/xfburn.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'xfburn.mo' | wc -l)" = 57
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/xfburn")
grep -q 'xfburn/xfburn.ui' < <(strings -n 6 "$UNPACK/usr/bin/xfburn")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/xfburn"

cp -al "$UNPACK/usr/bin/xfburn" "$STAGE/pkg/usr/bin/xfburn"
chmod 0755 "$STAGE/pkg/usr/bin/xfburn"

REPORT="$ROOT/probe/kemi-xfburn.json"
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
PROBE_ARGS=()
for e in "${ELFS[@]}"; do PROBE_ARGS+=(--elf "$e"); done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f = r["files"][0]
if Path(f["path"]).name != "xfburn":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") not in (None, ""):
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libexo-2.so.0",
            "libxfce4ui-2.so.0", "libxfce4util.so.7", "libburn.so.4",
            "libisofs.so.6", "libgstreamer-1.0.so.0", "libgstpbutils-1.0.so.0",
            "libgudev-1.0.so.0", "libgdk_pixbuf-2.0.so.0", "libgio-2.0.so.0",
            "libgobject-2.0.so.0", "libglib-2.0.so.0", "libpthread.so.0",
            "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=1")
PY

cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/xfburn" "$STAGE/pkg/usr/share/xfburn"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/Thunar/sendto"
cp -a --remove-destination "$UNPACK/usr/share/Thunar/sendto/thunar-sendto-xfburn.desktop" \
  "$STAGE/pkg/usr/share/Thunar/sendto/thunar-sendto-xfburn.desktop"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/xfburn.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/xfburn.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.xfce.xfburn.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.xfce.xfburn.appdata.xml"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/xfburn.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'xfburn.mo' | wc -l)" = 57
test -f "$STAGE/pkg/usr/share/xfburn/xfburn.ui"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/stock/media/stock_xfburn.svg"

if [[ -f "$UNPACK/usr/share/doc/xfburn/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfburn/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/xfburn/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfburn/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src: Path, dst: Path):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=xfburn\b", "Exec=/usr/bin/xfburn", text, flags=re.M)
    text2 = re.sub(r"^TryExec=xfburn$", "TryExec=/usr/bin/xfburn", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^(Exec=/usr/bin/xfburn)$", r"\1\nTryExec=/usr/bin/xfburn", text2, count=1, flags=re.M)
    if re.search(r"^Exec=xfburn(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {src}")
    if "Exec=/usr/bin/xfburn" not in text2:
        raise SystemExit(f"MISSING_EXEC {src}")
    if "TryExec=/usr/bin/xfburn" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC {src}")
    if not re.search(r"^Icon=stock_xfburn$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON {src}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

rewrite(
    Path("$UNPACK/usr/share/applications/xfburn.desktop"),
    Path("$STAGE/pkg/usr/share/applications/xfburn.desktop"),
)
rewrite(
    Path("$UNPACK/usr/share/Thunar/sendto/thunar-sendto-xfburn.desktop"),
    Path("$STAGE/pkg/usr/share/Thunar/sendto/thunar-sendto-xfburn.desktop"),
)
main = Path("$STAGE/pkg/usr/share/applications/xfburn.desktop").read_text(encoding="utf-8")
if "Exec=/usr/bin/xfburn -i %f" not in main:
    raise SystemExit("MISSING_BURN_IMAGE_EXEC")
PY

ln -sf /usr/bin/xfburn "$STAGE/pkg/opt/xfburn/xfburn"
ln -sf xfburn "$STAGE/pkg/usr/bin/kemi-xfburn"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://goodies.xfce.org/projects/applications/xfburn
Source: https://launchpad.net/ubuntu/+source/xfburn
Homepage: https://goodies.xfce.org/projects/applications/xfburn
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(xfburn_0.6.2-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xfburn_0.6.2-1_arm64.deb (focal
    universe) repackaged for KEMI as ${PKG}.
  * Official ELF stays at /usr/bin/xfburn because it embeds
    compiled /usr prefixes (/usr/share/locale; UI under
    /usr/share/xfburn). /opt/xfburn/xfburn is a symlink.
  * Desktop, Thunar sendto, man, metainfo, icons and 57 locales
    including zh_CN / zh_TW stay on standard paths. Official
    desktop Icon=stock_xfburn (icons shipped).
  * Conflicts/Replaces xfburn.
  * Depends kept for Ubuntu 20.04 (GTK3, libexo-2, libxfce4ui-2,
    libxfce4util7, libburn4, libisofs6, GStreamer 1.0, libgudev,
    libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:20:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xfburn ${VER_UP}-1 — official Ubuntu 20.04 (focal) arm64,
KEMI repack.

The official ELF stays at /usr/bin/xfburn (compiled /usr
prefixes). /opt/xfburn/xfburn is a symlink to /usr/bin/xfburn.
UI data stays at /usr/share/xfburn. Desktop, Thunar sendto,
man, metainfo, icons and 57 locales including zh_CN / zh_TW
remain on standard /usr/share paths.
Official desktop Icon=stock_xfburn (icons shipped under
hicolor stock/media).
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + libexo-2 + libxfce4ui-2 + libburn/libisofs + GStreamer;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libburn4 (>= 1.5.2), libc6 (>= 2.17), libexo-2-0
(>= 0.11.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0
(>= 2.41.1), libgstreamer-plugins-base1.0-0 (>= 1.0.0),
libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.21.5),
libgudev-1.0-0 (>= 146), libisofs6 (>= 1.5.2),
libxfce4ui-2-0 (>= 4.12.0), libxfce4util7 (>= 4.9.0).
Official publication: Ubuntu 20.04 focal universe arm64
xfburn 0.6.2-1 (current official U20 package; no newer
focal-updates binary). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64 Packages
stanzas.
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
Depends: libburn4 (>= 1.5.2), libc6 (>= 2.17), libexo-2-0 (>= 0.11.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.41.1), libgstreamer-plugins-base1.0-0 (>= 1.0.0), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.21.5), libgudev-1.0-0 (>= 146), libisofs6 (>= 1.5.2), libxfce4ui-2-0 (>= 4.12.0), libxfce4util7 (>= 4.9.0)
Conflicts: xfburn
Replaces: xfburn
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://goodies.xfce.org/projects/applications/xfburn
Description: CD-burner application for Xfce Desktop Environment (arm64)
 Xfburn ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 CD and DVD burning application.
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
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xfburn-control.txt"
