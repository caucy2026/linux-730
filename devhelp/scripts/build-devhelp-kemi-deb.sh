#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) devhelp
# 3.36.2-0ubuntu1 Architecture: arm64 as kemi-devhelp.
# Newer than focal Release 3.36.1-1 and still Ubuntu 20.04
# deps (libc6 >= 2.17). The devhelp source also ships
# same-source libdevhelp-3-6, devhelp-common, gir1.2-devhelp-3.0
# and libdevhelp-dev in focal. Official devhelp Depends
# libdevhelp-3-6 (>= 3.36.0) is same-source but not an
# exact-version hard-Depends, so the library stays Depends
# and is not bundled. Official devhelp does not hard-Depends
# on devhelp-common (the library does: devhelp-common (>=
# 3.36.2-0ubuntu1), the only focal-updates version); apt
# will pull both with libdevhelp-3-6. gir1.2-devhelp-3.0
# and libdevhelp-dev are not GUI hard-Depends and are not
# bundled. Official Recommends (libgtk-3-doc, libglib2.0-doc,
# libpango1.0-doc) are different-source documentation
# packages and stay Recommends / unbundled. Official control
# has no Suggests. Official Breaks/Replaces
# devhelp-common (<< 3.21.91-1) are kept (old split; the
# current official -common is not a transitional dummy and
# was inspected, not packaged). Versioned Provides:
# devhelp (= 3.36.2-0ubuntu1). No Debian epoch.
# Official /usr/bin/devhelp is a compiled aarch64 ELF that
# embeds help:devhelp and NEEDED libdevhelp-3.so.6.
# Official files stay on official paths; /opt/devhelp/*
# are symlinks. Also /usr/bin/kemi-devhelp → devhelp.
# Official GUI package ships no .mo, no icons, no help and
# no schemas (those live in official devhelp-common, pulled
# via apt with the library). Keep the official GUI tree;
# do not invent or bundle language packs, help, or icons.
# Official app icons are SVG only and live in
# devhelp-common. A 128×128 PNG rasterized from the official
# app SVG via Chrome headless lives at
# evidence/org.gnome.Devhelp-128.png and is used only as the
# mall CREATE --icon (GNOME Clocks / Calculator pattern);
# it is not shipped in the deb.
# Official changelog.Debian.gz in the GUI package is a
# dangling symlink to ../libdevhelp-3-6/changelog.Debian.gz;
# the real official changelog is copied from the
# same-source libdevhelp-3-6 package with cp -L into the
# kemi doc dir only; the dangling symlink is not packed.
# Official package has py3compile/py3clean maintainer
# scripts and a python3 rtupdate hook for the official
# gedit plugin (devhelp.py, not an ELF); they are
# retargeted to kemi-devhelp (blueman / zim / gnome-tweaks
# pattern). Official desktop Exec=devhelp is rewritten to
# /usr/bin/devhelp; TryExec is added; Icon=org.gnome.Devhelp
# is kept; DBusActivatable=true is kept. Official D-Bus
# Exec=/usr/bin/devhelp --gapplication-service is already
# absolute and is kept. Official emacs site-start conffile
# is kept. Official man, appdata, AUTHORS, NEWS, README
# and tools/devhelp.vim stay in the official tree.
# Probe: Architecture arm64 · 1 unique packaged ELF ·
# requiredGlibc 2.17 (1 versioned, 0 null) · no GLIBCXX
# (0 versioned, 1 null; null is not ranked as a max) ·
# official gedit plugin is Python, not counted as an ELF ·
# GTK3 + WebKitGTK API documentation browser · within 101
# ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal-updates universe
# arm64 Packages stanza (Aliyun ubuntu-ports mirror,
# streamed). No librarian URL and no .buildinfo is recorded
# this run (pool 404).
# KEMI version 3.36.2-0ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-calculator 3.36.0-1ubuntu1kemi1 was 20
# chars). No epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-devhelp
VER_UP=3.36.2-0ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-devhelp
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
LIBUNPACK="${LIBUNPACK:-$ROOT/unpack-lib}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/devhelp_3.36.2-0ubuntu1_arm64.deb"
EXPECT_SHA=7fab76a391c3c4ee154bd21ee97b91f732b211a5f96809bc005af196a9407465
EXPECT_BYTES=58112
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/devhelp"
python3 - << PY
from pathlib import Path
p=Path("$UNPACK/usr/bin/devhelp")
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F])+b"ELF"
plugin=Path("$UNPACK/usr/lib/aarch64-linux-gnu/gedit/plugins/devhelp.py")
assert plugin.is_file() and not plugin.is_symlink()
assert plugin.read_bytes()[:4] != bytes([0x7F])+b"ELF"
print("official_elf_ok python_plugin_not_elf")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Devhelp.desktop"
test -L "$UNPACK/usr/share/doc/devhelp/changelog.Debian.gz"
test ! -e "$UNPACK/usr/share/doc/devhelp/changelog.Debian.gz" -o ! -e "$(readlink -f "$UNPACK/usr/share/doc/devhelp/changelog.Debian.gz" 2>/dev/null || echo /nonexistent)"
# dangling official changelog — real file is in same-source lib package
test -f "$LIBUNPACK/usr/share/doc/libdevhelp-3-6/changelog.Debian.gz"
test ! -L "$LIBUNPACK/usr/share/doc/libdevhelp-3-6/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.Devhelp-128.png"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/icons"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$UNPACK/usr/share/locale"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/devhelp"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
# official emacs conffile
mkdir -p "$STAGE/pkg/etc/emacs/site-start.d"
cp -a "$UNPACK/etc/emacs/site-start.d/50devhelp.el" "$STAGE/pkg/etc/emacs/site-start.d/50devhelp.el"
chmod 0755 "$STAGE/pkg/usr/bin/devhelp"
# drop dangling official changelog symlink from the official doc tree
rm -f "$STAGE/pkg/usr/share/doc/devhelp/changelog.Debian.gz"

