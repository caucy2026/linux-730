#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) claws-mail
# 3.17.5-2 arm64 as kemi-claws-mail. There is no same-source
# claws-mail-common / claws-mail-data package (single official
# binary). Official Recommends claws-mail-i18n
#   (Depends: claws-mail (>= 3.17.5-2), not exact =)
#   stays Recommends and is not bundled (official language-pack
#   split; this deb ships no .mo). Official Recommends
#   xfonts-100dpi | xfonts-75dpi | transcoded variants and
#   aspell-en | aspell-dictionary also stay Recommends.
# Official Suggests claws-mail-doc (= 3.17.5-2),
#   www-browser, editors, claws-mail-tools stay Suggests
#   and are not bundled.
# Same-source plugin packages (acpi-notifier, address-keeper,
#   archiver-plugin, attach-remover, attach-warner, bogofilter,
#   bsfilter-plugin, clamd-plugin, dillo-viewer, feeds-reader,
#   fetchinfo-plugin, gdata-plugin, libravatar, litehtml-viewer,
#   mailmbox-plugin, managesieve, multi-notifier, newmail-plugin,
#   pdf-viewer, perl-filter, pgpinline, pgpmime, smime-plugin,
#   spam-report, spamassassin, tnef-parser, vcalendar-plugin)
#   and metapackages (claws-mail-plugins, claws-mail-extra-plugins)
#   are NOT official Recommends of claws-mail. Even though most
#   plugin packages Depends: claws-mail (= 3.17.5-2), they are
#   not bundled (Remmina/AbiWord exact-version bundling applies
#   only to official Recommends plugins). Versioned
#   Provides: claws-mail (= 3.17.5-2) lets later apt-install of
#   those plugins and of claws-mail-i18n work.
# claws-mail-themes is a different source and is not bundled.
# libclaws-mail-dev is a -dev package and is not bundled.
# Official binary: /usr/bin/claws-mail (compiled prefix bound
#   to /usr; ELF embeds /usr/lib/aarch64-linux-gnu/claws-mail/plugins/,
#   /usr/share/claws-mail, /usr/share/locale). Official main
#   package ships neither that plugin dir nor /usr/share/claws-mail
#   — do not invent them. /opt/claws-mail/* are symlinks
#   (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/
#   GNOME Disks/GNOME System Monitor/GParted/Seahorse/Remmina/
#   dconf-editor/xfce4-terminal/thunar/pcmanfm/geany/filezilla/
#   blueman/audacious/abiword/shotwell/gnumeric).
# Official icons (hicolor 48/64/128 png + pixmaps xpm) are kept;
#   do not invent additional UI/icons. Official language-pack
#   split: this deb ships no .mo; translations live in
#   Recommended claws-mail-i18n. Keep the official tree; do not
#   invent/bundle language-packs. No help directory in this deb
#   (manual is claws-mail-doc, a Suggests).
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404).
# KEMI version 3.17.5-2kemi1 is 13 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-claws-mail
VER_UP=3.17.5
VER_DEB="${VER_UP}-2kemi1"
ARCH=arm64
PKG=kemi-claws-mail
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/claws-mail-3.17.5-focal-unpack}"
UP_DEB="$DL/claws-mail_3.17.5-2_arm64.deb"
EXPECT_SHA=aecbd78db1573d7713c1bf640b6a9c7561919dba3bcb9edbeac259e38573fec1
EXPECT_BYTES=1288336
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/claws-mail"
test -f "$UNPACK/usr/share/applications/claws-mail.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/128x128/apps/claws-mail.png"
test -f "$UNPACK/usr/share/icons/hicolor/64x64/apps/claws-mail.png"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/claws-mail.png"
test -f "$UNPACK/usr/share/pixmaps/claws-mail-32x32.xpm"
test -f "$UNPACK/usr/share/man/man1/claws-mail.1.gz"
test ! -d "$UNPACK/usr/share/help"
test ! -d "$UNPACK/usr/share/claws-mail"
test ! -d "$UNPACK/usr/lib/aarch64-linux-gnu/claws-mail"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test ! -L "$UNPACK/usr/share/doc/claws-mail/changelog.Debian.gz"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/claws-mail")
grep -qx '/usr/lib/aarch64-linux-gnu/claws-mail/plugins/' < <(strings -n 8 "$UNPACK/usr/bin/claws-mail")
grep -qx '/usr/share/claws-mail' < <(strings -n 8 "$UNPACK/usr/bin/claws-mail")

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/64x64/apps" \
  "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps" \
  "$STAGE/pkg/usr/share/pixmaps" \
  "$STAGE/pkg/usr/share/lintian/overrides" \
  "$STAGE/pkg/opt/claws-mail"

