#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) keepassxc
# 2.4.3+dfsg.1-1build1 arm64 as kemi-keepassxc.
# There is no same-source -data/-common binary in focal (source
# keepassxc ships only this one package). Official control has
# no Recommends and no Suggests. System Qt5 and library Depends
# stay Depends and are not bundled. Versioned Provides:
# keepassxc (= 2.4.3+dfsg.1-1build1).
# Official binaries: /usr/bin/keepassxc, keepassxc-cli,
# keepassxc-proxy, plus official autotype plugin
# /usr/lib/aarch64-linux-gnu/keepassxc/libkeepassx-autotype-xcb.so.
# The main/cli ELFs embed /usr and a relative share/keepassxc
# datadir, so official files stay on official paths;
# /opt/keepassxc/* are symlinks (same compiled-/usr layout as
# homebank/dia/pidgin and earlier siblings).
# Official translations are 42 Qt .qm files including
# keepassx_zh_CN.qm under /usr/share/keepassxc/translations
# (no gettext .mo). Keep the official tree; do not invent or
# bundle language-packs or extra UI/icons.
# Official changelog is a real file. No official maintainer
# scripts or conffiles. No /usr/share/help.
# Leftover /workspace/t140-20261108-keepassxc probed the
# upstream KeePassXC 2.8.0-1 aarch64 AppImage (glibc 2.38 /
# GLIBCXX 3.4.32 / Qt6) and SKIPped that asset. This job
# packages the official Ubuntu 20.04 focal universe Qt5 deb
# instead; the AppImage SKIP does not apply to this package.
# Probe: aarch64 · 4 ELF · requiredGlibc max 2.29 (keepassxc
# and keepassxc-cli 2.29; keepassxc-proxy and autotype 2.17)
# · requiredGlibcxx max 3.4.21 (autotype 3.4) · PASS vs 101
# ≤2.31 / ≤3.4.28. None-safe: 4 glibc versioned, 0 null;
# 4 GLIBCXX versioned, 0 null.
# Official SHA256 + size matched official ports.ubuntu.com
# pool files and the Ubuntu 20.04 focal universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror, streamed).
# No newer package in focal-updates. No librarian URL and no
# .buildinfo is recorded this run (pool 404).
# KEMI version 2.4.3+dfsg.1-1build1kemi1 is 25 chars (under
# the mall version_name limit that rejected Remmina's
# 33-char string; homebank 5.3.2-1kemi1 was 12 chars).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-keepassxc
VER_UP=2.4.3+dfsg.1-1build1
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-keepassxc
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/keepassxc-2.4.3-focal-unpack}"
UP_DEB="$DL/keepassxc_2.4.3+dfsg.1-1build1_arm64.deb"
EXPECT_SHA=f79713282c966d4add61941b60cd3fd3fd93c9bc284cdee7b3b196de38775f96
EXPECT_BYTES=1820088
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/keepassxc"
test -x "$UNPACK/usr/bin/keepassxc-cli"
test -x "$UNPACK/usr/bin/keepassxc-proxy"
test -f "$UNPACK/usr/lib/aarch64-linux-gnu/keepassxc/libkeepassx-autotype-xcb.so"
test -f "$UNPACK/usr/share/applications/org.keepassxc.KeePassXC.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/keepassxc.png"
test -f "$UNPACK/usr/share/keepassxc/translations/keepassx_zh_CN.qm"
test "$(find "$UNPACK" -name '*.qm' | wc -l)" = 42
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -d "$UNPACK/usr/share/help"
test ! -L "$UNPACK/usr/share/doc/keepassxc/changelog.Debian.gz"
# compiled prefix / relative datadir — process substitution, no SIGPIPE
grep -qx '/usr' < <(strings -n 4 "$UNPACK/usr/bin/keepassxc")
grep -qx 'share/keepassxc' < <(strings -n 8 "$UNPACK/usr/bin/keepassxc")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/keepassxc" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/doc/keepassxc" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/icons" \
  "$STAGE/pkg/usr/share/keepassxc" \
  "$STAGE/pkg/usr/share/mime/packages" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/keepassxc"

