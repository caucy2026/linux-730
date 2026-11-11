#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# yelp 3.36.2-0ubuntu1.1 Architecture: arm64 as
# kemi-yelp, bundling same-source exact-version
# hard Depends libyelp0 (= 3.36.2-0ubuntu1.1).
# The same official stanza is also in
# focal-security main; newer than focal Release
# 3.36.0-1 and still Ubuntu 20.04 deps
# (libc6 >= 2.17). Official libyelp-dev is
# same-source but is not a GUI hard Depends; it
# was inspected and is not packaged (headers,
# gtk-doc, dangling .so / changelog symlinks).
# Official yelp-xsl (>= 3.27.1) is a different
# source and stays Depends, unbundled. Official
# typelib-equivalent / webkit / GTK / glib /
# soup / xml / xslt / lzma / bz2 / sqlite /
# python3-distro / man-db Depends stay Depends.
# Official Recommends docbook-xml stays
# Recommends / unbundled. Official control has
# no Suggests. Versioned Provides: yelp
# (= 3.36.2-0ubuntu1.1), libyelp0
# (= 3.36.2-0ubuntu1.1). No Debian epoch, no
# tilde. Official /usr/bin/yelp is a compiled
# aarch64 ELF (glibc 2.17, no GLIBCXX, no
# RUNPATH) that embeds /usr/share/locale;
# official libyelp.so.0 and
# libyelpwebextension.so stay at official
# paths (embed /usr/share/yelp and
# /usr/lib/aarch64-linux-gnu/yelp/web-extensions).
# Official /usr/bin/gnome-help is a symlink to
# yelp and is kept. Official files stay on
# official paths; /opt/yelp/* are symlinks
# only. Also /usr/bin/kemi-yelp → yelp.
# Official packages ship no .mo (Ubuntu
# language-pack split); keep official tree;
# do not invent packs. Official app icons are
# SVG only (org.gnome.Yelp.svg + symbolic);
# no official 256×256 PNG. Official in-app
# 16×16 / scalable status icons under
# /usr/share/yelp/icons stay official. A
# 128×128 PNG rasterized from the official
# app SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/org.gnome.Yelp-128.png and is used
# only as the mall CREATE --icon; it is not
# shipped in the deb. Official GUI
# changelog.Debian.gz is a dangling symlink
# into the same-source lib doc dir; because
# libyelp0 is bundled at its official doc
# path, the official symlink is kept and
# resolves; the real official lib changelog is
# also copied with cp -L into the kemi doc
# dir. Official desktop Name=Help is kept;
# mall app_name is Yelp. Official desktop
# Exec=yelp %u is rewritten to
# /usr/bin/yelp %u; TryExec is added;
# Icon=org.gnome.Yelp, OnlyShowIn=GNOME;Unity;
# and MimeType are kept. Official packages
# have no maintainer scripts; official
# libyelp0 shlibs, symbols, and
# activate-noawait ldconfig trigger are kept;
# icon-cache, desktop-database and
# glib-compile-schemas hooks are added.
# Official packages have no py3compile hooks;
# none are invented. Probe: Architecture
# arm64 · 3 unique packaged ELFs ·
# requiredGlibc 2.17 (3 versioned, 0 null) ·
# no GLIBCXX (0 versioned, 3 null; null is
# not ranked as a max) · within 101 ≤2.31 /
# ≤3.4.28. Official SHA256 + size matched
# official ports.ubuntu.com pool files and
# the Ubuntu 20.04 focal-updates main arm64
# Packages stanza (Aliyun ubuntu-ports
# mirror, streamed; same stanza in
# focal-security main). No librarian URL and
# no .buildinfo is recorded this run (pool
# 404). KEMI version 3.36.2-0ubuntu1.1kemi1
# is 22 chars (under the mall version_name
# limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded).
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-yelp
VER_UP=3.36.2-0ubuntu1.1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-yelp
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/yelp_3.36.2-0ubuntu1.1_arm64}"
LIB="${LIB:-$ROOT/unpack-official/libyelp0_3.36.2-0ubuntu1.1_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/yelp_3.36.2-0ubuntu1.1_arm64.deb"
UP_LIB="$DL/libyelp0_3.36.2-0ubuntu1.1_arm64.deb"
EXPECT_SHA=077aadcbdf60eafff23070037ab8162eac1bb43ccfbd016168c6fc03740ca972
EXPECT_BYTES=525776
EXPECT_LIB_SHA=85f97ac75ffed9ad6542dc0ade936b20d0f26cfdf9ac137385eab0742f86f201
EXPECT_LIB_BYTES=87472
python3 - << PY
s="${VER_DEB}"
assert len(s) == 22, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB" && test -f "$UP_LIB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_LIB")" = "$EXPECT_LIB_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_LIB_SHA  $UP_LIB" | sha256sum -c -
test -x "$UNPACK/usr/bin/yelp"
test -L "$UNPACK/usr/bin/gnome-help"
test "$(readlink "$UNPACK/usr/bin/gnome-help")" = "yelp"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/bin/yelp")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 59400
lib = Path("$LIB/usr/lib/aarch64-linux-gnu/libyelp.so.0.0.0")
assert not lib.is_symlink()
assert lib.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert lib.stat().st_size == 248576
ext = Path("$LIB/usr/lib/aarch64-linux-gnu/yelp/web-extensions/libyelpwebextension.so")
assert not ext.is_symlink()
assert ext.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert ext.stat().st_size == 63896
print("official_elfs_ok")
PY
test -f "$UNPACK/usr/share/applications/yelp.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Yelp.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Yelp.png"
test ! -f "$LIB/usr/share/icons/hicolor/256x256/apps/org.gnome.Yelp.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.yelp.gschema.xml"
test -L "$UNPACK/usr/share/doc/yelp/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/yelp/changelog.Debian.gz"
test ! -L "$LIB/usr/share/doc/libyelp0/changelog.Debian.gz"
test -f "$LIB/usr/share/doc/libyelp0/changelog.Debian.gz"
test -f "$LIB/DEBIAN/shlibs"
test -f "$LIB/DEBIAN/symbols"
test -f "$LIB/DEBIAN/triggers"
test -f "$ROOT/evidence/org.gnome.Yelp-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Yelp-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "e21f2737355027127b67bffc631f5b158514f888b1693c2c4b1ca89b354b7366"
print("evidence_128_ok", w, h, p.stat().st_size)
from pathlib import Path as P
for root in ("$UNPACK", "$LIB"):
    mos = list(P(root).rglob("*.mo"))
    assert mos == [], mos
