#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) gnote
# 3.36.0-1 Architecture: arm64 as kemi-gnote.
# No newer package in focal-updates. The gnote source ships
# only this one binary package in focal (no same-source
# -data/-common to bundle). Official control has no
# Recommends and no Suggests. System GTK3 / gtkmm / gspell /
# libsecret Depends stay Depends and are not bundled.
# Versioned Provides: gnote (= 3.36.0-1). No Debian epoch.
# Official /usr/bin/gnote is a compiled aarch64 ELF that
# embeds /usr/share/locale, /usr/share/icons, and
# /usr/share/gnote/... Official public lib libgnote-3.36
# under /usr/lib/aarch64-linux-gnu embeds the official
# addins path /usr/lib/aarch64-linux-gnu/gnote/addins/3.36.0.
# Official files stay on official paths; /opt/gnote/* are
# symlinks. Also /usr/bin/kemi-gnote → gnote.
# Official package ships 52 .mo including zh_CN / zh_TW /
# zh_HK. Keep the official tree; do not invent extra
# language packs. Official Yelp help has a real C tree plus
# official translated help for cs, da, de, el, es, fr, hu,
# lt, pl, ru, sl, sv, zh_CN (0 dangling help-langpack
# links; some figure PNGs are official symlinks to C).
# Official help PNGs stay in the official help tree and are
# not the mall icon. Official app icons include hicolor
# 16–256 PNG plus an SVG; official in-app PNGs under
# /usr/share/gnote/icons stay in the official tree. Do not
# invent a PNG inside the package. The official 256×256
# gnote.png is used as the mall CREATE --icon (Zim / gitg
# pattern) and is not packed a second time.
# Official changelog is a real file. Official package has a
# shlibs file (libgnote-3.36) and an ldconfig trigger, and
# no maintainer scripts; shlibs are retargeted to kemi-gnote
# (font-manager / gitg / gnome-calculator pattern); the
# official ldconfig trigger is kept; hicolor +
# desktop-database hooks are added. Official desktop
# Exec=gnote %u is rewritten to /usr/bin/gnote %u; TryExec
# is added; Icon=gnote is kept. Official addin .desktop
# files are AddinInfo metadata (no Exec) and are kept.
# Official D-Bus Exec=/usr/bin/gnote --shell-search is
# already absolute and is kept.
# Probe: Architecture arm64 · 23 unique packaged ELF ·
# requiredGlibc 2.29 (23 versioned: 22 at 2.17 and 1 at
# 2.29, 0 null; max 2.29, null is not ranked as a max) ·
# requiredGlibcxx 3.4.21 (23 versioned: 10 at 3.4, 1 at
# 3.4.15, 12 at 3.4.21, 0 null; max 3.4.21, null is not
# ranked as a max) · GTK3 C++ note-taker · within 101
# ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed).
# No librarian URL and no .buildinfo is recorded this run
# (pool 404).
# KEMI version 3.36.0-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-calculator 3.36.0-1ubuntu1kemi1 was 20
# chars). No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnote
VER_UP=3.36.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnote
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnote_3.36.0-1_arm64.deb"
EXPECT_SHA=da91d299e0768955a14972ef5b1a3556fbf7096b9b143bf143b3239d2a03e4c2
EXPECT_BYTES=3138384
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
test -x "$UNPACK/usr/bin/gnote"
python3 - << PY
from pathlib import Path
p=Path("$UNPACK/usr/bin/gnote")
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F])+b"ELF"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libgnote-3.36.so.0.0.0"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/libgnote-3.36.so.0"
test -f "$UNPACK/usr/share/applications/gnote.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/gnote.png"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/gnote.png"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/gnote.mo"
test -d "$UNPACK/usr/share/help/C/gnote"
test -d "$UNPACK/usr/share/help/zh_CN/gnote"
test ! -L "$UNPACK/usr/share/doc/gnote/changelog.Debian.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.gnote.gschema.xml"
test -f "$UNPACK/DEBIAN/shlibs"
test -f "$UNPACK/DEBIAN/triggers"
test ! -f "$UNPACK/DEBIAN/postinst"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 52

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnote"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnote"

