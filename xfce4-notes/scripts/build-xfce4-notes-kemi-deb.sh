#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) xfce4-notes 1.8.1-3 arm64
# as kemi-xfce4-notes. No common/data package. Same-source
# xfce4-notes-plugin is a panel plugin (Depends xfce4-panel
# 4.13–4.15) and is not a hard Depends of xfce4-notes — not
# bundled.
# Probe: aarch64 · 3 ELF · no GLIBCXX · PASS vs 101 ≤2.31
#   xfce4-notes requiredGlibc 2.29 (GTK2 + unique + xfce4util
#     + xfconf + cairo + pango + gdk-pixbuf + X11)
#   xfce4-notes-settings requiredGlibc 2.29 (GTK2 + libxfce4ui-1
#     + unique + xfce4util + xfconf)
#   xfce4-popup-notes requiredGlibc 2.17 (GTK2 + X11)
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.29,
#   libgtk2.0-0, libunique-1.0-0, libxfce4ui-1-0, libxfce4util7,
#   libxfconf-0-3, cairo, pango, gdk-pixbuf, glib, libx11-6).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). No newer focal-updates binary. No librarian URL
#   is recorded this run.
# Official ELFs embed compiled /usr prefixes
#   (/usr/share/locale, /usr/share/xfce4-notes-plugin). Layout
#   therefore keeps the official ELFs at /usr/bin and
#   /opt/xfce4-notes/* are symlinks (HardInfo/Xpad/qpdfview/
#   Pluma/Gedit). Data, locales, icons, desktop and official
#   autostart conffile (Hidden=true) stay on standard paths.
# Official desktop Icon=xfce4-notes-plugin (icons shipped).
# 48 locales including zh_CN / zh_TW. Reuse existing unpacked
# tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xfce4-notes
VER_UP=1.8.1
VER_DEB="${VER_UP}-3kemi1"
ARCH=arm64
PKG=kemi-xfce4-notes
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xfce4-notes-1.8.1-3-focal-unpack}"
UP_DEB="$DL/xfce4-notes_1.8.1-3_arm64.deb"
EXPECT_SHA=6b49e0cf9fd79aaf6e6ddd1f2663192be1a8dc9b788e102ee9fc9535e39de54e
EXPECT_BYTES=96036
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xfce4-notes"
test -x "$UNPACK/usr/bin/xfce4-notes-settings"
test -x "$UNPACK/usr/bin/xfce4-popup-notes"
test -f "$UNPACK/usr/share/applications/xfce4-notes.desktop"
test -f "$UNPACK/etc/xdg/autostart/xfce4-notes-autostart.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/xfce4-notes-plugin.svg"
test -f "$UNPACK/usr/share/xfce4-notes-plugin/gtk-2.0/notes.gtkrc"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/xfce4-notes-plugin.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/xfce4-notes-plugin.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'xfce4-notes-plugin.mo' | wc -l)" = 48
# compiled /usr prefixes — ELFs must stay at /usr/bin
grep -qx '/usr/share/xfce4-notes-plugin' < <(strings -n 8 "$UNPACK/usr/bin/xfce4-notes")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/xfce4-notes")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/etc/xdg/autostart" \
  "$STAGE/pkg/opt/xfce4-notes"

cp -al "$UNPACK/usr/bin/xfce4-notes" "$STAGE/pkg/usr/bin/xfce4-notes"
cp -al "$UNPACK/usr/bin/xfce4-notes-settings" "$STAGE/pkg/usr/bin/xfce4-notes-settings"
cp -al "$UNPACK/usr/bin/xfce4-popup-notes" "$STAGE/pkg/usr/bin/xfce4-popup-notes"
chmod 0755 "$STAGE/pkg/usr/bin/xfce4-notes" \
  "$STAGE/pkg/usr/bin/xfce4-notes-settings" \
  "$STAGE/pkg/usr/bin/xfce4-popup-notes"

REPORT="$ROOT/probe/kemi-xfce4-notes.json"
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
if len(r.get("files") or []) != 3:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in r["files"]}
for need in ("xfce4-notes", "xfce4-notes-settings", "xfce4-popup-notes"):
    if need not in by:
        raise SystemExit(f"PROBE_MISSING_{need}")
