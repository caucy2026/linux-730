#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) luckybackup
# 0.5.0-3build1 arm64 as kemi-luckybackup, bundling same-source
# exact-version hard-Depends luckybackup-data (= 0.5.0-3build1)
# (luckybackup-data is Architecture: all). Official binary
# control has no Recommends and no Suggests. Official
# luckybackup-data Recommends: luckybackup is dropped once
# bundled. System Depends (Qt5, libstdc++6, rsync, libc6)
# stay Depends. Versioned Provides: luckybackup (= 0.5.0-3build1)
# and luckybackup-data (= 0.5.0-3build1).
# Official binary stays at /usr/bin/luckybackup. The official
# pkexec wrapper /usr/bin/luckybackup-pkexec already calls
# /usr/bin/luckybackup and is kept. The ELF embeds
# /usr/share/luckybackup/translations/ and
# /usr/share/doc/luckybackup/manual/index.html, so official
# files stay on official paths; /opt/luckybackup/* are only
# symlinks (same compiled-/usr layout as keepassxc/gnome-clocks).
# Official luckybackup-data ships 26 Qt .qm (plus matching
# .ts; includes zh_TW, no official zh_CN) and the official
# HTML manual under /usr/share/doc/luckybackup/manual/. Keep
# the official tree; do not invent language packs, help trees,
# or extra SVG/PNG. Official desktop Icon is the already-
# absolute /usr/share/pixmaps/luckybackup.png (and .xpm);
# that official 60x57 PNG is used as the mall CREATE --icon
# and is not packed a second time (Zim pattern). Official
# desktop Exec lines are already absolute and are kept.
# Official changelogs are real files. No official maintainer
# scripts. No official polkit policy file is shipped (do not
# invent one). Official arch:all data has no
# /usr/lib/x86_64-linux-gnu paths. Probe: aarch64 · 1 ELF ·
# requiredGlibc 2.17 (1 versioned, 0 null) · requiredGlibcxx
# 3.4.21 (1 versioned, 0 null) · PASS vs 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
# No newer package in focal-updates. No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 0.5.0-3build1kemi1 is 18 chars (under the mall
# version_name limit that rejected Remmina's 33-char string;
# sibling 3.36.1-0ubuntu0.20.04.1kemi1 at 28 chars succeeded;
# gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars;
# gnome-calendar 3.36.2-0ubuntu1kemi1 was 20 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-luckybackup
VER_UP=0.5.0-3build1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-luckybackup
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/luckybackup-0.5.0-focal-unpack}"
BIN_UNPACK="$UNPACK/luckybackup"
DATA_UNPACK="$UNPACK/luckybackup-data"
UP_DEB="$DL/luckybackup_0.5.0-3build1_arm64.deb"
DATA_DEB="$DL/luckybackup-data_0.5.0-3build1_all.deb"
EXPECT_SHA=2e58d0b67d97cea41ff9c970adb4ec19e56b5e350f02f7a536c150a5e270beb2
EXPECT_BYTES=461892
EXPECT_DATA_SHA=ac4b4abae5dd006bb19ac1439070bffb8f122f6bec07a97e90d3a25b39bb97da
EXPECT_DATA_BYTES=3574912
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$DATA_DEB"
test "$(stat -c%s "$DATA_DEB")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$BIN_UNPACK/usr/bin/luckybackup"
test -x "$BIN_UNPACK/usr/bin/luckybackup-pkexec"
test -f "$BIN_UNPACK/usr/share/applications/luckybackup.desktop"
test -f "$BIN_UNPACK/usr/share/applications/luckybackup-su.desktop"
test -f "$BIN_UNPACK/usr/share/pixmaps/luckybackup.png"
test -f "$BIN_UNPACK/usr/share/pixmaps/luckybackup.xpm"
test -f "$DATA_UNPACK/usr/share/luckybackup/translations/luckybackup_zh_TW.qm"
test ! -f "$DATA_UNPACK/usr/share/luckybackup/translations/luckybackup_zh_CN.qm"
test "$(find "$DATA_UNPACK" -name '*.qm' | wc -l)" = 26
test "$(find "$BIN_UNPACK" -name '*.qm' | wc -l)" = 0
test -f "$DATA_UNPACK/usr/share/doc/luckybackup/manual/index.html"
test ! -d "$BIN_UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/help"
test ! -L "$BIN_UNPACK/usr/share/doc/luckybackup/changelog.Debian.gz"
test ! -L "$DATA_UNPACK/usr/share/doc/luckybackup-data/changelog.Debian.gz"
grep -qx '/usr/share/luckybackup/translations/' < <(strings -n 8 "$BIN_UNPACK/usr/bin/luckybackup")
grep -qx '/usr/share/doc/luckybackup/manual/index.html' < <(strings -n 8 "$BIN_UNPACK/usr/bin/luckybackup")
python3 -c 's="0.5.0-3build1kemi1"; assert len(s)==18, len(s); print("version_name_len", len(s))'

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/luckybackup" \
  "$STAGE/pkg/usr/share/doc/luckybackup-data" \
  "$STAGE/pkg/usr/share/man/man8" \
  "$STAGE/pkg/opt/luckybackup"

