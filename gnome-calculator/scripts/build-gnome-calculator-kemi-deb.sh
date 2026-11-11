#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release main) gnome-calculator
# 1:3.36.0-1ubuntu1 Architecture: arm64 as kemi-gnome-calculator.
# No newer package in focal-updates. The gnome-calculator source
# ships only this one binary package in focal (no same-source
# -data/-common to bundle). Official Recommends (yelp, gvfs) are
# different-source packages and stay Recommends; they are not
# bundled. Official control has no Suggests. Official Breaks /
# Replaces gcalctool (<< 6.7) are kept. Versioned Provides:
# gnome-calculator (= 1:3.36.0-1ubuntu1). Debian epoch 1: is
# omitted from mall version_name and the deb filename but is
# kept in dpkg Version (Pidgin pattern).
# Official /usr/bin/gnome-calculator is a compiled aarch64 ELF
# that embeds /usr/share/locale and help:gnome-calculator.
# Official companion CLI /usr/bin/gcalccmd, official
# /usr/libexec/gnome-calculator-search-provider, and official
# public libs libgcalc-2 / libgci-1 under
# /usr/lib/aarch64-linux-gnu stay on official paths (official
# soname symlinks kept). Official files stay on official
# paths; /opt/gnome-calculator/* are symlinks. Also
# /usr/bin/kemi-gnome-calculator → gnome-calculator.
# Official package ships no .mo (Ubuntu language-pack split;
# desktop X-Ubuntu-Gettext-Domain=gnome-calculator). Keep the
# official tree; do not invent or bundle language packs.
# Official Yelp help has a real C tree under
# /usr/share/help/C/gnome-calculator/ plus official
# help-langpack symlinks for other locales (including zh_CN /
# zh_TW / zh_HK); keep the official tree and do not invent or
# bundle language-packs. Official app icons are SVG only
# (org.gnome.Calculator.svg, Devel.svg, and symbolic). Official
# help figure SVG stays in the official help tree and is not
# the app icon. Do not invent a PNG inside the package. A
# 128×128 PNG rasterized from the official app SVG via Chrome
# headless lives at evidence/org.gnome.Calculator-128.png and
# is used only as the mall CREATE --icon (GNOME Clocks /
# Calendar / Tweaks / Weather / Maps / Logs pattern); it is
# not shipped in the deb.
# Official changelog is a real file. Official package has a
# shlibs file (libgcalc-2 / libgci-1) and an ldconfig trigger,
# and no maintainer scripts; shlibs are retargeted to
# kemi-gnome-calculator (font-manager / gitg pattern) keeping
# the official epoch in the shlibs version; the official
# ldconfig trigger is kept; hicolor + desktop-database hooks
# are added. Official desktop Exec=gnome-calculator is
# rewritten to /usr/bin/gnome-calculator; TryExec is added;
# Icon=org.gnome.Calculator is kept. Official D-Bus
# SearchProvider Exec is already absolute and is kept.
# Official gsettings schema, man pages, GIR, pkgconfig, Vala
# vapi, and headers stay in the official tree.
# Probe: Architecture arm64 · 5 unique packaged ELF ·
# requiredGlibc 2.17 (5 versioned, 0 null) · no GLIBCXX
# (0 versioned, 5 null; null is not ranked as a max) · GTK3
# calculator · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal main arm64 Packages
# stanza (Aliyun ubuntu-ports mirror, streamed). No librarian
# URL and no .buildinfo is recorded this run (pool 404).
# KEMI version 3.36.0-1ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-logs 3.34.0-1ubuntu1kemi1 was 20 chars).
# Epoch omitted from mall/filename; no tilde; no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-calculator
VER_UP=3.36.0-1ubuntu1
VER_DEB="${VER_UP}kemi1"
VER_DPKG="1:${VER_DEB}"
ARCH=arm64
PKG=kemi-gnome-calculator
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-calculator_3.36.0-1ubuntu1_arm64.deb"
EXPECT_SHA=e35204f373347defccf74a7d646f4772ce6e9f19790d080c336182b328d1199d
EXPECT_BYTES=329320
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
print("dpkg_version", "${VER_DPKG}")
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-calculator"
test -x "$UNPACK/usr/bin/gcalccmd"
test -x "$UNPACK/usr/libexec/gnome-calculator-search-provider"
python3 - << PY
from pathlib import Path
for rel in ("usr/bin/gnome-calculator","usr/bin/gcalccmd","usr/libexec/gnome-calculator-search-provider"):
    p=Path("$UNPACK")/rel
    assert not p.is_symlink(), rel
    assert p.read_bytes()[:4] == bytes([0x7F])+b"ELF", rel
