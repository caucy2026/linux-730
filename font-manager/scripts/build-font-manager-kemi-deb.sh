#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) font-manager
# 0.7.7-0.3 arm64 as kemi-font-manager, bundling same-source
# exact-version hard-Depends font-manager-common (= 0.7.7-0.3)
# and font-viewer (= 0.7.7-0.3). Official control has no
# Recommends. Official Suggests file-roller,
# nautilus-font-manager, nemo-font-manager and yelp stay
# Suggests and are not bundled (those extension debs Depends
# font-viewer (= 0.7.7-0.3) plus nautilus/nemo; they are
# Suggests, not the Remmina/AbiWord Recommends-plugin
# pattern). System library and
# dconf-gsettings-backend | gsettings-backend Depends stay
# Depends. Versioned Provides: font-manager (= 0.7.7-0.3),
# font-manager-common (= 0.7.7-0.3), font-viewer (= 0.7.7-0.3).
# Official binaries stay at /usr/bin/font-manager and
# /usr/libexec/font-manager/font-viewer; the private
# libfontmanager.so.0 lives under
# /usr/lib/aarch64-linux-gnu/font-manager and both ELFs have
# RUNPATH to that dir, so official files stay on official
# /usr paths; /opt/font-manager/* are only symlinks.
# Official font-manager-common ships 12 .mo including zh_CN
# and official Yelp help under
# /usr/share/help/{C,ar,ca,es,hr,pl,ru}/font-manager/.
# Keep the official tree; do not invent language-packs, help
# trees, or extra SVG/PNG. Official desktop Icon is the stock
# theme name preferences-desktop-font; the package ships no
# hicolor/pixmaps app icon. An official 48x48 PNG already
# exists in the help media tree and may be used only as the
# mall CREATE --icon (Zim pattern: do not invent another
# raster and do not pack an extra copy). Official
# org.gnome.FontManager.service already uses
# /usr/bin/font-manager --gapplication-service and
# org.gnome.FontViewer.service already uses
# /usr/libexec/font-manager/font-viewer --gapplication-service;
# both are kept. Official desktop Exec=font-manager %u is
# rewritten to /usr/bin/font-manager %u; Font Viewer Exec is
# already absolute and is kept. Official common changelog is
# a real file; the binary and viewer changelogs are official
# symlinks onto it and resolve after bundling. Official
# packages have no maintainer scripts. Official shlibs are
# retargeted to kemi-font-manager; official ldconfig trigger
# is kept. Probe: aarch64 · 3 unique ELF · all requiredGlibc
# 2.17 (3 versioned, 0 null) · no GLIBCXX (0 versioned, 3
# null) · PASS vs 101 ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal universe arm64 Packages stanzas (Aliyun
# ubuntu-ports mirror, streamed). No newer package in
# focal-updates. No librarian URL and no .buildinfo is
# recorded this run (pool 404). KEMI version 0.7.7-0.3kemi1
# is 14 chars (under the mall version_name limit that
# rejected Remmina's 33-char string; gnome-clocks
# 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars; zim 0.72.0-1kemi1
# was 13 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-font-manager
VER_UP=0.7.7-0.3
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-font-manager
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/font-manager-0.7.7-focal-unpack}"
BIN_UNPACK="$UNPACK/font-manager"
COMMON_UNPACK="$UNPACK/font-manager-common"
VIEW_UNPACK="$UNPACK/font-viewer"
UP_DEB="$DL/font-manager_0.7.7-0.3_arm64.deb"
COMMON_DEB="$DL/font-manager-common_0.7.7-0.3_arm64.deb"
VIEW_DEB="$DL/font-viewer_0.7.7-0.3_arm64.deb"
EXPECT_SHA=ea6f63421649df9d0556b728f95300bb5d672a95dc0825dc2ffb5638729d7aad
EXPECT_BYTES=153036
EXPECT_COMMON_SHA=0d25cb778199286df3a6350ef1e795e134cd5ed87de28ac508412c4f1166d3e1
EXPECT_COMMON_BYTES=1531196
EXPECT_VIEW_SHA=dddd19c5daa3d847f217c6d8f677752cfe1e1ae854c89ae97ae2b779ee09f925
EXPECT_VIEW_BYTES=26740
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$COMMON_DEB"
test "$(stat -c%s "$COMMON_DEB")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_COMMON_SHA  $COMMON_DEB" | sha256sum -c -
test -f "$VIEW_DEB"
test "$(stat -c%s "$VIEW_DEB")" = "$EXPECT_VIEW_BYTES"
echo "$EXPECT_VIEW_SHA  $VIEW_DEB" | sha256sum -c -
test -x "$BIN_UNPACK/usr/bin/font-manager"
test -x "$VIEW_UNPACK/usr/libexec/font-manager/font-viewer"
test -f "$COMMON_UNPACK/usr/lib/aarch64-linux-gnu/font-manager/libfontmanager.so.0.7.7"
test -L "$COMMON_UNPACK/usr/lib/aarch64-linux-gnu/font-manager/libfontmanager.so.0"
test -f "$BIN_UNPACK/usr/share/applications/org.gnome.FontManager.desktop"
test -f "$VIEW_UNPACK/usr/share/applications/org.gnome.FontViewer.desktop"
test -f "$COMMON_UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/font-manager.mo"
test "$(find "$COMMON_UNPACK" -name '*.mo' | wc -l)" = 12
test "$(find "$BIN_UNPACK" -name '*.mo' | wc -l)" = 0
test "$(find "$VIEW_UNPACK" -name '*.mo' | wc -l)" = 0
test -f "$COMMON_UNPACK/usr/share/help/C/font-manager/index.page"
test -f "$COMMON_UNPACK/usr/share/help/C/font-manager/media/preferences-desktop-font.png"
test ! -d "$BIN_UNPACK/usr/share/icons"
test ! -d "$COMMON_UNPACK/usr/share/icons"
test ! -d "$VIEW_UNPACK/usr/share/icons"
test ! -d "$BIN_UNPACK/usr/share/pixmaps"
test ! -L "$COMMON_UNPACK/usr/share/doc/font-manager-common/changelog.Debian.gz"
test -L "$BIN_UNPACK/usr/share/doc/font-manager/changelog.Debian.gz"
test -L "$VIEW_UNPACK/usr/share/doc/font-viewer/changelog.Debian.gz"
grep -qx '/usr/lib/aarch64-linux-gnu/font-manager' < <(strings -n 8 "$BIN_UNPACK/usr/bin/font-manager")
grep -qx '/usr/lib/aarch64-linux-gnu/font-manager' < <(strings -n 8 "$VIEW_UNPACK/usr/libexec/font-manager/font-viewer")
# version_name length under mall limit
python3 -c 's="0.7.7-0.3kemi1"; assert len(s)==14, len(s); print("version_name_len", len(s))'

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/libexec/font-manager" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/font-manager" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/font-manager" \
  "$STAGE/pkg/usr/share/doc/font-manager-common" \
  "$STAGE/pkg/usr/share/doc/font-viewer" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/font-manager"

