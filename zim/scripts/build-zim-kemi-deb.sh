#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) zim
# 0.72.0-1 Architecture: all as kemi-zim.
# The zim source ships only this one binary package in focal
# (no same-source -data/-common to bundle). Official Recommends
# gir1.2-gtkspell3-3.0 (different-source typelib, not an
# exact-version plugin Depends) stays Recommends. Official
# Suggests (bzr, git, mercurial, fossil, graphviz, ditaa,
# scrot, dvipng, gir1.2-gtksource-3.0, python3-zeitgeist,
# r-base, gnuplot, lilypond) stay Suggests and are not
# bundled. System Depends (python3, python3-gi, python3-xdg,
# gir1.2-gtk-3.0, xdg-utils) stay Depends. Versioned Provides:
# zim (= 0.72.0-1).
# Official /usr/bin/zim is a Python 3 wrapper script (not an
# ELF). Application code lives under
# /usr/lib/python3/dist-packages/zim and data under
# /usr/share/zim (XDG default /usr/share/). Official files
# stay on official paths; /opt/zim/* are symlinks (same
# compiled-/usr / XDG layout as earlier /usr-prefix siblings).
# Official translations are 34 .mo including zh_CN. Official
# manual lives under /usr/share/zim/manual (no /usr/share/help).
# Official icons include hicolor 16–48 PNG, official SVG, pixmap
# PNG and ubuntu-mono panel SVGs. Keep the official tree; do
# not invent language-packs, help trees, or SVG/PNG icons.
# Official changelog is a real file. Official maintainer
# scripts use py3compile/py3clean/dpkg -L -p zim and must be
# retargeted to kemi-zim (Blueman pattern). Official
# dh_icons update-icon-caches for ubuntu-mono-dark/light is
# kept; hicolor + desktop-database hooks are added.
# Official desktop Exec=zim %f (and Unity shortcut Exec=zim
# --plugin …) is rewritten to /usr/bin/zim; Icon=zim is kept.
# Official helper desktop for system meld is left unchanged.
# Probe: Architecture all · 0 packaged ELF · no
# requiredGlibc / requiredGlibcxx version-needs · Python 3
# GTK3 typelib GUI · vacuously within 101 ≤2.31 / ≤3.4.28
# (no ELF to exceed the baseline).
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed;
# arch:all listed in the arm64 index). No newer package in
# focal-updates. No librarian URL and no .buildinfo is
# recorded this run (pool 404).
# KEMI version 0.72.0-1kemi1 is 13 chars (under the mall
# version_name limit that rejected Remmina's 33-char string;
# gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-zim
VER_UP=0.72.0-1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-zim
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/probe/zim-0.72.0-focal-unpack}"
CTRL="${CTRL:-$ROOT/probe/official-control}"
UP_DEB="$DL/zim_0.72.0-1_all.deb"
EXPECT_SHA=5965e9ac3f0f465b4ef3b623ea771fef22b841c5103529003f9d202da1cad227
EXPECT_BYTES=1017948
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/zim"
test "$(head -n 1 "$UNPACK/usr/bin/zim")" = "#!/usr/bin/python3"
python3 - << PY
from pathlib import Path
p=Path("$UNPACK/usr/bin/zim")
assert p.read_bytes()[:4] != bytes([0x7F])+b"ELF"
PY
test -f "$UNPACK/usr/share/applications/zim.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/zim.png"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/zim.svg"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/zim.mo"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 34
test -f "$UNPACK/usr/share/zim/manual/Start.txt"
test ! -d "$UNPACK/usr/share/help"
test ! -L "$UNPACK/usr/share/doc/zim/changelog.Debian.gz"
test -d "$UNPACK/usr/lib/python3/dist-packages/zim"
test -f "$CTRL/postinst" && test -f "$CTRL/prerm"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/zim"

# official trees
cp -a "$UNPACK/usr/bin/zim" "$STAGE/pkg/usr/bin/zim"
chmod 0755 "$STAGE/pkg/usr/bin/zim"
cp -a "$UNPACK/usr/lib" "$STAGE/pkg/usr/lib"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

# 0-ELF probe report (None-safe; do not invent a glibc max)
REPORT="$ROOT/probe/kemi-zim.json"
python3 - << PY
from pathlib import Path
import json
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs=[]
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
script = Path("$STAGE/pkg/usr/bin/zim")
if script.read_bytes()[:2] != b"#!":
    raise SystemExit("MISSING_SCRIPT")
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "note": "official zim 0.72.0-1 is Architecture: all Python 3 / GTK3 typelib GUI; packaged tree contains 0 ELF files",
    "hostArchitecture": "x86_64",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "elfCount": 0,
    "glibcVersioned": 0,
    "glibcNull": 0,
    "glibcxxVersioned": 0,
    "glibcxxNull": 0,
    "maxVersionedGlibc": None,
    "maxVersionedGlibcxx": None,
    "wrapper": {
        "path": str(script),
        "shebang": script.read_text(encoding="utf-8").splitlines()[0],
        "bytes": script.stat().st_size,
    },
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 python3_wrapper glibc_versioned=0 glibc_null=0 noGLIBCXX configuredLimitsSatisfied=true (vacuous; no packaged ELF)")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 34
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/zim.mo"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/zim.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/zim.svg"
test -f "$STAGE/pkg/usr/share/zim/manual/Start.txt"
test ! -d "$STAGE/pkg/usr/share/help"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/zim/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/zim/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/zim.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/zim.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=zim(\s.*)?$", r"Exec=/usr/bin/zim\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=zim$", "TryExec=/usr/bin/zim", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/zim(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/zim", text2, count=1, flags=re.M)
if re.search(r"^Exec=zim(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in ("Exec=/usr/bin/zim %f", "TryExec=/usr/bin/zim",
               "Exec=/usr/bin/zim --plugin quicknote",
               "Exec=/usr/bin/zim --plugin quicknote input=clipboard"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=zim$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Zim Desktop Wiki" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten")

