#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) pluma 1.24.0-1 arm64
# plus pluma-common all and gir1.2-pluma-1.0 arm64 as
# kemi-pluma (common + typelib bundled).
# Probe: aarch64 · 10 ELF (pluma + 9 plugin .so) · requiredGlibc
#   2.17 · no GLIBCXX · PASS vs 101 ≤2.31
#   pluma: GTK3 + GDK3 + GtkSourceView 3 + libpeas/libpeas-gtk +
#     Pango + ATK + Cairo + GDK-Pixbuf + GIO/GObject/GLib +
#     X11 + ICE/SM + girepository + pthread + libc
#   plugins also use libxml2 and libenchant.so.1 where relevant
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.17,
#   libatk1.0-0 >= 1.12.4, libcairo2 >= 1.2.4,
#   libenchant1c2a >= 1.6.0, libgdk-pixbuf2.0-0 >= 2.22.0,
#   libgirepository-1.0-1 >= 0.9.3, libglib2.0-0 >= 2.37.3,
#   libgtk-3-0 >= 3.21.6, libgtksourceview-3.0-1 >= 3.23.90,
#   libice6 >= 1:1.0.0, libpango-1.0-0 >= 1.14.0,
#   libpeas-1.0-0 >= 1.0.0, libsm6, libx11-6, libxml2 >= 2.7.4,
#   gir1.2-peas-1.0, iso-codes, mate-desktop-common).
# pluma-common (= 1.24.0-1) is bundled (official arch:all;
#   Depends: python3, dconf-gsettings-backend | gsettings-backend
#   — folded into this package).
# gir1.2-pluma-1.0 (= 1.24.0-1) is bundled (same-source typelib,
#   exact-version Depends; typelib stays at compiled
#   /usr/lib/aarch64-linux-gnu/girepository-1.0/Pluma-1.0.typelib).
# Official mate-desktop-common remains a Depends (different
#   source, not bundled). Official Recommends (zenity) stay as
#   Recommends and are not bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal universe arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed — not saved as a Packages.gz dump). There is no
#   newer focal-updates binary; this is the current official
#   focal Release arm64 build. No librarian URL is recorded
#   this run.
# The official ELF embeds compiled /usr prefixes
#   (/usr/share/pluma, /usr/share/applications/pluma.desktop,
#   /usr/lib/aarch64-linux-gnu). Layout therefore keeps the
#   official ELF at /usr/bin/pluma and the plugin .so files at
#   /usr/lib/aarch64-linux-gnu/pluma/plugins.
#   /opt/pluma/pluma is a symlink to /usr/bin/pluma (KEMI
#   layout marker), not the real ELF (HardInfo/Xpad/qpdfview).
# Official desktop Icon=accessories-text-editor (theme icon,
#   not shipped in this deb). Exec=pluma %U (no TryExec
#   upstream). 119 locales including zh_CN / zh_TW; help
#   includes C and zh_CN (real files, not langpack symlinks).
# Python 3 plugins ship under the plugin dir (no PEP 585
#   annotations). Reuse existing unpacked tree; do not
#   re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-pluma
VER_UP=1.24.0
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-pluma
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/pluma-1.24.0-1-focal-unpack}"
UP_DEB="$DL/pluma_1.24.0-1_arm64.deb"
COM_DEB="$DL/pluma-common_1.24.0-1_all.deb"
GIR_DEB="$DL/gir1.2-pluma-1.0_1.24.0-1_arm64.deb"
EXPECT_SHA=f8f27a21899d3d2cceb4c918f17754344db6feebb552c89604a4bdd8438124cb
EXPECT_BYTES=392936
COM_SHA=f63c8ed3498b6316fc97d3850371268e5e8ac11083aa3f91bafb339d6a7898ce
COM_BYTES=1817508
GIR_SHA=d7dd21131bc76d7aed73914e4076dc6573b61933bda4ca71a7b57844f9e3cffe
GIR_BYTES=20788
PLUGIN_DIR="usr/lib/aarch64-linux-gnu/pluma/plugins"
TYPELIB="usr/lib/aarch64-linux-gnu/girepository-1.0/Pluma-1.0.typelib"
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB" && test -f "$COM_DEB" && test -f "$GIR_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$COM_DEB")" = "$COM_BYTES"
test "$(stat -c%s "$GIR_DEB")" = "$GIR_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$COM_SHA  $COM_DEB" | sha256sum -c -
echo "$GIR_SHA  $GIR_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/pluma"
test -f "$UNPACK/$TYPELIB"
test -f "$UNPACK/$PLUGIN_DIR/libspell.so"
test -f "$UNPACK/$PLUGIN_DIR/libfilebrowser.so"
test -f "$UNPACK/usr/share/applications/pluma.desktop"
test -f "$UNPACK/usr/share/man/man1/pluma.1.gz"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.mate.pluma.gschema.xml"
test -f "$UNPACK/usr/share/pluma/ui/pluma-ui.xml"
test -f "$UNPACK/usr/share/pluma/pluma.about"
test -f "$UNPACK/usr/share/metainfo/pluma.appdata.xml"
test -f "$UNPACK/usr/share/help/C/pluma/index.docbook"
test -f "$UNPACK/usr/share/help/zh_CN/pluma/index.docbook"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/pluma.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/pluma.mo"
test "$(find "$UNPACK/usr/share/locale" -name 'pluma.mo' | wc -l)" = 119
# compiled /usr prefixes — ELF must stay at /usr/bin
# Process substitution avoids SIGPIPE/pipefail (grep -qx exits early).
grep -qx '/usr/share/pluma' < <(strings -n 8 "$UNPACK/usr/bin/pluma")
grep -qx '/usr/share/applications/pluma.desktop' < <(strings -n 8 "$UNPACK/usr/bin/pluma")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/pluma"