# official trees: data first, then binary
cp -a "$DATA_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
cp -a "$BIN_UNPACK/usr/bin/luckybackup" "$STAGE/pkg/usr/bin/luckybackup"
chmod 0755 "$STAGE/pkg/usr/bin/luckybackup"
cp -a "$BIN_UNPACK/usr/bin/luckybackup-pkexec" "$STAGE/pkg/usr/bin/luckybackup-pkexec"
chmod 0755 "$STAGE/pkg/usr/bin/luckybackup-pkexec"
cp -a "$BIN_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

REPORT="$ROOT/probe/kemi-luckybackup.json"
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
if Path(f["path"]).name != "luckybackup":
    raise SystemExit(f"PROBE_NAME:{f['path']}")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") != "3.4.21":
    raise SystemExit(f"PROBE_GLIBCXX:{f.get('requiredGlibcxx')}")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or nulls or len(cxx) != 1 or cxx_null:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
needed = set(f.get("neededLibraries") or [])
for lib in ("libQt5Widgets.so.5", "libQt5Core.so.5", "libstdc++.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
r["elfCount"] = 1
r["glibcVersioned"] = 1
r["glibcNull"] = 0
r["glibcxxVersioned"] = 1
r["glibcxxNull"] = 0
r["maxVersionedGlibc"] = "2.17"
r["maxVersionedGlibcxx"] = "3.4.21"
Path("$REPORT").write_text(json.dumps(r, ensure_ascii=False, indent=2) + "\n")
print("PROBE_PASS n_elf=1 arch=aarch64 glibc_versioned=1 glibc_null=0 max_glibc=2.17 glibcxx_versioned=1 glibcxx_null=0 max_glibcxx=3.4.21")
PY

test "$(find "$STAGE/pkg" -name '*.qm' | wc -l)" = 26
test -f "$STAGE/pkg/usr/share/luckybackup/translations/luckybackup_zh_TW.qm"
test ! -f "$STAGE/pkg/usr/share/luckybackup/translations/luckybackup_zh_CN.qm"
test -f "$STAGE/pkg/usr/share/doc/luckybackup/manual/index.html"
test -f "$STAGE/pkg/usr/share/pixmaps/luckybackup.png"
test ! -d "$STAGE/pkg/usr/share/help"
# official pkexec wrapper kept
grep -F 'pkexec "/usr/bin/luckybackup"' "$STAGE/pkg/usr/bin/luckybackup-pkexec"

cp --remove-destination -L \
  "$BIN_UNPACK/usr/share/doc/luckybackup/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$BIN_UNPACK/usr/share/doc/luckybackup/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

def keep_absolute(src: Path, dst: Path, name_line: str, exec_abs: str):
    text = src.read_text(encoding="utf-8")
    if f"Exec={exec_abs}" not in text and not re.search(rf"^Exec={re.escape(exec_abs)}(\s|$)", text, flags=re.M):
        # already must be absolute official
        if not re.search(rf"^Exec={re.escape(exec_abs)}$", text, flags=re.M):
            raise SystemExit(f"EXEC_NOT_ABSOLUTE:{src.name}:{exec_abs}")
    text2 = text
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(rf"^(Exec={re.escape(exec_abs)}(?:\s.*)?)$",
                       rf"\1\nTryExec={exec_abs}", text2, count=1, flags=re.M)
    if "Icon=/usr/share/pixmaps/luckybackup.png" not in text2:
        raise SystemExit(f"MISSING_ICON:{src.name}")
    if name_line not in text2:
        raise SystemExit(f"MISSING_NAME:{src.name}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_kept_absolute", src.name)

keep_absolute(
    Path("$BIN_UNPACK/usr/share/applications/luckybackup.desktop"),
    Path("$STAGE/pkg/usr/share/applications/luckybackup.desktop"),
    "Name=luckyBackup",
    "/usr/bin/luckybackup",
)
keep_absolute(
    Path("$BIN_UNPACK/usr/share/applications/luckybackup-su.desktop"),
    Path("$STAGE/pkg/usr/share/applications/luckybackup-su.desktop"),
    "Name=luckyBackup (super user)",
    "/usr/bin/luckybackup-pkexec",
)

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".so", ".png", ".svg", ".mo", ".qm", ".gz", ".ts", ".xpm", ".html"}:
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

