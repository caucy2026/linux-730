#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) gnome-system-monitor
# 3.36.1-0ubuntu0.20.04.1 arm64 as kemi-gnome-system-monitor.
# No common/data or typelib package.
# Official binaries: /usr/bin/gnome-system-monitor plus pkexec
#   helpers /usr/libexec/gnome-system-monitor/{gsm-kill,gsm-renice}.
# Probe: aarch64 · 3 ELF · gnome-system-monitor requiredGlibc 2.29
#   GLIBCXX 3.4.21 · gsm-kill / gsm-renice requiredGlibc 2.17
#   no GLIBCXX · PASS vs 101 ≤2.31 / GLIBCXX ≤3.4.28
#   GTK3 + gtkmm-3.0 + glibmm + gdkmm + giomm + sigc++ +
#   libgtop + librsvg + libsystemd + cairo/pango + GDK-Pixbuf +
#   GIO/GObject/GLib + libstdc++ + libgcc_s + pthread + libm + libc
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.29,
#   libgtk-3-0, libgtkmm-3.0-1v5, libglibmm-2.4-1v5,
#   libgtop-2.0-11, librsvg2-2, libsigc++-2.0-0v5, libsystemd0,
#   libstdc++6, libgcc-s1, cairo/pango/gdk-pixbuf, glib).
# Official Recommends gvfs kept as Recommends, not bundled
#   (different source).
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal-updates main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). Newer than focal Release 3.36.0-1; still
#   U20-compatible. No librarian URL is recorded this run.
# Official main ELF embeds compiled /usr prefixes
#   (/usr/share/locale, /usr/share/gnome-system-monitor/gsm.gresource,
#   /usr/libexec/gnome-system-monitor, /usr/bin/pkexec). Layout
#   therefore keeps official ELFs at /usr/bin and /usr/libexec;
#   /opt/gnome-system-monitor/* are symlinks (HardInfo/Xpad/
#   qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks).
# Official desktop Icon=org.gnome.SystemMonitor (icons shipped).
# Official language-pack split: no .mo in this deb (do not
#   invent/bundle language packs). C help is real; other official
#   help locales are help-langpack symlinks. Reuse existing
#   unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-system-monitor
VER_UP=3.36.1
VER_DEB="${VER_UP}-0ubuntu0.20.04.1kemi1"
ARCH=arm64
PKG=kemi-gnome-system-monitor
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gnome-system-monitor-3.36.1-0ubuntu0.20.04.1-focal-unpack}"
UP_DEB="$DL/gnome-system-monitor_3.36.1-0ubuntu0.20.04.1_arm64.deb"
EXPECT_SHA=6c14c73054c0a21d122ef52bb8153f029de4fc4690220cc9a8a091be82e99b3f
EXPECT_BYTES=171468
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-system-monitor"
test -x "$UNPACK/usr/libexec/gnome-system-monitor/gsm-kill"
test -x "$UNPACK/usr/libexec/gnome-system-monitor/gsm-renice"
test -f "$UNPACK/usr/share/applications/gnome-system-monitor.desktop"
test -f "$UNPACK/usr/share/applications/gnome-system-monitor-kde.desktop"
test -f "$UNPACK/usr/share/gnome-system-monitor/gsm.gresource"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.gschema.xml"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.enums.xml"
test -f "$UNPACK/usr/share/polkit-1/actions/org.gnome.gnome-system-monitor.policy"
test -f "$UNPACK/usr/share/man/man1/gnome-system-monitor.1.gz"
test -f "$UNPACK/usr/share/metainfo/gnome-system-monitor.appdata.xml"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.SystemMonitor.svg"
test -f "$UNPACK/usr/share/help/C/gnome-system-monitor/index.page"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test "$(find "$UNPACK/usr/share/help/C/gnome-system-monitor" -type f | wc -l)" = 26
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/gnome-system-monitor")
grep -qx '/usr/share/gnome-system-monitor/gsm.gresource' < <(strings -n 8 "$UNPACK/usr/bin/gnome-system-monitor")
grep -qx '/usr/libexec/gnome-system-monitor' < <(strings -n 8 "$UNPACK/usr/bin/gnome-system-monitor")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/libexec/gnome-system-monitor" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/gnome-system-monitor"

