#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) workrave
# 1.10.37-1 arm64 as kemi-workrave, bundling same-source exact
# version hard-Depends workrave-data_1.10.37-1_all.deb
# (Depends: workrave-data (= 1.10.37-1)). Official control has
# no Recommends. Official Suggests gnome-panel and gnome-shell
# stay Suggests and are not bundled (the official gnome-panel
# applet, gnome-shell extension and related data files already
# ship in workrave-data and are kept). System library and
# xfce4-panel Depends stay Depends. workrave-data's
# dconf-gsettings-backend | gsettings-backend is kept as a
# system Depends. Versioned Provides: workrave (= 1.10.37-1)
# and workrave-data (= 1.10.37-1).
# Official binaries stay at /usr/bin/workrave plus official
# private libs and panel/indicator plugins under
# /usr/lib/aarch64-linux-gnu and /usr/lib/indicators3.
# The ELF embeds /usr/share/workrave, /usr/share/locale and
# /usr/share/sounds/workrave, so official files stay on
# official paths; /opt/workrave/* are symlinks (same
# compiled-/usr layout as keepassxc/homebank/dia).
# Official workrave-data ships 37 .mo including zh_CN, hicolor
# icons (16–128 + official svg), sounds, exercises, images,
# gsettings schemas, typelib/gir, AppStream metadata, and
# official cinnamon/gnome-shell/xfce/mate/gnome-panel applet
# files. Keep the official tree; do not invent language-packs,
# help trees, /usr/share/workrave/etc, or extra SVG.
# Official workrave-data (Architecture: all) hardcodes
# /usr/lib/x86_64-linux-gnu for XFCE/GNOME/MATE panel applet
# Exec/Location; those four files are rewritten to
# /usr/lib/aarch64-linux-gnu to match the official arm64
# plugin paths. Official org.workrave.Workrave.service already
# uses /usr/bin/workrave and is kept. Official desktop
# Exec=workrave is rewritten to /usr/bin/workrave.
# Official binary changelog is a real file. No official
# maintainer scripts. Official shlibs are retargeted to
# kemi-workrave; official ldconfig trigger is kept.
# Probe: aarch64 · 7 ELF · all requiredGlibc 2.17 (7
# versioned, 0 null) · only /usr/bin/workrave has
# requiredGlibcxx 3.4.21 (1 versioned, 6 null) · PASS vs 101
# ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
# No newer package in focal-updates. No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 1.10.37-1kemi1 is 14 chars (under the mall
# version_name limit that rejected Remmina's 33-char string;
# keepassxc 2.4.3+dfsg.1-1build1kemi1 was 25 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-workrave
VER_UP=1.10.37-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-workrave
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/workrave-1.10.37-focal-unpack}"
DATA_UNPACK="${DATA_UNPACK:-$ROOT/probe/workrave-data-1.10.37-focal-unpack}"
UP_DEB="$DL/workrave_1.10.37-1_arm64.deb"
DATA_DEB="$DL/workrave-data_1.10.37-1_all.deb"
EXPECT_SHA=0b33b5dc848f8bd1eb4b7657f77c40424da377715a11f1f0af88a9348361b7a3
EXPECT_BYTES=466188
EXPECT_DATA_SHA=e99f3ee6ec3a0b5a961f9efde486d87575b8e72e41f8f8ce72a369fe4a321f89
EXPECT_DATA_BYTES=4021484
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -f "$DATA_DEB"
test "$(stat -c%s "$DATA_DEB")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_DATA_SHA  $DATA_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/workrave"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libworkrave-private-1.0.so.0.0.0"
test -f "$UNPACK/usr/share/applications/workrave.desktop"
test -f "$DATA_UNPACK/usr/share/icons/hicolor/128x128/apps/workrave.png"
test -f "$DATA_UNPACK/usr/share/icons/hicolor/scalable/apps/workrave.svg"
test -f "$DATA_UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/workrave.mo"
test "$(find "$DATA_UNPACK" -name '*.mo' | wc -l)" = 37
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/help"
test ! -d "$DATA_UNPACK/usr/share/workrave/etc"
test ! -L "$UNPACK/usr/share/doc/workrave/changelog.Debian.gz"
test ! -L "$DATA_UNPACK/usr/share/doc/workrave-data/changelog.Debian.gz"
grep -qx '/usr/share/workrave' < <(strings -n 8 "$UNPACK/usr/bin/workrave")
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/workrave")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu" \
  "$STAGE/pkg/usr/lib/girepository-1.0" \
  "$STAGE/pkg/usr/lib/indicators3/7" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/workrave" \
  "$STAGE/pkg/usr/share/doc/workrave-data" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/opt/workrave"

