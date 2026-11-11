#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal) seahorse 3.36-1 arm64
# as kemi-seahorse. There is no same-source common/data/typelib
# package (single official binary).
# Official binaries: /usr/bin/seahorse plus helpers
#   /usr/libexec/seahorse/{ssh-askpass,xloadimage}.
# Probe: aarch64 · 3 ELF · seahorse requiredGlibc 2.28 ·
#   no GLIBCXX · ssh-askpass / xloadimage requiredGlibc 2.17 ·
#   no GLIBCXX · PASS vs 101 ≤2.31
# Official Depends already match Ubuntu 20.04 (libc6 >= 2.28,
#   GTK3, libhandy, libsecret, libgcr, libgpgme, gnome-keyring,
#   gcr, gnupg, avahi, libsoup, libldap). Official Recommends
#   openssh-client kept as Recommends, not bundled.
# Official SHA256 + size matched official ports.ubuntu.com pool
#   files and the Ubuntu 20.04 focal main arm64 Packages
#   stanzas (Aliyun ubuntu-ports mirror of the same index,
#   streamed). No newer focal-updates binary. No librarian URL
#   is recorded this run.
# ELF embeds /usr/share/locale, /usr/libexec/seahorse,
#   /usr/bin/gpg, /usr/bin/ssh, /usr/bin/ssh-keygen. Layout
#   therefore keeps official files at /usr/bin and /usr/libexec;
#   /opt/seahorse/* are symlinks (HardInfo/Xpad/qpdfview/Pluma/
#   Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME System
#   Monitor/GParted). Official desktop Icon=
#   org.gnome.seahorse.Application (SVG shipped). Official
#   language-pack split: no .mo in this deb. Reuse existing
#   unpacked tree; do not re-download.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-seahorse
VER_UP=3.36
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-seahorse
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/seahorse-3.36-1-focal-unpack}"
UP_DEB="$DL/seahorse_3.36-1_arm64.deb"
EXPECT_SHA=b91a61984e35b6b178ea4f6888a8c7274d92fab898afcf2c4a27bc1c61c54512
EXPECT_BYTES=367520
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/seahorse"
test -x "$UNPACK/usr/libexec/seahorse/ssh-askpass"
test -x "$UNPACK/usr/libexec/seahorse/xloadimage"
test -f "$UNPACK/usr/share/applications/org.gnome.seahorse.Application.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.seahorse.Application.service"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.seahorse.Application.svg"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.seahorse.gschema.xml"
test -f "$UNPACK/usr/share/help/C/seahorse/index.page"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test "$(find "$UNPACK/usr/share/help/C/seahorse" -type f ! -type l | wc -l)" = 44
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/seahorse")
grep -qx '/usr/libexec/seahorse' < <(strings -n 8 "$UNPACK/usr/bin/seahorse")
grep -q 'Exec=/usr/bin/seahorse --gapplication-service' \
  "$UNPACK/usr/share/dbus-1/services/org.gnome.seahorse.Application.service"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/libexec/seahorse" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/metainfo" \
  "$STAGE/pkg/opt/seahorse"

cp -al "$UNPACK/usr/bin/seahorse" "$STAGE/pkg/usr/bin/seahorse"
cp -al "$UNPACK/usr/libexec/seahorse/ssh-askpass" "$STAGE/pkg/usr/libexec/seahorse/ssh-askpass"
cp -al "$UNPACK/usr/libexec/seahorse/xloadimage" "$STAGE/pkg/usr/libexec/seahorse/xloadimage"
chmod 0755 "$STAGE/pkg/usr/bin/seahorse" \
  "$STAGE/pkg/usr/libexec/seahorse/ssh-askpass" \
  "$STAGE/pkg/usr/libexec/seahorse/xloadimage"

REPORT="$ROOT/probe/kemi-seahorse.json"
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
test "${#ELFS[@]}" = 3
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
python3 "$PROBE_PY" "${PROBE_ARGS[@]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
python3 - << PY
import json
from pathlib import Path
r = json.loads(Path("$REPORT").read_text())
if not r.get("configuredLimitsSatisfied"):
    raise SystemExit("PROBE_FAIL")
files = r.get("files") or []
if len(files) != 3:
    raise SystemExit("PROBE_UNEXPECTED_COUNT")
by = {Path(f["path"]).name: f for f in files}
if set(by) != {"seahorse", "ssh-askpass", "xloadimage"}:
    raise SystemExit(f"PROBE_UNEXPECTED_NAMES {sorted(by)}")
