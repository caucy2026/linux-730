#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) tilix
# 1.9.3-4build3 Architecture: arm64 as kemi-tilix,
# bundling same-source exact-version hard Depends
# tilix-common (= 1.9.3-4build3) Architecture: all.
# No newer package in focal-updates. Official
# gnome-shell-extension-tilix-dropdown and
# gnome-shell-extension-tilix-shortcut are different
# sources and are not GUI hard Depends; they were
# inspected in the index only and are not packaged.
# Official typelib-equivalent GTKD / VTE-D / libphobos
# / libunwind / libX11 / libc6 Depends stay Depends,
# unbundled (non-exact, different source). Official
# Suggests python-nautilus stays Suggests. Official
# control has no Recommends. Official Provides:
# x-terminal-emulator is kept; also versioned Provides:
# tilix (= 1.9.3-4build3) and tilix-common
# (= 1.9.3-4build3). Official Breaks/Replaces of the
# old terminix / terminix-common names are kept. No
# Debian epoch, no tilde. Official /usr/bin/tilix is a
# compiled aarch64 ELF (glibc 2.17, no GLIBCXX, no
# RUNPATH) linking system GTK-D / VTE-D / Phobos
# libraries. Official /usr/bin/tilix.wrapper is a Perl
# wrapper (not an ELF) used by x-terminal-emulator
# alternatives and must not be counted as an ELF.
# Official tilix-common ships no ELF (data, icons,
# locales, schemes, nautilus python extension, helper
# script). Official files stay on official paths;
# /opt/tilix/* are symlinks. Also /usr/bin/kemi-tilix
# → tilix. Official tilix-common ships 33 .mo including
# zh_CN / zh_TW (keep official; do not invent extra
# language packs). Official package ships no Yelp help.
# Official app icons are SVG only
# (com.gexperts.Tilix.svg + symbolic) in tilix-common;
# no official hicolor PNGs. A 128×128 PNG rasterized
# from the official app SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/com.gexperts.Tilix-128.png and is used only
# as the mall CREATE --icon; it is not shipped in the
# deb. Official changelog.Debian.gz in both packages is
# a real file and is copied with cp -L. Official desktop
# Exec=tilix is rewritten to /usr/bin/tilix (including
# action Exec lines); TryExec is added;
# Icon=com.gexperts.Tilix and Name=Tilix are kept;
# DBusActivatable=true is kept. Official D-Bus
# Exec=/usr/bin/tilix --gapplication-service is already
# absolute and is kept. Official update-alternatives
# for x-terminal-emulator pointing at
# /usr/bin/tilix.wrapper are kept (official path).
# Official packages have no shlibs and no ldconfig
# trigger. Probe: Architecture arm64 · 1 unique
# packaged ELF · requiredGlibc 2.17 (1 versioned,
# 0 null) · no GLIBCXX (0 versioned, 1 null; null is
# not ranked as a max) · official tilix.wrapper is a
# Perl script, not an ELF · GTK3/D tiling terminal ·
# within 101 ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool files and the
# Ubuntu 20.04 focal universe arm64 Packages stanza
# (Aliyun ubuntu-ports mirror, streamed). No librarian
# URL and no .buildinfo is recorded this run (pool 404).
# KEMI version 1.9.3-4build3kemi1 is 18 chars (under
# the mall version_name limit that rejected Remmina's
# 33-char string; 12–28 char siblings succeeded). No
# epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-tilix
VER_UP=1.9.3-4build3
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-tilix
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
COMMON="${COMMON:-$ROOT/unpack-common}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/tilix_1.9.3-4build3_arm64.deb"
UP_COMMON="$DL/tilix-common_1.9.3-4build3_all.deb"
EXPECT_SHA=6dc8e3c48752cd936e33848c1d770b81d3330455703501cf9d84d34ef9b47dbc
EXPECT_BYTES=528312
EXPECT_COMMON_SHA=e99412d59fe1d7d5c6af0ac4b1119a715539760e00fb87f0d9f61457a2ba391e
EXPECT_COMMON_BYTES=208144
python3 - << PY
s="${VER_DEB}"
assert len(s) == 18, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB" && test -f "$UP_COMMON"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_COMMON")" = "$EXPECT_COMMON_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_COMMON_SHA  $UP_COMMON" | sha256sum -c -
test -x "$UNPACK/usr/bin/tilix"
test -x "$UNPACK/usr/bin/tilix.wrapper"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/bin/tilix")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
w = Path("$UNPACK/usr/bin/tilix.wrapper")
assert not w.is_symlink()
assert w.read_bytes()[:2] == b"#!"
assert w.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_elf_ok official_wrapper_not_elf")
PY
test -f "$UNPACK/usr/share/applications/com.gexperts.Tilix.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/com.gexperts.Tilix.service"
test -f "$COMMON/usr/share/icons/hicolor/scalable/apps/com.gexperts.Tilix.svg"
test ! -f "$COMMON/usr/share/icons/hicolor/256x256/apps/com.gexperts.Tilix.png"
test -f "$ROOT/evidence/com.gexperts.Tilix-128.png"
test ! -L "$UNPACK/usr/share/doc/tilix/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/tilix/changelog.Debian.gz"
test ! -L "$COMMON/usr/share/doc/tilix-common/changelog.Debian.gz"
test "$(find "$COMMON" -name '*.mo' | wc -l)" = 33
test -f "$COMMON/usr/share/locale/zh_CN/LC_MESSAGES/tilix.mo"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/tilix"