print("official_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/yelp"

# bundle official exact-version lib first, then official GUI
cp -a "$LIB/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/yelp"
# official library packaging metadata
cp -a "$LIB/DEBIAN/shlibs" "$STAGE/pkg/DEBIAN/shlibs"
cp -a "$LIB/DEBIAN/symbols" "$STAGE/pkg/DEBIAN/symbols"
cp -a "$LIB/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"
# official GUI changelog symlink now resolves into bundled lib doc
test -L "$STAGE/pkg/usr/share/doc/yelp/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/yelp/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/libyelp0/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/bin/gnome-help"
test "$(readlink "$STAGE/pkg/usr/bin/gnome-help")" = "yelp"

REPORT="$ROOT/probe/kemi-yelp.json"
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
by_name = {Path(f["path"]).name: f for f in files}
expect = {
    "yelp": ("c3edc82a9b4d10791ee7d2b035355b3dc8d0fbf78d7533cc868338dca7898ca2", 59400),
    "libyelp.so.0.0.0": ("f71240324193f7d8d73e06e2e015270ef374b40873cdeb10b87e8b3412b4c37a", 248576),
    "libyelpwebextension.so": ("ad60cbefa18933f0ffe07831b98152c3bcc1d387058b50f78a4101f5e26ec18f", 63896),
}
if set(by_name) != set(expect):
    raise SystemExit("PROBE_NAMES:" + ",".join(sorted(by_name)))
for name, (sha, nbytes) in expect.items():
    f = by_name[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH:" + name)
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit("PROBE_GLIBC:" + name + ":" + str(f.get("requiredGlibc")))
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + name)
    if f.get("sha256") != sha:
        raise SystemExit("PROBE_SHA:" + name)
    if int(f.get("bytes") or 0) != nbytes:
        raise SystemExit("PROBE_BYTES:" + name)
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 3 or len(nulls) != 0 or cxx or len(cxx_null) != 3:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
# official gnome-help is a symlink, not an ELF
gh = Path("$STAGE/pkg/usr/bin/gnome-help")
if not gh.is_symlink():
    raise SystemExit("GNOME_HELP_NOT_SYMLINK")
print("PROBE_PASS n_elf=3 unique aarch64 glibc=2.17 (3 versioned, 0 null) noGLIBCXX (0 versioned, 3 null; null not ranked as a max) official gnome-help symlink not ELF configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Yelp.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Yelp.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'org.gnome.Yelp-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# libyelp-dev must not be staged
test ! -e "$STAGE/pkg/usr/include/libyelp" -a ! -d "$STAGE/pkg/usr/share/gtk-doc/html/libyelp"
test ! -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libyelp.so" -o ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libyelp.so"
# the runtime SONAME symlink must exist
test -L "$STAGE/pkg/usr/lib/aarch64-linux-gnu/libyelp.so.0"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/yelp/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$LIB/usr/share/doc/libyelp0/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/yelp.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/yelp.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Help\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=yelp %u\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = re.sub(
    r"^Exec=yelp\b",
    "Exec=/usr/bin/yelp",
    text,
    flags=re.M,
)
text = re.sub(
    r"^Exec=/usr/bin/yelp.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/yelp",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/yelp %u" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/yelp" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
if "OnlyShowIn=GNOME;Unity;" not in text:
    raise SystemExit("DESKTOP_ONLYSHOWIN")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/yelp"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/yelp":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-yelp/scripts/build-yelp-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/yelp\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/yelp" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/yelp "$STAGE/pkg/opt/yelp/yelp"
ln -sf /usr/bin/gnome-help "$STAGE/pkg/opt/yelp/gnome-help"
ln -sf yelp "$STAGE/pkg/usr/bin/kemi-yelp"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".woff"} or p.name.endswith(".typelib"):
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        bad.append(("elf", str(p)))
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        bad.append(("bin", str(p)))
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "x86_64" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

python3 - << PY
import subprocess
from pathlib import Path
root = Path("$STAGE/pkg")
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.read_bytes()[:4] != bytes([0x7F]) + b"ELF":
        continue
    out = subprocess.check_output(["readelf", "-d", str(p)], text=True, errors="replace")
    if "RPATH" in out or "RUNPATH" in out:
        raise SystemExit("UNEXPECTED_RUNPATH:" + str(p))
print("no_runpath")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-yelp (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    yelp 3.36.2-0ubuntu1.1 arm64, KEMI mall
    linuxpkg repack. Same stanza also in
    focal-security main; newer than focal
    Release 3.36.0-1. Same-source exact-version
    hard Depends libyelp0 (= 3.36.2-0ubuntu1.1)
    bundled (libyelp.so.0 and
    libyelpwebextension.so). Official
    libyelp-dev inspected and not packaged.
    Official yelp-xsl / webkit / GTK / glib /
    python3-distro / man-db Depends stay
    Depends. Official Recommends docbook-xml
    stays Recommends. Official control has no
    Suggests. Versioned Provides: yelp
    (= 3.36.2-0ubuntu1.1), libyelp0
    (= 3.36.2-0ubuntu1.1). Official
    /usr/bin/yelp stays at the official path;
    official gnome-help symlink kept;
    /opt/yelp/* are symlinks. Also
    /usr/bin/kemi-yelp → yelp. Official desktop
    Name=Help kept; Exec rewritten to
    /usr/bin/yelp %u; TryExec added. Official
    GUI changelog symlink into bundled lib doc
    is kept (resolves); real official lib
    changelog also copied with cp -L into the
    kemi doc dir. Official icons are SVG only;
    a 128×128 evidence PNG rasterized from the
    official SVG is used only as mall CREATE
    --icon and is not packed. Official packages
    ship no .mo; none invented. Official
    libyelp0 shlibs / symbols / ldconfig
    trigger kept. Icon-cache, desktop-database
    and glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 02:31:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Yelp — official Ubuntu 20.04 (focal-updates main)
yelp 3.36.2-0ubuntu1.1 arm64, KEMI repack.
Official /usr/bin/yelp, libyelp.so.0 and
libyelpwebextension.so are aarch64 ELFs and
stay under /usr. /opt/yelp/* are symlinks.
Same-source libyelp0 (= 3.36.2-0ubuntu1.1) is
bundled. Official yelp-xsl / webkit / GTK
Depends stay Depends and are not bundled.
Official Recommends docbook-xml stays
Recommends. Official package ships no .mo.
Official icons are SVG only; a 128×128
evidence PNG is used only as mall CREATE
--icon and is not packed.
Probe: 3 unique ELFs · requiredGlibc 2.17 (3
versioned, 0 null; no max invented from null) ·
no requiredGlibcxx (0 versioned, 3 null; null
not ranked as a max) · no RUNPATH; within
Ubuntu 20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal-updates main yelp
3.36.2-0ubuntu1.1 (arm64); same stanza in
focal-security main. Official SHA256 + size
matched ports.ubuntu.com pool files and the
focal-updates main arm64 Packages stanza. No
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
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.39.90), libgtk-3-0 (>= 3.13.3), libwebkit2gtk-4.0-37 (>= 2.19.2), libbz2-1.0, liblzma5 (>= 5.1.1alpha+20120614), libsoup2.4-1 (>= 2.30.0), libsqlite3-0 (>= 3.5.9), libxml2 (>= 2.7.4), libxslt1.1 (>= 1.1.25), dconf-gsettings-backend | gsettings-backend, python3-distro, yelp-xsl (>= 3.27.1), man-db (>= 2.5.1-1)
Recommends: docbook-xml
Replaces: yelp, libyelp0
Conflicts: yelp, libyelp0
Provides: yelp (= 3.36.2-0ubuntu1.1), libyelp0 (= 3.36.2-0ubuntu1.1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Yelp
Description: Help browser for GNOME
 Yelp ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack. Bundles official
 libyelp0.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
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
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
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
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'activate-noawait ldconfig' "$STAGE/pkg/DEBIAN/triggers"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'Version: 3.36.2-0ubuntu1.1kemi1' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'Provides: yelp (= 3.36.2-0ubuntu1.1)' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'libyelp0 (= 3.36.2-0ubuntu1.1)' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'Conflicts: yelp, libyelp0' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'Recommends: docbook-xml' "$ROOT/evidence/kemi-yelp-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-yelp-control.txt"
! grep -q 'libyelp-dev' "$ROOT/evidence/kemi-yelp-control.txt"
! grep -E '^ Depends:.*libyelp0 \(=' "$ROOT/evidence/kemi-yelp-control.txt"
grep -q 'yelp-xsl (>= 3.27.1)' "$ROOT/evidence/kemi-yelp-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/yelp.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Help" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/yelp %u" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/yelp" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re_search := __import__("re").search(r"^Exec=yelp\b", desk, flags=__import__("re").M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/yelp"
test -L "$CHECK/usr/bin/kemi-yelp"
test "$(readlink "$CHECK/usr/bin/kemi-yelp")" = "yelp"
test -L "$CHECK/usr/bin/gnome-help"
test "$(readlink "$CHECK/usr/bin/gnome-help")" = "yelp"
test -L "$CHECK/opt/yelp/yelp"
test "$(readlink "$CHECK/opt/yelp/yelp")" = "/usr/bin/yelp"
test -f "$CHECK/usr/lib/aarch64-linux-gnu/libyelp.so.0.0.0"
test -f "$CHECK/usr/lib/aarch64-linux-gnu/yelp/web-extensions/libyelpwebextension.so"
if find "$CHECK" -name 'org.gnome.Yelp-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -d "$CHECK/usr/share/gtk-doc/html/libyelp"
sha256sum "$CHECK/usr/bin/yelp"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