cp -al "$UNPACK/usr/bin/gnome-system-monitor" "$STAGE/pkg/usr/bin/gnome-system-monitor"
cp -al "$UNPACK/usr/libexec/gnome-system-monitor/gsm-kill" "$STAGE/pkg/usr/libexec/gnome-system-monitor/gsm-kill"
cp -al "$UNPACK/usr/libexec/gnome-system-monitor/gsm-renice" "$STAGE/pkg/usr/libexec/gnome-system-monitor/gsm-renice"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-system-monitor" \
  "$STAGE/pkg/usr/libexec/gnome-system-monitor/gsm-kill" \
  "$STAGE/pkg/usr/libexec/gnome-system-monitor/gsm-renice"

REPORT="$ROOT/probe/kemi-gnome-system-monitor.json"
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
for name in ("gnome-system-monitor", "gsm-kill", "gsm-renice"):
    if name not in by:
        raise SystemExit(f"PROBE_MISSING_{name}")
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
main = by["gnome-system-monitor"]
if main.get("requiredGlibc") != "2.29":
    raise SystemExit("PROBE_GLIBC_MAIN")
if main.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit("PROBE_GLIBCXX_MAIN")
for name in ("gsm-kill", "gsm-renice"):
    f = by[name]
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(main.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libgtkmm-3.0.so.1",
            "libgdkmm-3.0.so.1", "libgiomm-2.4.so.1", "libglibmm-2.4.so.1",
            "libsigc-2.0.so.0", "libgtop-2.0.so.11", "librsvg-2.so.2",
            "libsystemd.so.0", "libstdc++.so.6", "libgcc_s.so.1",
            "libpangocairo-1.0.so.0", "libpango-1.0.so.0", "libcairo.so.2",
            "libgdk_pixbuf-2.0.so.0", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0", "libpthread.so.0", "libm.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.29/2.17 GLIBCXX=3.4.21 arch=aarch64 n_elf=3")
PY

cp -a "$UNPACK/usr/share/gnome-system-monitor" "$STAGE/pkg/usr/share/gnome-system-monitor"
# official help tree (C real; other locales official help-langpack symlinks)
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/glib-2.0/schemas"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.gschema.xml"
cp -a --remove-destination "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.enums.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.gnome-system-monitor.enums.xml"
mkdir -p "$STAGE/pkg/usr/share/polkit-1/actions"
cp -a --remove-destination "$UNPACK/usr/share/polkit-1/actions/org.gnome.gnome-system-monitor.policy" \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.gnome-system-monitor.policy"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/gnome-system-monitor.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/gnome-system-monitor.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/gnome-system-monitor.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/gnome-system-monitor.appdata.xml"
test -f "$STAGE/pkg/usr/share/gnome-system-monitor/gsm.gresource"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.SystemMonitor.svg"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg/usr/share/help/C/gnome-system-monitor" -type f | wc -l)" = 26
grep -q '/usr/libexec/gnome-system-monitor/gsm-kill' \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.gnome-system-monitor.policy"
grep -q '/usr/libexec/gnome-system-monitor/gsm-renice' \
  "$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.gnome-system-monitor.policy"

