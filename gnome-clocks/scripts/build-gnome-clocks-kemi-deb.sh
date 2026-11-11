#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) gnome-clocks
# 3.36.2-1~ubuntu20.04.1 arm64 as kemi-gnome-clocks.
# focal Release is 3.36.0-1; this job uses the current official
# focal-updates package (still Ubuntu 20.04 deps). The
# gnome-clocks source ships only this one binary package in
# focal (no same-source -data/-common to bundle). Official
# control has no Recommends and no Suggests. System Depends
# (geoclue, GTK3, libhandy-0.0, gweather, gnome-desktop,
# gsound, etc.) stay Depends. Versioned Provides:
# gnome-clocks (= 3.36.2-1~ubuntu20.04.1).
# Official binary: /usr/bin/gnome-clocks. The ELF embeds
# /usr/share/locale and help:gnome-clocks (official Yelp
# help under /usr/share/help). Official files stay on
# official paths; /opt/gnome-clocks/* are symlinks (same
# compiled-/usr layout as workrave/keepassxc/homebank).
# Official translations are 72 .mo including zh_CN. Official
# help is a real /usr/share/help tree (C + 18 locales, not
# language-pack symlinks). Official icons are SVG only
# (org.gnome.clocks.svg and -symbolic.svg). Keep the official
# tree; do not invent language-packs, help trees, or SVG/PNG
# icons in the package.
# Official changelog is a real file. No official maintainer
# scripts. Official org.gnome.clocks.service already uses
# /usr/bin/gnome-clocks --gapplication-service and is kept.
# Official desktop Exec=gnome-clocks is rewritten to
# /usr/bin/gnome-clocks; Icon=org.gnome.clocks is kept.
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1 versioned,
# 0 null) · no GLIBCXX · PASS vs 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal-updates universe
# arm64 Packages stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no .buildinfo is recorded
# this run (pool 404).
# KEMI version 3.36.2-1~ubuntu20.04.1kemi1 is 27 chars
# (under the mall version_name limit that rejected Remmina's
# 33-char string; sibling 3.36.1-0ubuntu0.20.04.1kemi1 at
# 28 chars succeeded; workrave 1.10.37-1kemi1 was 14 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-clocks
VER_UP=3.36.2-1~ubuntu20.04.1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-clocks
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gnome-clocks-3.36.2-focal-updates-unpack}"
UP_DEB="$DL/gnome-clocks_3.36.2-1~ubuntu20.04.1_arm64.deb"
EXPECT_SHA=428d9e015fee705d7796d13b1c7d69fca9a9d542c0e2f06c31bcb1241d4a00be
EXPECT_BYTES=242580
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-clocks"
test -f "$UNPACK/usr/share/applications/org.gnome.clocks.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.clocks.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.clocks-symbolic.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.clocks.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/gnome-clocks.mo"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 72
test -f "$UNPACK/usr/share/help/C/gnome-clocks/index.page"
test -d "$UNPACK/usr/share/help/uk/gnome-clocks"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.clocks.service"
test ! -L "$UNPACK/usr/share/doc/gnome-clocks/changelog.Debian.gz"
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/gnome-clocks")
grep -qx 'help:gnome-clocks' < <(strings -n 8 "$UNPACK/usr/bin/gnome-clocks")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/gnome-clocks" \
  "$STAGE/pkg/opt/gnome-clocks"

cp -al "$UNPACK/usr/bin/gnome-clocks" "$STAGE/pkg/usr/bin/gnome-clocks"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-clocks"

REPORT="$ROOT/probe/kemi-gnome-clocks.json"
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
if len(files) != 1:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
f = files[0]
if Path(f["path"]).name != "gnome-clocks":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
if len(versioned) != 1 or nulls:
    raise SystemExit("PROBE_NONE_SAFE_COUNTS")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libhandy-0.0.so.0", "libgweather-3.so.16", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=1 arch=aarch64 glibc_versioned=1 glibc_null=0 requiredGlibc=2.17 noGLIBCXX")
PY