# Official ELF stays at /usr/bin/pluma (compiled /usr prefixes).
cp -al "$UNPACK/usr/bin/pluma" "$STAGE/pkg/usr/bin/pluma"
chmod 0755 "$STAGE/pkg/usr/bin/pluma"

# Plugins + typelib stay on compiled /usr/lib paths (hardlink tree).
mkdir -p "$STAGE/pkg/usr/lib/aarch64-linux-gnu"
cp -al "$UNPACK/usr/lib/aarch64-linux-gnu/pluma" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/pluma"
mkdir -p "$STAGE/pkg/usr/lib/aarch64-linux-gnu/girepository-1.0"
cp -al "$UNPACK/$TYPELIB" "$STAGE/pkg/$TYPELIB"
if [[ -d "$UNPACK/usr/lib/pluma" ]]; then
  cp -al "$UNPACK/usr/lib/pluma" "$STAGE/pkg/usr/lib/pluma"
fi
test -f "$STAGE/pkg/$PLUGIN_DIR/libspell.so"
test -f "$STAGE/pkg/$TYPELIB"

# Probe staged ELFs before packing.
REPORT="$ROOT/probe/kemi-pluma.json"
rm -f "$REPORT"
mapfile -t ELFS < <(python3 - << PY
from pathlib import Path
root=Path("$STAGE/pkg")
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4)==b"\\x7fELF":
            print(p)
PY
)
test "${#ELFS[@]}" = 10
PROBE_ARGS=()
for e in "${ELFS[@]}"; do PROBE_ARGS+=(--elf "$e"); done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r=json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
if len(r.get("files") or []) != 10:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by={Path(f["path"]).name:f for f in r["files"]}
if "pluma" not in by:
    raise SystemExit("PROBE_MISSING_MAIN")
