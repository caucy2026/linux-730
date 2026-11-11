#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal main) gnome-font-viewer
# 3.34.0-2 arm64 as kemi-gnome-font-viewer.
# No newer package in focal-updates, focal-security, or
# focal-backports. The gnome-font-viewer source ships only
# this one binary package in focal (no same-source
# -data/-common or exact-version library to bundle).
# Official libc / cairo / fontconfig / freetype /
# gdk-pixbuf / glib / gnome-desktop / GTK / harfbuzz /
# pango / pangocairo Depends stay Depends, unbundled.
# Official control has no Recommends and no Suggests.
# Versioned Provides: gnome-font-viewer (= 3.34.0-2).
# No Debian epoch, no tilde. Official
# /usr/bin/gnome-font-viewer and
# /usr/bin/gnome-thumbnail-font are real aarch64 ELFs
# and stay at the official path. /opt/gnome-font-viewer/*
# and /usr/bin/kemi-gnome-font-viewer are symlinks only
# (kemi-gnome-font-viewer → gnome-font-viewer). Official
# package ships no .mo (Ubuntu language-pack split; keep
# official tree; do not invent language packs). Official
# app icons are SVG only (hicolor scalable
# org.gnome.font-viewer.svg and symbolic). There is no
# official 256×256 PNG. A 128×128 evidence PNG rasterized
# from the official scalable SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/gnome-font-viewer-128.png and is used only as
# the mall CREATE --icon; it is not shipped in the deb.
# Official changelog.Debian.gz and NEWS.gz are real files
# and are copied with cp -L. Official desktop Name=Fonts
# is kept (mall app_name is GNOME Font Viewer). Official
# desktop Exec=gnome-font-viewer %u is rewritten to
# /usr/bin/gnome-font-viewer %u; TryExec is added; Icon=
# org.gnome.font-viewer. Official D-Bus Exec is already
# absolute and is kept. Official DBusActivatable=true is
# kept. Official thumbnailer Exec/TryExec are rewritten
# to /usr/bin/gnome-thumbnail-font. Official appdata and
# the official leftover X-GNOME-Bugzilla-Version=@VERSION@
# stay official. Official package has no maintainer
# scripts and no gschema; icon-cache and desktop-database
# hooks are added. Probe: arm64 · 2 unique packaged ELFs
# · requiredGlibc 2.17 (2 versioned, 0 null; do not
# invent a max from null) · no GLIBCXX (0 versioned, 2
# null; null is not ranked as a max) · no RUNPATH ·
# within 101 ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool files and the
# Ubuntu 20.04 focal main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL and
# no .buildinfo is recorded this run (pool 404). KEMI
# version 3.34.0-2kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded, including
# GNOME Characters 3.34.0-1kemi1 at 13). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-font-viewer
VER_UP=3.34.0-2
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-font-viewer
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/gnome-font-viewer_3.34.0-2_arm64.deb"
EXPECT_SHA=2a4695a4d65047de4f2e14558028de9666b176bb03933aa5490c5a2faf18e0e5
EXPECT_BYTES=49856
python3 -c 's="'"$VER_DEB"'"; assert len(s)==13, len(s); assert ":" not in s, s; print("version_name_len", len(s), s)'
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

if [ ! -x "$UNPACK/usr/bin/gnome-font-viewer" ]; then
  rm -rf "$UNPACK"
  mkdir -p "$UNPACK"
  dpkg-deb -x "$UP_DEB" "$UNPACK"
  dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"
fi

test -x "$UNPACK/usr/bin/gnome-font-viewer"
test -x "$UNPACK/usr/bin/gnome-thumbnail-font"
python3 - << 'END_GNOME_FONT_VIEWER_ELFCHECK'
from pathlib import Path
root = Path("/workspace/t142-20261112-gnome-font-viewer/unpack-official")
for rel in ("usr/bin/gnome-font-viewer", "usr/bin/gnome-thumbnail-font"):
    p = root / rel
    assert not p.is_symlink()
    assert p.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
    print("official_elf", rel, p.stat().st_size)
