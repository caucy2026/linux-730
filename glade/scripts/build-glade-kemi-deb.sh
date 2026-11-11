#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) glade
# 3.22.2-1 Architecture: arm64 as kemi-glade.
# No newer package in focal-updates. The glade source also
# ships same-source libgladeui-2-6, libgladeui-common,
# gir1.2-gladeui-2.0, libgladeui-dev and libgladeui-doc
# in focal. Official glade Depends libgladeui-2-6
# (>= 3.22.0) is same-source but not an exact-version
# hard-Depends, so the library stays Depends and is not
# bundled. Official glade does not hard-Depends on
# libgladeui-common (the library does: libgladeui-common
# (>= 3.22.2-1), the only focal version); apt will pull
# both with libgladeui-2-6. gir1.2-gladeui-2.0,
# libgladeui-dev and libgladeui-doc are not GUI
# hard-Depends and are not bundled. Official Recommends
# (libgtk-3-dev, devhelp) are different-source packages
# and stay Recommends / unbundled (not the Remmina/AbiWord
# Recommends-plugin pattern). Official control has no
# Suggests. Versioned Provides: glade (= 3.22.2-1). No
# Debian epoch. Official /usr/bin/glade and
# /usr/bin/glade-previewer are compiled aarch64 ELFs
# (NEEDED libgladeui-2.so.6). Official files stay on
# official paths; /opt/glade/* are symlinks. Also
# /usr/bin/kemi-glade → glade. Official GUI package ships
# no .mo (language-pack split; keep official, do not
# invent packs). Official Yelp help has a real C tree plus
# official help-langpack symlinks for translated locales
# including zh_CN (dangling without language packs; kept,
# not invented). Official help figure PNGs stay in the
# official help tree and are not the mall icon. Official
# app icons include hicolor 16–256 PNG plus symbolic SVGs;
# official in-app pixmaps live in unbundled
# libgladeui-common and are not packed here. Do not invent
# a PNG inside the package. The official 256×256 glade.png
# is used as the mall CREATE --icon (Zim / gitg / gnote
# pattern) and is not packed a second time. Official
# changelog.Debian.gz in the GUI package is a dangling
# symlink to ../libgladeui-2-6/changelog.Debian.gz; the
# real official changelog is copied from the same-source
# libgladeui-2-6 package with cp -L into the kemi doc dir
# only; the dangling symlink is not packed. Official
# package has no maintainer scripts, no shlibs and no
# ldconfig trigger (those live on the unbundled library);
# hicolor icon-cache and desktop-database hooks are added.
# Official desktop Exec=glade %F is rewritten to
# /usr/bin/glade %F; TryExec is added; Icon=glade is kept;
# Name=Glade is kept. Official man, appdata, AUTHORS, NEWS,
# README stay in the official tree. Probe: Architecture
# arm64 · 2 unique packaged ELF · requiredGlibc 2.17
# (2 versioned, 0 null) · no GLIBCXX (0 versioned, 2 null;
# null is not ranked as a max) · GTK3 UI designer · within
# 101 ≤2.31 / ≤3.4.28. Official SHA256 + size matched
# official ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal universe arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL and no
# .buildinfo is recorded this run (pool 404). KEMI version
# 3.22.2-1kemi1 is 13 chars (under the mall version_name
# limit that rejected Remmina's 33-char string;
# gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars;
# gnome-calculator 3.36.0-1ubuntu1kemi1 was 20 chars;
# devhelp 3.36.2-0ubuntu1kemi1 was 20 chars; gnote
# 3.36.0-1kemi1 was 13 chars). No epoch, no tilde, no
# shortening needed. gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-glade
VER_UP=3.22.2-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-glade
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
LIBUNPACK="${LIBUNPACK:-$ROOT/unpack-lib}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/glade_3.22.2-1_arm64.deb"
EXPECT_SHA=498b364e869641fbc0ab72011bc90d7d2fd1e17e4be037fd7354e523d918e230
EXPECT_BYTES=188316
python3 - << PY
s="${VER_DEB}"
assert len(s) == 13, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/glade"
test -x "$UNPACK/usr/bin/glade-previewer"
python3 - << PY
from pathlib import Path
for name in ("glade", "glade-previewer"):
    p = Path("$UNPACK/usr/bin") / name
    assert not p.is_symlink(), name
    assert p.read_bytes()[:4] == bytes([0x7F]) + b"ELF", name