for name,f in by.items():
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") not in (None, ""):
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed=set(by["pluma"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libgtksourceview-3.0.so.1",
            "libpeas-1.0.so.0", "libpeas-gtk-1.0.so.0", "libpango-1.0.so.0",
            "libatk-1.0.so.0", "libcairo.so.2", "libgdk_pixbuf-2.0.so.0",
            "libgio-2.0.so.0", "libgobject-2.0.so.0", "libglib-2.0.so.0",
            "libgirepository-1.0.so.1", "libX11.so.6", "libICE.so.6",
            "libSM.so.6", "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 no-GLIBCXX arch=aarch64 n_elf=10")
PY

# Locales, help, UI, schemas, icons-in-share, man, metainfo stay on /usr/share.
cp -a "$UNPACK/usr/share/locale" "$STAGE/pkg/usr/share/locale"
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
cp -a "$UNPACK/usr/share/pluma" "$STAGE/pkg/usr/share/pluma"
cp -a "$UNPACK/usr/share/glib-2.0/schemas/." "$STAGE/pkg/usr/share/glib-2.0/schemas/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/pluma.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/pluma.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/pluma.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/pluma.appdata.xml"
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/pluma.mo"
test "$(find "$STAGE/pkg/usr/share/locale" -name 'pluma.mo' | wc -l)" = 119
test -f "$STAGE/pkg/usr/share/help/zh_CN/pluma/index.docbook"
test -f "$STAGE/pkg/usr/share/pluma/ui/pluma-ui.xml"
test -f "$STAGE/pkg/usr/share/glib-2.0/schemas/org.mate.pluma.gschema.xml"

# Official pluma changelog.Debian.gz may be a symlink into
# ../gir1.2-pluma-1.0/; dereference so the kemi doc is a real file.
if [[ -f "$UNPACK/usr/share/doc/pluma/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/pluma/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/pluma/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/pluma/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

# Desktop: keep official Icon=accessories-text-editor; point Exec/TryExec.
sed -e 's|^Exec=pluma %U$|Exec=/usr/bin/pluma %U|' \
    -e 's|^Exec=pluma$|Exec=/usr/bin/pluma|' \
    -e 's|^TryExec=pluma$|TryExec=/usr/bin/pluma|' \
  "$UNPACK/usr/share/applications/pluma.desktop" \
  > "$STAGE/pkg/usr/share/applications/pluma.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/pluma.desktop"; then
  sed -i '/^Exec=\/usr\/bin\/pluma %U$/a TryExec=/usr/bin/pluma' \
    "$STAGE/pkg/usr/share/applications/pluma.desktop"
fi
grep -q '^Exec=/usr/bin/pluma %U$' "$STAGE/pkg/usr/share/applications/pluma.desktop"
grep -q '^TryExec=/usr/bin/pluma$' "$STAGE/pkg/usr/share/applications/pluma.desktop"
grep -q '^Icon=accessories-text-editor$' "$STAGE/pkg/usr/share/applications/pluma.desktop"
if grep -E '^Exec=pluma( |$)' "$STAGE/pkg/usr/share/applications/pluma.desktop"; then
  echo "LEFTOVER_RELATIVE_EXEC" >&2
  exit 1
fi

# /opt is a layout marker only — symlink to the official ELF path.
ln -sf /usr/bin/pluma "$STAGE/pkg/opt/pluma/pluma"
ln -sf pluma "$STAGE/pkg/usr/bin/kemi-pluma"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://www.mate-desktop.org/
Source: https://launchpad.net/ubuntu/+source/pluma
Homepage: http://www.mate-desktop.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(pluma_1.24.0-1_arm64.deb) plus official arch:all
pluma-common_1.24.0-1_all.deb and official
gir1.2-pluma-1.0_1.24.0-1_arm64.deb
repackaged for KEMI as ${PKG} (common + typelib bundled).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 pluma_1.24.0-1_arm64.deb (focal
    universe) plus official pluma-common and gir1.2-pluma-1.0
    of the same version, repackaged for KEMI as ${PKG}
    (common + typelib bundled).
  * Official ELF stays at /usr/bin/pluma because the binary
    embeds compiled /usr prefixes (/usr/share/pluma,
    /usr/lib/aarch64-linux-gnu). Plugin .so files and the
    typelib stay on those standard /usr/lib paths.
    /opt/pluma/pluma is a symlink to /usr/bin/pluma.
  * Desktop, man, GSettings schemas, metainfo, UI, help and
    119 locales including zh_CN / zh_TW stay on standard
    /usr/share paths. Official desktop
    Icon=accessories-text-editor (theme icon, not shipped).
  * Conflicts/Replaces pluma, pluma-common, gir1.2-pluma-1.0;
    also Breaks/Replaces mate-text-editor (<< 1.5.0) and
    Provides: mate-text-editor, matching official.
  * Depends kept for Ubuntu 20.04 (GTK3, GtkSourceView 3,
    libpeas, typelibs gir1.2-peas-1.0 / gtk / gtksource,
    enchant, cairo, pango, iso-codes, mate-desktop-common,
    python3, gsettings backend, libc6 >= 2.17).
    Recommends: zenity.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 19:58:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Pluma ${VER_UP}-1 — official Ubuntu 20.04 (focal) arm64,
KEMI repack (pluma-common + gir1.2-pluma-1.0 bundled).

The official ELF stays at /usr/bin/pluma (compiled /usr
prefixes for data and plugins). /opt/pluma/pluma is a
symlink to /usr/bin/pluma. Plugin .so files stay at
/usr/lib/aarch64-linux-gnu/pluma/plugins; the typelib stays
at /usr/lib/aarch64-linux-gnu/girepository-1.0/Pluma-1.0.typelib.
Desktop, man, GSettings schemas, metainfo, UI, help and
locales remain on standard /usr/share paths.
Official desktop Icon=accessories-text-editor (theme icon).
119 locales including zh_CN / zh_TW are bundled. Help includes
C and zh_CN as real files.
Probe: aarch64 · 10 ELF · requiredGlibc 2.17 · no GLIBCXX ·
GTK3 + GtkSourceView 3 + libpeas; Ubuntu 20.04 / glibc 2.31 OK.
Runtime: gir1.2-peas-1.0, iso-codes, mate-desktop-common,
python3, dconf-gsettings-backend | gsettings-backend,
libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4),
libenchant1c2a (>= 1.6.0), libgdk-pixbuf2.0-0 (>= 2.22.0),
libgirepository-1.0-1 (>= 0.9.3), libglib2.0-0 (>= 2.37.3),
libgtk-3-0 (>= 3.21.6), libgtksourceview-3.0-1 (>= 3.23.90),
libice6 (>= 1:1.0.0), libpango-1.0-0 (>= 1.14.0),
libpeas-1.0-0 (>= 1.0.0), libsm6, libx11-6, libxml2 (>= 2.7.4).
Recommends: zenity.
Official publication: Ubuntu 20.04 focal universe arm64
pluma 1.24.0-1 (current official U20 package; no newer
focal-updates binary). Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64 Packages
stanzas.
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
Depends: gir1.2-peas-1.0, iso-codes, mate-desktop-common, python3, dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libenchant1c2a (>= 1.6.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libgirepository-1.0-1 (>= 0.9.3), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.6), libgtksourceview-3.0-1 (>= 3.23.90), libice6 (>= 1:1.0.0), libpango-1.0-0 (>= 1.14.0), libpeas-1.0-0 (>= 1.0.0), libsm6, libx11-6, libxml2 (>= 2.7.4)
Recommends: zenity
Conflicts: pluma, pluma-common, gir1.2-pluma-1.0
Replaces: pluma, pluma-common, gir1.2-pluma-1.0, mate-text-editor (<< 1.5.0)
Breaks: mate-text-editor (<< 1.5.0)
Provides: mate-text-editor
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://www.mate-desktop.org/
Description: official text editor of the MATE desktop (arm64)
 Pluma ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Tabbed GTK3 text editor with syntax highlighting and plugins
 (common + typelib bundled).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v py3compile >/dev/null 2>&1; then
  py3compile /usr/lib/aarch64-linux-gnu/pluma/plugins >/dev/null 2>&1 || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
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
if command -v py3clean >/dev/null 2>&1; then
  py3clean /usr/lib/aarch64-linux-gnu/pluma/plugins >/dev/null 2>&1 || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-pluma-control.txt"
