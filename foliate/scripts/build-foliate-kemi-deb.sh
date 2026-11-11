#!/usr/bin/env bash
# Wrap official Foliate 2.6.4 GTK3 all.deb as kemi-foliate.
# Probe: arch=all · 0 ELF · GJS + GTK3 + WebKitGTK 4.0; Ubuntu 20.04 deps packagable.
# Official Depends already match focal (gjs 1.64.5, gir1.2-webkit2-4.0 2.38.6).
# Foliate 3.x official all.deb needs GTK4 / WebKitGTK 6 — not used.
# Launcher libdir was baked as /usr/lib/x86_64-linux-gnu (amd64 build host);
# rewrite prefix/datadir/libdir to /opt/foliate so 101 aarch64 is not pointed at a foreign multiarch dir.
# Reuse existing unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-foliate
VER_UP=2.6.4
VER_DEB="${VER_UP}-1kemi1"
ARCH=all
PKG=kemi-foliate
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/probe/foliate-264-unpack}"
UP_DEB="$DL/com.github.johnfactotum.foliate_2.6.4_all.deb"
EXPECT_SHA=fdc7d45a0b357c4a58aa08ddadf581dd21f3761bc6c74a80e39174ce77b75d66
EXPECT_BYTES=914108
mkdir -p "$DL" "$OUT"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/com.github.johnfactotum.Foliate"
test -f "$UNPACK/usr/share/applications/com.github.johnfactotum.Foliate.desktop"
test -f "$UNPACK/usr/share/com.github.johnfactotum.Foliate/com.github.johnfactotum.Foliate.src.gresource"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/foliate/bin" \
  "$STAGE/pkg/opt/foliate/lib" \
  "$STAGE/pkg/opt/foliate/share"

# App data under /opt/foliate/share (hardlink to avoid doubling disk).
cp -al "$UNPACK/usr/share/com.github.johnfactotum.Foliate" \
  "$STAGE/pkg/opt/foliate/share/com.github.johnfactotum.Foliate"

# Locales stay on the standard gettext path.
while IFS= read -r -d '' mo; do
  rel="${mo#*$UNPACK/usr/share/locale/}"
  dest="$STAGE/pkg/usr/share/locale/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -al "$mo" "$dest"
done < <(find "$UNPACK/usr/share/locale" -name '*.mo' -print0)

# Desktop / icons / schema / metainfo / docs stay under /usr/share so DEs find them.
cp -a --remove-destination \
  "$UNPACK/usr/share/applications/com.github.johnfactotum.Foliate.desktop" \
  "$STAGE/pkg/usr/share/applications/com.github.johnfactotum.Foliate.desktop"
# Point Exec at the KEMI PATH name (absolute).
sed -i -e 's|^Exec=com.github.johnfactotum.Foliate|Exec=/usr/bin/com.github.johnfactotum.Foliate|' \
  "$STAGE/pkg/usr/share/applications/com.github.johnfactotum.Foliate.desktop"
if ! grep -q '^TryExec=' "$STAGE/pkg/usr/share/applications/com.github.johnfactotum.Foliate.desktop"; then
  sed -i '/^Exec=/a TryExec=/usr/bin/com.github.johnfactotum.Foliate' \
    "$STAGE/pkg/usr/share/applications/com.github.johnfactotum.Foliate.desktop"
fi

cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/scalable/apps/com.github.johnfactotum.Foliate.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/com.github.johnfactotum.Foliate.svg"
cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/symbolic/apps/com.github.johnfactotum.Foliate-symbolic.svg" \
  "$STAGE/pkg/usr/share/icons/hicolor/symbolic/apps/com.github.johnfactotum.Foliate-symbolic.svg"
cp -a --remove-destination \
  "$UNPACK/usr/share/glib-2.0/schemas/com.github.johnfactotum.Foliate.gschema.xml" \
  "$STAGE/pkg/usr/share/glib-2.0/schemas/com.github.johnfactotum.Foliate.gschema.xml"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/com.github.johnfactotum.Foliate.metainfo.xml" \
  "$STAGE/pkg/usr/share/metainfo/com.github.johnfactotum.Foliate.metainfo.xml"