# official meld helper must stay official (system meld), not rewritten to zim
helper = Path("$STAGE/pkg/usr/share/zim/helpers/compare_files/meld.desktop")
ht = helper.read_text(encoding="utf-8")
if "Exec=meld %F" not in ht:
    raise SystemExit("HELPER_MELD_CHANGED")
print("helper_meld_kept")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "x86_64-linux-gnu" in t:
        leftover.append(str(p))
if leftover:
    raise SystemExit("LEFTOVER_X86:" + ",".join(leftover))
print("no_x86_paths")
PY

ln -sf /usr/bin/zim "$STAGE/pkg/opt/zim/zim"
ln -sf zim "$STAGE/pkg/usr/bin/kemi-zim"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://zim-wiki.org
Source: https://launchpad.net/ubuntu/+source/zim
Homepage: http://zim-wiki.org
License: see copyright.upstream
Official Ubuntu 20.04 (focal) Architecture: all deb v${VER_UP}
(zim_0.72.0-1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 zim_0.72.0-1_all.deb (focal
    universe; no newer package in focal-updates) repackaged
    for KEMI as ${PKG}. No same-source data package in focal.
    Official Recommends gir1.2-gtkspell3-3.0 stays Recommends.
    Official Suggests stay Suggests. Versioned Provides:
    zim (= 0.72.0-1).
  * Official /usr/bin/zim is a Python 3 wrapper (no packaged
    ELF). Data stays under /usr/share/zim (XDG /usr/share/).
    /opt/zim/* are symlinks.
  * Desktop, man, official 34 .mo (including zh_CN), official
    hicolor PNG+SVG icons, official manual under
    /usr/share/zim/manual stay on standard paths. Official
    desktop Exec=zim rewritten to /usr/bin/zim; Icon=zim.
  * Official py3compile/py3clean/dpkg -L scripts retargeted
    to kemi-zim. Official changelogs are real files.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 23:00:35 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Zim Desktop Wiki ${VER_UP} — official Ubuntu 20.04
(focal) universe Architecture: all, KEMI repack.

Official /usr/bin/zim is a Python 3 wrapper (no
packaged ELF). /opt/zim/* are symlinks. Desktop, man,
official 34 .mo (including zh_CN), official icons and
official /usr/share/zim manual remain on standard
paths. Official Recommends gir1.2-gtkspell3-3.0 stays
Recommends. Official Suggests stay Suggests.
Probe: 0 ELF · no requiredGlibc / requiredGlibcxx
version-needs; Python 3 GTK3 typelib GUI; vacuously
within Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04 focal universe
zim 0.72.0-1 (Architecture: all). Official SHA256 +
size matched ports.ubuntu.com pool files and focal
universe arm64 Packages stanza. No librarian URL this
run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: x11
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: python3:any, python3-gi, python3-xdg, gir1.2-gtk-3.0, xdg-utils
Recommends: gir1.2-gtkspell3-3.0
Suggests: bzr, git, mercurial, fossil, graphviz, ditaa, scrot, dvipng, gir1.2-gtksource-3.0, python3-zeitgeist, r-base, gnuplot, lilypond
Replaces: zim
Conflicts: zim
Provides: zim (= 0.72.0-1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://zim-wiki.org
Description: graphical text editor based on wiki technologies
 Zim ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Desktop wiki for notes and notebooks (GTK3, Python 3).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# official scripts retargeted to kemi-zim (Blueman / py3compile pattern)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi-zim):
if which py3compile >/dev/null 2>&1; then
	py3compile -p kemi-zim
fi
if which pypy3compile >/dev/null 2>&1; then
	pypy3compile -p kemi-zim || true
fi

# End automatically added section
# Automatically added by dh_icons/12.6.1ubuntu2
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if which update-icon-caches >/dev/null 2>&1 ; then
		update-icon-caches /usr/share/icons/ubuntu-mono-dark /usr/share/icons/ubuntu-mono-light /usr/share/icons/hicolor || true
	elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache -q /usr/share/icons/hicolor || true
	fi
fi
# End automatically added section
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/prerm" << 'EOT'
#!/bin/sh
set -e

# Automatically added by dh_python3 (retargeted to kemi-zim):
if which py3clean >/dev/null 2>&1; then
	py3clean -p kemi-zim
else
	dpkg -L kemi-zim | perl -ne 's,/([^/]*)\.py$,/__pycache__/\1.*, or next; unlink $_ or die $! foreach glob($_)'
	find /usr/lib/python3/dist-packages/ -type d -name __pycache__ -empty -print0 | xargs --null --no-run-if-empty rmdir
fi

# End automatically added section
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
# Automatically added by dh_icons/12.6.1ubuntu2
if which update-icon-caches >/dev/null 2>&1 ; then
	update-icon-caches /usr/share/icons/ubuntu-mono-dark /usr/share/icons/ubuntu-mono-light /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
	gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
# End automatically added section
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-zim-control.txt"
# confirm scripts retargeted
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./postinst | grep -q 'py3compile -p kemi-zim'
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./prerm | grep -q 'py3clean -p kemi-zim'
dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./prerm | grep -q 'dpkg -L kemi-zim'
if dpkg-deb --ctrl-tarfile "$DEB" | tar -xO ./postinst | grep -q 'py3compile -p zim '; then
  echo "LEFTOVER_PY3COMPILE_ZIM" >&2
  exit 1
fi
echo "SCRIPTS_RETARGETED"