# official binary tree (elfs, typelib, indicator, private libs, applets)
cp -a "$UNPACK/usr/bin/workrave" "$STAGE/pkg/usr/bin/workrave"
chmod 0755 "$STAGE/pkg/usr/bin/workrave"
cp -a "$UNPACK/usr/lib/aarch64-linux-gnu/." "$STAGE/pkg/usr/lib/aarch64-linux-gnu/"
cp -a "$UNPACK/usr/lib/girepository-1.0/." "$STAGE/pkg/usr/lib/girepository-1.0/"
cp -a "$UNPACK/usr/lib/indicators3/." "$STAGE/pkg/usr/lib/indicators3/"

REPORT="$ROOT/probe/kemi-workrave.json"
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
test "${#ELFS[@]}" = 7
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
if len(files) != 7:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by = {Path(f["path"]).name: f for f in files}
need_glibc = {
    "workrave": "2.17",
    "libworkrave-gtk2-private-1.0.so.0.0.0": "2.17",
    "libworkrave-private-1.0.so.0.0.0": "2.17",
    "workrave-applet": "2.17",
    "libworkrave-applet.so": "2.17",
    "xfce4-workrave-plugin": "2.17",
    "libworkrave.so": "2.17",
}
if set(by) != set(need_glibc):
    raise SystemExit(f"PROBE_NAMES:{sorted(by)}")
versioned = [f for f in files if f.get("requiredGlibc") is not None]
nulls = [f for f in files if f.get("requiredGlibc") is None]
cxx = [f for f in files if f.get("requiredGlibcxx") is not None]
cxx_null = [f for f in files if f.get("requiredGlibcxx") is None]
if len(versioned) != 7 or nulls or len(cxx) != 1 or len(cxx_null) != 6:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
for name, glibc in need_glibc.items():
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH:{name}")
    if f.get("requiredGlibc") != glibc:
        raise SystemExit(f"PROBE_GLIBC:{name}:{f.get('requiredGlibc')}")
if by["workrave"].get("requiredGlibcxx") != "3.4.21":
    raise SystemExit(f"PROBE_GLIBCXX_MAIN:{by['workrave'].get('requiredGlibcxx')}")
for name, f in by.items():
    if name != "workrave" and f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{name}")
needed = set(by["workrave"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgtkmm-3.0.so.1", "libstdc++.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=7 arch=aarch64 glibc_versioned=7 glibc_null=0 max_glibc=2.17 glibcxx_versioned=1 glibcxx_null=6 max_glibcxx=3.4.21")
PY

# official data + remaining share from binary (desktop/man/doc handled below)
cp -a "$DATA_UNPACK/usr/share/." "$STAGE/pkg/usr/share/"
cp -a "$UNPACK/usr/share/doc/workrave/." "$STAGE/pkg/usr/share/doc/workrave/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/workrave.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/workrave.1.gz"

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 37
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/workrave.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/workrave.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/workrave.svg"
test -f "$STAGE/pkg/usr/share/workrave/images/workrave.png"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.workrave.gschema.xml"
test ! -d "$STAGE/pkg/usr/share/help"
test ! -d "$STAGE/pkg/usr/share/workrave/etc"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/workrave/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/workrave/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/workrave.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/workrave.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=workrave(\s.*)?$", r"Exec=/usr/bin/workrave\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=workrave$", "TryExec=/usr/bin/workrave", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/workrave(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/workrave", text2, count=1, flags=re.M)
if re.search(r"^Exec=workrave(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/workrave", "TryExec=/usr/bin/workrave"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=workrave$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Workrave" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten")

# official arch:all data hardcodes x86_64 libdir; retarget to official arm64 plugin paths
rewrites = {
    Path("$STAGE/pkg/usr/share/xfce4/panel-plugins/workrave-xfce-applet.desktop"):
        ("/usr/lib/x86_64-linux-gnu/xfce4/panel-plugins/xfce4-workrave-plugin",
         "/usr/lib/aarch64-linux-gnu/xfce4/panel-plugins/xfce4-workrave-plugin"),
    Path("$STAGE/pkg/usr/share/gnome-panel/applets/org.workrave.WorkraveApplet.panel-applet"):
        ("/usr/lib/x86_64-linux-gnu/workrave/libworkrave-applet.so",
         "/usr/lib/aarch64-linux-gnu/workrave/libworkrave-applet.so"),
    Path("$STAGE/pkg/usr/share/mate-panel/applets/org.workrave.WorkraveApplet.mate-panel-applet"):
        ("/usr/lib/x86_64-linux-gnu/mate-applets/workrave-applet",
         "/usr/lib/aarch64-linux-gnu/mate-applets/workrave-applet"),
    Path("$STAGE/pkg/usr/share/dbus-1/services/org.mate.panel.applet.WorkraveAppletFactory.service"):
        ("/usr/lib/x86_64-linux-gnu/mate-applets/workrave-applet",
         "/usr/lib/aarch64-linux-gnu/mate-applets/workrave-applet"),
}
for path, (old, new) in rewrites.items():
    t = path.read_text(encoding="utf-8")
    if old not in t:
        raise SystemExit(f"MISSING_X86_PATH:{path}")
    t2 = t.replace(old, new)
    if "x86_64-linux-gnu" in t2:
        raise SystemExit(f"LEFTOVER_X86:{path}")
    if new not in t2:
        raise SystemExit(f"REWRITE_FAIL:{path}")
    path.write_text(t2, encoding="utf-8")
    print("retargeted", path.name)

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.workrave.Workrave.service")
st = svc.read_text(encoding="utf-8")
if "Exec=/usr/bin/workrave" not in st:
    raise SystemExit("DBUS_MAIN_EXEC")
print("dbus_main_ok")
# leftover wrong-arch paths must be gone from the staged tree
leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".so", ".png", ".svg", ".mo", ".gz", ".wav", ".ogg", ".typelib", ".xpm"}:
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