# official share tree (locale, help, icons, schemas, dbus, metainfo, search provider, desktop later rewritten)
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
# official docs already copied via share; ensure kemi doc copies
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-clocks/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-clocks/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 72
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/gnome-clocks.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.clocks.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps/org.gnome.clocks-symbolic.svg"
test "$(find "$STAGE/pkg/usr/share/icons" -name '*.png' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/help/C/gnome-clocks/index.page"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.gnome.clocks.gschema.xml"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/org.gnome.clocks.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.clocks.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnome-clocks(\s.*)?$", r"Exec=/usr/bin/gnome-clocks\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=gnome-clocks$", "TryExec=/usr/bin/gnome-clocks", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gnome-clocks(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/gnome-clocks", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnome-clocks(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/gnome-clocks", "TryExec=/usr/bin/gnome-clocks"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=org.gnome.clocks$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "X-GNOME-FullName=GNOME Clocks" not in text2 or "Name=Clocks" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten")

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.clocks.service")
st = svc.read_text(encoding="utf-8")
if "Exec=/usr/bin/gnome-clocks --gapplication-service" not in st:
    raise SystemExit("DBUS_EXEC")
if "x86_64-linux-gnu" in st:
    raise SystemExit("DBUS_X86")
print("dbus_ok")
# no leftover x86_64 paths in text files
leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".so", ".png", ".svg", ".mo", ".gz", ".page"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in t:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/gnome-clocks "$STAGE/pkg/opt/gnome-clocks/gnome-clocks"
ln -sf gnome-clocks "$STAGE/pkg/usr/bin/kemi-gnome-clocks"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Clocks
Source: https://launchpad.net/ubuntu/+source/gnome-clocks
Homepage: https://wiki.gnome.org/Apps/Clocks
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(gnome-clocks_3.36.2-1~ubuntu20.04.1_arm64.deb),
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-clocks_3.36.2-1~ubuntu20.04.1_arm64.deb
    (focal-updates universe; newer than focal Release 3.36.0-1)
    repackaged for KEMI as ${PKG}. No same-source data package
    in focal. Official control has no Recommends or Suggests.
    Versioned Provides: gnome-clocks (= 3.36.2-1~ubuntu20.04.1).
  * Official ELF stays at /usr/bin/gnome-clocks (compiled
    /usr/share/locale and help:gnome-clocks). /opt/gnome-clocks/*
    are symlinks.
  * Desktop, official 72 .mo (including zh_CN), official Yelp
    help, official SVG icons, schemas, D-Bus and AppStream
    metadata stay on standard paths. Official desktop
    Exec=gnome-clocks rewritten to /usr/bin/gnome-clocks;
    Icon=org.gnome.clocks. Official D-Bus service already
    uses /usr/bin/gnome-clocks --gapplication-service.
  * Official changelogs are real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:54:21 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Clocks ${VER_UP} — official Ubuntu 20.04
(focal-updates) universe arm64, KEMI repack.

Official ELF stays at /usr/bin/gnome-clocks
(compiled /usr/share/locale and help:gnome-clocks).
/opt/gnome-clocks/* are symlinks. Desktop, official
72 .mo (including zh_CN), official Yelp help and
official SVG icons remain on standard paths.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1
versioned, 0 null) · no GLIBCXX; Ubuntu 20.04 /
glibc 2.31 OK.
Official publication: Ubuntu 20.04 focal-updates
universe arm64 gnome-clocks 3.36.2-1~ubuntu20.04.1
(newer than focal Release 3.36.0-1). Official
SHA256 + size matched ports.ubuntu.com pool files
and focal-updates universe arm64 Packages stanza.
No librarian URL this run.
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
Depends: geoclue-2.0, dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libgeoclue-2-0 (>= 2.4.0), libgeocode-glib0 (>= 1.0), libglib2.0-0 (>= 2.58), libgnome-desktop-3-19 (>= 3.17.92), libgsound0 (>= 1.0.1), libgtk-3-0 (>= 3.20.0), libgweather-3-16 (>= 3.32.0), libhandy-0.0-0 (>= 0.0.10)
Replaces: gnome-clocks
Conflicts: gnome-clocks
Provides: gnome-clocks (= 3.36.2-1~ubuntu20.04.1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Clocks
Description: Simple GNOME app with stopwatch, timer, and world clock support (arm64)
 GNOME Clocks ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
 World clocks, alarms, stopwatch and timer (GTK3).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-clocks-control.txt"