cp -al "$UNPACK/usr/bin/keepassxc" "$STAGE/pkg/usr/bin/keepassxc"
cp -al "$UNPACK/usr/bin/keepassxc-cli" "$STAGE/pkg/usr/bin/keepassxc-cli"
cp -al "$UNPACK/usr/bin/keepassxc-proxy" "$STAGE/pkg/usr/bin/keepassxc-proxy"
chmod 0755 "$STAGE/pkg/usr/bin/keepassxc" \
  "$STAGE/pkg/usr/bin/keepassxc-cli" \
  "$STAGE/pkg/usr/bin/keepassxc-proxy"
cp -a "$UNPACK/usr/lib/aarch64-linux-gnu/keepassxc/." \
  "$STAGE/pkg/usr/lib/aarch64-linux-gnu/keepassxc/"

REPORT="$ROOT/probe/kemi-keepassxc.json"
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
test "${#ELFS[@]}" = 4
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
if len(files) != 4:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by = {Path(f["path"]).name: f for f in files}
need = {
    "keepassxc": ("2.29", "3.4.21"),
    "keepassxc-cli": ("2.29", "3.4.21"),
    "keepassxc-proxy": ("2.17", "3.4.21"),
    "libkeepassx-autotype-xcb.so": ("2.17", "3.4"),
}
if set(by) != set(need):
    raise SystemExit(f"PROBE_NAMES:{sorted(by)}")
versioned = [f for f in files if f.get("requiredGlibc") is not None]
nulls = [f for f in files if f.get("requiredGlibc") is None]
cxx = [f for f in files if f.get("requiredGlibcxx") is not None]
cxx_null = [f for f in files if f.get("requiredGlibcxx") is None]
if len(versioned) != 4 or nulls or len(cxx) != 4 or cxx_null:
    raise SystemExit("PROBE_NONE_SAFE_COUNTS")
for name, (glibc, cxxv) in need.items():
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH:{name}")
    if f.get("requiredGlibc") != glibc:
        raise SystemExit(f"PROBE_GLIBC:{name}:{f.get('requiredGlibc')}")
    if f.get("requiredGlibcxx") != cxxv:
        raise SystemExit(f"PROBE_GLIBCXX:{name}:{f.get('requiredGlibcxx')}")
needed = set(by["keepassxc"].get("neededLibraries") or [])
for lib in ("libQt5Widgets.so.5", "libQt5Core.so.5", "libgcrypt.so.20", "libc.so.6", "libstdc++.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS n_elf=4 arch=aarch64 glibc_versioned=4 glibc_null=0 max_glibc=2.29 glibcxx_versioned=4 glibcxx_null=0 max_glibcxx=3.4.21")
PY

cp -a "$UNPACK/usr/share/keepassxc/." "$STAGE/pkg/usr/share/keepassxc/"
cp -a "$UNPACK/usr/share/icons/." "$STAGE/pkg/usr/share/icons/"
cp -a "$UNPACK/usr/share/doc/keepassxc/." "$STAGE/pkg/usr/share/doc/keepassxc/"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/keepassxc.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/keepassxc.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/keepassxc-cli.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/keepassxc-cli.1.gz"
cp -a --remove-destination "$UNPACK/usr/share/mime/packages/keepassxc.xml" \
  "$STAGE/pkg/usr/share/mime/packages/keepassxc.xml"
cp -a --remove-destination "$UNPACK/usr/share/metainfo/org.keepassxc.KeePassXC.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.keepassxc.KeePassXC.appdata.xml"

test "$(find "$STAGE/pkg" -name '*.qm' | wc -l)" = 42
test -f "$STAGE/pkg/usr/share/keepassxc/translations/keepassx_zh_CN.qm"
test -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/keepassxc.png"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/keepassxc.png"
test -f "$STAGE/pkg/usr/share/keepassxc/wordlists/eff_large.wordlist"
test ! -d "$STAGE/pkg/usr/share/help"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/keepassxc/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/keepassxc/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/org.keepassxc.KeePassXC.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.keepassxc.KeePassXC.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=keepassxc(\s.*)?$", r"Exec=/usr/bin/keepassxc\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=keepassxc$", "TryExec=/usr/bin/keepassxc", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/keepassxc(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/keepassxc", text2, count=1, flags=re.M)
if re.search(r"^Exec=keepassxc(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if re.search(r"^TryExec=keepassxc$", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_TRYEXEC")
for expect in ("Exec=/usr/bin/keepassxc %f", "TryExec=/usr/bin/keepassxc"):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=keepassxc$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=KeePassXC" not in text2:
    raise SystemExit("MISSING_NAME")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/keepassxc "$STAGE/pkg/opt/keepassxc/keepassxc"