print("official_elfs_ok")
PY
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libgcalc-2.so.1"
test -L "$UNPACK/usr/lib/aarch64-linux-gnu/libgcalc-2.so.1.0.1"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/libgci-1.so.0"
test -f "$UNPACK/usr/share/applications/org.gnome.Calculator.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg"
test ! -d "$UNPACK/usr/share/icons/hicolor/256x256"
test ! -d "$UNPACK/usr/share/locale"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -d "$UNPACK/usr/share/help/C/gnome-calculator"
test ! -L "$UNPACK/usr/share/doc/gnome-calculator/changelog.Debian.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.calculator.gschema.xml"
test -f "$UNPACK/DEBIAN/shlibs"
test -f "$UNPACK/DEBIAN/triggers"
test ! -f "$UNPACK/DEBIAN/postinst"
test -f "$ROOT/evidence/org.gnome.Calculator-128.png"
# evidence raster must not already be inside the official tree
if find "$UNPACK" -name 'org.gnome.Calculator-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_OFFICIAL" >&2
  exit 1
fi

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-calculator"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
# official binaries must remain mode 0755
chmod 0755 "$STAGE/pkg/usr/bin/gnome-calculator" \
  "$STAGE/pkg/usr/bin/gcalccmd" \
  "$STAGE/pkg/usr/libexec/gnome-calculator-search-provider"

REPORT="$ROOT/probe/kemi-gnome-calculator.json"
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
expect = ["gcalccmd", "gnome-calculator", "gnome-calculator-search-provider", "libgcalc-2.so.1", "libgci-1.so.0"]
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
if len(versioned) != 5 or len(nulls) != 0 or cxx or len(cxx_null) != 5:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
if any(x.get("requiredGlibc") != "2.17" for x in versioned):
    raise SystemExit("PROBE_GLIBC:"+str([x.get("requiredGlibc") for x in versioned]))