expect_glibc = {
    "xfce4-notes": "2.29",
    "xfce4-notes-settings": "2.29",
    "xfce4-popup-notes": "2.17",
}
for name, f in by.items():
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != expect_glibc[name]:
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["xfce4-notes"].get("neededLibraries") or [])
for lib in ("libgtk-x11-2.0.so.0", "libgdk-x11-2.0.so.0", "libunique-1.0.so.0",
            "libxfce4util.so.7", "libxfconf-0.so.3", "libcairo.so.2",
            "libgdk_pixbuf-2.0.so.0", "libpango-1.0.so.0", "libgio-2.0.so.0",
            "libgobject-2.0.so.0", "libglib-2.0.so.0", "libX11.so.6",
            "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
if "libxfce4ui-1.so.0" not in set(by["xfce4-notes-settings"].get("neededLibraries") or []):
    raise SystemExit("PROBE_SETTINGS_MISSING_XFCE4UI")
print("PROBE_PASS requiredGlibc=2.29/2.29/2.17 no-GLIBCXX arch=aarch64 n_elf=3")
PY

cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/xfce4-notes-plugin" "$STAGE/pkg/usr/share/xfce4-notes-plugin"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/xfce4-notes-plugin.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'xfce4-notes-plugin.mo' | wc -l)" = 48
test -f "$STAGE/pkg/usr/share/xfce4-notes-plugin/gtk-2.0/notes.gtkrc"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/xfce4-notes-plugin.svg"

if [[ -f "$UNPACK/usr/share/doc/xfce4-notes/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfce4-notes/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/xfce4-notes/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfce4-notes/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src: Path, dst: Path):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=xfce4-notes\b", "Exec=/usr/bin/xfce4-notes", text, flags=re.M)
    text2 = re.sub(r"^TryExec=xfce4-notes$", "TryExec=/usr/bin/xfce4-notes", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = text2.replace(
            "Exec=/usr/bin/xfce4-notes",
            "Exec=/usr/bin/xfce4-notes\nTryExec=/usr/bin/xfce4-notes",
            1,
        )
    if re.search(r"^Exec=xfce4-notes(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {src}")
    if "Exec=/usr/bin/xfce4-notes" not in text2:
        raise SystemExit(f"MISSING_EXEC {src}")
    if "TryExec=/usr/bin/xfce4-notes" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC {src}")
    if not re.search(r"^Icon=xfce4-notes-plugin$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON {src}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

rewrite(
    Path("$UNPACK/usr/share/applications/xfce4-notes.desktop"),
    Path("$STAGE/pkg/usr/share/applications/xfce4-notes.desktop"),
)
rewrite(
    Path("$UNPACK/etc/xdg/autostart/xfce4-notes-autostart.desktop"),
    Path("$STAGE/pkg/etc/xdg/autostart/xfce4-notes-autostart.desktop"),
)
# official autostart stays Hidden=true
text = Path("$STAGE/pkg/etc/xdg/autostart/xfce4-notes-autostart.desktop").read_text(encoding="utf-8")
if not re.search(r"^Hidden=true$", text, flags=re.M):
    raise SystemExit("AUTOSTART_HIDDEN_MISSING")
PY

printf '%s\n' /etc/xdg/autostart/xfce4-notes-autostart.desktop > "$STAGE/pkg/DEBIAN/conffiles"

ln -sf /usr/bin/xfce4-notes "$STAGE/pkg/opt/xfce4-notes/xfce4-notes"
ln -sf /usr/bin/xfce4-notes-settings "$STAGE/pkg/opt/xfce4-notes/xfce4-notes-settings"
ln -sf /usr/bin/xfce4-popup-notes "$STAGE/pkg/opt/xfce4-notes/xfce4-popup-notes"
ln -sf xfce4-notes "$STAGE/pkg/usr/bin/kemi-xfce4-notes"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://goodies.xfce.org/projects/panel-plugins/xfce4-notes-plugin
Source: https://launchpad.net/ubuntu/+source/xfce4-notes-plugin
Homepage: https://goodies.xfce.org/projects/panel-plugins/xfce4-notes-plugin
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(xfce4-notes_1.8.1-3_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xfce4-notes_1.8.1-3_arm64.deb
    (focal universe) repackaged for KEMI as ${PKG}.
  * Official ELFs stay at /usr/bin because they embed compiled
    /usr prefixes (/usr/share/locale,
    /usr/share/xfce4-notes-plugin). /opt/xfce4-notes/* are
    symlinks to /usr/bin.
  * Desktop, autostart conffile (Hidden=true), icons, GTK2
    theme data and 48 locales including zh_CN / zh_TW stay on
    standard paths. Official desktop Icon=xfce4-notes-plugin.
  * Same-source xfce4-notes-plugin (panel plugin, Depends
    xfce4-panel 4.13–4.15) is not a hard Depends and is not
    bundled.
  * Conflicts/Replaces xfce4-notes.
  * Depends kept for Ubuntu 20.04 (GTK2, libunique, libxfce4ui-1,
    libxfce4util7, libxfconf, cairo, pango, gdk-pixbuf, libc6
    >= 2.29).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:16:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
XFCE Notes ${VER_UP}-3 — official Ubuntu 20.04 (focal) arm64,
KEMI repack.

Official ELFs stay at /usr/bin/xfce4-notes,
/usr/bin/xfce4-notes-settings and /usr/bin/xfce4-popup-notes
(compiled /usr prefixes). /opt/xfce4-notes/* are symlinks.
GTK2 theme data stays at /usr/share/xfce4-notes-plugin.
Desktop, autostart conffile (Hidden=true), icons and 48 locales
including zh_CN / zh_TW remain on standard paths.
Official desktop Icon=xfce4-notes-plugin (icons shipped).
Same-source xfce4-notes-plugin panel plugin is not bundled.
Probe: aarch64 · 3 ELF · requiredGlibc 2.29 / 2.29 / 2.17 ·
no GLIBCXX · GTK2; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: libc6 (>= 2.29), libcairo2 (>= 1.2.4),
libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.24.0),
libgtk2.0-0 (>= 2.24.0), libpango-1.0-0 (>= 1.14.0),
libunique-1.0-0 (>= 1.0.0), libx11-6, libxfce4ui-1-0 (>= 4.8.0),
libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.6.0).
Official publication: Ubuntu 20.04 focal universe arm64
xfce4-notes 1.8.1-3 (current official U20 package; no newer
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
Depends: libc6 (>= 2.29), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.24.0), libgtk2.0-0 (>= 2.24.0), libpango-1.0-0 (>= 1.14.0), libunique-1.0-0 (>= 1.0.0), libx11-6, libxfce4ui-1-0 (>= 4.8.0), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.6.0)
Conflicts: xfce4-notes
Replaces: xfce4-notes
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://goodies.xfce.org/projects/panel-plugins/xfce4-notes-plugin
Description: Notes application for the Xfce4 desktop (arm64)
 XFCE Notes ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Sticky-note GTK2 applet for quick notes.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xfce4-notes-control.txt"