cp -al "$UNPACK/usr/bin/claws-mail" "$STAGE/pkg/usr/bin/claws-mail"
chmod 0755 "$STAGE/pkg/usr/bin/claws-mail"

REPORT="$ROOT/probe/kemi-claws-mail.json"
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
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
f = files[0]
if Path(f["path"]).name != "claws-mail":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libgtk-x11-2.0.so.0", "libgdk-x11-2.0.so.0",
            "libetpan.so.20", "libgnutls.so.30",
            "libenchant-2.so.2", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=1")
PY

# official icons, man, lintian override — keep official tree
cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/128x128/apps/claws-mail.png" \
  "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/claws-mail.png"
cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/64x64/apps/claws-mail.png" \
  "$STAGE/pkg/usr/share/icons/hicolor/64x64/apps/claws-mail.png"
cp -a --remove-destination \
  "$UNPACK/usr/share/icons/hicolor/48x48/apps/claws-mail.png" \
  "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/claws-mail.png"
cp -a --remove-destination \
  "$UNPACK/usr/share/pixmaps/claws-mail-32x32.xpm" \
  "$STAGE/pkg/usr/share/pixmaps/claws-mail-32x32.xpm"
cp -a --remove-destination \
  "$UNPACK/usr/share/man/man1/claws-mail.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/claws-mail.1.gz"
# retarget official lintian override package name
python3 - << PY
from pathlib import Path
src = Path("$UNPACK/usr/share/lintian/overrides/claws-mail")
dst = Path("$STAGE/pkg/usr/share/lintian/overrides/kemi-claws-mail")
text = src.read_text(encoding="utf-8")
text2 = text.replace("claws-mail binary:", "kemi-claws-mail binary:")
dst.write_text(text2, encoding="utf-8")
print("lintian_override_rewritten", dst)
PY
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test ! -d "$STAGE/pkg/usr/share/help"
test ! -d "$STAGE/pkg/usr/share/claws-mail"
test "$(find "$STAGE/pkg" \( -name '*.png' -o -name '*.xpm' \) | wc -l)" = 4