REPORT="$ROOT/probe/kemi-gnote.json"
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
test "${#ELFS[@]}" = 23
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
if len(files) != 23:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
for f in files:
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH:"+f["path"])
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 23 or len(nulls) != 0 or len(cxx) != 23 or len(cxx_null) != 0:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
glibcs = [x.get("requiredGlibc") for x in versioned]
# None-safe: only compare versioned values; null is not ranked as a max
if any(g not in {"2.17", "2.29"} for g in glibcs):
    raise SystemExit("PROBE_GLIBC:"+str(glibcs))
if "2.29" not in glibcs or glibcs.count("2.17") != 22:
    raise SystemExit("PROBE_GLIBC_HIST:"+str(glibcs))
cxxs = [x.get("requiredGlibcxx") for x in cxx]
if any(c not in {"3.4", "3.4.15", "3.4.21"} for c in cxxs):
    raise SystemExit("PROBE_GLIBCXX:"+str(cxxs))
if "3.4.21" not in cxxs:
    raise SystemExit("PROBE_GLIBCXX_MISSING_MAX")
# names
names = {Path(f["path"]).name for f in files}
if "gnote" not in names or "libgnote-3.36.so.0.0.0" not in names:
    raise SystemExit("PROBE_CORE_NAMES:"+str(sorted(names)))