icon = Path("$UNPACK/usr/share/icons/hicolor/256x256/apps/glade.png")
assert icon.is_file() and not icon.is_symlink()
assert icon.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"
print("official_elfs_ok official_256_png_ok")
PY
test -f "$UNPACK/usr/share/applications/glade.desktop"
test -L "$UNPACK/usr/share/doc/glade/changelog.Debian.gz"
# dangling official changelog — real file is in same-source lib package
test -f "$LIBUNPACK/usr/share/doc/libgladeui-2-6/changelog.Debian.gz"
test ! -L "$LIBUNPACK/usr/share/doc/libgladeui-2-6/changelog.Debian.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -d "$UNPACK/usr/share/help/C/glade"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/glade.png"
# convenience copy of official 256 for CREATE --icon only; must not be packed a second time
cp -a "$UNPACK/usr/share/icons/hicolor/256x256/apps/glade.png" "$ROOT/evidence/glade-256.png"
python3 - << PY
from pathlib import Path
from struct import unpack
p = Path("$ROOT/evidence/glade-256.png")
d = p.read_bytes()
w, h = unpack(">II", d[16:24])
assert (w, h) == (256, 256)
off = Path("$UNPACK/usr/share/icons/hicolor/256x256/apps/glade.png").read_bytes()
assert d == off
print("evidence_256_is_official_copy", p.stat().st_size)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/glade"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/glade" "$STAGE/pkg/usr/bin/glade-previewer"
# drop dangling official changelog symlink from the official doc tree
rm -f "$STAGE/pkg/usr/share/doc/glade/changelog.Debian.gz"
# official help-langpack dangling symlinks are kept (language-pack split)

REPORT="$ROOT/probe/kemi-glade.json"
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
test "${#ELFS[@]}" = 2
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
if len(files) != 2:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
names = sorted(Path(f["path"]).name for f in files)
if names != ["glade", "glade-previewer"]:
    raise SystemExit("PROBE_NAMES:" + ",".join(names))
for f in files:
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + str(f.get("requiredGlibcxx")))
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 2 or len(nulls) != 0 or cxx or len(cxx_null) != 2:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
print("PROBE_PASS n_elf=2 unique aarch64 glibc=2.17 (2 versioned, 0 null) noGLIBCXX (0 versioned, 2 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
# official app PNGs must remain exactly once under official hicolor paths
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/glade.png"
# evidence copy / invented extra 256 must not be staged outside official tree
if find "$STAGE/pkg" -name 'glade-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
if [ -L "$STAGE/pkg/usr/share/doc/glade/changelog.Debian.gz" ] || [ -e "$STAGE/pkg/usr/share/doc/glade/changelog.Debian.gz" ]; then
  echo "DANGLING_CHANGELOG_STAGED" >&2
  exit 1
fi
# official C help kept; official help-langpack dangling kept
test -f "$STAGE/pkg/usr/share/help/C/glade/index.docbook"
test -L "$STAGE/pkg/usr/share/help/zh_CN/glade/index.docbook"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/glade/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$LIBUNPACK/usr/share/doc/libgladeui-2-6/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/glade.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/glade.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=glade(\s.*)?$", r"Exec=/usr/bin/glade\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/glade", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/glade.*$", lambda m: m.group(0) + "\nTryExec=/usr/bin/glade", text2, count=1, flags=re.M)
if re.search(r"^Exec=glade(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/glade %F",
               "TryExec=/usr/bin/glade",
               "Icon=glade",
               "Name=Glade"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".page"}:
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