# bundle same-source exact-version tilix-common first, then official GUI
cp -a "$COMMON/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/tilix" "$STAGE/pkg/usr/bin/tilix.wrapper"
# official alternatives scripts
cp -a "$UNPACK/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"

REPORT="$ROOT/probe/kemi-tilix.json"
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
if Path(f["path"]).name != "tilix":
    raise SystemExit("PROBE_NAME")
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
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
w = Path("$STAGE/pkg/usr/bin/tilix.wrapper")
if w.read_bytes()[:2] != b"#!":
    raise SystemExit("WRAPPER_MISSING")
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) official tilix.wrapper is Perl not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 33
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/com.gexperts.Tilix.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/com.gexperts.Tilix.png"
if find "$STAGE/pkg" -name 'com.gexperts.Tilix-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/tilix/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/tilix/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/com.gexperts.Tilix.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/com.gexperts.Tilix.desktop"
export STAGE_DBUS="$STAGE/pkg/usr/share/dbus-1/services/com.gexperts.Tilix.service"
export STAGE_PKG="$STAGE/pkg"
python3 - << 'PY'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=tilix(\s.*)?$", r"Exec=/usr/bin/tilix\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/tilix", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/tilix$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/tilix",
        text2,
        count=1,
        flags=re.M,
    )
if re.search(r"^Exec=tilix(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in (
    "Exec=/usr/bin/tilix",
    "Exec=/usr/bin/tilix --action=app-new-window",
    "Exec=/usr/bin/tilix --action=app-new-session",
    "Exec=/usr/bin/tilix --preferences",
    "TryExec=/usr/bin/tilix",
    "Icon=com.gexperts.Tilix",
    "Name=Tilix",
    "DBusActivatable=true",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if text2.count("Exec=/usr/bin/tilix") < 4:
    raise SystemExit("DESKTOP_EXEC_COUNT")
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_rewritten")

svc = Path(os.environ["STAGE_DBUS"]).read_text(encoding="utf-8")
if "Exec=/usr/bin/tilix --gapplication-service" not in svc:
    raise SystemExit("DBUS_EXEC_CHANGED")
print("dbus_kept")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".gresource"}:
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

