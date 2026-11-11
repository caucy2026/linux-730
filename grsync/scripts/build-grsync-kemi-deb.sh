#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) grsync
# 1.2.6-2 arm64 as kemi-grsync. The grsync source ships only
# this one binary package in focal (no same-source
# -data/-common to bundle). Official Recommends ssh-askpass
# (different source, not an exact-version plugin Depends)
# stays Recommends and is not bundled. Official control has
# no Suggests. System Depends (GTK2, glib, pango, rsync,
# libc6) stay Depends. Official Description correctly says
# GTK2; the ELF NEEDED libgtk-x11-2.0.so.0 confirms GTK2
# (not a stale GTK2 description of a GTK3 binary).
# Versioned Provides: grsync (= 1.2.6-2).
# Official binary stays at /usr/bin/grsync. Official
# /usr/bin/grsync-batch is a bash wrapper and is kept. The
# ELF embeds /usr/share/grsync/grsync.glade,
# /usr/share/locale and /usr/share/pixmaps/grsync.png, so
# official files stay on official paths; /opt/grsync/* are
# only symlinks (same compiled-/usr layout as
# gnome-clocks/luckybackup). Official package ships 18 .mo
# (including a zh locale and official zh/zh_TW tree; no
# official zh_CN .mo). Official glade UI, pixmap icons
# (128x128 PNG + XPM + busy PNG) and a 48x48 mime icon are
# kept. Do not invent language packs, help trees, or extra
# SVG/PNG. Official desktop Icon=grsync.png; the official
# pixmap PNG is used as the mall CREATE --icon and is not
# packed a second time (Zim pattern). Official desktop
# Exec=/usr/bin/grsync -i %f is already absolute and is
# kept. Official changelog is a real file. No official
# maintainer scripts. Probe: aarch64 · 1 ELF · requiredGlibc
# 2.17 (1 versioned, 0 null) · no GLIBCXX (0 versioned, 1
# null) · PASS vs 101 ≤2.31 / ≤3.4.28. Official SHA256 +
# size matched official ports.ubuntu.com pool files and the
# Ubuntu 20.04 focal universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No newer package in
# focal-updates. No librarian URL and no .buildinfo is
# recorded this run (pool 404).
# KEMI version 1.2.6-2kemi1 is 12 chars (under the mall
# version_name limit that rejected Remmina's 33-char string;
# sibling 3.36.1-0ubuntu0.20.04.1kemi1 at 28 chars succeeded;
# gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars;
# gnome-calendar 3.36.2-0ubuntu1kemi1 was 20 chars;
# luckybackup 0.5.0-3build1kemi1 was 18 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-grsync
VER_UP=1.2.6-2
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-grsync
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/grsync-1.2.6-focal-unpack}"
UP_DEB="$DL/grsync_1.2.6-2_arm64.deb"
EXPECT_SHA=400888f8f38cca84210bf4c410e04c5d23dfb9e5eac184c403fb3dec176d1de8
EXPECT_BYTES=135996
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/grsync"
test -x "$UNPACK/usr/bin/grsync-batch"
test -f "$UNPACK/usr/share/applications/grsync.desktop"
test -f "$UNPACK/usr/share/pixmaps/grsync.png"
test -f "$UNPACK/usr/share/pixmaps/grsync.xpm"
test -f "$UNPACK/usr/share/grsync/grsync.glade"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 18
test -f "$UNPACK/usr/share/locale/zh/LC_MESSAGES/grsync.mo"
test ! -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/grsync.mo"
test ! -d "$UNPACK/usr/share/help"
test ! -L "$UNPACK/usr/share/doc/grsync/changelog.Debian.gz"
grep -qx '/usr/share/grsync/grsync.glade' < <(strings -n 8 "$UNPACK/usr/bin/grsync")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/grsync")
python3 -c 's="1.2.6-2kemi1"; assert len(s)==12, len(s); print("version_name_len", len(s))'
# official PNG exists; do not invent another
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/grsync.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/grsync" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/grsync"

