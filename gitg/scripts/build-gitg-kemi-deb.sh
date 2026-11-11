#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) gitg
# 3.32.1-1 Architecture: arm64 as kemi-gitg.
# No newer package in focal-updates. The gitg source ships
# only this one binary package in focal (no same-source
# -data/-common to bundle). Official control has no
# Recommends and no Suggests. System typelib / git / GTK3
# / libgit2-glib Depends stay Depends and are not bundled
# (different-source, not exact-version data). Versioned
# Provides: gitg (= 3.32.1-1).
# Official /usr/bin/gitg is a compiled aarch64 ELF with
# RUNPATH /usr/lib/gitg. Private libs and plugins stay
# under /usr/lib/gitg (official soname symlinks kept).
# Official files stay on official paths; /opt/gitg/* are
# symlinks. Official package ships no .mo (Ubuntu
# language-pack split; desktop X-Ubuntu-Gettext-Domain=gitg).
# Keep the official tree; do not invent or bundle language
# packs. Official package has no /usr/share/help tree; do
# not invent one. Official app icons include hicolor
# 16–256 PNG plus a symbolic SVG; official in-app
# diff-symbolic.svg is kept. Do not invent a PNG inside
# the package. The official 256x256 PNG may be used as the
# mall CREATE --icon (Zim pattern) and is not packed a
# second time. Official changelog is a real file. Official
# package has a shlibs file (libgitg-1.0 / libgitg-ext-1.0)
# and no maintainer scripts; shlibs are retargeted to
# kemi-gitg (font-manager pattern); hicolor +
# desktop-database hooks are added. Official desktop
# Exec=gitg --no-wd %U and TryExec=gitg are rewritten to
# /usr/bin/gitg; Icon=org.gnome.gitg is kept.
# Probe: Architecture arm64 · 5 unique packaged ELF ·
# requiredGlibc 2.17 (4 versioned, 1 null — official
# libdiff.so has no libc version-need; null is not ranked
# as a max) · no GLIBCXX (0 versioned, 5 null) · GTK3 git
# repository viewer · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed).
# No librarian URL and no .buildinfo is recorded this run
# (pool 404).
# KEMI version 3.32.1-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-logs 3.34.0-1ubuntu1kemi1 was 20 chars).
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gitg
VER_UP=3.32.1-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gitg
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gitg_3.32.1-1_arm64.deb"
EXPECT_SHA=92d866fdc7f379c77e570f8e599825d45d484bf7c9b839e88fec6ba9b604633c
EXPECT_BYTES=430192
python3 - << PY
s="${VER_DEB}"
assert len(s) == 13, len(s)
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gitg"
python3 - << PY
from pathlib import Path
p=Path("$UNPACK/usr/bin/gitg")
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F])+b"ELF"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/lib/gitg/libgitg-1.0.so.0.0.0"
test -L "$UNPACK/usr/lib/gitg/libgitg-1.0.so.0"
test -f "$UNPACK/usr/lib/gitg/gitg/plugins/libdiff.so"
test -f "$UNPACK/usr/share/applications/org.gnome.gitg.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.gitg.png"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/org.gnome.gitg.png"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.gitg-symbolic.svg"
test ! -d "$UNPACK/usr/share/help"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/gitg/changelog.Debian.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gitg.gschema.xml"
test -f "$UNPACK/DEBIAN/shlibs"
test ! -f "$UNPACK/DEBIAN/postinst"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gitg"

cp -a "$UNPACK/usr/bin/gitg" "$STAGE/pkg/usr/bin/gitg"
chmod 0755 "$STAGE/pkg/usr/bin/gitg"
cp -a "$UNPACK/usr/lib" "$STAGE/pkg/usr/lib"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

REPORT="$ROOT/probe/kemi-gitg.json"
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
test "${#ELFS[@]}" = 5
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
if len(files) != 5:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
names = sorted(Path(f["path"]).name for f in files)
expect = ["gitg", "libdiff.so", "libfiles.so", "libgitg-1.0.so.0.0.0", "libgitg-ext-1.0.so.0.0.0"]
if names != expect:
    raise SystemExit(f"PROBE_NAMES:{names}")
for f in files:
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH:"+f["path"])
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{f.get('requiredGlibcxx')}")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 4 or len(nulls) != 1 or cxx or len(cxx_null) != 5:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
if any(x.get("requiredGlibc") != "2.17" for x in versioned):
    raise SystemExit("PROBE_GLIBC:"+str([x.get("requiredGlibc") for x in versioned]))
# the null glibc ELF must be libdiff.so
null_names = {Path(x["path"]).name for x in nulls}
if null_names != {"libdiff.so"}:
    raise SystemExit("PROBE_NULL_ELF:"+str(null_names))
