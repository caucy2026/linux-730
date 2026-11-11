#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe) synaptic
# 0.84.6ubuntu5 arm64 as kemi-synaptic.
# No newer package in focal-updates, focal-security, or
# focal-backports. The synaptic source ships only this
# one binary package in focal (no same-source
# -data/-common or exact-version library to bundle).
# Official Depends (libapt-pkg6.0, libc6, libept1.6.0,
# libgcc-s1, libgdk-pixbuf2.0-0, libglib2.0-0,
# libgtk-3-0, libpango-1.0-0, libstdc++6, libvte-2.91-0,
# libxapian30, hicolor-icon-theme, policykit-1) stay
# Depends, unbundled. Official Recommends (libgtk3-perl,
# xdg-utils) stay Recommends, unbundled. Official
# Suggests (dwww, menu, deborphan, apt-xapian-index,
# tasksel, software-properties-gtk) stay Suggests,
# unbundled. Official Conflicts: menu (<< 2.1.11) is
# kept; also Conflicts/Replaces the official synaptic
# name. Versioned Provides: synaptic (= 0.84.6ubuntu5).
# No Debian epoch, no tilde. Official /usr/sbin/synaptic
# is a real aarch64 ELF and stays at the official path.
# Official /usr/bin/synaptic-pkexec is a shell wrapper
# (not an ELF) and stays official. /opt/synaptic/* and
# /usr/bin/kemi-synaptic are symlinks only
# (kemi-synaptic → synaptic-pkexec, the official
# user-facing launcher). Official package ships no .mo
# (Ubuntu language-pack split; keep official tree; do
# not invent language packs). Official non-C GNOME help
# may be help-langpack symlinks; those official dangling
# symlinks are kept; language packs are not invented.
# Official app icon is the 48×48 pixmap
# /usr/share/pixmaps/synaptic.png. There is no official
# hicolor apps/ icon, no official 256×256, and no
# official SVG. Official 16×16/24×24 hicolor PNGs are
# in-app action icons. Official in-app / gtkbuilder /
# help-media PNGs stay official. The official 48×48
# pixmap is used only as the mall CREATE --icon
# (copied to evidence/; not packed a second time). Do
# not invent a packaged icon or a 128 raster. Official
# changelog.gz, NEWS.gz and NEWS.Debian.gz are real
# files and are copied with cp -L. Official desktop
# Name=Synaptic Package Manager is kept (mall app_name
# is Synaptic). Official desktop Exec=synaptic-pkexec
# is rewritten to /usr/bin/synaptic-pkexec; TryExec is
# added (official has no TryExec; official is not
# TryExec=pkexec). Official PolicyKit exec.path=
# /usr/sbin/synaptic is already absolute and is kept.
# Official pkexec wrapper already uses an absolute
# /usr/sbin/synaptic path and is kept. Official
# update-menus hooks and the official postrm purge of
# /etc/apt/apt.conf.d/99synaptic are kept; icon-cache
# and desktop-database hooks are added. Probe: arm64
# · 1 unique packaged ELF · requiredGlibc 2.17 (1
# versioned, 0 null; do not invent a max from null) ·
# requiredGlibcxx 3.4.21 (1 versioned, 0 null) · no
# RUNPATH · within 101 ≤2.31 / ≤3.4.28. Official
# SHA256 + size matched official ports.ubuntu.com pool
# files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no .buildinfo is
# recorded this run (pool 404). KEMI version
# 0.84.6ubuntu5kemi1 is 18 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-synaptic
VER_UP=0.84.6ubuntu5
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-synaptic
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
UP_DEB="$DL/synaptic_0.84.6ubuntu5_arm64.deb"
EXPECT_SHA=54cf8c99e877ed1cf1b3d77c876cfe34d78677a13f5ae78a79e57b1802b12a89
EXPECT_BYTES=589424
python3 - << 'END_SYNAPTIC_VERSION'
import os
s = os.environ.get("VER_DEB_CHECK", "")
END_SYNAPTIC_VERSION
python3 -c 's="'"$VER_DEB"'"; assert len(s)==18, len(s); assert ":" not in s, s; print("version_name_len", len(s), s)'
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

if [ ! -x "$UNPACK/usr/sbin/synaptic" ]; then
  rm -rf "$UNPACK"
  mkdir -p "$UNPACK"
  dpkg-deb -x "$UP_DEB" "$UNPACK"
  dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"