for name, expect_glibc, expect_cxx in (
    ("seahorse", "2.28", None),
    ("ssh-askpass", "2.17", None),
    ("xloadimage", "2.17", None),
):
    f = by[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit(f"PROBE_ARCH_{name}")
    if f.get("requiredGlibc") != expect_glibc:
        raise SystemExit(f"PROBE_GLIBC_{name}")
    if f.get("requiredGlibcxx") != expect_cxx:
        raise SystemExit(f"PROBE_GLIBCXX_{name}")
needed = set(by["seahorse"].get("neededLibraries") or [])
for lib in ("libgtk-3.so.0", "libgdk-3.so.0", "libhandy-0.0.so.0",
            "libsecret-1.so.0", "libgcr-ui-3.so.1", "libgcr-base-3.so.1",
            "libgck-1.so.0", "libpwquality.so.1", "libgpgme.so.11",
            "libldap_r-2.4.so.2", "libsoup-2.4.so.1",
            "libavahi-common.so.3", "libavahi-client.so.3",
            "libavahi-glib.so.1", "libatk-1.0.so.0",
            "libgio-2.0.so.0", "libgobject-2.0.so.0", "libglib-2.0.so.0",
            "libgdk_pixbuf-2.0.so.0", "libpthread.so.0", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.28/2.17/2.17 noGLIBCXX arch=aarch64 n_elf=3")
PY

# official trees
cp -a "$UNPACK/usr/share/help" "$STAGE/pkg/usr/share/help"
mkdir -p "$STAGE/pkg/usr/share/icons"
cp -a "$UNPACK/usr/share/icons/hicolor" "$STAGE/pkg/usr/share/icons/hicolor"
mkdir -p "$STAGE/pkg/usr/share/seahorse"
cp -a "$UNPACK/usr/share/seahorse/icons" "$STAGE/pkg/usr/share/seahorse/icons"
mkdir -p "$STAGE/pkg/usr/share/glib-2.0/schemas"
cp -a "$UNPACK/usr/share/glib-2.0/schemas/." "$STAGE/pkg/usr/share/glib-2.0/schemas/"
mkdir -p "$STAGE/pkg/usr/share/dbus-1/services"
cp -a --remove-destination \
  "$UNPACK/usr/share/dbus-1/services/org.gnome.seahorse.Application.service" \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.seahorse.Application.service"
mkdir -p "$STAGE/pkg/usr/share/gnome-shell/search-providers"
cp -a --remove-destination \
  "$UNPACK/usr/share/gnome-shell/search-providers/seahorse-search-provider.ini" \
  "$STAGE/pkg/usr/share/gnome-shell/search-providers/seahorse-search-provider.ini"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/seahorse.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/seahorse.1.gz"
cp -a --remove-destination \
  "$UNPACK/usr/share/metainfo/org.gnome.seahorse.Application.appdata.xml" \
  "$STAGE/pkg/usr/share/metainfo/org.gnome.seahorse.Application.appdata.xml"
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.seahorse.Application.svg"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test "$(find "$STAGE/pkg/usr/share/help/C/seahorse" -type f ! -type l | wc -l)" = 44
test "$(find "$STAGE/pkg/usr/share/glib-2.0/schemas" -name 'org.gnome.seahorse*.gschema.xml' | wc -l)" = 3
grep -q 'Exec=/usr/bin/seahorse --gapplication-service' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.gnome.seahorse.Application.service"

if [[ -f "$UNPACK/usr/share/doc/seahorse/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/seahorse/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/seahorse/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/seahorse/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/seahorse/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/seahorse/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/seahorse/AUTHORS" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/seahorse/AUTHORS" \
    "$STAGE/pkg/usr/share/doc/$PKG/AUTHORS.upstream"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re
src = Path("$UNPACK/usr/share/applications/org.gnome.seahorse.Application.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.seahorse.Application.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=seahorse(\s.*)?$", r"Exec=/usr/bin/seahorse\1", text, flags=re.M)
text2 = re.sub(r"^TryExec=seahorse$", "TryExec=/usr/bin/seahorse", text2, flags=re.M)
if not re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^(Exec=/usr/bin/seahorse(?:\s.*)?)$",
                   r"\1\nTryExec=/usr/bin/seahorse", text2, count=1, flags=re.M)
if re.search(r"^Exec=seahorse(\s|$)", text2, flags=re.M):
    raise SystemExit("LEFTOVER_RELATIVE_EXEC")
if not re.search(r"^Exec=/usr/bin/seahorse$", text2, flags=re.M):
    raise SystemExit("MISSING_EXEC")
if "TryExec=/usr/bin/seahorse" not in text2:
    raise SystemExit("MISSING_TRYEXEC")
if not re.search(r"^Icon=org.gnome.seahorse.Application$", text2, flags=re.M):
    raise SystemExit("MISSING_ICON")
if "X-Ubuntu-Gettext-Domain=seahorse" not in text2:
    raise SystemExit("MISSING_GETTEXT_DOMAIN")
dst.write_text(text2, encoding="utf-8")
print("desktop_rewritten", dst)
PY

ln -sf /usr/bin/seahorse "$STAGE/pkg/opt/seahorse/seahorse"
ln -sf /usr/libexec/seahorse/ssh-askpass "$STAGE/pkg/opt/seahorse/ssh-askpass"
ln -sf /usr/libexec/seahorse/xloadimage "$STAGE/pkg/opt/seahorse/xloadimage"
ln -sf seahorse "$STAGE/pkg/usr/bin/kemi-seahorse"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://wiki.gnome.org/Apps/Seahorse
Source: https://launchpad.net/ubuntu/+source/seahorse
Homepage: https://wiki.gnome.org/Apps/Seahorse
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(seahorse_3.36-1_arm64.deb) repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 seahorse_3.36-1_arm64.deb
    (focal main; no newer focal-updates binary) repackaged
    for KEMI as ${PKG}. No same-source common/data/typelib
    package.
  * Official ELFs stay at /usr/bin/seahorse and
    /usr/libexec/seahorse/{ssh-askpass,xloadimage} (compiled
    /usr/share/locale and /usr/libexec/seahorse). /opt/seahorse/*
    are symlinks.
  * Desktop, official D-Bus, gschema, official help tree, man,
    metainfo, search-provider and icons stay on standard paths.
    Official desktop Exec=seahorse rewritten to
    /usr/bin/seahorse; Icon=org.gnome.seahorse.Application
    (SVG shipped). Official D-Bus already
    Exec=/usr/bin/seahorse --gapplication-service.
    Official language-pack split: no .mo in this deb; C help
    is real; other help locales are official help-langpack
    symlinks.
  * Conflicts/Replaces seahorse. Official Depends kept for
    Ubuntu 20.04. Official Recommends openssh-client kept as
    Recommends, not bundled.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 20:50:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Seahorse ${VER_UP}-1 — official Ubuntu 20.04 (focal)
arm64, KEMI repack.

Official ELFs stay at /usr/bin/seahorse and
/usr/libexec/seahorse/{ssh-askpass,xloadimage} (compiled
/usr prefixes). /opt/seahorse/* are symlinks.
Desktop, official D-Bus, gschema, official help tree, man,
metainfo, search-provider and icons remain on standard paths.
Official desktop Icon=org.gnome.seahorse.Application
(SVG shipped). Official language-pack split: no .mo in this
deb.
Probe: aarch64 · 3 ELF · seahorse requiredGlibc 2.28 · no
GLIBCXX · helpers requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GTK3, libhandy, libsecret, libgcr,
libgpgme, gcr, gnome-keyring, gnupg, libc6 >= 2.28). Official
Recommends openssh-client kept as Recommends.
Official publication: Ubuntu 20.04 focal main arm64 seahorse
3.36-1 (no newer focal-updates binary). Official SHA256 +
size matched ports.ubuntu.com pool files and focal main
arm64 Packages stanzas.
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
Depends: dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libavahi-client3 (>= 0.6.16), libavahi-common3 (>= 0.6.16), libavahi-glib1 (>= 0.6.16), libc6 (>= 2.28), libgck-1-0 (>= 3.12.0), libgcr-base-3-1 (>= 3.12.0), libgcr-ui-3-1 (>= 3.11.91), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.53.2), libgpgme11 (>= 1.9.0), libgtk-3-0 (>= 3.22), libhandy-0.0-0 (>= 0.0.12), libldap-2.4-2 (>= 2.4.7), libpwquality1 (>= 1.1.0), libsecret-1-0 (>= 0.18), libsoup2.4-1 (>= 2.41.90), gcr (>= 3.4), gnome-keyring (>= 3.4), gnupg (>= 2.0.12)
Recommends: openssh-client
Conflicts: seahorse
Replaces: seahorse
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Seahorse
Description: GNOME front end for GnuPG (arm64)
 Seahorse ${VER_UP} — official Ubuntu 20.04 arm64, KEMI repack.
 Manage passwords and encryption keys.
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
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-seahorse-control.txt"