print("PROBE_PASS n_elf=23 unique aarch64 glibc=2.29 (23 versioned: 22 at 2.17, 1 at 2.29, 0 null; max 2.29, null not ranked as a max) GLIBCXX=3.4.21 (23 versioned: 10 at 3.4, 1 at 3.4.15, 12 at 3.4.21, 0 null; max 3.4.21, null not ranked as a max) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 52
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/gnote.mo"
test -d "$STAGE/pkg/usr/share/help/C/gnote"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/gnote.png"
test -f "$STAGE/pkg/usr/share/gnote/icons/hicolor/16x16/actions/note-new.png"
# do not invent a second mall PNG
if find "$STAGE/pkg" -name 'gnote-128.png' -o -name 'org.gnome.Gnote-128.png' | grep -q .; then
  echo "INVENTED_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnote/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnote/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/gnote.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/gnote.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnote(\s.*)?$", r"Exec=/usr/bin/gnote\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/gnote", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/gnote.*$", lambda m: m.group(0)+"\nTryExec=/usr/bin/gnote", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnote(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gnote %u",
               "TryExec=/usr/bin/gnote",
               "Icon=gnote",
               "Name=Gnote"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Gnote.service").read_text()
if "Exec=/usr/bin/gnote --shell-search" not in svc:
    raise SystemExit("DBUS_EXEC_CHANGED")
print("dbus_kept")

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

ln -sf /usr/bin/gnote "$STAGE/pkg/opt/gnote/gnote"
ln -sf gnote "$STAGE/pkg/usr/bin/kemi-gnote"

cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libgnote-3.36 0 kemi-gnote (>= 3.36.0)
EOT
cp -a "$UNPACK/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Gnote
Source: https://launchpad.net/ubuntu/+source/gnote
Homepage: https://wiki.gnome.org/Apps/Gnote
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: arm64 deb v${VER_UP}
(gnote_3.36.0-1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnote_3.36.0-1_arm64.deb (focal
    universe; no newer package in focal-updates) repackaged
    for KEMI as ${PKG}. No same-source data package in
    focal. Official control has no Recommends and no
    Suggests. Versioned Provides: gnote (= 3.36.0-1).
  * Official /usr/bin/gnote is a compiled aarch64 ELF that
    embeds /usr/share/locale, /usr/share/icons and
    /usr/share/gnote. Official public lib and addins stay
    under /usr/lib/aarch64-linux-gnu. /opt/gnote/* are
    symlinks. Also /usr/bin/kemi-gnote.
  * Desktop, man, official hicolor PNG+SVG icons, official
    in-app icons, official 52 .mo including zh_CN, official
    help (C + translated trees including zh_CN), official
    gsettings schema, official addins and official D-Bus
    service stay on standard paths. Official desktop
    Exec=gnote %u rewritten to /usr/bin/gnote %u; TryExec
    added; Icon=gnote. Official D-Bus Exec already absolute
    and kept. Official app icons include PNG; no PNG is
    invented inside the package.
  * Official shlibs retargeted to kemi-gnote. Official
    ldconfig trigger kept. Official package has no
    maintainer scripts; icon-cache and desktop-database
    hooks are added. Official changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gnote ${VER_UP} — official Ubuntu 20.04 (focal)
universe Architecture: arm64, KEMI repack.

Official /usr/bin/gnote is a compiled aarch64 ELF
(requiredGlibc 2.29 max, requiredGlibcxx 3.4.21 max)
that embeds /usr/share/locale and /usr/share/gnote.
/opt/gnote/* are symlinks. Desktop, man, official
hicolor PNG+SVG icons, official 52 .mo including
zh_CN, official help including zh_CN, official schema
and official addins remain on standard paths. Official
control has no Recommends and no Suggests. Probe: 23
unique ELF · requiredGlibc 2.29 (23 versioned: 22 at
2.17, 1 at 2.29, 0 null; null not ranked as a max) ·
requiredGlibcxx 3.4.21 (23 versioned, 0 null; null not
ranked as a max); GTK3 C++ note-taker; within Ubuntu
20.04 / glibc 2.31 / GLIBCXX 3.4.28. Official
publication: Ubuntu 20.04 focal universe gnote
3.36.0-1 (Architecture: arm64). Official SHA256 + size
matched ports.ubuntu.com pool files and focal universe
arm64 Packages stanza. No librarian URL this run.
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
Depends: dconf-gsettings-backend | gsettings-backend, libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.29), libgcc-s1 (>= 3.0), libglib2.0-0 (>= 2.28.0), libglibmm-2.4-1v5 (>= 2.54.0), libgspell-1-2 (>= 1.8.2), libgtk-3-0 (>= 3.21.4), libgtkmm-3.0-1v5 (>= 3.24.0), libpango-1.0-0 (>= 1.14.0), libpangomm-1.4-1v5 (>= 2.42.0), libsecret-1-0 (>= 0.8), libsigc++-2.0-0v5 (>= 2.8.0), libstdc++6 (>= 5.2), libuuid1 (>= 2.16), libxml2 (>= 2.7.4), libxslt1.1 (>= 1.1.25)
Replaces: gnote
Conflicts: gnote
Provides: gnote (= 3.36.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Gnote
Description: desktop note taking program using Wiki style links
 Gnote ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 Desktop note-taking with Wiki-style
 links (GTK3 C++ GUI; Tomboy port).
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnote-control.txt"
grep -q 'Version: 3.36.0-1kemi1' "$ROOT/evidence/kemi-gnote-control.txt"
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | tee "$ROOT/evidence/kemi-gnote-shlibs.txt"
grep -q 'kemi-gnote (>= 3.36.0)' "$ROOT/evidence/kemi-gnote-shlibs.txt"
if dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | grep -q ' gnote ('; then
  echo "LEFTOVER_SHLIBS_UPSTREAM" >&2
  exit 1
fi
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./triggers | grep -q 'ldconfig'

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gnote",
    "./usr/bin/kemi-gnote",
    "./opt/gnote/gnote",
    "./usr/lib/aarch64-linux-gnu/libgnote-3.36.so.0.0.0",
    "./usr/lib/aarch64-linux-gnu/gnote/addins/3.36.0/libbugzilla.so",
    "./usr/share/icons/hicolor/256x256/apps/gnote.png",
    "./usr/share/locale/zh_CN/LC_MESSAGES/gnote.mo",
    "./usr/share/help/C/gnote/figures/gnote-new-note.png",
    "./usr/share/help/zh_CN/gnote",
    "./usr/share/glib-2.0/schemas/org.gnome.gnote.gschema.xml",
    "./usr/share/man/man1/gnote.1.gz",
    "./usr/share/dbus-1/services/org.gnome.Gnote.service",
    "./usr/share/gnote/icons/hicolor/16x16/actions/note-new.png",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gnote-128.png" in out or "org.gnome.Gnote-128.png" in out:
    raise SystemExit("INVENTED_PNG_IN_DEB")
for line in out.splitlines():
    if "./usr/bin/gnote" in line and "kemi-gnote" not in line:
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:"+line)
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
