#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates) dconf-editor
# 3.36.7-0ubuntu1 arm64 as kemi-dconf-editor. There is no
# same-source common/data/typelib package (single official
# binary).
# Official binary: /usr/bin/dconf-editor.
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   GTK3, libdconf, glib, dconf-gsettings-backend). No official
#   Recommends/Suggests.
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal-updates universe
#   arm64 Packages stanzas (Aliyun ubuntu-ports mirror,
#   streamed). Newer than focal Release 3.36.0-1 and still
#   U20-compatible. No librarian URL is recorded this run.
# ELF embeds /usr/share/locale (UI compiled into the ELF).
# Layout keeps official files at /usr/bin; /opt/dconf-editor/*
#   are symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/
#   Xfburn/Parole/GNOME Disks/GNOME System Monitor/GParted/
#   Seahorse/Remmina). Official desktop Icon=
#   ca.desrt.dconf-editor (PNG + symbolic SVG shipped). Official
#   language-pack split: no .mo / no help in this deb. Reuse
#   existing unpacked tree; do not re-download.
# KEMI version 3.36.7-0ubuntu1kemi1 is 21 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-dconf-editor
VER_UP=3.36.7
VER_DEB="${VER_UP}-0ubuntu1kemi1"
ARCH=arm64
PKG=kemi-dconf-editor
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/dconf-editor-3.36.7-focal-updates-unpack}"
UP_DEB="$DL/dconf-editor_3.36.7-0ubuntu1_arm64.deb"
EXPECT_SHA=56c2cf9bbeece7b3b2bdeee6623919ba98d9239d9d4cb8affa360a2ef328f051
EXPECT_BYTES=295396
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/dconf-editor"
test -f "$UNPACK/usr/share/applications/ca.desrt.dconf-editor.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/ca.desrt.dconf-editor.service"
test -f "$UNPACK/usr/share/glib-2.0/schemas/ca.desrt.dconf-editor.gschema.xml"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/ca.desrt.dconf-editor.png"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/help"
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/dconf-editor")
grep -q 'Exec=/usr/bin/dconf-editor --gapplication-service' \
  "$UNPACK/usr/share/dbus-1/services/ca.desrt.dconf-editor.service"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/dconf-editor"

cp -al "$UNPACK/usr/bin/dconf-editor" "$STAGE/pkg/usr/bin/dconf-editor"
chmod 0755 "$STAGE/pkg/usr/bin/dconf-editor"

REPORT="$ROOT/probe/kemi-dconf-editor.json"
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
python3 "$PROBE_PY" --elf "${ELFS[0]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 1:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f = files[0]
if Path(f["path"]).name != "dconf-editor":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libdconf.so.1", "libgio-2.0.so.0", "libgobject-2.0.so.0",
            "libglib-2.0.so.0", "libgtk-3.so.0", "libgdk-3.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=1")
PY

mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/glib-2.0/schemas"
cp -a --remove-destination \
  "$UNPACK/usr/share/glib-2.0/schemas/ca.desrt.dconf-editor.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/ca.desrt.dconf-editor.gschema.xml"
mkdir -p "$STAGE/pkg/usr/share/dbus-1/services"
cp -a --remove-destination \
  "$UNPACK/usr/share/dbus-1/services/ca.desrt.dconf-editor.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/ca.desrt.dconf-editor.service"
mkdir -p "$STAGE/pkg/usr/share/bash-completion/completions"
cp -a --remove-destination \
  "$UNPACK/usr/share/bash-completion/completions/dconf-editor" \
  "$STAGE/pkg/usr/share/bash-completion/completions/dconf-editor"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/dconf-editor.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/dconf-editor.1.gz"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/ca.desrt.dconf-editor.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/ca.desrt.dconf-editor.appdata.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/ca.desrt.dconf-editor.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
grep -q 'Exec=/usr/bin/dconf-editor --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/ca.desrt.dconf-editor.service"

if [[ -f "$UNPACK/usr/share/doc/dconf-editor/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/dconf-editor/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/dconf-editor/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/dconf-editor/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/dconf-editor/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/dconf-editor/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/ca.desrt.dconf-editor.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/ca.desrt.dconf-editor.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=dconf-editor(\s.*)?$", r"Exec=/usr/bin/dconf-editor\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=dconf-editor$", "TryExec=/usr/bin/dconf-editor", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/dconf-editor(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/dconf-editor", text2, count=1, flags=re.M)
if re.search(r"^Exec=dconf-editor(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if not re.search(r"^Exec=/usr/bin/dconf-editor$", text2, flags=re.M):
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/dconf-editor" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=ca.desrt.dconf-editor$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "X-Ubuntu-Gettext-Domain=dconf-editor" not in text2:
    raise SystemExit("MISSING_GETTEXT_DOMAIN")
if "Name=dconf Editor" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/dconf-editor "$STAGE/pkg/opt/dconf-editor/dconf-editor"
ln -sf dconf-editor "$STAGE/pkg/usr/bin/kemi-dconf-editor"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Projects/dconf
Source: https://launchpad.net/ubuntu/+source/dconf-editor
Homepage: https://wiki.gnome.org/Projects/dconf
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) arm64 deb v${VER_UP}
(dconf-editor_3.36.7-0ubuntu1_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 dconf-editor_3.36.7-0ubuntu1_arm64.deb
    (focal-updates universe; newer than Release 3.36.0-1, still
    U20-compatible) repackaged for KEMI as ${PKG}. No same-source
    common/data/typelib package.
  * Official ELF stays at /usr/bin/dconf-editor (compiled
    /usr/share/locale; UI compiled into the ELF).
    /opt/dconf-editor/* are symlinks.
  * Desktop, official D-Bus, gschema, bash-completion, man,
    metainfo and icons stay on standard paths. Official desktop
    Exec=dconf-editor rewritten to /usr/bin/dconf-editor;
    Icon=ca.desrt.dconf-editor (PNG shipped). Official D-Bus
    already Exec=/usr/bin/dconf-editor --gapplication-service.
    Official language-pack split: no .mo and no help in this deb.
  * Conflicts/Replaces dconf-editor. Official Depends kept for
    Ubuntu 20.04 (GTK3, libdconf, glib, libc6 >= 2.17).

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:05:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
dconf Editor ${VER_UP}-0ubuntu1 — official Ubuntu 20.04
(focal-updates) arm64, KEMI repack.

Official ELF stays at /usr/bin/dconf-editor (compiled
/usr/share/locale). /opt/dconf-editor/* are symlinks.
Desktop, official D-Bus, gschema, bash-completion, man,
metainfo and icons remain on standard paths.
Official desktop Icon=ca.desrt.dconf-editor (PNG shipped).
Official language-pack split: no .mo / no help in this deb.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GTK3, libdconf, glib,
dconf-gsettings-backend, libc6 >= 2.17).
Official publication: Ubuntu 20.04 focal-updates universe
arm64 dconf-editor 3.36.7-0ubuntu1. Official SHA256 + size
matched ports.ubuntu.com pool files and focal-updates
universe arm64 Packages stanzas.
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
Depends: dconf-gsettings-backend | gsettings-backend, libc6 (>= 2.17), libdconf1 (>= 0.25.1), libglib2.0-0 (>= 2.55.1), libgtk-3-0 (>= 3.22.0)
Conflicts: dconf-editor
Replaces: dconf-editor
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Projects/dconf
Description: graphical editor for dconf settings (arm64)
 dconf Editor ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Edit settings stored in dconf.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-dconf-editor-control.txt"
