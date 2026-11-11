#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) gsmartcontrol
# 1.1.3-2build1 Architecture: arm64 as kemi-gsmartcontrol.
# No newer package in focal-updates. The gsmartcontrol
# source ships only this one binary package in focal (no
# same-source -data/-common to bundle). Official Depends
# (GTK/glibmm/gtkmm/cairomm/pcre/libstdc++ and
# smartmontools (>= 5.43)) are different-source and stay
# Depends, unbundled. Official control has no Recommends
# and no Suggests. Versioned Provides: gsmartcontrol
# (= 1.1.3-2build1). No Debian epoch, no tilde. Official
# /usr/sbin/gsmartcontrol is a compiled aarch64 ELF
# (glibc 2.17, GLIBCXX 3.4.26) with no RUNPATH, linking
# only system libraries. Official
# /usr/bin/gsmartcontrol-root is a bash wrapper (not an
# ELF) that launches /usr/sbin/gsmartcontrol via pkexec
# (or another su helper) and must not be counted as an
# ELF. Official contrib cron scripts under
# /usr/share/doc are also shell wrappers, not ELFs.
# Official files stay on official paths;
# /opt/gsmartcontrol/* are symlinks. Also
# /usr/bin/kemi-gsmartcontrol → gsmartcontrol-root.
# Official GUI package ships no .mo (keep official, do
# not invent packs). Official package ships no Yelp
# help. Official app icons include hicolor 16–256 PNGs;
# official 256×256
# /usr/share/icons/hicolor/256x256/apps/gsmartcontrol.png
# is used as the mall CREATE --icon (Zim / gitg / gnote /
# glade pattern) and is not packed a second time.
# Official in-app PNGs icon_hdd.png / icon_cddvd.png and
# the official pixmap stay in the official tree. Official
# changelog.Debian.gz is a real file and is copied with
# cp -L. Official desktop Exec="/usr/bin/gsmartcontrol-root"
# is already absolute and is kept; TryExec is added;
# Icon=gsmartcontrol and Name=GSmartControl are kept.
# Official PolicyKit exec.path=/usr/sbin/gsmartcontrol is
# already absolute and is kept. Official man pages,
# appdata, lintian override, and contrib stay in the
# official tree. Official package has no maintainer
# scripts and no conffiles; icon-cache and
# desktop-database hooks are added. Official package has
# no shlibs and no ldconfig trigger. Probe: Architecture
# arm64 · 1 unique packaged ELF · requiredGlibc 2.17
# (1 versioned, 0 null) · requiredGlibcxx 3.4.26
# (1 versioned, 0 null; null is not ranked as a max) ·
# official gsmartcontrol-root is a shell wrapper, not an
# ELF · GTK3 SMART utility · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04 focal
# universe arm64 Packages stanza (Aliyun ubuntu-ports
# mirror, streamed). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI version
# 1.1.3-2build1kemi1 is 18 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gsmartcontrol
VER_UP=1.1.3-2build1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gsmartcontrol
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gsmartcontrol_1.1.3-2build1_arm64.deb"
EXPECT_SHA=32fde8b589a4aeabb87d060c68312fc1b4e5b9be13bd3af0301334b88ab0adcd
EXPECT_BYTES=531824
python3 - << PY
s="${VER_DEB}"
assert len(s) == 18, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/sbin/gsmartcontrol"
test -x "$UNPACK/usr/bin/gsmartcontrol-root"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/sbin/gsmartcontrol")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
w = Path("$UNPACK/usr/bin/gsmartcontrol-root")
assert not w.is_symlink()
assert w.read_bytes()[:2] == b"#!"
assert w.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_elf_ok official_root_wrapper_not_elf")
PY
test -f "$UNPACK/usr/share/applications/gsmartcontrol.desktop"
test -f "$UNPACK/usr/share/polkit-1/actions/org.gsmartcontrol.policy"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/gsmartcontrol.png"
test -f "$ROOT/evidence/gsmartcontrol-256.png"
test ! -L "$UNPACK/usr/share/doc/gsmartcontrol/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gsmartcontrol/changelog.Debian.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/sbin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gsmartcontrol"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/sbin/gsmartcontrol" \
  "$STAGE/pkg/usr/bin/gsmartcontrol-root"