ln -sf /usr/bin/glade "$STAGE/pkg/opt/glade/glade"
ln -sf /usr/bin/glade-previewer "$STAGE/pkg/opt/glade/glade-previewer"
ln -sf glade "$STAGE/pkg/usr/bin/kemi-glade"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://glade.gnome.org/
Source: https://launchpad.net/ubuntu/+source/glade
Homepage: https://glade.gnome.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: arm64 deb v${VER_UP}
(glade_3.22.2-1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 glade_3.22.2-1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official Depends
    libgladeui-2-6 (>= 3.22.0) is same-source but not
    exact-version, so the library and official
    libgladeui-common stay Depends (pulled by apt) and
    are not bundled. Official Recommends (libgtk-3-dev,
    devhelp) stay Recommends. Official control has no
    Suggests. Versioned Provides: glade (= 3.22.2-1).
  * Official /usr/bin/glade and /usr/bin/glade-previewer
    are compiled aarch64 ELFs (NEEDED libgladeui-2.so.6).
    /opt/glade/* are symlinks. Also /usr/bin/kemi-glade.
  * Official GUI package ships no .mo. Official Yelp help
    has a real C tree plus official help-langpack
    symlinks (including zh_CN); keep official, do not
    invent language packs. Official help figure PNGs stay
    in the official help tree. Official hicolor 16–256
    app PNGs are kept; the official 256×256 glade.png is
    used as the mall CREATE --icon and is not packed a
    second time.
  * Official changelog in the GUI package is a dangling
    symlink; the real official changelog was copied from
    same-source libgladeui-2-6. Official desktop
    Exec=glade %F rewritten to /usr/bin/glade %F;
    TryExec added; Icon=glade.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Glade ${VER_UP} — official Ubuntu 20.04 (focal)
universe Architecture: arm64, KEMI repack.

Official /usr/bin/glade and /usr/bin/glade-previewer
are compiled aarch64 ELFs (glibc 2.17, no GLIBCXX).
/opt/glade/* are symlinks. Official same-source
libgladeui-2-6 (>= 3.22.0) and libgladeui-common stay
Depends and are not bundled. Official Recommends
(libgtk-3-dev, devhelp) stay Recommends. Official GUI
package ships no .mo. Official help C tree is kept;
official help-langpack symlinks are kept and not
invented. Probe: 2 unique ELF · requiredGlibc 2.17
(2 versioned, 0 null) · no requiredGlibcxx (0
versioned, 2 null; null not ranked as a max); GTK3 UI
designer; within Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal universe glade
3.22.2-1 (Architecture: arm64). Official SHA256 +
size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanza. No librarian URL this
run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libgladeui-2-6 (>= 3.22.0), libglib2.0-0 (>= 2.53.2), libgtk-3-0 (>= 3.21.5), libpango-1.0-0 (>= 1.18.0)
Recommends: libgtk-3-dev, devhelp
Replaces: glade
Conflicts: glade
Provides: glade (= 3.22.2-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://glade.gnome.org/
Description: GTK+ User Interface Builder
 Glade ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 GTK3 UI designer (RAD / XML).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-glade-control.txt"
grep -q 'Version: 3.22.2-1kemi1' "$ROOT/evidence/kemi-glade-control.txt"
grep -q 'Recommends: libgtk-3-dev, devhelp' "$ROOT/evidence/kemi-glade-control.txt"
grep -q 'libgladeui-2-6 (>= 3.22.0)' "$ROOT/evidence/kemi-glade-control.txt"
grep -q 'Provides: glade (= 3.22.2-1)' "$ROOT/evidence/kemi-glade-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/glade",
    "./usr/bin/glade-previewer",
    "./usr/bin/kemi-glade",
    "./opt/glade/glade",
    "./opt/glade/glade-previewer",
    "./usr/share/applications/glade.desktop",
    "./usr/share/icons/hicolor/256x256/apps/glade.png",
    "./usr/share/help/C/glade/index.docbook",
    "./usr/share/help/C/glade/figures/main-window.png",
    "./usr/share/man/man1/glade.1.gz",
    "./usr/share/man/man1/glade-previewer.1.gz",
    "./usr/share/metainfo/glade.appdata.xml",
    "./usr/share/doc/kemi-glade/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "glade-256.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
# official dangling changelog name must not appear
for line in out.splitlines():
    if "changelog.Debian.gz" in line:
        raise SystemExit("DANGLING_CHANGELOG_IN_DEB:" + line)
# official ELFs must be real files, not symlinks
for line in out.splitlines():
    if "./usr/bin/glade " in line or line.rstrip().endswith("./usr/bin/glade"):
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/glade-previewer" in line and "->" in line:
        raise SystemExit("PREVIEWER_UNEXPECTED_SYMLINK:" + line)
# kemi wrapper and opt entries must be symlinks
found_kemi = False
for line in out.splitlines():
    if "./usr/bin/kemi-glade" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