# official trees: common first, then binary + viewer
cp -a "$COMMON_UNPACK/usr/lib/aarch64-linux-gnu/font-manager/." \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/font-manager/"
cp -a "$COMMON_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
cp -a "$BIN_UNPACK/usr/bin/font-manager" "$STAGE/pkg/usr/bin/font-manager"
chmod 0755 "$STAGE/pkg/usr/bin/font-manager"
cp -a "$BIN_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
cp -a "$VIEW_UNPACK/usr/libexec/font-manager/font-viewer" \
  "$STAGE/pkg/usr/libexec/font-manager/font-viewer"
chmod 0755 "$STAGE/pkg/usr/libexec/font-manager/font-viewer"
cp -a "$VIEW_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

# unique ELF (skip symlinks)
REPORT="$ROOT/probe/kemi-font-manager.json"
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
if len(files) != 3:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by = {Path(f["path"]).name: f for f in files}
need_glibc = {
    "font-manager": "2.17",
    "font-viewer": "2.17",
    "libfontmanager.so.0.7.7": "2.17",
}
if set(by) != set(need_glibc):
    raise SystemExit(f"PROBE_NAMES:{sorted(by)}")
versioned = [f for f in files if f.get("requiredGlibc") is not None]
nulls = [f for f in files if f.get("requiredGlibc") is None]
cxx = [f for f in files if f.get("requiredGlibcxx") is not None]
cxx_null = [f for f in files if f.get("requiredGlibcxx") is None]
if len(versioned) != 3 or nulls or cxx or len(cxx_null) != 3:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
for name, glibc in need_glibc.items():
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH:{name}")
    if f.get("requiredGlibc") != glibc:
        raise SystemExit(f"PROBE_GLIBC:{name}:{f.get('requiredGlibc')}")
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{name}")
needed = set(by["font-manager"].get("neededLibraries") or [])
for lib in ("libfontmanager.so.0", "libgtk-3.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
# None-safe summary fields (do not rank a null as the max)
r["elfCount"] = 3
r["glibcVersioned"] = 3
r["glibcNull"] = 0
r["glibcxxVersioned"] = 0
r["glibcxxNull"] = 3
r["maxVersionedGlibc"] = "2.17"
r["maxVersionedGlibcxx"] = None
Path("$REPORT").write_text(json.dumps(r, ensure_ascii=False, indent=2) + "\n")
print("PROBE_PASS n_elf=3 arch=aarch64 glibc_versioned=3 glibc_null=0 max_glibc=2.17 glibcxx_versioned=0 glibcxx_null=3 max_glibcxx=null")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 12
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/font-manager.mo"
test -f "$STAGE/pkg/usr/share/help/C/font-manager/index.page"
test -f "$STAGE/pkg/usr/share/help/C/font-manager/media/preferences-desktop-font.png"
test ! -d "$STAGE/pkg/usr/share/icons"
test ! -d "$STAGE/pkg/usr/share/pixmaps"
# official changelog symlink now resolves after bundling
test -f "$STAGE/pkg/usr/share/doc/font-manager/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/font-viewer/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/font-manager-common/changelog.Debian.gz"

cp --remove-destination -L \
  "$COMMON_UNPACK/usr/share/doc/font-manager-common/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$COMMON_UNPACK/usr/share/doc/font-manager-common/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$BIN_UNPACK/usr/share/applications/org.gnome.FontManager.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.FontManager.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=font-manager(\s.*)?$", r"Exec=/usr/bin/font-manager\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=font-manager$", "TryExec=/usr/bin/font-manager", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/font-manager(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/font-manager", text2, count=1, flags=re.M)
if re.search(r"^Exec=font-manager(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/font-manager %u", "TryExec=/usr/bin/font-manager", "Icon=preferences-desktop-font", "Name=Font Manager"):
    if expect not in text2 and not (expect.startswith("Icon=") and re.search(r"^Icon=preferences-desktop-font$", text2, flags=re.M)):
        if expect.startswith("Icon=") and re.search(r"^Icon=preferences-desktop-font$", text2, flags=re.M):
            pass
        elif expect not in text2:
            raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=preferences-desktop-font$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Font Manager" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_manager_rewritten")

vsrc = Path("$VIEW_UNPACK/usr/share/applications/org.gnome.FontViewer.desktop")
vdst = Path("$STAGE/pkg/usr/share/applications/org.gnome.FontViewer.desktop")
vtext = vsrc.read_text(encoding="utf-8")
# official Exec is already absolute
if "Exec=/usr/libexec/font-manager/font-viewer %u" not in vtext:
    raise SystemExit("VIEWER_EXEC_NOT_ABSOLUTE")
v2 = vtext
if not re.search(r"^TryExec=", v2, flags=re.M):
    v2 = re.sub(r"^(Exec=/usr/libexec/font-manager/font-viewer(?:\s.*)?)$",
                r"\1\nTryExec=/usr/libexec/font-manager/font-viewer", v2, count=1, flags=re.M)
if not re.search(r"^Icon=preferences-desktop-font$", v2, flags=re.M):
    raise SystemExit("VIEWER_MISSING_ICON")
if "Name=Font Viewer" not in v2:
    raise SystemExit("VIEWER_MISSING_NAME")
vdst.write_text(v2, encoding="utf-8")
print("desktop_viewer_kept_absolute")

for svc, needle in (
    (Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.FontManager.service"),
     "Exec=/usr/bin/font-manager --gapplication-service"),
    (Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.FontViewer.service"),
     "Exec=/usr/libexec/font-manager/font-viewer --gapplication-service"),
):
    st = svc.read_text(encoding="utf-8")
    if needle not in st:
        raise SystemExit(f"DBUS_EXEC:{svc.name}")
print("dbus_ok")

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
    raise SystemExit("LEFTOVER_X86_TREE:" + ",".join(leftover))
print("no_leftover_x86_paths")
PY

ln -sf /usr/bin/font-manager "$STAGE/pkg/opt/font-manager/font-manager"
ln -sf /usr/libexec/font-manager/font-viewer "$STAGE/pkg/opt/font-manager/font-viewer"
ln -sf font-manager "$STAGE/pkg/usr/bin/kemi-font-manager"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://fontmanager.github.io/
Source: https://launchpad.net/ubuntu/+source/font-manager
Homepage: https://fontmanager.github.io/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(font-manager_0.7.7-0.3_arm64.deb) plus bundled same-source
exact-version font-manager-common_0.7.7-0.3_arm64.deb and
font-viewer_0.7.7-0.3_arm64.deb, repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 font-manager_0.7.7-0.3_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    exact-version hard-Depends font-manager-common
    (= 0.7.7-0.3) and font-viewer (= 0.7.7-0.3).
  * Official Suggests file-roller, nautilus-font-manager,
    nemo-font-manager and yelp stay Suggests. Versioned
    Provides: font-manager (= 0.7.7-0.3),
    font-manager-common (= 0.7.7-0.3),
    font-viewer (= 0.7.7-0.3).
  * Official ELF stays at /usr/bin/font-manager (RUNPATH
    /usr/lib/aarch64-linux-gnu/font-manager). Official
    font-viewer stays at /usr/libexec/font-manager/font-viewer.
    Official private lib stays on the official /usr/lib path.
    /opt/font-manager/* are symlinks.
  * Desktop, man, official 12 .mo (including zh_CN) and
    official Yelp help stay on standard paths. Official
    desktop Exec=font-manager %u rewritten to
    /usr/bin/font-manager %u. Official Font Viewer Exec
    already absolute and kept. Official desktop Icon is
    the stock name preferences-desktop-font; no hicolor
    app icon is invented.
  * Official common changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 23:08:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Font Manager ${VER_UP} — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source exact-version font-manager-common and
font-viewer.

Official ELF stays at /usr/bin/font-manager (RUNPATH
/usr/lib/aarch64-linux-gnu/font-manager).
/opt/font-manager/* are symlinks.
Desktop, man, official 12 .mo (including zh_CN) and
official Yelp help remain on standard paths. Official
Suggests file-roller, nautilus-font-manager,
nemo-font-manager and yelp stay Suggests.
Probe: aarch64 · 3 unique ELF · requiredGlibc 2.17
(3 versioned, 0 null) · no GLIBCXX (0 versioned, 3
null); Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal universe
arm64 font-manager 0.7.7-0.3 plus font-manager-common
and font-viewer. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: graphics
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.10.0), libfontconfig1 (>= 2.12.6), libfreetype6 (>= 2.6), libglib2.0-0 (>= 2.44), libgtk-3-0 (>= 3.22), libjson-glib-1.0-0 (>= 1.2.0), libpango-1.0-0 (>= 1.22.0), libpangoft2-1.0-0 (>= 1.14.0), libsqlite3-0 (>= 3.6.17), libxml2 (>= 2.7.4)
Suggests: file-roller, nautilus-font-manager, nemo-font-manager, yelp
Replaces: font-manager, font-manager-common, font-viewer
Conflicts: font-manager, font-manager-common, font-viewer
Provides: font-manager (= 0.7.7-0.3), font-manager-common (= 0.7.7-0.3), font-viewer (= 0.7.7-0.3)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://fontmanager.github.io/
Description: font management application for the GNOME desktop (arm64)
 Font Manager ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled font-manager-common and
 font-viewer.
 Preview, compare and manage desktop fonts (GTK3).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official shlibs retargeted to kemi-font-manager
cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libfontmanager 0 kemi-font-manager (>= 0.7.7-0.3kemi1)
EOT

# official ldconfig trigger kept
cat > "$STAGE/pkg/DEBIAN/triggers" << 'EOT'
# Triggers added by dh_makeshlibs/12.10ubuntu1
activate-noawait ldconfig
EOT

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
# hash by explicit path (do not use find | head)
sha256sum "$DEB" | tee "$OUT/${PKG}_${VER_DEB}_${ARCH}.deb.sha256"
# also write basename sidecar form later for recipe
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-font-manager-control.txt"
python3 -c 's="0.7.7-0.3kemi1"; print("BUILT_VERSION_NAME_LEN", len(s))'
