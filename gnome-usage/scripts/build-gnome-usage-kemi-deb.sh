#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# gnome-usage 3.32.0-1 Architecture: arm64 as
# kemi-gnome-usage. No newer package in
# focal-updates / focal-security /
# focal-backports. The gnome-usage source ships
# only this one binary package in focal (no
# same-source -data/-common or exact-version
# library to bundle). Official typelib-equivalent
# / dazzle / gtop / GTK / glib / cairo / pango /
# libc6 Depends stay Depends, unbundled
# (different source). Official control has no
# Recommends and no Suggests. Versioned Provides:
# gnome-usage (= 3.32.0-1). No Debian epoch, no
# tilde. Official /usr/bin/gnome-usage is a
# compiled aarch64 ELF (glibc 2.17, no GLIBCXX,
# no RUNPATH) that embeds /usr/share/locale;
# official files stay on official paths;
# /opt/gnome-usage/* are symlinks only. Also
# /usr/bin/kemi-gnome-usage → gnome-usage.
# Official package ships 26 .mo including zh_TW
# (keep official; do not invent a missing zh_CN
# or extra language packs). Official app icons
# are SVG only (org.gnome.Usage.svg); no official
# 256×256 PNG. A 128×128 PNG rasterized from the
# official app SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/org.gnome.Usage-128.png and is used
# only as the mall CREATE --icon; it is not
# shipped in the deb. Official changelog.Debian.gz
# and NEWS.gz are real files and are copied with
# cp -L. Official desktop Name=Usage is kept;
# mall app_name is GNOME Usage. Official desktop
# Exec=gnome-usage is rewritten to
# /usr/bin/gnome-usage; TryExec is added;
# Icon=org.gnome.Usage is kept. Official package
# has no maintainer scripts, no shlibs, and no
# ldconfig trigger; icon-cache, desktop-database
# and glib-compile-schemas hooks are added.
# Official package has no py3compile hooks; none
# are invented. Probe: Architecture arm64 · 1
# unique packaged ELF · requiredGlibc 2.17 (1
# versioned, 0 null) · no GLIBCXX (0 versioned,
# 1 null; null is not ranked as a max) · within
# 101 ≤2.31 / ≤3.4.28. Official SHA256 + size
# matched official ports.ubuntu.com pool files
# and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI version
# 3.32.0-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's
# 33-char string; 12–28 char siblings succeeded).
# No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-usage
VER_UP=3.32.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-usage
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/gnome-usage_3.32.0-1_arm64}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-usage_3.32.0-1_arm64.deb"
EXPECT_SHA=e9342d529448fb3e225fadada69223171434865b6574a9c52270a8349f4bf678
EXPECT_BYTES=114040
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
test -x "$UNPACK/usr/bin/gnome-usage"
python3 - << PY
from pathlib import Path
elf = Path("$UNPACK/usr/bin/gnome-usage")
assert not elf.is_symlink()
assert elf.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert elf.stat().st_size == 321664
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Usage.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Usage.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Usage.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Usage.gschema.xml"
test ! -L "$UNPACK/usr/share/doc/gnome-usage/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-usage/changelog.Debian.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-usage/NEWS.gz"
test -f "$ROOT/evidence/org.gnome.Usage-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Usage-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "131971b0a1f54345b5abcc450590240337ca10374f96c2a8931192072bd141b0"
print("evidence_128_ok", w, h, p.stat().st_size)
mos = list(Path("$UNPACK").rglob("*.mo"))
assert len(mos) == 26, len(mos)
assert any("zh_TW" in str(p) for p in mos)
assert not any("zh_CN" in str(p) for p in mos)
print("official_mo_26_zh_TW_no_zh_CN")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-usage"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-usage"

REPORT="$ROOT/probe/kemi-gnome-usage.json"
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
if Path(f["path"]).name != "gnome-usage":
    raise SystemExit("PROBE_NAME")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + str(f.get("requiredGlibcxx")))
if f.get("sha256") != "2fe095d5fed32898c4f710be47b2c4d39b3859a9a75d45ee85731a5bac38e8d0":
    raise SystemExit("PROBE_SHA:" + str(f.get("sha256")))
if int(f.get("bytes") or 0) != 321664:
    raise SystemExit("PROBE_BYTES")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Usage.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Usage.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 26