if [[ -f "$UNPACK/usr/share/doc/claws-mail/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/claws-mail/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/claws-mail/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/claws-mail/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/claws-mail.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/claws-mail.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=claws-mail(\s.*)?$", r"Exec=/usr/bin/claws-mail\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=claws-mail$", "TryExec=/usr/bin/claws-mail", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/claws-mail(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/claws-mail", text2, count=1, flags=re.M)
if re.search(r"^Exec=claws-mail(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
for expect in (
    "Exec=/usr/bin/claws-mail %u",
    "Exec=/usr/bin/claws-mail --receive-all",
    "Exec=/usr/bin/claws-mail --compose",
    "Exec=/usr/bin/claws-mail --compose --attach %f",
    "TryExec=/usr/bin/claws-mail",
):
    if expect not in text2:
        raise SystemExit(f"MISSING:{expect}")
if not re.search(r"^Icon=claws-mail$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "Name=Claws Mail" not in text2:
    raise SystemExit("MISSING_NAME")
if "Actions=GetMail;ComposeMail;SendFile;" not in text2:
    raise SystemExit("MISSING_ACTIONS")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/claws-mail "$STAGE/pkg/opt/claws-mail/claws-mail"
ln -sf claws-mail "$STAGE/pkg/usr/bin/kemi-claws-mail"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://www.claws-mail.org
Source: https://launchpad.net/ubuntu/+source/claws-mail
Homepage: https://www.claws-mail.org
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}-2
(claws-mail_3.17.5-2_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 claws-mail_3.17.5-2_arm64.deb
    (focal universe; no newer package in focal-updates)
    repackaged for KEMI as ${PKG}. No same-source
    common/data package. Official Recommends claws-mail-i18n
    (Depends: claws-mail (>= 3.17.5-2), not exact) stays
    Recommends and is not bundled. Official Suggests
    claws-mail-doc / claws-mail-tools stay Suggests.
    Same-source plugin packages have exact-version Depends
    on claws-mail but are not official Recommends, so they
    are not bundled (Remmina/AbiWord pattern does not apply).
    Versioned Provides: claws-mail (= 3.17.5-2) lets later
    apt-install of those plugins and of claws-mail-i18n work.
  * Official ELF stays at /usr/bin/claws-mail (compiled
    /usr prefix: /usr/share/locale, /usr/share/claws-mail,
    /usr/lib/aarch64-linux-gnu/claws-mail/plugins/).
    Official main package ships neither that plugin dir
    nor /usr/share/claws-mail; they are not invented.
    /opt/claws-mail/* are symlinks.
  * Desktop, man, official icons (hicolor 48/64/128 + pixmap)
    stay on standard paths. Official desktop Exec=claws-mail
    (including Desktop Actions) rewritten to /usr/bin/claws-mail;
    Icon=claws-mail. Official language-pack split: this deb
    ships no .mo (translations live in Recommended
    claws-mail-i18n). Do not invent/bundle language-packs.
  * Conflicts/Replaces claws-mail. Official Breaks/Replaces
    claws-mail-extra-plugins (<< 3.9.1-1) kept. Official
    Depends kept for Ubuntu 20.04 (GTK2, libetpan20,
    libgnutls30, libenchant-2-2, libc6 >= 2.17). Official
    Recommends claws-mail-i18n / xfonts / aspell kept as
    Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 22:11:15 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Claws Mail ${VER_UP}-2 — official Ubuntu 20.04
(focal) universe arm64, KEMI repack.

Official ELF stays at /usr/bin/claws-mail (compiled
/usr prefix). /opt/claws-mail/* are symlinks.
Desktop, man and official icons remain on standard
paths. Official language-pack split: this deb ships
no .mo; translations live in Recommended
claws-mail-i18n (not bundled; Depends is >= not =).
Same-source plugins with exact-version Depends are
not official Recommends and are not bundled.
Versioned Provides: claws-mail (= 3.17.5-2) lets later
apt-install of those plugins work.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GTK2, libetpan20, libgnutls30,
libenchant-2-2, libc6 >= 2.17). Official Recommends
claws-mail-i18n / xfonts / aspell kept as Recommends.
Official publication: Ubuntu 20.04 focal universe arm64
claws-mail 3.17.5-2. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: mail
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.17), libcairo2 (>= 1.2.4), libcompfaceg1, libenchant-2-2 (>= 2.2.3), libetpan20 (>= 1.9.2), libgdk-pixbuf2.0-0 (>= 2.27.1), libglib2.0-0 (>= 2.41.1), libgnutls30 (>= 3.6.10), libgtk2.0-0 (>= 2.24.0), libice6 (>= 1:1.0.0), libldap-2.4-2 (>= 2.4.7), libnettle7, libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), librsvg2-2 (>= 2.40.5), libsm6, xdg-utils
Recommends: claws-mail-i18n, xfonts-100dpi | xfonts-75dpi | xfonts-100dpi-transcoded | xfonts-75dpi-transcoded, aspell-en | aspell-dictionary
Suggests: claws-mail-doc (= 3.17.5-2), www-browser, gedit | kwrite | mousepad | nedit, claws-mail-tools
Breaks: claws-mail-extra-plugins (<< 3.9.1-1)
Replaces: claws-mail, claws-mail-extra-plugins (<< 3.9.1-1)
Conflicts: claws-mail
Provides: claws-mail (= 3.17.5-2), imap-client, mail-reader, news-reader
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://www.claws-mail.org
Description: Fast, lightweight GTK+2 email client (arm64)
 Claws Mail ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Fast, lightweight and user-friendly GTK+2 based email
 client, formerly called Sylpheed-Claws.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-claws-mail-control.txt"