ln -sf /usr/bin/workrave "$STAGE/pkg/opt/workrave/workrave"
ln -sf workrave "$STAGE/pkg/usr/bin/kemi-workrave"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.workrave.org/
Source: https://launchpad.net/ubuntu/+source/workrave
Homepage: http://www.workrave.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(workrave_1.10.37-1_arm64.deb) plus bundled same-source
exact-version workrave-data_1.10.37-1_all.deb, repackaged
for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 workrave_1.10.37-1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}, bundling same-source
    exact-version hard-Depends workrave-data_1.10.37-1_all.deb
    (Depends: workrave-data (= 1.10.37-1)).
  * Official Suggests gnome-panel and gnome-shell stay
    Suggests. Versioned Provides: workrave (= 1.10.37-1)
    and workrave-data (= 1.10.37-1).
  * Official ELF stays at /usr/bin/workrave (compiled
    /usr/share/workrave). Official private libs and panel
    plugins stay on official /usr/lib paths. /opt/workrave/*
    are symlinks.
  * Desktop, man, official 37 .mo (including zh_CN), hicolor
    icons including official svg, sounds, exercises and
    official applet/extension data stay on standard paths.
    Official desktop Exec=workrave rewritten to
    /usr/bin/workrave. Official arch:all x86_64 libdir in
    XFCE/GNOME/MATE applet Exec/Location rewritten to
    aarch64-linux-gnu.
  * Official changelogs are real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:47:42 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Workrave ${VER_UP} — official Ubuntu 20.04
(focal) universe arm64, KEMI repack, with bundled
same-source exact-version workrave-data.

Official ELF stays at /usr/bin/workrave (compiled
/usr/share/workrave). /opt/workrave/* are symlinks.
Desktop, man, official 37 .mo (including zh_CN),
icons, sounds and official applet data remain on
standard paths. Official Suggests gnome-panel and
gnome-shell stay Suggests.
Probe: aarch64 · 7 ELF · requiredGlibc 2.17 (7
versioned, 0 null) · requiredGlibcxx 3.4.21 on
/usr/bin/workrave only (1 versioned, 6 null);
Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal universe
arm64 workrave 1.10.37-1 plus workrave-data.
Official SHA256 + size matched ports.ubuntu.com
pool files and focal universe arm64 Packages
stanzas. No librarian URL this run.
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
Depends: libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.17), libcairo2 (>= 1.10.0), libcairomm-1.0-1v5 (>= 1.12.0), libdbusmenu-glib4 (>= 0.4.2), libdbusmenu-gtk3-4 (>= 0.4.2), libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libgdome2-0, libglib2.0-0 (>= 2.39.4), libglibmm-2.4-1v5 (>= 2.54.0), libgstreamer1.0-0 (>= 1.0.0), libgtk-3-0 (>= 3.21.4), libgtk2.0-0 (>= 2.24.0), libgtkmm-3.0-1v5 (>= 3.24.0), libindicator3-7 (>= 0.4.90), libmate-panel-applet-4-1 (>= 1.6.1), libpanel-applet3 (>= 3.2.1), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libpangomm-1.4-1v5 (>= 2.42.0), libsigc++-2.0-0v5 (>= 2.8.0), libstdc++6 (>= 5.2), libx11-6, libxss1, libxtst6, xfce4-panel (>= 4.13), xfce4-panel (<< 4.15), dconf-gsettings-backend | gsettings-backend
Suggests: gnome-panel, gnome-shell
Replaces: workrave, workrave-data
Conflicts: workrave, workrave-data
Provides: workrave (= 1.10.37-1), workrave-data (= 1.10.37-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.workrave.org/
Description: Repetitive Strain Injury prevention tool (arm64)
 Workrave ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack, with bundled workrave-data.
 RSI prevention breaks and daily limits (GTK3).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official shlibs retargeted to kemi-workrave
cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libworkrave-gtk2-private-1.0 0 kemi-workrave (>= 1.10.37-1kemi1)
libworkrave-private-1.0 0 kemi-workrave (>= 1.10.37-1kemi1)
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-workrave-control.txt"