if [[ -f "$UNPACK/usr/share/doc/com.github.johnfactotum.foliate/copyright" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/com.github.johnfactotum.foliate/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/com.github.johnfactotum.foliate/changelog.gz" ]]; then
  cp -a --remove-destination \
    "$UNPACK/usr/share/doc/com.github.johnfactotum.foliate/changelog.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi

# Rewritten GJS launcher: official all.deb hardcodes libdir=/usr/lib/x86_64-linux-gnu.
cat > "$STAGE/pkg/opt/foliate/bin/com.github.johnfactotum.Foliate" << 'EOT'
#!/usr/bin/gjs
imports.package.init({
  name: "com.github.johnfactotum.Foliate",
  version: "2.6.4",
  prefix: "/opt/foliate",
  libdir: "/opt/foliate/lib",
  datadir: "/opt/foliate/share",
});
imports.package.run(imports.main);
EOT
chmod 0755 "$STAGE/pkg/opt/foliate/bin/com.github.johnfactotum.Foliate"
ln -s /opt/foliate/bin/com.github.johnfactotum.Foliate \
  "$STAGE/pkg/usr/bin/com.github.johnfactotum.Foliate"
ln -s /opt/foliate/bin/com.github.johnfactotum.Foliate \
  "$STAGE/pkg/usr/bin/foliate"

# Probe report: 0 ELF (GJS + data + wasm). Record explicitly.
REPORT="$ROOT/probe/kemi-foliate.json"
python3 - << PY
import json, os
from pathlib import Path
root = Path("$STAGE/pkg")
elfs = []
wasm = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        magic = f.read(8)
    if magic.startswith(b"\\x7fELF"):
        elfs.append(str(p))
    elif magic.startswith(b"\\x00asm"):
        wasm.append({"path": str(p.relative_to(root)), "bytes": p.stat().st_size})
report = {
    "package": "$PKG",
    "version": "$VER_DEB",
    "architecture": "$ARCH",
    "target_arch": "arm64",
    "max_glibc": "2.31",
    "elf_count": len(elfs),
    "elfs": elfs,
    "wasm_count": len(wasm),
    "wasm": wasm,
    "requiredGlibc": None,
    "pass": len(elfs) == 0,
    "note": "arch=all GJS GTK3 ebook viewer; no native ELF. Runtime: gjs>=1.52, gir1.2-webkit2-4.0, dconf-gsettings-backend|gsettings-backend, python3 (KindleUnpack). Ubuntu 20.04 focal arm64: gjs 1.64.5, gir1.2-webkit2-4.0 2.38.6, dconf 0.36.0, python3 3.8.2 — packagable. Foliate 3.x needs GTK4/WebKitGTK 6 and was not used.",
}
Path("$REPORT").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\\n")
if elfs:
    raise SystemExit("UNEXPECTED_ELF")
print("PROBE_PASS elf_count=0 wasm_count=%d" % len(wasm))
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official com.github.johnfactotum.foliate_2.6.4_all.deb (GTK3, last 2.x line)
    repackaged for KEMI as ${PKG}.
  * Layout /opt/foliate + /usr/bin/{com.github.johnfactotum.Foliate,foliate}.
  * Launcher libdir rewritten off x86_64-linux-gnu to /opt/foliate/lib.
  * Depends kept for Ubuntu 20.04 (gjs, gir1.2-webkit2-4.0); added python3.
  * Foliate 3.x (GTK4 / WebKitGTK 6) not used.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 16:30:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Foliate ${VER_UP} — official GTK3 all.deb, KEMI repack.

Installs under /opt/foliate/; launchers /usr/bin/com.github.johnfactotum.Foliate and /usr/bin/foliate.
No native ELF (GJS + data + bundled libarchive.wasm). Ubuntu 20.04 / glibc 2.31 OK.
Runtime: gjs (>= 1.52), gir1.2-webkit2-4.0 (WebKitGTK 4.0 / GTK3), a GSettings backend, python3 (Kindle/MOBI unpack).
Foliate 3.x official all.deb needs GTK4 / WebKitGTK 6 and is not used.
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
Depends: dconf-gsettings-backend | gsettings-backend, gjs (>= 1.52), gir1.2-webkit2-4.0, python3
Recommends: gir1.2-gspell-1, gir1.2-handy-0.0, iso-codes (>= 3.67)
Conflicts: com.github.johnfactotum.foliate, foliate
Replaces: com.github.johnfactotum.foliate, foliate
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://johnfactotum.github.io/foliate/
Description: Foliate eBook viewer (GTK3)
 Foliate ${VER_UP} — official GTK3 all.deb, KEMI repack.
 Simple modern GTK eBook viewer (GJS + Epub.js). glibc≤2.31 (Ubuntu 20.04).
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
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
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
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-foliate-control.txt"