print("PROBE_PASS n_elf=5 unique aarch64 glibc=2.17 (5 versioned, 0 null) noGLIBCXX (0 versioned, 5 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -d "$STAGE/pkg/usr/share/help/C/gnome-calculator"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg"
test ! -e "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.Calculator.png"
if find "$STAGE/pkg" -name 'org.gnome.Calculator-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-calculator/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-calculator/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.Calculator.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Calculator.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnome-calculator(\s.*)?$", r"Exec=/usr/bin/gnome-calculator\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/gnome-calculator", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/gnome-calculator.*$", lambda m: m.group(0)+"\nTryExec=/usr/bin/gnome-calculator", text2, count=1, flags=re.M)
if re.search(r"^Exec=gnome-calculator(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gnome-calculator",
               "TryExec=/usr/bin/gnome-calculator",
               "Icon=org.gnome.Calculator",
               "Name=Calculator"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

# official D-Bus Exec must remain absolute
svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service").read_text()
if "Exec=/usr/libexec/gnome-calculator-search-provider" not in svc:
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

ln -sf /usr/bin/gnome-calculator "$STAGE/pkg/opt/gnome-calculator/gnome-calculator"
ln -sf gnome-calculator "$STAGE/pkg/usr/bin/kemi-gnome-calculator"

# official shlibs retargeted to kemi-gnome-calculator; keep official epoch
cat > "$STAGE/pkg/DEBIAN/shlibs" << 'EOT'
libgcalc-2 1.0.1 kemi-gnome-calculator (>= 1:3.36.0)
libgci-1 0.0.0 kemi-gnome-calculator (>= 1:3.36.0)
EOT

# official ldconfig trigger kept
cp -a "$UNPACK/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Calculator
Source: https://launchpad.net/ubuntu/+source/gnome-calculator
Homepage: https://wiki.gnome.org/Apps/Calculator
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: arm64 deb v1:${VER_UP}
(gnome-calculator_3.36.0-1ubuntu1_arm64.deb), repackaged for KEMI as ${PKG}.
Debian epoch 1: is kept in dpkg Version and omitted from the mall
version_name / filename.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DPKG}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-calculator_3.36.0-1ubuntu1_arm64.deb
    (focal main; no newer package in focal-updates) repackaged
    for KEMI as ${PKG}. Official Version is 1:3.36.0-1ubuntu1;
    epoch 1: is kept in dpkg Version and omitted from mall
    version_name / filename (Pidgin pattern). No same-source
    data package in focal. Official Recommends (yelp, gvfs)
    stay Recommends and are not bundled. Official control has
    no Suggests. Official Breaks/Replaces gcalctool (<< 6.7)
    are kept. Versioned Provides: gnome-calculator (=
    1:3.36.0-1ubuntu1).
  * Official /usr/bin/gnome-calculator is a compiled aarch64
    ELF embedding /usr/share/locale and help:gnome-calculator.
    Official gcalccmd, search-provider, and public libs stay
    under /usr. /opt/gnome-calculator/* are symlinks. Also
    /usr/bin/kemi-gnome-calculator.
  * Desktop, man, official SVG icons, official gsettings
    schema, official help (C tree + help-langpack symlinks),
    official GIR/pkgconfig/headers, and official plugins stay
    on standard paths. Official package ships no .mo
    (language-pack split). Official desktop Exec=gnome-calculator
    rewritten to /usr/bin/gnome-calculator; TryExec added;
    Icon=org.gnome.Calculator. Official D-Bus Exec already
    absolute and kept. Official app icons are SVG only; a
    128×128 evidence PNG is used only for mall CREATE --icon
    and is not packed in the deb.
  * Official shlibs retargeted to kemi-gnome-calculator
    (epoch kept). Official ldconfig trigger kept. Official
    package has no maintainer scripts; icon-cache and
    desktop-database hooks are added. Official changelog is
    a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Calculator 1:${VER_UP} — official Ubuntu 20.04 (focal)
main Architecture: arm64, KEMI repack.

Official /usr/bin/gnome-calculator is a compiled aarch64
ELF (glibc 2.17, no GLIBCXX) that embeds /usr/share/locale
and help:gnome-calculator. /opt/gnome-calculator/* are
symlinks. Desktop, man, official SVG icons, official schema,
official help, and official public libs remain on standard
paths. Official package ships no .mo (language-pack split).
Official Recommends (yelp, gvfs) stay Recommends. Probe: 5
unique ELF · requiredGlibc 2.17 (5 versioned, 0 null) · no
requiredGlibcxx (0 versioned, 5 null; null not ranked as a
max); GTK3 calculator; within Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04 focal main
gnome-calculator 1:3.36.0-1ubuntu1 (Architecture: arm64).
Official SHA256 + size matched ports.ubuntu.com pool files
and focal main arm64 Packages stanza. No librarian URL this
run. Epoch omitted from mall version_name / filename.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DPKG
Section: math
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libgee-0.8-2 (>= 0.20), libglib2.0-0 (>= 2.43.92), libgtk-3-0 (>= 3.19.12), libgtksourceview-4-0 (>= 2.91.4), libmpc3, libmpfr6 (>= 3.1.3), libsoup2.4-1 (>= 2.42), libxml2 (>= 2.7.4), dconf-gsettings-backend | gsettings-backend
Recommends: yelp, gvfs
Breaks: gcalctool (<< 6.7)
Replaces: gnome-calculator, gcalctool (<< 6.7)
Conflicts: gnome-calculator
Provides: gnome-calculator (= 1:3.36.0-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Calculator
Description: GNOME desktop calculator
 GNOME Calculator 1:${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 Graphical calculator with financial,
 logical and scientific modes
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
# filename must not contain the epoch
case "$DEB" in
  *":"*) echo "EPOCH_IN_FILENAME $DEB" >&2; exit 1 ;;
esac
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-calculator-control.txt"
# dpkg Version must keep the epoch
grep -q 'Version: 1:3.36.0-1ubuntu1kemi1' "$ROOT/evidence/kemi-gnome-calculator-control.txt"
grep -q 'Recommends: yelp, gvfs' "$ROOT/evidence/kemi-gnome-calculator-control.txt"
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | tee "$ROOT/evidence/kemi-gnome-calculator-shlibs.txt"
grep -q 'kemi-gnome-calculator (>= 1:3.36.0)' "$ROOT/evidence/kemi-gnome-calculator-shlibs.txt"
if dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./shlibs | grep -q ' gnome-calculator ('; then
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
    "./usr/bin/gnome-calculator",
    "./usr/bin/gcalccmd",
    "./usr/bin/kemi-gnome-calculator",
    "./opt/gnome-calculator/gnome-calculator",
    "./usr/libexec/gnome-calculator-search-provider",
    "./usr/lib/aarch64-linux-gnu/libgcalc-2.so.1",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg",
    "./usr/share/glib-2.0/schemas/org.gnome.calculator.gschema.xml",
    "./usr/share/help/C/gnome-calculator/index.page",
    "./usr/share/man/man1/gnome-calculator.1.gz",
    "./usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "org.gnome.Calculator-128.png" in out or "128x128/apps/org.gnome.Calculator.png" in out:
    raise SystemExit("EVIDENCE_PNG_IN_DEB")
for line in out.splitlines():
    if "./usr/bin/gnome-calculator" in line and "kemi-gnome-calculator" not in line:
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:"+line)
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