print("PROBE_PASS n_elf=5 unique aarch64 glibc=2.17 (4 versioned, 1 null libdiff.so; null not ranked as a max) noGLIBCXX (0 versioned, 5 null) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.gitg.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/org.gnome.gitg.png"
test -f "$STAGE/pkg/usr/share/gitg/icons/hicolor/scalable/actions/diff-symbolic.svg"
test -f "$STAGE/pkg/usr/lib/gitg/gitg/plugins/diff.plugin"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gitg/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gitg/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.gitg.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.gitg.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gitg(\s.*)?$", r"Exec=/usr/bin/gitg\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=gitg$", "TryExec=/usr/bin/gitg", text2, flags=re.M)
if re.search(r"^Exec=gitg(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gitg --no-wd %U",
               "TryExec=/usr/bin/gitg",
               "Icon=org.gnome.gitg",
               "Name=gitg"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        txt = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in txt:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/gitg "$STAGE/pkg/opt/gitg/gitg"
ln -sf gitg "$STAGE/pkg/usr/bin/kemi-gitg"

# official shlibs retargeted to kemi-gitg (font-manager pattern)
cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libgitg-1.0 0 kemi-gitg (>= 3.32.1)
libgitg-ext-1.0 0 kemi-gitg (>= 3.32.1)
EOT

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Gitg
Source: https://launchpad.net/ubuntu/+source/gitg
Homepage: https://wiki.gnome.org/Apps/Gitg
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: arm64 deb v${VER_UP}
(gitg_3.32.1-1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gitg_3.32.1-1_arm64.deb (focal
    universe; no newer package in focal-updates) repackaged
    for KEMI as ${PKG}. No same-source data package in
    focal. Official control has no Recommends and no
    Suggests. Versioned Provides: gitg (= 3.32.1-1).
  * Official /usr/bin/gitg is a compiled aarch64 ELF with
    RUNPATH /usr/lib/gitg. Private libs and plugins stay
    under /usr/lib/gitg. /opt/gitg/* are symlinks. Also
    /usr/bin/kemi-gitg.
  * Desktop, man, official hicolor PNG+SVG icons, official
    gsettings schema and official plugins stay on standard
    paths. Official package ships no .mo and no
    /usr/share/help (language-pack split). Official desktop
    Exec=gitg --no-wd %U rewritten to /usr/bin/gitg;
    Icon=org.gnome.gitg. Official app icons include PNG;
    no PNG is invented inside the package.
  * Official shlibs retargeted to kemi-gitg. Official
    package has no maintainer scripts. Official changelog
    is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
gitg ${VER_UP} — official Ubuntu 20.04 (focal)
universe Architecture: arm64, KEMI repack.

Official /usr/bin/gitg is a compiled aarch64 ELF
(glibc 2.17, no GLIBCXX) with RUNPATH /usr/lib/gitg.
/opt/gitg/* are symlinks. Desktop, man, official
hicolor PNG+SVG icons, official schema and official
plugins remain on standard paths. Official package
ships no .mo (language-pack split) and no
/usr/share/help. Official control has no Recommends
and no Suggests. Probe: 5 unique ELF · requiredGlibc
2.17 (4 versioned, 1 null; null not ranked as a max)
· no requiredGlibcxx (0 versioned, 5 null); GTK3 git
repository viewer; within Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04 focal universe
gitg 3.32.1-1 (Architecture: arm64). Official SHA256
+ size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanza. No librarian URL
this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: vcs
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: default-dbus-session-bus | dbus-session-bus, gir1.2-peas-1.0, git, gsettings-desktop-schemas, dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.14.0), libdazzle-1.0-0 (>= 3.25.3), libgdk-pixbuf2.0-0 (>= 2.22.0), libgee-0.8-2 (>= 0.10.1), libgirepository-1.0-1 (>= 0.9.2), libgit2-glib-1.0-0 (>= 0.28.0.1), libglib2.0-0 (>= 2.43.1), libgtk-3-0 (>= 3.21.5), libgtksourceview-3.0-1 (>= 3.13.90), libgtkspell3-3-0, libpango-1.0-0 (>= 1.14.0), libpeas-1.0-0 (>= 1.6.2), libsecret-1-0 (>= 0.7), libsoup2.4-1 (>= 2.32.2), libxml2 (>= 2.7.4)
Replaces: gitg
Conflicts: gitg
Provides: gitg (= 3.32.1-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Gitg
Description: git repository viewer
 gitg ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 Fast git repository browser
 (GTK3 GUI).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v update-icon-caches >/dev/null 2>&1; then
		update-icon-caches /usr/share/icons/hicolor || true
	elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q /usr/share/icons/hicolor || true
	fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-icon-caches >/dev/null 2>&1; then
	update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gitg-control.txt"
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | tee "$ROOT/evidence/kemi-gitg-shlibs.txt"
grep -q 'kemi-gitg (>= 3.32.1)' "$ROOT/evidence/kemi-gitg-shlibs.txt"
if dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | grep -q ' gitg ('; then
  echo "LEFTOVER_SHLIBS_UPSTREAM" >&2
  exit 1
fi

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gitg",
    "./usr/bin/kemi-gitg",
    "./opt/gitg/gitg",
    "./usr/lib/gitg/libgitg-1.0.so.0.0.0",
    "./usr/lib/gitg/gitg/plugins/libdiff.so",
    "./usr/share/icons/hicolor/256x256/apps/org.gnome.gitg.png",
    "./usr/share/glib-2.0/schemas/org.gnome.gitg.gschema.xml",
    "./usr/share/man/man1/gitg.1.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
# official binary must remain a regular ELF
binlines=[line for line in out.splitlines() if "./usr/bin/gitg " in line or line.endswith("./usr/bin/gitg") or "./usr/bin/gitg" in line]
# filter kemi symlink
real=[line for line in binlines if "kemi-gitg" not in line and "opt/gitg" not in line]
if not real or any("->" in line and "./usr/bin/gitg" in line and "kemi" not in line and "opt/" not in line for line in real):
    # inspect more carefully
    for line in out.splitlines():
        if "./usr/bin/gitg" in line and "kemi-gitg" not in line:
            if "->" in line:
                raise SystemExit("BIN_UNEXPECTED_SYMLINK:"+line)
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