REPORT="$ROOT/probe/kemi-gsmartcontrol.json"
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
if Path(f["path"]).name != "gsmartcontrol":
    raise SystemExit("PROBE_NAME")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") != "3.4.26":
    raise SystemExit("PROBE_GLIBCXX:" + str(f.get("requiredGlibcxx")))
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or len(nulls) != 0 or len(cxx) != 1 or len(cxx_null) != 0:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
wrap = Path("$STAGE/pkg/usr/bin/gsmartcontrol-root")
if wrap.read_bytes()[:2] != b"#!":
    raise SystemExit("WRAPPER_MISSING")
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.17 (1 versioned, 0 null) GLIBCXX=3.4.26 (1 versioned, 0 null; null not ranked as a max) official gsmartcontrol-root is shell not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/gsmartcontrol.png"
test -f "$STAGE/pkg/usr/share/gsmartcontrol/icon_hdd.png"
test -f "$STAGE/pkg/usr/share/gsmartcontrol/icon_cddvd.png"
# evidence copy must not be packed as a second icon
if find "$STAGE/pkg" -name 'gsmartcontrol-256.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gsmartcontrol/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gsmartcontrol/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << 'PY'
from pathlib import Path
import re
import os

src = Path(os.environ["UNPACK_DESKTOP"] if False else "")
PY
# quoted block cannot see STAGE; use env
UNPACK_DESKTOP="$UNPACK/usr/share/applications/gsmartcontrol.desktop"
STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/gsmartcontrol.desktop"
STAGE_POLKIT="$STAGE/pkg/usr/share/polkit-1/actions/org.gsmartcontrol.policy"
STAGE_WRAP="$STAGE/pkg/usr/bin/gsmartcontrol-root"
export UNPACK_DESKTOP STAGE_DESKTOP STAGE_POLKIT STAGE_WRAP STAGE_PKG="$STAGE/pkg"
python3 - << 'PY'
from pathlib import Path
import os, re