if [[ -f "$UNPACK/usr/share/doc/gnome-system-monitor/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gnome-system-monitor/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/gnome-system-monitor/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/gnome-system-monitor/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src: Path, dst: Path):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=gnome-system-monitor\b", "Exec=/usr/bin/gnome-system-monitor", text, flags=re.M)
    text2 = re.sub(r"^TryExec=gnome-system-monitor$", "TryExec=/usr/bin/gnome-system-monitor", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^(Exec=/usr/bin/gnome-system-monitor(?:\s.*)?)$",
                       r"\1\nTryExec=/usr/bin/gnome-system-monitor", text2, count=1, flags=re.M)
    if re.search(r"^Exec=gnome-system-monitor(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC {src}")
    if re.search(r"^TryExec=gnome-system-monitor$", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_TRYEXEC {src}")
    if "Exec=/usr/bin/gnome-system-monitor" not in text2:
        raise SystemExit(f"MISSING_EXEC {src}")
    if "TryExec=/usr/bin/gnome-system-monitor" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC {src}")
    if not re.search(r"^Icon=org.gnome.SystemMonitor$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON {src}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

base = Path("$UNPACK/usr/share/applications")
out = Path("$STAGE/pkg/usr/share/applications")
rewrite(base / "gnome-system-monitor.desktop", out / "gnome-system-monitor.desktop")
rewrite(base / "gnome-system-monitor-kde.desktop", out / "gnome-system-monitor-kde.desktop")
main = (out / "gnome-system-monitor.desktop").read_text(encoding="utf-8")
if not re.search(r"^NotShowIn=KDE;$", main, flags=re.M):
    raise SystemExit("MISSING_NOTSHOWIN")
kde = (out / "gnome-system-monitor-kde.desktop").read_text(encoding="utf-8")
if not re.search(r"^OnlyShowIn=KDE;$", kde, flags=re.M):
    raise SystemExit("MISSING_ONLYSHOWIN")
PY

ln -sf /usr/bin/gnome-system-monitor "$STAGE/pkg/opt/gnome-system-monitor/gnome-system-monitor"
ln -sf /usr/libexec/gnome-system-monitor/gsm-kill "$STAGE/pkg/opt/gnome-system-monitor/gsm-kill"
ln -sf /usr/libexec/gnome-system-monitor/gsm-renice "$STAGE/pkg/opt/gnome-system-monitor/gsm-renice"
ln -sf gnome-system-monitor "$STAGE/pkg/usr/bin/kemi-gnome-system-monitor"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/SystemMonitor
Source: https://launchpad.net/ubuntu/+source/gnome-system-monitor
Homepage: https://wiki.gnome.org/Apps/SystemMonitor
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(gnome-system-monitor_3.36.1-0ubuntu0.20.04.1_arm64.deb)
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04
    gnome-system-monitor_3.36.1-0ubuntu0.20.04.1_arm64.deb
    (focal-updates main; newer than Release 3.36.0-1)
    repackaged for KEMI as ${PKG}.
  * Official ELFs stay at /usr/bin/gnome-system-monitor and
    /usr/libexec/gnome-system-monitor/{gsm-kill,gsm-renice}
    because the main ELF embeds compiled /usr prefixes
    (/usr/share/locale, gsm.gresource, libexec helpers).
    /opt/gnome-system-monitor/* are symlinks.
  * Desktop, polkit policy, gschema, gresource, man, metainfo,
    official help tree and icons stay on standard paths.
    Official desktop Icon=org.gnome.SystemMonitor (icons shipped).
    Official language-pack split: no .mo in this deb; C help is
    real; other help locales are official help-langpack symlinks.
  * Conflicts/Replaces gnome-system-monitor.
  * Depends kept for Ubuntu 20.04 (GTK3, gtkmm, glibmm, libgtop,
    librsvg, libsigc++, libsystemd, libc6 >= 2.29, libstdc++6).
    Official Recommends gvfs kept as Recommends, not bundled.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:40:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME System Monitor ${VER_UP}-0ubuntu0.20.04.1 — official
Ubuntu 20.04 (focal-updates) arm64, KEMI repack.

Official ELFs stay at /usr/bin/gnome-system-monitor and
/usr/libexec/gnome-system-monitor/{gsm-kill,gsm-renice}
(compiled /usr prefixes; gresource under
/usr/share/gnome-system-monitor).
/opt/gnome-system-monitor/* are symlinks.
Desktop, polkit, gschema, man, metainfo, official help tree
and icons remain on standard paths.
Official desktop Icon=org.gnome.SystemMonitor (icons shipped).
Official language-pack split: no .mo in this deb.
Probe: aarch64 · 3 ELF · requiredGlibc 2.29 / 2.17 ·
GLIBCXX 3.4.21 · GTK3 + gtkmm + libgtop;
Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Runtime: official Depends (GTK3, gtkmm, glibmm, libgtop,
librsvg, libsigc++, libsystemd, libc6 >= 2.29, libstdc++6).
Recommends gvfs (not bundled).
Official publication: Ubuntu 20.04 focal-updates main arm64
gnome-system-monitor 3.36.1-0ubuntu0.20.04.1 (newer than
Release 3.36.0-1; still U20-compatible). Official SHA256 +
size matched ports.ubuntu.com pool files and focal-updates
main arm64 Packages stanzas.
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
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.29), libcairo2 (>= 1.2.4), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.56.0), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.22.0), libgtkmm-3.0-1v5 (>= 3.24.0), libgtop-2.0-11 (>= 2.37.90), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), librsvg2-2 (>= 2.35.0), libsigc++-2.0-0v5 (>= 2.2.0), libstdc++6 (>= 5.2), libsystemd0
Recommends: gvfs
Conflicts: gnome-system-monitor
Replaces: gnome-system-monitor
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/SystemMonitor
Description: Process viewer and system resource monitor for GNOME (arm64)
 GNOME System Monitor ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Process viewer and system resource monitor.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-system-monitor-control.txt"