# retarget official python3 rtupdate hook to the kemi package name
if [ -f "$STAGE/pkg/usr/share/python3/runtime.d/devhelp.rtupdate" ]; then
  sed -e 's/-p devhelp/-p kemi-devhelp/g' \
    "$STAGE/pkg/usr/share/python3/runtime.d/devhelp.rtupdate" \
    > "$STAGE/pkg/usr/share/python3/runtime.d/kemi-devhelp.rtupdate"
  chmod 0755 "$STAGE/pkg/usr/share/python3/runtime.d/kemi-devhelp.rtupdate"
  rm -f "$STAGE/pkg/usr/share/python3/runtime.d/devhelp.rtupdate"
  grep -q 'kemi-devhelp' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-devhelp.rtupdate"
  if grep -q -- '-p devhelp' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-devhelp.rtupdate"; then
    echo "RTUPDATE_NOT_RETARGETED" >&2
    exit 1
  fi
fi

REPORT="$ROOT/probe/kemi-devhelp.json"
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
if Path(f["path"]).name != "devhelp":
    raise SystemExit("PROBE_NAME:"+Path(f["path"]).name)
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC:"+str(f.get("requiredGlibc")))
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:"+str(f.get("requiredGlibcxx")))
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or len(nulls) != 0 or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
# official python plugin must not have been counted as an ELF
print("PROBE_PASS n_elf=1 unique aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) official gedit plugin is Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/icons"
test ! -d "$STAGE/pkg/usr/share/help"
if find "$STAGE/pkg" -name 'org.gnome.Devhelp-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# no dangling changelog packed
if [ -L "$STAGE/pkg/usr/share/doc/devhelp/changelog.Debian.gz" ]; then
  echo "DANGLING_CHANGELOG_STAGED" >&2
  exit 1
fi

# official copyright is a real file; changelog from same-source lib package
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/devhelp/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$LIBUNPACK/usr/share/doc/libdevhelp-3-6/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.Devhelp.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Devhelp.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=devhelp(\s.*)?$", r"Exec=/usr/bin/devhelp\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/devhelp", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/devhelp.*$", lambda m: m.group(0)+"\nTryExec=/usr/bin/devhelp", text2, count=1, flags=re.M)
if re.search(r"^Exec=devhelp(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/devhelp",
               "TryExec=/usr/bin/devhelp",
               "Icon=org.gnome.Devhelp",
               "Name=Devhelp",
               "DBusActivatable=true"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Devhelp.service").read_text()
if "Exec=/usr/bin/devhelp --gapplication-service" not in svc:
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

ln -sf /usr/bin/devhelp "$STAGE/pkg/opt/devhelp/devhelp"
ln -sf devhelp "$STAGE/pkg/usr/bin/kemi-devhelp"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Devhelp
Source: https://launchpad.net/ubuntu/+source/devhelp
Homepage: https://wiki.gnome.org/Apps/Devhelp
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) Architecture: arm64 deb v${VER_UP}
(devhelp_3.36.2-0ubuntu1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 devhelp_3.36.2-0ubuntu1_arm64.deb
    (focal-updates universe; newer than focal Release
    3.36.1-1 and still Ubuntu 20.04 deps) repackaged for
    KEMI as ${PKG}. Official Depends libdevhelp-3-6
    (>= 3.36.0) is same-source but not exact-version, so
    the library and official devhelp-common stay Depends
    (pulled by apt) and are not bundled. Official
    Recommends (libgtk-3-doc, libglib2.0-doc,
    libpango1.0-doc) stay Recommends. Official control has
    no Suggests. Official Breaks/Replaces devhelp-common
    (<< 3.21.91-1) are kept. Versioned Provides: devhelp
    (= 3.36.2-0ubuntu1).
  * Official /usr/bin/devhelp is a compiled aarch64 ELF
    that embeds help:devhelp and NEEDED libdevhelp-3.so.6.
    /opt/devhelp/* are symlinks. Also /usr/bin/kemi-devhelp.
  * Official GUI package ships no .mo, no icons, no help
    and no schemas (those live in official devhelp-common).
    Official desktop Exec=devhelp rewritten to
    /usr/bin/devhelp; TryExec added; Icon=org.gnome.Devhelp.
    Official D-Bus Exec already absolute and kept. Official
    app icons are SVG only in -common; a 128×128 evidence
    PNG is used only for mall CREATE --icon and is not
    packed in the deb.
  * Official py3compile/py3clean and the python3 rtupdate
    hook for the official gedit plugin are retargeted to
    kemi-devhelp. Official emacs site-start conffile is
    kept. Official changelog in the GUI package is a
    dangling symlink; the real official changelog was
    copied from same-source libdevhelp-3-6.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Devhelp ${VER_UP} — official Ubuntu 20.04
(focal-updates) universe Architecture: arm64, KEMI
repack.

Official /usr/bin/devhelp is a compiled aarch64 ELF
(glibc 2.17, no GLIBCXX) that embeds help:devhelp.
/opt/devhelp/* are symlinks. Official same-source
libdevhelp-3-6 (>= 3.36.0) and devhelp-common stay
Depends and are not bundled. Official Recommends
(libgtk-3-doc, libglib2.0-doc, libpango1.0-doc) stay
Recommends. Official GUI package ships no .mo, no
icons, no help and no schemas. Probe: 1 unique ELF ·
requiredGlibc 2.17 (1 versioned, 0 null) · no
requiredGlibcxx (0 versioned, 1 null; null not ranked
as a max); official gedit plugin is Python, not an
ELF; GTK3 + WebKitGTK API documentation browser;
within Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal-updates universe
devhelp 3.36.2-0ubuntu1 (Architecture: arm64). Official
SHA256 + size matched ports.ubuntu.com pool files and
focal-updates universe arm64 Packages stanza. No
librarian URL this run.
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
Depends: python3:any, libamtk-5-0 (>= 5.0.0), libc6 (>= 2.17), libdevhelp-3-6 (>= 3.36.0), libglib2.0-0 (>= 2.60), libgtk-3-0 (>= 3.22), libpango-1.0-0 (>= 1.14.0), libwebkit2gtk-4.0-37 (>= 2.24)
Recommends: libgtk-3-doc, libglib2.0-doc, libpango1.0-doc
Breaks: devhelp-common (<< 3.21.91-1)
Replaces: devhelp, devhelp-common (<< 3.21.91-1)
Conflicts: devhelp
Provides: devhelp (= 3.36.2-0ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Devhelp
Description: GNOME developers help program
 Devhelp ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 API documentation browser for GNOME
 (GTK3 + WebKitGTK GUI).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/conffiles" << 'EOT'
/etc/emacs/site-start.d/50devhelp.el
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_python3 (retargeted to kemi-devhelp):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-devhelp /usr/lib/aarch64-linux-gnu/gedit/plugins
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-devhelp /usr/lib/aarch64-linux-gnu/gedit/plugins || true
fi
# End automatically added section
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

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_python3 (retargeted to kemi-devhelp):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-devhelp
else
	dpkg -L kemi-devhelp | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi
# End automatically added section
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

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

# leftover official package name in maintainer scripts?
if grep -R -- '-p devhelp' "$STAGE/pkg/DEBIAN" "$STAGE/pkg/usr/share/python3" 2>/dev/null | grep -v kemi-devhelp; then
  echo "LEFTOVER_PY3_PKGNAME" >&2
  exit 1
fi
if grep -n 'dpkg -L devhelp' "$STAGE/pkg/DEBIAN/prerm"; then
  echo "LEFTOVER_DPKG_L" >&2
  exit 1
fi

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-devhelp-control.txt"
grep -q 'Version: 3.36.2-0ubuntu1kemi1' "$ROOT/evidence/kemi-devhelp-control.txt"
grep -q 'Recommends: libgtk-3-doc, libglib2.0-doc, libpango1.0-doc' "$ROOT/evidence/kemi-devhelp-control.txt"
grep -q 'libdevhelp-3-6 (>= 3.36.0)' "$ROOT/evidence/kemi-devhelp-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/devhelp",
    "./usr/bin/kemi-devhelp",
    "./opt/devhelp/devhelp",
    "./usr/share/applications/org.gnome.Devhelp.desktop",
    "./usr/share/dbus-1/services/org.gnome.Devhelp.service",
    "./usr/lib/aarch64-linux-gnu/gedit/plugins/devhelp.py",
    "./usr/share/python3/runtime.d/kemi-devhelp.rtupdate",
    "./etc/emacs/site-start.d/50devhelp.el",
    "./usr/share/man/man1/devhelp.1.gz",
    "./usr/share/metainfo/org.gnome.Devhelp.appdata.xml",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "org.gnome.Devhelp-128.png" in out or "org.gnome.Devhelp.svg" in out:
    raise SystemExit("ICON_INVENTED_OR_COMMON_PACKED")
if "changelog.Debian.gz" in out and "changelog.upstream.gz" not in "".join(line for line in out.splitlines() if "changelog.Debian.gz" in line):
    # official dangling name must not appear
    for line in out.splitlines():
        if "changelog.Debian.gz" in line and "changelog.upstream.gz" not in line:
            raise SystemExit("DANGLING_CHANGELOG_IN_DEB:"+line)
if "usr/share/python3/runtime.d/devhelp.rtupdate" in out:
    raise SystemExit("OLD_RTUPDATE_NAME")
for line in out.splitlines():
    if "./usr/bin/devhelp" in line and "kemi-devhelp" not in line:
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:"+line)
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