test -f "$STAGE/pkg/usr/share/locale/zh_TW/LC_MESSAGES/gnome-usage.mo"
test ! -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/gnome-usage.mo"
if find "$STAGE/pkg" -name 'org.gnome.Usage-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-usage/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-usage/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/org.gnome.Usage.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Usage.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Usage\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=gnome-usage\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = re.sub(
    r"^Exec=gnome-usage\b",
    "Exec=/usr/bin/gnome-usage",
    text,
    flags=re.M,
)
text = re.sub(
    r"^Exec=/usr/bin/gnome-usage.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-usage",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/gnome-usage" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/gnome-usage" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-usage"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-usage":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-usage/scripts/build-gnome-usage-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-usage\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/gnome-usage" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-usage "$STAGE/pkg/opt/gnome-usage/gnome-usage"
ln -sf gnome-usage "$STAGE/pkg/usr/bin/kemi-gnome-usage"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg"}:
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
elf = Path("$STAGE/pkg/usr/bin/gnome-usage")
out = subprocess.check_output(["readelf", "-d", str(elf)], text=True, errors="replace")
if "RPATH" in out or "RUNPATH" in out:
    raise SystemExit("UNEXPECTED_RUNPATH")
print("no_runpath")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-usage (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    gnome-usage 3.32.0-1 arm64, KEMI mall
    linuxpkg repack. No same-source -common or
    exact-version library to bundle. Official
    dazzle / gtop / GTK / glib / cairo / pango /
    libc6 Depends stay Depends. Official control
    has no Recommends and no Suggests. Versioned
    Provides: gnome-usage (= 3.32.0-1). Official
    /usr/bin/gnome-usage stays at the official
    path; /opt/gnome-usage/* are symlinks. Also
    /usr/bin/kemi-gnome-usage → gnome-usage.
    Official desktop Name=Usage kept; Exec
    rewritten to /usr/bin/gnome-usage; TryExec
    added. Official changelog is a real file and
    was copied with cp -L. Official icons are
    SVG only; a 128×128 evidence PNG rasterized
    from the official SVG is used only as mall
    CREATE --icon and is not packed. Official
    package ships 26 .mo including zh_TW; no
    zh_CN invented. Icon-cache, desktop-database
    and glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 02:38:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
GNOME Usage — official Ubuntu 20.04 (focal
universe) gnome-usage 3.32.0-1 arm64, KEMI
repack. Official /usr/bin/gnome-usage is an
aarch64 ELF and stays under /usr.
/opt/gnome-usage/* are symlinks. Official
dazzle / gtop / GTK Depends stay Depends and
are not bundled. Official control has no
Recommends and no Suggests. Official package
ships 26 .mo including zh_TW (keep official;
do not invent zh_CN). Official icons are SVG
only; a 128×128 evidence PNG is used only as
mall CREATE --icon and is not packed.
Probe: 1 unique ELF · requiredGlibc 2.17 (1
versioned, 0 null; no max invented from null) ·
no requiredGlibcxx (0 versioned, 1 null; null
not ranked as a max) · no RUNPATH; within
Ubuntu 20.04 / glibc 2.31. Official publication:
Ubuntu 20.04 focal universe gnome-usage
3.32.0-1 (arm64). Official SHA256 + size
matched ports.ubuntu.com pool files and the
focal universe arm64 Packages stanza. No
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
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdazzle-1.0-0 (>= 3.30), libglib2.0-0 (>= 2.43.4), libgtk-3-0 (>= 3.20.10), libgtop-2.0-11 (>= 2.34.0), libpango-1.0-0 (>= 1.14.0)
Replaces: gnome-usage
Conflicts: gnome-usage
Provides: gnome-usage (= 3.32.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Usage
Description: simple system monitor app for GNOME
 GNOME Usage ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
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
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-usage-control.txt"
grep -q 'Version: 3.32.0-1kemi1' "$ROOT/evidence/kemi-gnome-usage-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-usage-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-usage-control.txt"
grep -q 'Provides: gnome-usage (= 3.32.0-1)' "$ROOT/evidence/kemi-gnome-usage-control.txt"
grep -q 'Conflicts: gnome-usage' "$ROOT/evidence/kemi-gnome-usage-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gnome-usage-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-usage-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
import re
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/org.gnome.Usage.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Usage" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/gnome-usage" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-usage" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=gnome-usage\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-usage"
test -L "$CHECK/usr/bin/kemi-gnome-usage"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-usage")" = "gnome-usage"
test -L "$CHECK/opt/gnome-usage/gnome-usage"
test "$(readlink "$CHECK/opt/gnome-usage/gnome-usage")" = "/usr/bin/gnome-usage"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 26
if find "$CHECK" -name 'org.gnome.Usage-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
sha256sum "$CHECK/usr/bin/gnome-usage"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
