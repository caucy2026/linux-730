#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main) gnome-logs
# 3.34.0-1ubuntu1 Architecture: arm64 as kemi-gnome-logs.
# Newer than focal Release 3.34.0-1 and still Ubuntu 20.04
# deps (libc6 >= 2.17). The gnome-logs source ships only this
# one binary package in focal (no same-source -data/-common
# to bundle). Official control has no Recommends and no
# Suggests. System library Depends stay Depends and are not
# bundled. Versioned Provides: gnome-logs (= 3.34.0-1ubuntu1).
# Official /usr/bin/gnome-logs is a compiled aarch64 ELF.
# The ELF embeds /usr/share/locale and help:gnome-logs
# (UI in a GResource). Official files stay on official
# paths; /opt/gnome-logs/* are symlinks.
# Official package ships no .mo (Ubuntu language-pack split;
# desktop X-Ubuntu-Gettext-Domain=gnome-logs). Keep the
# official tree; do not invent or bundle language packs.
# Official Yelp help: real C tree under
# /usr/share/help/C/gnome-logs/ plus official help-langpack
# symlinks for other locales; keep the official tree, do
# not invent or bundle language-packs. Official app icons
# are SVG only (org.gnome.Logs.svg and symbolic). Official
# help-media PNGs stay in the official help tree and are
# not the app icon. Do not invent a PNG inside the package.
# A 128x128 PNG rasterized from the official app SVG may
# be used only as the mall CREATE --icon and must live
# under evidence/ (GNOME Clocks / Calendar / Weather /
# Tweaks / Maps pattern). Official changelog is a real
# file. Official package has no maintainer scripts;
# hicolor + desktop-database hooks are added. Official
# D-Bus service Exec is already absolute
# /usr/bin/gnome-logs --gapplication-service and is kept.
# Official desktop Exec=gnome-logs is rewritten to
# /usr/bin/gnome-logs; Icon=org.gnome.Logs is kept;
# TryExec is added. DBusActivatable=true is kept.
# Probe: Architecture arm64 · 1 unique packaged ELF ·
# requiredGlibc 2.17 (1 versioned, 0 null) · no GLIBCXX
# (0 versioned, 1 null; null is not ranked as a max) ·
# GTK3 + libsystemd GUI · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal-updates main arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed).
# No librarian URL and no .buildinfo is recorded this run
# (pool 404).
# KEMI version 3.34.0-1ubuntu1kemi1 is 20 chars (under the
# mall version_name limit that rejected Remmina's 33-char
# string; gnome-clocks 3.36.2-1~ubuntu20.04.1kemi1 was 27
# chars; gnome-tweaks / gnome-maps were 20 chars). No
# epoch, no tilde, no shortening needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-gnome-logs
VER_UP=3.34.0-1ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-logs
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-logs_3.34.0-1ubuntu1_arm64.deb"
EXPECT_SHA=de80888b89485ce17e72a807a1f425d40742ab4d2f7ac23afaae6affe9ff1000
EXPECT_BYTES=118592
python3 - << PY
s="${VER_DEB}"
assert len(s) == 20, len(s)
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-logs"
python3 - << PY
from pathlib import Path
p=Path("$UNPACK/usr/bin/gnome-logs")
assert not p.is_symlink()
assert p.read_bytes()[:4] == bytes([0x7F])+b"ELF"
print("official_elf_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Logs.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Logs.svg"
test -f "$UNPACK/usr/share/icons/hicolor/symbolic/apps/org.gnome.Logs-symbolic.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/org.gnome.Logs.png"
test ! -d "$UNPACK/usr/share/icons/hicolor/48x48"
test -d "$UNPACK/usr/share/help/C/gnome-logs"
test -f "$UNPACK/usr/share/help/C/gnome-logs/index.page"
test ! -d "$UNPACK/usr/share/help/zh_CN"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/gnome-logs/changelog.Debian.gz"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.Logs.service"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Logs.gschema.xml"
test ! -f "$UNPACK/DEBIAN/postinst"
test -f "$ROOT/evidence/org.gnome.Logs-128.png"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-logs"

cp -a "$UNPACK/usr/bin/gnome-logs" "$STAGE/pkg/usr/bin/gnome-logs"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-logs"
cp -a "$UNPACK/usr/share/." "$STAGE/pkg/usr/share/"

REPORT="$ROOT/probe/kemi-gnome-logs.json"
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
if Path(f["path"]).name != "gnome-logs":
    raise SystemExit(f"PROBE_NAME:{f['path']}")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit(f"PROBE_GLIBC:{f.get('requiredGlibc')}")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit(f"PROBE_UNEXPECTED_GLIBCXX:{f.get('requiredGlibcxx')}")
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 1 or nulls or cxx or len(cxx_null) != 1:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libsystemd.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit("PROBE_MISSING_NEEDED:"+lib)
print("PROBE_PASS n_elf=1 unique gnome-logs aarch64 glibc=2.17 (1 versioned, 0 null) noGLIBCXX (0 versioned, 1 null; null not ranked as a max) configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -d "$STAGE/pkg/usr/share/help/C/gnome-logs"
test -f "$STAGE/pkg/usr/share/help/C/gnome-logs/media/gnome-logs.png"
test ! -d "$STAGE/pkg/usr/share/help/zh_CN"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Logs.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.Logs.png"
if find "$STAGE/pkg" -name 'org.gnome.Logs-128.png' | grep -q .; then
  echo "PACKED_EVIDENCE_PNG" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-logs/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-logs/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.Logs.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.Logs.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=gnome-logs(\s.*)?$", r"Exec=/usr/bin/gnome-logs\1", text, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/gnome-logs(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/gnome-logs",
                   text2, count=1, flags=re.M)
if re.search(r"^Exec=gnome-logs(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/gnome-logs",
               "TryExec=/usr/bin/gnome-logs",
               "Icon=org.gnome.Logs",
               "Name=Logs",
               "DBusActivatable=true"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

t = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Logs.service").read_text(encoding="utf-8")
if "Exec=/usr/bin/gnome-logs --gapplication-service" not in t:
    raise SystemExit("DBUS_CHANGED")

leftover = []
for p in Path("$STAGE/pkg").rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz"}:
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

ln -sf /usr/bin/gnome-logs "$STAGE/pkg/opt/gnome-logs/gnome-logs"
ln -sf gnome-logs "$STAGE/pkg/usr/bin/kemi-gnome-logs"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Logs
Source: https://launchpad.net/ubuntu/+source/gnome-logs
Homepage: https://wiki.gnome.org/Apps/Logs
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) Architecture: arm64 deb v${VER_UP}
(gnome-logs_3.34.0-1ubuntu1_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gnome-logs_3.34.0-1ubuntu1_arm64.deb
    (focal-updates main; newer than focal Release 3.34.0-1,
    still Ubuntu 20.04 deps) repackaged for KEMI as ${PKG}.
    No same-source data package in focal. Official control
    has no Recommends and no Suggests. Versioned Provides:
    gnome-logs (= 3.34.0-1ubuntu1).
  * Official /usr/bin/gnome-logs is a compiled aarch64 ELF.
    The ELF embeds /usr/share/locale and help:gnome-logs
    (UI in a GResource). /opt/gnome-logs/* are symlinks.
    Also /usr/bin/kemi-gnome-logs.
  * Desktop, man, official SVG app icons, official C help
    tree plus official help-langpack symlinks, official
    gsettings schema and D-Bus service stay on standard
    paths. Official package ships no .mo (language-pack
    split). Official desktop Exec=gnome-logs rewritten to
    /usr/bin/gnome-logs; Icon=org.gnome.Logs. Official
    D-Bus Exec already absolute and kept. Official app
    icons are SVG only; no PNG is invented inside the
    package.
  * Official package has no maintainer scripts. Official
    changelog is a real file.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
GNOME Logs ${VER_UP} — official Ubuntu 20.04
(focal-updates) main Architecture: arm64,
KEMI repack.

Official /usr/bin/gnome-logs is a compiled
aarch64 ELF (glibc 2.17, no GLIBCXX).
/opt/gnome-logs/* are symlinks. Desktop, man,
official SVG app icons, official C help plus
official help-langpack symlinks, official schema
and D-Bus service remain on standard paths.
Official package ships no .mo (language-pack
split). Official control has no Recommends and
no Suggests. Probe: 1 unique ELF · requiredGlibc
2.17 (1 versioned, 0 null) · no requiredGlibcxx
(0 versioned, 1 null; null not ranked as a max);
GTK3 + libsystemd GUI; within Ubuntu 20.04 /
glibc 2.31.
Official publication: Ubuntu 20.04
focal-updates main gnome-logs 3.34.0-1ubuntu1
(Architecture: arm64). Official SHA256 + size
matched ports.ubuntu.com pool files and
focal-updates main arm64 Packages stanza.
No librarian URL this run.
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
Depends: libc6 (>= 2.17), libglib2.0-0 (>= 2.43.90), libgtk-3-0 (>= 3.22.0), libpango-1.0-0 (>= 1.14.0), libsystemd0, dconf-gsettings-backend | gsettings-backend, gsettings-desktop-schemas
Replaces: gnome-logs
Conflicts: gnome-logs
Provides: gnome-logs (= 3.34.0-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Logs
Description: viewer for the systemd journal
 GNOME Logs ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 View systemd journal event logs
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
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-logs-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
if "org.gnome.Logs-128.png" in out or "128x128/apps/org.gnome.Logs.png" in out:
    raise SystemExit("PACKED_RASTER_OR_INVENTED_PNG")
need = [
    "./usr/bin/gnome-logs",
    "./usr/bin/kemi-gnome-logs",
    "./opt/gnome-logs/gnome-logs",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.Logs.svg",
    "./usr/share/dbus-1/services/org.gnome.Logs.service",
    "./usr/share/glib-2.0/schemas/org.gnome.Logs.gschema.xml",
    "./usr/share/help/C/gnome-logs/index.page",
    "./usr/share/man/man1/gnome-logs.1.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
# official binary must remain a regular ELF, not a symlink
if any("usr/bin/gnome-logs" in line and "->" in line and "kemi-gnome-logs" not in line and "opt/gnome-logs" not in line for line in out.splitlines()):
    # kemi symlink and opt symlink also mention gnome-logs; ensure the real bin line has no ->
    binlines=[line for line in out.splitlines() if "./usr/bin/gnome-logs" in line and "kemi-gnome-logs" not in line]
    if not binlines or "->" in binlines[0]:
        raise SystemExit("BIN_UNEXPECTED_SYMLINK:"+repr(binlines))
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