ln -sf /usr/bin/tilix "$STAGE/pkg/opt/tilix/tilix"
ln -sf /usr/bin/tilix.wrapper "$STAGE/pkg/opt/tilix/tilix.wrapper"
ln -sf tilix "$STAGE/pkg/usr/bin/kemi-tilix"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://gnunn1.github.io/tilix-web/
Source: https://launchpad.net/ubuntu/+source/tilix
Homepage: https://gnunn1.github.io/tilix-web/
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) Architecture: arm64 deb v${VER_UP}
(tilix_1.9.3-4build3_arm64.deb) plus same-source exact-version
tilix-common_1.9.3-4build3_all.deb, repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 tilix_1.9.3-4build3_arm64.deb
    (focal universe; no newer package in focal-updates)
    plus same-source exact-version hard Depends
    tilix-common (= 1.9.3-4build3) Architecture: all,
    repackaged for KEMI as ${PKG}. Official GTK-D / VTE-D
    / Phobos / libc6 Depends stay Depends and are not
    bundled. Official Suggests python-nautilus stays
    Suggests. Official Provides: x-terminal-emulator is
    kept. Versioned Provides: tilix (= 1.9.3-4build3)
    and tilix-common (= 1.9.3-4build3).
  * Official /usr/bin/tilix is a compiled aarch64 ELF.
    Official /usr/bin/tilix.wrapper is a Perl wrapper,
    not an ELF. Official files stay under /usr.
    /opt/tilix/* are symlinks. Also /usr/bin/kemi-tilix
    → tilix.
  * Official tilix-common ships 33 .mo including zh_CN /
    zh_TW and no Yelp help. Official app icons are SVG
    only; a 128×128 evidence PNG rasterized from the
    official SVG is used only for mall CREATE --icon and
    is not packed in the deb.
  * Official changelog is a real file and was copied with
    cp -L. Official desktop Exec=tilix rewritten to
    /usr/bin/tilix (including action Exec lines);
    TryExec added; Icon=com.gexperts.Tilix; Name=Tilix.
    Official D-Bus Exec is already absolute and is kept.
    Official x-terminal-emulator alternatives at
    /usr/bin/tilix.wrapper are kept.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Tilix ${VER_UP} — official Ubuntu 20.04
(focal universe) Architecture: arm64 plus bundled
same-source tilix-common Architecture: all, KEMI
repack.

Official /usr/bin/tilix is a compiled aarch64 ELF
(glibc 2.17, no GLIBCXX). Official
/usr/bin/tilix.wrapper is a Perl wrapper, not an ELF.
/opt/tilix/* are symlinks. Official GTK-D / VTE-D /
Phobos Depends stay Depends and are not bundled.
Official Suggests stay Suggests. Official tilix-common
ships 33 .mo including zh_CN. Official app icons are
SVG only; a 128×128 evidence PNG is used only as mall
CREATE --icon and is not packed. Probe: 1 unique ELF ·
requiredGlibc 2.17 (1 versioned, 0 null) · no
requiredGlibcxx (0 versioned, 1 null; null not ranked
as a max); GTK3/D tiling terminal; within Ubuntu 20.04
/ glibc 2.31 / GLIBCXX 3.4.28. Official publication:
Ubuntu 20.04 focal universe tilix 1.9.3-4build3
(Architecture: arm64) and tilix-common 1.9.3-4build3
(Architecture: all). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanza. No librarian URL this run.
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
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libgtkd-3-0 (>= 3.9.0), libphobos2-ldc-shared90 (>= 1:1.20.0), libunwind8, libvted-3-0 (>= 3.9.0), libx11-6
Suggests: python-nautilus
Breaks: terminix (<< 1.5.4-1~), terminix-common (<< 1.5.4-1~)
Replaces: tilix, tilix-common, terminix (<< 1.5.4-1~), terminix-common (<< 1.5.4-1~)
Conflicts: tilix, tilix-common
Provides: x-terminal-emulator, tilix (= 1.9.3-4build3), tilix-common (= 1.9.3-4build3)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://gnunn1.github.io/tilix-web/
Description: Tiling terminal emulator for GNOME
 Tilix ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64 plus bundled tilix-common, KEMI
 repack. GTK3/D tiling terminal emulator.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-alternatives --install /usr/bin/x-terminal-emulator' "$STAGE/pkg/DEBIAN/postinst"
grep -q '/usr/bin/tilix.wrapper 30' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-alternatives --remove x-terminal-emulator /usr/bin/tilix.wrapper' "$STAGE/pkg/DEBIAN/prerm"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-tilix-control.txt"
grep -q 'Version: 1.9.3-4build3kemi1' "$ROOT/evidence/kemi-tilix-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-tilix-control.txt"
grep -q 'libphobos2-ldc-shared90' "$ROOT/evidence/kemi-tilix-control.txt"
grep -q 'Suggests: python-nautilus' "$ROOT/evidence/kemi-tilix-control.txt"
grep -q 'Provides: x-terminal-emulator, tilix (= 1.9.3-4build3), tilix-common (= 1.9.3-4build3)' "$ROOT/evidence/kemi-tilix-control.txt"
! grep -q 'tilix-common (=' "$ROOT/evidence/kemi-tilix-control.txt" <<< '' # bundled, must not remain in Depends
! grep -E '^ Depends:.*tilix-common' "$ROOT/evidence/kemi-tilix-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-tilix-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/tilix",
    "./usr/bin/tilix.wrapper",
    "./usr/bin/kemi-tilix",
    "./opt/tilix/tilix",
    "./usr/share/applications/com.gexperts.Tilix.desktop",
    "./usr/share/dbus-1/services/com.gexperts.Tilix.service",
    "./usr/share/glib-2.0/schemas/com.gexperts.Tilix.gschema.xml",
    "./usr/share/icons/hicolor/scalable/apps/com.gexperts.Tilix.svg",
    "./usr/share/locale/zh_CN/LC_MESSAGES/tilix.mo",
    "./usr/share/man/man1/tilix.1.gz",
    "./usr/share/metainfo/com.gexperts.Tilix.appdata.xml",
    "./usr/share/tilix/resources/tilix.gresource",
    "./usr/share/nautilus-python/extensions/open-tilix.py",
    "./usr/share/doc/kemi-tilix/changelog.upstream.gz",
    "./usr/share/doc/tilix-common/changelog.Debian.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "com.gexperts.Tilix-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = found_wrap = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/tilix " in line or line.rstrip().endswith("./usr/bin/tilix")) and "tilix.wrapper" not in line and "kemi-tilix" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/tilix.wrapper" in line:
        found_wrap = True
        if "->" in line:
            raise SystemExit("WRAPPER_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-tilix" in line:
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