END_GNOME_FONT_VIEWER_ELFCHECK
test -f "$UNPACK/usr/share/applications/org.gnome.font-viewer.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.font-viewer.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.font-viewer.png"
test ! -L "$UNPACK/usr/share/doc/gnome-font-viewer/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-font-viewer/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-font-viewer/NEWS.gz"
test -f "$UNPACK/usr/share/doc/gnome-font-viewer/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -f "$ROOT/evidence/gnome-font-viewer-128.png"
python3 - << 'END_GNOME_FONT_VIEWER_EVIDENCE'
import struct
from pathlib import Path
p = Path("/workspace/t142-20261112-gnome-font-viewer/evidence/gnome-font-viewer-128.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (128, 128), (w, h)
print("evidence_128_for_create", w, h, p.stat().st_size)
END_GNOME_FONT_VIEWER_EVIDENCE

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-font-viewer"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
rm -rf "$STAGE/pkg/usr/DEBIAN" || true
chmod 0755 "$STAGE/pkg/usr/bin/gnome-font-viewer" "$STAGE/pkg/usr/bin/gnome-thumbnail-font"

REPORT="$ROOT/probe/kemi-gnome-font-viewer.json"
export STAGE_PKG="$STAGE/pkg"
export REPORT
python3 - << 'END_GNOME_FONT_VIEWER_PROBE'
import json, os, subprocess, sys
from pathlib import Path
root = Path(os.environ["STAGE_PKG"])
magic = bytes([0x7F]) + b"ELF"
elfs = []
seen = set()
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            rp = str(p.resolve())
            if rp not in seen:
                seen.add(rp)
                elfs.append(str(p))
if len(elfs) != 2:
    raise SystemExit("ELF_COUNT:" + ",".join(elfs))
want = {
    "/usr/bin/gnome-font-viewer",
    "/usr/bin/gnome-thumbnail-font",
}
got = {str(Path(e))[str(Path(e)).find("/usr/"):] for e in elfs}
if got != want:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
cmd = [
    sys.executable,
    "/workspace/t142-20261112-gnome-font-viewer/scripts/probe_elf.py",
    "--target-arch", "arm64",
    "--max-glibc", "2.31",
    "--report", os.environ["REPORT"],
]
for e in elfs:
    cmd.extend(["--elf", e])
subprocess.check_call(cmd)
rep = json.loads(Path(os.environ["REPORT"]).read_text())
files = rep.get("files") or []
if len(files) != 2:
    raise SystemExit("PROBE_FILE_COUNT")

def parse_ver(s):
    return tuple(int(x) for x in s.split("."))

glibc_vals = []
glibcxx_vals = []
glibc_versioned = glibc_null = 0
glibcxx_versioned = glibcxx_null = 0
for f in files:
    glibc = f.get("requiredGlibc")
    glibcxx = f.get("requiredGlibcxx")
    if glibc not in (None, "", []):
        glibc_versioned += 1
        glibc_vals.append(glibc)
    else:
        glibc_null += 1
    if glibcxx not in (None, "", []):
        glibcxx_versioned += 1
        glibcxx_vals.append(glibcxx)
    else:
        glibcxx_null += 1
    if f.get("architecture") not in {"aarch64", "arm64"}:
        raise SystemExit("ARCH:" + str(f.get("architecture")))
# None-safe: do not rank a null requiredGlibc/requiredGlibcxx as a max
max_glibc = max(glibc_vals, key=parse_ver) if glibc_vals else None
max_glibcxx = max(glibcxx_vals, key=parse_ver) if glibcxx_vals else None
if max_glibc != "2.17" or glibc_versioned != 2 or glibc_null != 0:
    raise SystemExit(f"GLIBC_UNEXPECTED:{max_glibc}:{glibc_versioned}:{glibc_null}")
if max_glibcxx is not None or glibcxx_versioned != 0 or glibcxx_null != 2:
    raise SystemExit(f"GLIBCXX_UNEXPECTED:{max_glibcxx}:{glibcxx_versioned}:{glibcxx_null}")
if not rep.get("configuredLimitsSatisfied"):
    raise SystemExit("LIMITS_NOT_SATISFIED")
for e in elfs:
    dyn = subprocess.check_output(["readelf", "-d", e], text=True)
    if "RUNPATH" in dyn or "(RPATH)" in dyn:
        raise SystemExit("UNEXPECTED_RUNPATH:" + e)
rep["nUniqueElf"] = 2
rep["maxVersionedGlibc"] = max_glibc
rep["maxVersionedGlibcxx"] = max_glibcxx
rep["glibcVersioned"] = glibc_versioned
rep["glibcNull"] = glibc_null
rep["glibcxxVersioned"] = glibcxx_versioned
rep["glibcxxNull"] = glibcxx_null
rep["note"] = (
    "2 unique packaged ELFs /usr/bin/gnome-font-viewer and "
    "/usr/bin/gnome-thumbnail-font; requiredGlibc 2.17 (2 versioned, 0 null); "
    "no GLIBCXX (0 versioned, 2 null; null is not ranked as a max); no RUNPATH; "
    "configuredLimitsSatisfied true vs 101"
)
Path(os.environ["REPORT"]).write_text(json.dumps(rep, indent=2) + "\n")
print(
    "PROBE_PASS n_elf=2 unique aarch64 glibc 2.17 (2 versioned, 0 null; no max invented from null) "
    "noGLIBCXX (0 versioned, 2 null; null not ranked as a max) noRUNPATH configuredLimitsSatisfied=true"
)
END_GNOME_FONT_VIEWER_PROBE

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.font-viewer.svg"
if find "$STAGE/pkg" -name 'gnome-font-viewer-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-font-viewer/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-font-viewer/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-font-viewer/NEWS.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.font-viewer.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.font-viewer.desktop"
export STAGE_THUMB="$STAGE/pkg/usr/share/thumbnailers/gnome-font-viewer.thumbnailer"
export UNPACK_THUMB="$UNPACK/usr/share/thumbnailers/gnome-font-viewer.thumbnailer"
export STAGE_PKG
python3 - << 'END_GNOME_FONT_VIEWER_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=gnome-font-viewer %u\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Name=Fonts" not in text or "Icon=org.gnome.font-viewer" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_UNEXPECTED_OFFICIAL_TRYEXEC")
text2 = re.sub(
    r"^Exec=gnome-font-viewer\b",
    "Exec=/usr/bin/gnome-font-viewer",
    text,
    flags=re.M,
)
text2 = re.sub(
    r"^Exec=/usr/bin/gnome-font-viewer.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-font-viewer",
    text2,
    count=1,
    flags=re.M,
)
for expect in (
    "Exec=/usr/bin/gnome-font-viewer %u",
    "TryExec=/usr/bin/gnome-font-viewer",
    "Icon=org.gnome.font-viewer",
    "Name=Fonts",
    "DBusActivatable=true",
    "X-GNOME-Bugzilla-Version=@VERSION@",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
for i, line in enumerate(text2.splitlines(), 1):
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-font-viewer"):
        raise SystemExit(f"DESKTOP_NONABS_EXEC:{i}:{line}")
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-font-viewer":
        raise SystemExit(f"DESKTOP_TRYEXEC:{i}:{line}")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_rewritten_tryexec_added")

bus = Path(os.environ["STAGE_PKG"]) / "usr/share/dbus-1/services/org.gnome.font-viewer.service"
bt = bus.read_text()
if "Exec=/usr/bin/gnome-font-viewer --gapplication-service" not in bt:
    raise SystemExit("DBUS_EXEC_UNEXPECTED")
print("dbus_exec_kept_absolute")

thumb = Path(os.environ["UNPACK_THUMB"]).read_text(encoding="utf-8")
if "Exec=gnome-thumbnail-font --size %s %u %o" not in thumb:
    raise SystemExit("THUMB_EXEC_UNEXPECTED")
if "TryExec=gnome-thumbnail-font" not in thumb:
    raise SystemExit("THUMB_TRYEXEC_UNEXPECTED")
thumb2 = re.sub(
    r"^TryExec=gnome-thumbnail-font\s*$",
    "TryExec=/usr/bin/gnome-thumbnail-font",
    thumb,
    flags=re.M,
)
thumb2 = re.sub(
    r"^Exec=gnome-thumbnail-font\b",
    "Exec=/usr/bin/gnome-thumbnail-font",
    thumb2,
    flags=re.M,
)
if "Exec=/usr/bin/gnome-thumbnail-font --size %s %u %o" not in thumb2:
    raise SystemExit("THUMB_ABS_EXEC_MISSING")
if "TryExec=/usr/bin/gnome-thumbnail-font" not in thumb2:
    raise SystemExit("THUMB_ABS_TRYEXEC_MISSING")
if "\\1" in thumb2:
    raise SystemExit("THUMB_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_THUMB"]).write_text(thumb2)
print("thumbnailer_exec_rewritten")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw.startswith(bytes([0x7F]) + b"ELF"):
        continue
    try:
        txt = raw.decode("utf-8")
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
END_GNOME_FONT_VIEWER_DESKTOP

python3 - << 'END_GNOME_FONT_VIEWER_DESKTOP_SRCCHECK'
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-font-viewer/scripts/build-gnome-font-viewer-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-font-viewer\\1"' in text:
    raise SystemExit("BAD_DESKTOP_REPLACEMENT")
if "Exec=/usr/bin/gnome-font-viewer" not in text:
    raise SystemExit("MISSING_ABS_EXEC_IN_SCRIPT")
if "m.group(0)" not in text:
    raise SystemExit("MISSING_GROUP0")
print("desktop_script_replacements_ok")
END_GNOME_FONT_VIEWER_DESKTOP_SRCCHECK

ln -sf /usr/bin/gnome-font-viewer "$STAGE/pkg/opt/gnome-font-viewer/gnome-font-viewer"
ln -sf /usr/bin/gnome-thumbnail-font "$STAGE/pkg/opt/gnome-font-viewer/gnome-thumbnail-font"
ln -sf gnome-font-viewer "$STAGE/pkg/usr/bin/kemi-gnome-font-viewer"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.gnome.org/gnome-3/
Source: official Ubuntu 20.04 focal main
Homepage: http://www.gnome.org/gnome-3/
License: see copyright.upstream
Official Ubuntu 20.04 (focal main) arm64 deb v${VER_UP}
(gnome-font-viewer_3.34.0-2_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-font-viewer_3.34.0-2_arm64.deb
    (focal main; no newer package in focal-updates,
    focal-security, or focal-backports) repackaged for
    KEMI as ${PKG}. Official libc / cairo / fontconfig /
    freetype / gdk-pixbuf / glib / gnome-desktop / GTK /
    harfbuzz / pango / pangocairo Depends stay Depends
    and are not bundled. Official control has no
    Recommends and no Suggests. Versioned Provides:
    gnome-font-viewer (= 3.34.0-2).
  * Official /usr/bin/gnome-font-viewer and
    /usr/bin/gnome-thumbnail-font are aarch64 ELFs and
    stay under /usr. /opt/gnome-font-viewer/* are
    symlinks. Also /usr/bin/kemi-gnome-font-viewer →
    gnome-font-viewer.
  * Official package ships no .mo (keep official; do
    not invent language packs). Official app icons are
    SVG only; a 128×128 evidence PNG rasterized from
    the official scalable SVG is used only for mall
    CREATE --icon and is not packed in the deb.
  * Official changelog is a real file and was copied
    with cp -L. Official desktop Exec=gnome-font-viewer
    %u is rewritten to /usr/bin/gnome-font-viewer %u;
    TryExec added; Icon=org.gnome.font-viewer; Name=
    Fonts. Official D-Bus Exec is already absolute and
    is kept. Official thumbnailer Exec/TryExec are
    rewritten to /usr/bin/gnome-thumbnail-font.
    Official leftover X-GNOME-Bugzilla-Version=@VERSION@
    is kept official. Icon-cache and desktop-database
    hooks are added (official package has no maintainer
    scripts and no gschema).

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Font Viewer ${VER_UP} — official Ubuntu 20.04
(focal main) arm64, KEMI repack.

Official /usr/bin/gnome-font-viewer and
/usr/bin/gnome-thumbnail-font are aarch64 ELFs and
stay under /usr. /opt/gnome-font-viewer/* are
symlinks. Official libc / cairo / fontconfig /
freetype / GTK / pango Depends stay Depends and are
not bundled. Official control has no Recommends and
no Suggests. Official package ships no .mo. Official
icons are SVG only; a 128×128 evidence PNG is used
only as mall CREATE --icon and is not packed. Probe:
2 unique ELFs · requiredGlibc 2.17 (2 versioned, 0
null; no max invented from null) · no
requiredGlibcxx (0 versioned, 2 null; null not
ranked as a max) · no RUNPATH; within Ubuntu 20.04 /
glibc 2.31. Official publication: Ubuntu 20.04 focal
main gnome-font-viewer 3.34.0-2 (arm64). Official
SHA256 + size matched ports.ubuntu.com pool files
and the focal main arm64 Packages stanza. No
librarian URL this run.
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
Depends: libc6 (>= 2.17), libcairo2 (>= 1.14.0), libfontconfig1 (>= 2.12.6), libfreetype6 (>= 2.2.1), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.4), libgnome-desktop-3-19 (>= 3.17.92), libgtk-3-0 (>= 3.20.0), libharfbuzz0b (>= 0.9.9), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.22.0)
Replaces: gnome-font-viewer
Conflicts: gnome-font-viewer
Provides: gnome-font-viewer (= 3.34.0-2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.gnome.org/gnome-3/
Description: font viewer for GNOME
 GNOME Font Viewer ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
 glibc≤2.31 (Ubuntu 20.04).
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
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
grep -q 'Version: 3.34.0-2kemi1' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
grep -q 'Provides: gnome-font-viewer (= 3.34.0-2)' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-font-viewer-control.txt"

python3 - << END_GNOME_FONT_VIEWER_TREE
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gnome-font-viewer",
    "./usr/bin/gnome-thumbnail-font",
    "./usr/bin/kemi-gnome-font-viewer",
    "./opt/gnome-font-viewer/gnome-font-viewer",
    "./opt/gnome-font-viewer/gnome-thumbnail-font",
    "./usr/share/applications/org.gnome.font-viewer.desktop",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.font-viewer.svg",
    "./usr/share/dbus-1/services/org.gnome.font-viewer.service",
    "./usr/share/thumbnailers/gnome-font-viewer.thumbnailer",
    "./usr/share/metainfo/org.gnome.font-viewer.appdata.xml",
    "./usr/share/doc/kemi-gnome-font-viewer/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gnome-font-viewer-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = found_thumb = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/gnome-font-viewer " in line or line.rstrip().endswith("./usr/bin/gnome-font-viewer")) and "kemi-gnome-font-viewer" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/gnome-thumbnail-font" in line:
        found_thumb = True
        if "->" in line:
            raise SystemExit("THUMB_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-gnome-font-viewer" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_thumb:
    raise SystemExit("MISSING_THUMB")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
END_GNOME_FONT_VIEWER_TREE
echo "BUILD_OK $DEB"