fi

test -x "$UNPACK/usr/sbin/synaptic"
test -x "$UNPACK/usr/bin/synaptic-pkexec"
python3 - << 'END_SYNAPTIC_ELFCHECK'
from pathlib import Path
p = Path("/workspace/t142-20261112-synaptic/unpack-official/usr/sbin/synaptic")
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
w = Path("/workspace/t142-20261112-synaptic/unpack-official/usr/bin/synaptic-pkexec")
assert not w.is_symlink()
assert w.read_bytes().startswith(b"#!")
print("official_elf_and_wrapper", p.stat().st_size, w.stat().st_size)
END_SYNAPTIC_ELFCHECK
test -f "$UNPACK/usr/share/applications/synaptic.desktop"
test -f "$UNPACK/usr/share/pixmaps/synaptic.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/synaptic.png"
test ! -e "$UNPACK/usr/share/icons/hicolor/scalable/apps/synaptic.svg"
test ! -L "$UNPACK/usr/share/doc/synaptic/changelog.gz"
test -f "$UNPACK/usr/share/doc/synaptic/changelog.gz"
test ! -L "$UNPACK/usr/share/doc/synaptic/NEWS.gz"
test -f "$UNPACK/usr/share/doc/synaptic/NEWS.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -f "$ROOT/evidence/synaptic-official-48.png"
python3 - << 'END_SYNAPTIC_EVIDENCE'
import struct
from pathlib import Path
p = Path("/workspace/t142-20261112-synaptic/evidence/synaptic-official-48.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (48, 48), (w, h)
print("evidence_official_48_for_create", w, h, p.stat().st_size)
END_SYNAPTIC_EVIDENCE
grep -q 'org.freedesktop.policykit.exec.path">/usr/sbin/synaptic<' \
  "$UNPACK/usr/share/polkit-1/actions/com.ubuntu.pkexec.synaptic.policy"
grep -qx 'pkexec "/usr/sbin/synaptic" "$@"' "$UNPACK/usr/bin/synaptic-pkexec" \
  || grep -q 'pkexec "/usr/sbin/synaptic"' "$UNPACK/usr/bin/synaptic-pkexec"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/sbin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/synaptic"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
if [ -d "$UNPACK/var" ]; then
  mkdir -p "$STAGE/pkg/var"
  cp -a "$UNPACK/var/." "$STAGE/pkg/var/"
fi
chmod 0755 "$STAGE/pkg/usr/sbin/synaptic" "$STAGE/pkg/usr/bin/synaptic-pkexec"
rm -rf "$STAGE/pkg/usr/DEBIAN" || true

REPORT="$ROOT/probe/kemi-synaptic.json"
export STAGE_PKG="$STAGE/pkg"
export REPORT
python3 - << 'END_SYNAPTIC_PROBE'
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
if len(elfs) != 1:
    raise SystemExit("ELF_COUNT:" + ",".join(elfs))
if not str(Path(elfs[0])).endswith("/usr/sbin/synaptic"):
    raise SystemExit("UNEXPECTED_ELF:" + elfs[0])
cmd = [
    sys.executable,
    "/workspace/t142-20261112-synaptic/scripts/probe_elf.py",
    "--target-arch", "arm64",
    "--max-glibc", "2.31",
    "--report", os.environ["REPORT"],
    "--elf", elfs[0],
]
subprocess.check_call(cmd)
rep = json.loads(Path(os.environ["REPORT"]).read_text())
files = rep.get("files") or []
if len(files) != 1:
    raise SystemExit("PROBE_FILE_COUNT")
f = files[0]
glibc = f.get("requiredGlibc")
glibcxx = f.get("requiredGlibcxx")
glibc_versioned = 1 if glibc not in (None, "", []) else 0
glibc_null = 1 if glibc in (None, "", []) else 0
glibcxx_versioned = 1 if glibcxx not in (None, "", []) else 0
glibcxx_null = 1 if glibcxx in (None, "", []) else 0
# None-safe: do not rank a null requiredGlibc/requiredGlibcxx as a max
max_glibc = glibc if glibc_versioned else None
max_glibcxx = glibcxx if glibcxx_versioned else None
if glibc != "2.17" or glibc_versioned != 1 or glibc_null != 0:
    raise SystemExit(f"GLIBC_UNEXPECTED:{glibc}")
if glibcxx != "3.4.21" or glibcxx_versioned != 1 or glibcxx_null != 0:
    raise SystemExit(f"GLIBCXX_UNEXPECTED:{glibcxx}")
if f.get("architecture") not in {"aarch64", "arm64"}:
    raise SystemExit("ARCH:" + str(f.get("architecture")))
if not rep.get("configuredLimitsSatisfied"):
    raise SystemExit("LIMITS_NOT_SATISFIED")
dyn = subprocess.check_output(["readelf", "-d", elfs[0]], text=True)
if "RUNPATH" in dyn or "(RPATH)" in dyn:
    raise SystemExit("UNEXPECTED_RUNPATH")
rep["nUniqueElf"] = 1
rep["maxVersionedGlibc"] = max_glibc
rep["maxVersionedGlibcxx"] = max_glibcxx
rep["glibcVersioned"] = glibc_versioned
rep["glibcNull"] = glibc_null
rep["glibcxxVersioned"] = glibcxx_versioned
rep["glibcxxNull"] = glibcxx_null
rep["note"] = (
    "1 unique packaged ELF /usr/sbin/synaptic; official "
    "/usr/bin/synaptic-pkexec is a shell wrapper and is not "
    "counted as an ELF; requiredGlibc 2.17 (1 versioned, 0 null); "
    "requiredGlibcxx 3.4.21 (1 versioned, 0 null); no RUNPATH; "
    "configuredLimitsSatisfied true vs 101"
)
Path(os.environ["REPORT"]).write_text(json.dumps(rep, indent=2) + "\n")
print(
    "PROBE_PASS n_elf=1 unique aarch64 glibc 2.17 (1 versioned, 0 null; no max invented from null) "
    "GLIBCXX 3.4.21 (1 versioned, 0 null) noRUNPATH configuredLimitsSatisfied=true"
)
END_SYNAPTIC_PROBE

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/pixmaps/synaptic.png"
if find "$STAGE/pkg" -name 'synaptic-official-48.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# do not invent a 128 or 256 icon in the package
if find "$STAGE/pkg" -name 'synaptic-128.png' -o -name 'synaptic-256.png' | grep -q .; then
  echo "INVENTED_ICON_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/synaptic/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/synaptic/changelog.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/synaptic/NEWS.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/synaptic.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/synaptic.desktop"
export STAGE_PKG
python3 - << 'END_SYNAPTIC_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=synaptic-pkexec\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Name=Synaptic Package Manager" not in text or "Icon=synaptic" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_UNEXPECTED_OFFICIAL_TRYEXEC")
text2 = re.sub(
    r"^Exec=synaptic-pkexec\b",
    "Exec=/usr/bin/synaptic-pkexec",
    text,
    flags=re.M,
)
text2 = re.sub(
    r"^Exec=/usr/bin/synaptic-pkexec.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/synaptic-pkexec",
    text2,
    count=1,
    flags=re.M,
)
for expect in (
    "Exec=/usr/bin/synaptic-pkexec",
    "TryExec=/usr/bin/synaptic-pkexec",
    "Icon=synaptic",
    "Name=Synaptic Package Manager",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
for i, line in enumerate(text2.splitlines(), 1):
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/synaptic-pkexec"):
        raise SystemExit(f"DESKTOP_NONABS_EXEC:{i}:{line}")
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/synaptic-pkexec":
        raise SystemExit(f"DESKTOP_TRYEXEC:{i}:{line}")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_rewritten_tryexec_added")

pol = Path(os.environ["STAGE_PKG"]) / "usr/share/polkit-1/actions/com.ubuntu.pkexec.synaptic.policy"
pt = pol.read_text()
if 'org.freedesktop.policykit.exec.path">/usr/sbin/synaptic<' not in pt:
    raise SystemExit("POLICY_EXEC_UNEXPECTED")
print("policy_exec_kept_absolute")

wrap = Path(os.environ["STAGE_PKG"]) / "usr/bin/synaptic-pkexec"
wt = wrap.read_text()
if 'pkexec "/usr/sbin/synaptic"' not in wt:
    raise SystemExit("WRAPPER_PATH_UNEXPECTED")
print("wrapper_path_kept_absolute")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".xpm"}:
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
END_SYNAPTIC_DESKTOP

# confirm the rewrite source used a real group only in the lambda, and
# the replacement strings have no accidental literal backslash-one
python3 - << 'END_SYNAPTIC_DESKTOP_SRCCHECK'
from pathlib import Path
text = Path("/workspace/t142-20261112-synaptic/scripts/build-synaptic-kemi-deb.sh").read_text()
# the written desktop file must later be checked; here ensure the
# replacement literals are absolute paths, not r"...\\1"
if 'r"Exec=/usr/bin/synaptic-pkexec\\1"' in text:
    raise SystemExit("BAD_DESKTOP_REPLACEMENT")
if "Exec=/usr/bin/synaptic-pkexec" not in text:
    raise SystemExit("MISSING_ABS_EXEC_IN_SCRIPT")
print("desktop_script_replacements_ok")
END_SYNAPTIC_DESKTOP_SRCCHECK

ln -sf /usr/sbin/synaptic "$STAGE/pkg/opt/synaptic/synaptic"
ln -sf /usr/bin/synaptic-pkexec "$STAGE/pkg/opt/synaptic/synaptic-pkexec"
ln -sf synaptic-pkexec "$STAGE/pkg/usr/bin/kemi-synaptic"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.nongnu.org/synaptic/
Source: official Ubuntu 20.04 focal universe
Homepage: http://www.nongnu.org/synaptic/
License: see copyright.upstream
Official Ubuntu 20.04 (focal universe) arm64 deb v${VER_UP}
(synaptic_0.84.6ubuntu5_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 synaptic_0.84.6ubuntu5_arm64.deb
    (focal universe; no newer package in focal-updates,
    focal-security, or focal-backports) repackaged for
    KEMI as ${PKG}. Official Depends stay Depends and
    are not bundled. Official Recommends (libgtk3-perl,
    xdg-utils) stay Recommends and are not bundled.
    Official Suggests stay Suggests and are not
    bundled. Official Conflicts: menu (<< 2.1.11) is
    kept. Versioned Provides: synaptic (= 0.84.6ubuntu5).
  * Official /usr/sbin/synaptic is an aarch64 ELF and
    stays under /usr. Official /usr/bin/synaptic-pkexec
    is a shell wrapper and stays official.
    /opt/synaptic/* are symlinks. Also
    /usr/bin/kemi-synaptic → synaptic-pkexec.
  * Official package ships no .mo (keep official; do
    not invent language packs). Official non-C GNOME
    help may be help-langpack symlinks; official
    dangling help-langpack symlinks are kept. Official
    app icon is the 48×48 pixmap synaptic.png; there is
    no official 256 or SVG. That official pixmap is
    used only for mall CREATE --icon (evidence copy)
    and is not packed a second time. Official in-app
    / help PNGs stay official.
  * Official changelog is a real file and was copied
    with cp -L. Official desktop Exec=synaptic-pkexec
    is rewritten to /usr/bin/synaptic-pkexec; TryExec
    added; Icon=synaptic; Name=Synaptic Package
    Manager. Official PolicyKit exec.path is already
    absolute and is kept. Official update-menus hooks
    and the official postrm purge of
    /etc/apt/apt.conf.d/99synaptic are kept;
    icon-cache and desktop-database hooks are added.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Synaptic ${VER_UP} — official Ubuntu 20.04
(focal universe) arm64, KEMI repack.

Official /usr/sbin/synaptic is an aarch64 ELF and
stays under /usr. Official /usr/bin/synaptic-pkexec
is a shell wrapper and stays official.
/opt/synaptic/* are symlinks. Official Depends stay
Depends and are not bundled. Official Recommends and
Suggests stay Recommends/Suggests and are unbundled.
Official package ships no .mo. Official app icon is
the 48×48 pixmap; no official 256 or SVG. The official
48×48 pixmap is used only as mall CREATE --icon and is
not packed a second time. Probe: 1 unique ELF ·
requiredGlibc 2.17 (1 versioned, 0 null; no max
invented from null) · requiredGlibcxx 3.4.21 (1
versioned, 0 null) · no RUNPATH; within Ubuntu 20.04
/ glibc 2.31 / GLIBCXX 3.4.28. Official publication:
Ubuntu 20.04 focal universe synaptic 0.84.6ubuntu5
(arm64). Official SHA256 + size matched
ports.ubuntu.com pool files and the focal universe
arm64 Packages stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libapt-pkg6.0 (>= 1.9.0), libc6 (>= 2.17), libept1.6.0, libgcc-s1 (>= 3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.14.0), libgtk-3-0 (>= 3.11.7), libpango-1.0-0 (>= 1.14.0), libstdc++6 (>= 5.2), libvte-2.91-0, libxapian30 (>= 1.4.14~), hicolor-icon-theme, policykit-1
Recommends: libgtk3-perl, xdg-utils
Suggests: dwww, menu, deborphan, apt-xapian-index, tasksel, software-properties-gtk
Conflicts: synaptic, menu (<< 2.1.11)
Replaces: synaptic
Provides: synaptic (= 0.84.6ubuntu5)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.nongnu.org/synaptic/
Description: Graphical package manager
 Synaptic ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cp -a "$UNPACK/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
# kemi added: icon cache + desktop database
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ]; then
	if command -v update-icon-caches >/dev/null 2>&1; then
		update-icon-caches /usr/share/icons/hicolor || true
	elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q /usr/share/icons/hicolor || true
	fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
HOOK

cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
# postrm script for synpatic
#
# see: dh_installdeb(1)

set -e

# summary of how this script can be called:
#        * <postrm> `remove'
#        * <postrm> `purge'
#        * <old-postrm> `upgrade' <new-version>
#        * <new-postrm> `failed-upgrade' <old-version>
#        * <new-postrm> `abort-install'
#        * <new-postrm> `abort-install' <old-version>
#        * <new-postrm> `abort-upgrade' <old-version>
#        * <disappearer's-postrm> `disappear' <overwriter>
#          <overwriter-version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package


case "$1" in
    purge)
        rm -f /etc/apt/apt.conf.d/99synaptic
    ;;

    remove|upgrade|failed-upgrade|abort-install|abort-upgrade|disappear)
    ;;

    *)
        echo "postrm called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

# Automatically added by dh_installmenu/12.9ubuntu1
if [ -x "`which update-menus 2>/dev/null`" ]; then update-menus ; fi
# End automatically added section

# kemi added: icon cache + desktop database
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
grep -q 'update-menus' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'rm -f /etc/apt/apt.conf.d/99synaptic' "$STAGE/pkg/DEBIAN/postrm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postrm"
# official $1 must still be present (quoted hook write)
grep -q 'case "$1" in' "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Version: 0.84.6ubuntu5kemi1' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'libstdc++6 (>= 5.2)' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Provides: synaptic (= 0.84.6ubuntu5)' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Recommends: libgtk3-perl, xdg-utils' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Suggests: dwww, menu, deborphan, apt-xapian-index, tasksel, software-properties-gtk' "$ROOT/evidence/kemi-synaptic-control.txt"
grep -q 'Conflicts: synaptic, menu (<< 2.1.11)' "$ROOT/evidence/kemi-synaptic-control.txt"

python3 - << END_SYNAPTIC_TREE
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/sbin/synaptic",
    "./usr/bin/synaptic-pkexec",
    "./usr/bin/kemi-synaptic",
    "./opt/synaptic/synaptic",
    "./opt/synaptic/synaptic-pkexec",
    "./usr/share/applications/synaptic.desktop",
    "./usr/share/pixmaps/synaptic.png",
    "./usr/share/polkit-1/actions/com.ubuntu.pkexec.synaptic.policy",
    "./usr/share/man/man8/synaptic.8.gz",
    "./usr/share/doc/kemi-synaptic/changelog.upstream.gz",
    "./var/lib/synaptic",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "synaptic-official-48.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "synaptic-128.png" in out or "synaptic-256.png" in out:
    raise SystemExit("INVENTED_ICON_PACKED")
found_bin = found_wrap = found_kemi = False
for line in out.splitlines():
    if ("./usr/sbin/synaptic " in line or line.rstrip().endswith("./usr/sbin/synaptic")):
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/synaptic-pkexec" in line:
        found_wrap = True
        if "->" in line:
            raise SystemExit("WRAP_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-synaptic" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_wrap:
    raise SystemExit("MISSING_WRAP")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
print("DEB_TREE_OK")
END_SYNAPTIC_TREE
echo "BUILD_OK $DEB"