src = Path(os.environ["UNPACK_DESKTOP"])
dst = Path(os.environ["STAGE_DESKTOP"])
text = src.read_text(encoding="utf-8")
# official Exec is already absolute; keep it
if 'Exec="/usr/bin/gsmartcontrol-root"' not in text and "Exec=/usr/bin/gsmartcontrol-root" not in text:
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED:" + text)
if re.search(r"^TryExec=", text, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/gsmartcontrol-root", text, flags=re.M)
else:
    text2 = re.sub(
        r'^Exec="/usr/bin/gsmartcontrol-root".*$',
        lambda m: m.group(0) + "\nTryExec=/usr/bin/gsmartcontrol-root",
        text,
        count=1,
        flags=re.M,
    )
for expect in (
    'Exec="/usr/bin/gsmartcontrol-root"',
    "TryExec=/usr/bin/gsmartcontrol-root",
    "Icon=gsmartcontrol",
    "Name=GSmartControl",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
dst.write_text(text2)
print("desktop_kept_absolute_tryexec_added")

pol = Path(os.environ["STAGE_POLKIT"]).read_text(encoding="utf-8")
if 'org.freedesktop.policykit.exec.path">/usr/sbin/gsmartcontrol</annotate>' not in pol:
    raise SystemExit("POLKIT_EXEC_CHANGED")
print("polkit_kept")

wrap = Path(os.environ["STAGE_WRAP"]).read_text(encoding="utf-8")
if 'EXEC_BIN="/usr/sbin/gsmartcontrol"' not in wrap:
    raise SystemExit("WRAPPER_EXEC_CHANGED")
print("wrapper_kept")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".xpm"}:
        continue
    try:
        txt = p.read_text(encoding="utf-8")
    except Exception:
        continue
    for i, line in enumerate(txt.splitlines(), 1):
        s = line.strip()
        if "x86_64-linux-gnu" not in s:
            continue
        if s.startswith("#"):
            continue
        leftover.append(f"{p}:{i}:{s}")
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_live_x86_paths")
PY

ln -sf /usr/sbin/gsmartcontrol "$STAGE/pkg/opt/gsmartcontrol/gsmartcontrol"
ln -sf /usr/bin/gsmartcontrol-root "$STAGE/pkg/opt/gsmartcontrol/gsmartcontrol-root"
ln -sf gsmartcontrol-root "$STAGE/pkg/usr/bin/kemi-gsmartcontrol"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gsmartcontrol.sourceforge.io/
Source: https://launchpad.net/ubuntu/+source/gsmartcontrol
Homepage: https://gsmartcontrol.sourceforge.io/
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: arm64 deb v${VER_UP}
(gsmartcontrol_1.1.3-2build1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gsmartcontrol_1.1.3-2build1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. Official Depends
    (GTK/glibmm/gtkmm and smartmontools (>= 5.43)) stay
    Depends and are not bundled. Official control has no
    Recommends and no Suggests. Versioned Provides:
    gsmartcontrol (= 1.1.3-2build1).
  * Official /usr/sbin/gsmartcontrol is a compiled
    aarch64 ELF. Official /usr/bin/gsmartcontrol-root is
    a shell wrapper, not an ELF. Official files stay
    under /usr. /opt/gsmartcontrol/* are symlinks. Also
    /usr/bin/kemi-gsmartcontrol → gsmartcontrol-root.
  * Official GUI package ships no .mo and no Yelp help.
    Official hicolor 16–256 PNGs stay official; official
    256×256 is used as mall CREATE --icon and is not
    packed a second time. Official in-app icon_hdd.png
    and icon_cddvd.png stay in the official tree.
  * Official changelog is a real file and was copied with
    cp -L. Official desktop Exec="/usr/bin/gsmartcontrol-root"
    is already absolute and is kept; TryExec is added;
    Icon=gsmartcontrol; Name=GSmartControl. Official
    PolicyKit exec.path=/usr/sbin/gsmartcontrol is
    already absolute and is kept.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GSmartControl ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: arm64, KEMI repack.

Official /usr/sbin/gsmartcontrol is a compiled aarch64
ELF (glibc 2.17, GLIBCXX 3.4.26). Official
/usr/bin/gsmartcontrol-root is a shell wrapper, not an
ELF. /opt/gsmartcontrol/* are symlinks. Official GTK /
glibmm / smartmontools Depends stay Depends and are
not bundled. Official control has no Recommends and no
Suggests. Official GUI package ships no .mo and no
Yelp help. Official hicolor 256×256 is used only as
mall CREATE --icon and is not packed a second time.
Probe: 1 unique ELF · requiredGlibc 2.17 (1 versioned,
0 null) · requiredGlibcxx 3.4.26 (1 versioned, 0 null;
null not ranked as a max); GTK3 SMART utility; within
Ubuntu 20.04 / glibc 2.31 / GLIBCXX 3.4.28. Official
publication: Ubuntu 20.04 focal universe gsmartcontrol
1.1.3-2build1 (Architecture: arm64). Official SHA256 +
size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanza. No librarian URL this
run.
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
Depends: libatkmm-1.6-1v5 (>= 2.24.0), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libcairomm-1.0-1v5 (>= 1.12.0), libgcc-s1 (>= 4.2), libglib2.0-0 (>= 2.16.0), libglibmm-2.4-1v5 (>= 2.54.0), libgtk-3-0 (>= 3.21.4), libgtkmm-3.0-1v5 (>= 3.24.0), libpangomm-1.4-1v5 (>= 2.42.0), libpcrecpp0v5 (>= 7.7), libsigc++-2.0-0v5 (>= 2.8.0), libstdc++6 (>= 9), smartmontools (>= 5.43)
Replaces: gsmartcontrol
Conflicts: gsmartcontrol
Provides: gsmartcontrol (= 1.1.3-2build1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gsmartcontrol.sourceforge.io/
Description: graphical user interface for smartctl
 GSmartControl ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 GTK3 SMART disk health utility.
 glibc≤2.31 / GLIBCXX≤3.4.28 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
grep -q 'Version: 1.1.3-2build1kemi1' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
grep -q 'smartmontools (>= 5.43)' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
grep -q 'Provides: gsmartcontrol (= 1.1.3-2build1)' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gsmartcontrol-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/sbin/gsmartcontrol",
    "./usr/bin/gsmartcontrol-root",
    "./usr/bin/kemi-gsmartcontrol",
    "./opt/gsmartcontrol/gsmartcontrol",
    "./opt/gsmartcontrol/gsmartcontrol-root",
    "./usr/share/applications/gsmartcontrol.desktop",
    "./usr/share/polkit-1/actions/org.gsmartcontrol.policy",
    "./usr/share/icons/hicolor/256x256/apps/gsmartcontrol.png",
    "./usr/share/gsmartcontrol/icon_hdd.png",
    "./usr/share/gsmartcontrol/icon_cddvd.png",
    "./usr/share/pixmaps/gsmartcontrol.png",
    "./usr/share/man/man1/gsmartcontrol.1.gz",
    "./usr/share/metainfo/gsmartcontrol.appdata.xml",
    "./usr/share/doc/kemi-gsmartcontrol/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gsmartcontrol-256.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = found_wrap = found_kemi = False
for line in out.splitlines():
    if "./usr/sbin/gsmartcontrol" in line and "kemi-" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/gsmartcontrol-root" in line and "kemi-" not in line:
        found_wrap = True
        if "->" in line:
            raise SystemExit("WRAPPER_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-gsmartcontrol" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_wrap:
    raise SystemExit("MISSING_WRAPPER")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