ln -sf /usr/bin/keepassxc-cli "$STAGE/pkg/opt/keepassxc/keepassxc-cli"
ln -sf /usr/bin/keepassxc-proxy "$STAGE/pkg/opt/keepassxc/keepassxc-proxy"
ln -sf keepassxc "$STAGE/pkg/usr/bin/kemi-keepassxc"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.keepassxc.org/
Source: https://launchpad.net/ubuntu/+source/keepassxc
Homepage: https://www.keepassxc.org/
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(keepassxc_2.4.3+dfsg.1-1build1_arm64.deb), repackaged
for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 keepassxc_2.4.3+dfsg.1-1build1_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. No same-source data package
    in focal. Official control has no Recommends or Suggests.
    Versioned Provides: keepassxc (= 2.4.3+dfsg.1-1build1).
  * Official ELFs stay at /usr/bin/keepassxc,
    /usr/bin/keepassxc-cli, /usr/bin/keepassxc-proxy and
    /usr/lib/aarch64-linux-gnu/keepassxc/libkeepassx-autotype-xcb.so
    (compiled /usr plus relative share/keepassxc).
    /opt/keepassxc/* are symlinks.
  * Desktop, man, official 42 Qt .qm (including zh_CN),
    hicolor icons, /usr/share/keepassxc data, mime and
    AppStream metadata stay on standard paths. Official
    desktop Exec=keepassxc rewritten to /usr/bin/keepassxc;
    Icon=keepassxc. Official changelogs are real files.
  * Distinct from the leftover t140 KeePassXC 2.8.0-1
    aarch64 AppImage SKIP (glibc 2.38 / Qt6). This package
    is the official Ubuntu 20.04 Qt5 deb.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:39:31 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
KeePassXC ${VER_UP} — official Ubuntu 20.04
(focal) universe arm64, KEMI repack.

Official ELFs stay at /usr/bin/keepassxc,
keepassxc-cli, keepassxc-proxy and the official
autotype plugin under
/usr/lib/aarch64-linux-gnu/keepassxc/.
/opt/keepassxc/* are symlinks. Desktop, man,
official 42 Qt .qm (including zh_CN), icons and
data remain on standard paths.
Probe: aarch64 · 4 ELF · requiredGlibc max 2.29
(2 versioned at 2.29, 2 at 2.17, 0 null) ·
requiredGlibcxx max 3.4.21 (3 at 3.4.21, 1 at
3.4, 0 null); Ubuntu 20.04 / glibc 2.31 /
GLIBCXX 3.4.28 OK.
Official publication: Ubuntu 20.04 focal universe
arm64 keepassxc 2.4.3+dfsg.1-1build1. Official
SHA256 + size matched ports.ubuntu.com pool files
and focal universe arm64 Packages stanza. No
librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libargon2-1 (>= 0~20171227), libc6 (>= 2.29), libgcrypt20 (>= 1.8.0), libqrencode4 (>= 3.2.0), libqt5concurrent5 (>= 5.6.0~rc), libqt5core5a (>= 5.10.0), libqt5dbus5 (>= 5.0.2), libqt5gui5 (>= 5.10.0) | libqt5gui5-gles (>= 5.10.0), libqt5network5 (>= 5.0.2), libqt5svg5 (>= 5.6.0~beta), libqt5widgets5 (>= 5.11.0~rc1), libqt5x11extras5 (>= 5.6.0), libsodium23 (>= 1.0.8), libstdc++6 (>= 5.2), libx11-6, libxi6, libxtst6, libykpers-1-1 (>= 1.12.0), libzxcvbn0 (>= 0.20150103), zlib1g (>= 1:1.1.4)
Replaces: keepassxc
Conflicts: keepassxc
Provides: keepassxc (= 2.4.3+dfsg.1-1build1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.keepassxc.org/
Description: Cross Platform Password Manager (arm64)
 KeePassXC ${VER_UP} — official Ubuntu 20.04
 arm64, KEMI repack.
 Community-driven KeePass password manager (Qt5).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches /usr/share/icons/hicolor || true
elif command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-keepassxc-control.txt"
