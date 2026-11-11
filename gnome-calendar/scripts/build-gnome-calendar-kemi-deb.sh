#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main) gnome-calendar
# 3.36.2-0ubuntu1 arm64 as kemi-gnome-calendar.
# focal Release is 3.36.1-1; this job uses the current official
# focal-updates package (still Ubuntu 20.04 deps). The
# gnome-calendar source ships only this one binary package in
# focal (no same-source -data/-common to bundle). Official
# Recommends evolution-data-server (different source, not an
# exact-version plugin Depends of gnome-calendar) stays
# Recommends and is not bundled. Official control has no
# Suggests. System Depends (GTK3, libhandy-0.0, gweather,
# evolution-data-server libs, geoclue, goa, etc.) stay
# Depends. Versioned Provides:
# gnome-calendar (= 3.36.2-0ubuntu1).
# Official binary: /usr/bin/gnome-calendar. The ELF embeds
# /usr/share/locale and UI in a GResource
# (/org/gnome/calendar/...). Official files stay on official
# paths; /opt/gnome-calendar/* are symlinks (same compiled-/usr
# layout as gnome-clocks/workrave). Official package ships no
# .mo (Ubuntu language-pack split; desktop
# X-Ubuntu-Gettext-Domain=gnome-calendar). Official package
# has no /usr/share/help tree. Official icons are SVG only
# (org.gnome.Calendar.svg, Devel, and symbolic). Keep the
# official tree; do not invent language-packs, help trees, or
# SVG/PNG icons in the package. A 128x128 PNG rasterized from
# the official SVG may be used only as the mall CREATE --icon
# and must live under evidence/, not in the deb (GNOME Clocks
# pattern). Official changelog is a real file. No official
# maintainer scripts. Official org.gnome.Calendar.service
# already uses /usr/bin/gnome-calendar --gapplication-service
# and is kept. Official desktop Exec=gnome-calendar is
# rewritten to /usr/bin/gnome-calendar; Icon=org.gnome.Calendar
# is kept. Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1
# versioned, 0 null) · no GLIBCXX (0 versioned, 1 null) · PASS
# vs 101 ≤2.31 / ≤3.4.28. Official SHA256 + size matched
# official ports.ubuntu.com pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 3.36.2-0ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; sibling 3.36.1-0ubuntu0.20.04.1kemi1 at 28 chars
# succeeded; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; font-manager 0.7.7-0.3kemi1 was 14 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-calendar
VER_UP=3.36.2-0ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-calendar
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/gnome-calendar-3.36.2-focal-unpack}"
UP_DEB="$DL/gnome-calendar_3.36.2-0ubuntu1_arm64.deb"
EXPECT_SHA=43ce30c6ff3eb31ee647f63889ba03cae681e9c7eb6996dbb780a54e2df0c494
EXPECT_BYTES=205476
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-calendar"
test -f "$UNPACK/usr/share/applications/org.gnome.Calendar.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Calendar.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Calendar-symbolic.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.Calendar.png"
test ! -d "$UNPACK/usr/share/icons/hicolor/48x48"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/help"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.Calendar.service"
test -f "$UNPACK/usr/share/gnome-shell/search-providers/org.gnome.Calendar.search-provider.ini"
test ! -L "$UNPACK/usr/share/doc/gnome-calendar/changelog.Debian.gz"
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/gnome-calendar")
python3 -c 's="3.36.2-0ubuntu1kemi1"; assert len(s)==20, len(s); print("version_name_len", len(s))'
# evidence raster must not be packed later; just confirm it is outside the unpack
test -f "$ROOT/evidence/org.gnome.Calendar-128.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.Calendar.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/gnome-calendar" \
  "$STAGE/pkg/opt/gnome-calendar"

cp -a "$UNPACK/usr/bin/gnome-calendar" "$STAGE/pkg/usr/bin/gnome-calendar"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-calendar"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

REPORT="$ROOT/probe/kemi-gnome-calendar.json"
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
if Path(f["path"]).name != "gnome-calendar":
    raise SystemExit(f"PROBE_NAME:{f['path']}")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{f.get('requiredGlibcxx')}")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or nulls or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libhandy-0.0.so.0", "libecal-2.0.so.1", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
r["elfCount"] = 1
r["glibcVersioned"] = 1
r["glibcNull"] = 0
r["glibcxxVersioned"] = 0
r["glibcxxNull"] = 1
r["maxVersionedGlibc"] = "2.17"
r["maxVersionedGlibcxx"] = None
Path("$REPORT").write_text(json.dumps(r, ensure_ascii=False, indent=2) + "\n")
print("PROBE_PASS n_elf=1 arch=aarch64 glibc_versioned=1 glibc_null=0 max_glibc=2.17 glibcxx_versioned=0 glibcxx_null=1 max_glibcxx=null")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Calendar.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.Calendar.png"
# evidence raster must not have been copied into the package
if find "$STAGE/pkg" -name 'org.gnome.Calendar-128.png' | grep -q .; then
  raise_fail() { echo "INVENTED_RASTER_IN_PACKAGE"; exit 1; }
  raise_fail