ln -sf /usr/bin/luckybackup "$STAGE/pkg/opt/luckybackup/luckybackup"
ln -sf /usr/bin/luckybackup-pkexec "$STAGE/pkg/opt/luckybackup/luckybackup-pkexec"
ln -sf luckybackup "$STAGE/pkg/usr/bin/kemi-luckybackup"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://luckybackup.sourceforge.net/
Source: https://launchpad.net/ubuntu/+source/luckybackup
Homepage: http://luckybackup.sourceforge.net/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(luckybackup_0.5.0-3build1_arm64.deb) plus bundled same-source
exact-version luckybackup-data_0.5.0-3build1_all.deb,
repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 luckybackup_0.5.0-3build1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    exact-version hard-Depends luckybackup-data
    (= 0.5.0-3build1).
  * Official binary has no Recommends/Suggests. Versioned
    Provides: luckybackup (= 0.5.0-3build1) and
    luckybackup-data (= 0.5.0-3build1).
  * Official ELF stays at /usr/bin/luckybackup (compiled
    /usr/share/luckybackup/translations/ and official
    manual). Official pkexec wrapper stays at
    /usr/bin/luckybackup-pkexec. /opt/luckybackup/* are
    symlinks.
  * Desktop, man, official 26 Qt .qm (including zh_TW; no
    official zh_CN), official pixmap icons and official HTML
    manual stay on standard paths. Official desktop Exec
    lines already absolute and kept. Official icons already
    include a pixmap PNG; no extra raster is invented in the
    package.
  * Official changelogs are real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 23:21:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
luckyBackup ${VER_UP} — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source exact-version luckybackup-data.

Official ELF stays at /usr/bin/luckybackup (compiled
/usr/share/luckybackup/translations/). /opt/luckybackup/*
are symlinks. Desktop, man, official 26 Qt .qm
(including zh_TW), official pixmap icons and official
HTML manual remain on standard paths.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 (1
versioned, 0 null) · requiredGlibcxx 3.4.21 (1
versioned, 0 null); Ubuntu 20.04 / glibc 2.31 /
GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal universe
arm64 luckybackup 0.5.0-3build1 plus luckybackup-data.
Official SHA256 + size matched ports.ubuntu.com pool
files and focal universe arm64 Packages stanzas. No
librarian URL this run.
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
Depends: libc6 (>= 2.17), libgcc-s1 (>= 3.0), libqt5core5a (>= 5.5.0), libqt5gui5 (>= 5.0.2) | libqt5gui5-gles (>= 5.0.2), libqt5widgets5 (>= 5.0.2), libstdc++6 (>= 5.2), rsync
Replaces: luckybackup, luckybackup-data
Conflicts: luckybackup, luckybackup-data
Provides: luckybackup (= 0.5.0-3build1), luckybackup-data (= 0.5.0-3build1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://luckybackup.sourceforge.net/
Description: rsync-based GUI data backup utility (arm64)
 luckyBackup ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled luckybackup-data.
 Backup and synchronize directories with rsync (Qt5).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
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
sha256sum "$DEB" | tee "$OUT/${PKG}_${VER_DEB}_${ARCH}.deb.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-luckybackup-control.txt"
python3 -c 's="0.5.0-3build1kemi1"; print("BUILT_VERSION_NAME_LEN", len(s))'