cp -a "$UNPACK/usr/bin/grsync" "$STAGE/pkg/usr/bin/grsync"
chmod 0755 "$STAGE/pkg/usr/bin/grsync"
cp -a "$UNPACK/usr/bin/grsync-batch" "$STAGE/pkg/usr/bin/grsync-batch"
chmod 0755 "$STAGE/pkg/usr/bin/grsync-batch"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

REPORT="$ROOT/probe/kemi-grsync.json"
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
if Path(f["path"]).name != "grsync":
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
for lib in ("libgtk-x11-2.0.so.0", "libglib-2.0.so.0", "libc.so.6"):
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

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 18
test -f "$STAGE/pkg/usr/share/locale/zh/LC_MESSAGES/grsync.mo"
test ! -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/grsync.mo"
test -f "$STAGE/pkg/usr/share/grsync/grsync.glade"
test -f "$STAGE/pkg/usr/share/pixmaps/grsync.png"
test ! -d "$STAGE/pkg/usr/share/help"
head -1 "$STAGE/pkg/usr/bin/grsync-batch" | grep -qx '#!/bin/bash'

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/grsync/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/grsync/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/grsync.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/grsync.desktop")
text = src.read_text(encoding="utf-8")
if not re.search(r"^Exec=/usr/bin/grsync -i %f$", text, flags=re.M):
    raise SystemExit("EXEC_NOT_ABSOLUTE")
text2 = text
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/grsync(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/grsync", text2, count=1, flags=re.M)
if not re.search(r"^Icon=grsync\.png$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if not re.search(r"^Name=Grsync$", text2, flags=re.M):
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_kept_absolute")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".so", ".png", ".svg", ".mo", ".gz", ".xpm", ".glade", ".xml"}:
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

ln -sf /usr/bin/grsync "$STAGE/pkg/opt/grsync/grsync"
ln -sf /usr/bin/grsync-batch "$STAGE/pkg/opt/grsync/grsync-batch"
ln -sf grsync "$STAGE/pkg/usr/bin/kemi-grsync"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.opbyte.it/grsync/
Source: https://launchpad.net/ubuntu/+source/grsync
Homepage: http://www.opbyte.it/grsync/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(grsync_1.2.6-2_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 grsync_1.2.6-2_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}.
  * No same-source -data/-common to bundle. Official
    Recommends ssh-askpass stays Recommends. Versioned
    Provides: grsync (= 1.2.6-2).
  * Official ELF stays at /usr/bin/grsync (compiled
    /usr/share/grsync/grsync.glade). Official
    grsync-batch wrapper stays at /usr/bin/grsync-batch.
    /opt/grsync/* are symlinks.
  * Desktop, man, official 18 .mo (including zh; no
    official zh_CN), official glade UI and official pixmap
    icons stay on standard paths. Official desktop Exec
    already absolute and kept. Official Description and
    binary are GTK2. Official pixmap already includes a
    128x128 PNG; no extra raster is invented in the package.
  * Official changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 23:26:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Grsync ${VER_UP} — official Ubuntu 20.04
(focal) universe arm64, KEMI repack.

Official ELF stays at /usr/bin/grsync (compiled
/usr/share/grsync/grsync.glade). /opt/grsync/* are
symlinks. Desktop, man, official 18 .mo, official
glade UI and official pixmap icons remain on standard
paths. Official Recommends ssh-askpass stays
Recommends. Official binary is GTK2.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1
versioned, 0 null) · no GLIBCXX (0 versioned, 1 null);
Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal universe
arm64 grsync 1.2.6-2. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: x11
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.35.9), libgtk2.0-0 (>= 2.12.0), libpango-1.0-0 (>= 1.14.0), rsync
Recommends: ssh-askpass
Replaces: grsync
Conflicts: grsync
Provides: grsync (= 1.2.6-2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.opbyte.it/grsync/
Description: GTK+ frontend for rsync (arm64)
 Grsync ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Simple GTK2 GUI for rsync directory synchronization.
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
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime >/dev/null 2>&1 || true
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-grsync-control.txt"
python3 -c 's="1.2.6-2kemi1"; print("BUILT_VERSION_NAME_LEN", len(s))'