fi
test ! -L "$STAGE/pkg/usr/share/doc/gnome-calendar/changelog.Debian.gz"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-calendar/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-calendar/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/org.gnome.Calendar.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Calendar.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnome-calendar(\s.*)?$", r"Exec=/usr/bin/gnome-calendar\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=gnome-calendar$", "TryExec=/usr/bin/gnome-calendar", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gnome-calendar(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/gnome-calendar", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnome-calendar(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/gnome-calendar", "TryExec=/usr/bin/gnome-calendar"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=org.gnome.Calendar$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if not re.search(r"^Name=Calendar$", text2, flags=re.M):
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten")

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Calendar.service")
st = svc.read_text(encoding="utf-8")
if "Exec=/usr/bin/gnome-calendar --gapplication-service" not in st:
    raise SystemExit("DBUS_EXEC")
print("dbus_ok")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".so", ".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in t:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86_TREE:" + ",".join(leftover))
print("no_leftover_x86_paths")
PY

ln -sf /usr/bin/gnome-calendar "$STAGE/pkg/opt/gnome-calendar/gnome-calendar"
ln -sf gnome-calendar "$STAGE/pkg/usr/bin/kemi-gnome-calendar"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Calendar
Source: https://launchpad.net/ubuntu/+source/gnome-calendar
Homepage: https://wiki.gnome.org/Apps/Calendar
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(gnome-calendar_3.36.2-0ubuntu1_arm64.deb), repackaged
for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-calendar_3.36.2-0ubuntu1_arm64.deb
    (focal-updates main; newer than focal Release 3.36.1-1,
    still Ubuntu 20.04 deps) repackaged for KEMI as ${PKG}.
  * No same-source -data/-common to bundle. Official
    Recommends evolution-data-server stays Recommends.
    Versioned Provides: gnome-calendar (= 3.36.2-0ubuntu1).
  * Official ELF stays at /usr/bin/gnome-calendar (compiled
    /usr/share/locale; UI in a GResource). /opt/gnome-calendar/*
    are symlinks.
  * Desktop, official SVG icons, gsettings schemas, D-Bus
    service and GNOME Shell search provider stay on standard
    paths. Official desktop Exec=gnome-calendar rewritten to
    /usr/bin/gnome-calendar. Official package ships no .mo
    and no /usr/share/help; language packs and help trees
    are not invented. Official icons are SVG only; no PNG is
    invented in the package.
  * Official changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 23:15:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Calendar ${VER_UP} — official Ubuntu 20.04
(focal-updates) main arm64, KEMI repack.

Official ELF stays at /usr/bin/gnome-calendar (compiled
/usr/share/locale). /opt/gnome-calendar/* are symlinks.
Desktop, official SVG icons, schemas and D-Bus service
remain on standard paths. Official Recommends
evolution-data-server stays Recommends. Official package
ships no .mo and no help tree; those are not invented.
Official icons are SVG only.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1 versioned,
0 null) · no GLIBCXX (0 versioned, 1 null); Ubuntu 20.04 /
glibc 2.31 / GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal-updates main
arm64 gnome-calendar 3.36.2-0ubuntu1. Official SHA256 +
size matched ports.ubuntu.com pool files and
focal-updates main arm64 Packages stanza. No librarian
URL this run.
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
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdazzle-1.0-0 (>= 3.33.90), libecal-2.0-1 (>= 3.33.4), libedataserver-1.2-24 (>= 3.17.90), libedataserverui-1.2-2 (>= 3.17.1), libgeoclue-2-0 (>= 2.4.0), libglib2.0-0 (>= 2.61.2), libgoa-1.0-0b (>= 3.2.0), libgtk-3-0 (>= 3.22.20), libgweather-3-16 (>= 3.27.2), libhandy-0.0-0 (>= 0.0.9), libical3 (>= 3.0.0), libpango-1.0-0 (>= 1.22.0), libpangocairo-1.0-0 (>= 1.14.0), libsoup2.4-1 (>= 2.41.90), gsettings-desktop-schemas (>= 3.21.2)
Recommends: evolution-data-server
Replaces: gnome-calendar
Conflicts: gnome-calendar
Provides: gnome-calendar (= 3.36.2-0ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Calendar
Description: Calendar application for GNOME (arm64)
 GNOME Calendar ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Simple calendar for the GNOME desktop (GTK3).
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
sha256sum "$DEB" | tee "$OUT/${PKG}_${VER_DEB}_${ARCH}.deb.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-calendar-control.txt"
python3 -c 's="3.36.2-0ubuntu1kemi1"; print("BUILT_VERSION_NAME_LEN", len(s))'
# final: packaged tree has no invented PNG
python3 - << PY
import tarfile, subprocess, io
from pathlib import Path
deb=Path("$DEB")
# list data.tar
out=subprocess.check_output(["dpkg-deb","-c",str(deb)], text=True)
if "org.gnome.Calendar-128.png" in out or "128x128/apps/org.gnome.Calendar.png" in out:
    raise SystemExit("INVENTED_PNG_IN_DEB")
if ".mo" in out:
    # ok if none expected
    pass
print("DEB_HAS_NO_INVENTED_PNG")
PY
