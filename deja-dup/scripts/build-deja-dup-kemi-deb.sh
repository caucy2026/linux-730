#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main) deja-dup
# 40.7-0ubuntu2 Architecture: arm64 as kemi-deja-dup.
# Newer than focal Release 40.6-1ubuntu2 and still Ubuntu
# 20.04 deps (libc6 >= 2.17). The deja-dup source ships
# only this one binary package in focal (no same-source
# -data/-common to bundle). Official deja-dup-caja is a
# different-source Caja plugin and is not a GUI hard
# Depends; it is inspected in the index only and not
# packaged. Official Depends duplicity (>= 0.7.14) is
# different-source and stays Depends, unbundled, as do
# the typelib / GTK / GOA / Nautilus / PackageKit /
# libsecret / libsoup system libraries. Official
# Recommends (gvfs-backends, packagekit, policykit-1)
# stay Recommends / unbundled (not the Remmina/AbiWord
# Recommends-plugin pattern). Official Suggests
# (python3-boto, python3-swiftclient, python3-pydrive)
# stay Suggests. Versioned Provides: deja-dup
# (= 40.7-0ubuntu2). No Debian epoch. Official
# /usr/bin/deja-dup and /usr/libexec/deja-dup/deja-dup-monitor
# are compiled aarch64 ELFs with RUNPATH
# /usr/lib/aarch64-linux-gnu/deja-dup (NEEDED private
# libdeja.so / libwidgets.so). Official nautilus
# extension libdeja-dup.so and the two private libs are
# also compiled aarch64 ELFs. Official
# /usr/libexec/deja-dup/duplicity is a shell wrapper
# (not an ELF) used by PolicyKit and must not be counted
# as an ELF. Official files stay on official paths;
# /opt/deja-dup/* are symlinks. Also
# /usr/bin/kemi-deja-dup → deja-dup. Official GUI package
# ships no .mo (language-pack split; keep official, do
# not invent packs). Official Yelp help has a real C
# tree plus official help-langpack symlinks for many
# locales including zh_CN / zh_TW (dangling without
# language packs; kept, not invented). Official app
# icons are SVG only (org.gnome.DejaDup.svg + symbolic).
# Do not invent a PNG inside the package. A 128×128 PNG
# rasterized from the official app SVG via Chrome
# headless lives at evidence/org.gnome.DejaDup-128.png
# and is used only as the mall CREATE --icon (GNOME
# Clocks / Calculator / Devhelp / D-Feet pattern); it is
# not shipped in the deb. Official changelog.Debian.gz
# is a real file and is copied with cp -L. Official
# package has dh_installdeb mv_conffile maintainer
# scripts for the autostart desktop rename and a
# conffile at
# /etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop;
# those official scripts and the conffile are kept.
# Official desktop Exec=deja-dup %u is rewritten to
# /usr/bin/deja-dup %u; the desktop action Exec=deja-dup
# --backup is rewritten to /usr/bin/deja-dup --backup;
# TryExec is added; Icon=org.gnome.DejaDup and
# Name=Backups are kept; DBusActivatable=true is kept.
# Official autostart Exec=/usr/libexec/deja-dup/deja-dup-monitor
# is already absolute and is kept. Official D-Bus
# Exec=/usr/bin/deja-dup --gapplication-service is
# already absolute and is kept. Official PolicyKit
# exec.path=/usr/libexec/deja-dup/duplicity is already
# absolute and is kept. Official man, appdata, gschema,
# NEWS stay in the official tree. Probe: Architecture
# arm64 · 5 unique packaged ELF · requiredGlibc 2.17
# (5 versioned, 0 null) · no GLIBCXX (0 versioned, 5
# null; null is not ranked as a max) · official
# duplicity wrapper is a shell script, not an ELF ·
# GTK3 backup utility · within 101 ≤2.31 / ≤3.4.28.
# Official SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza (Aliyun
# ubuntu-ports mirror, streamed). No librarian URL and
# no .buildinfo is recorded this run (pool 404). KEMI
# version 40.7-0ubuntu2kemi1 is 18 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded). No epoch, no
# tilde, no shortening needed. gork.bot协助开发 ·
# Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-deja-dup
VER_UP=40.7-0ubuntu2
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-deja-dup
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/deja-dup_40.7-0ubuntu2_arm64.deb"
EXPECT_SHA=4e8305ebd16348a10e16bfa5e8f596b6d1f7495c28a4715ccec854e8b75bcfc8
EXPECT_BYTES=249652
python3 - << PY
s="${VER_DEB}"
assert len(s) == 18, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/deja-dup"
test -x "$UNPACK/usr/libexec/deja-dup/deja-dup-monitor"
test -x "$UNPACK/usr/libexec/deja-dup/duplicity"
python3 - << PY
from pathlib import Path
for rel in (
    "usr/bin/deja-dup",
    "usr/libexec/deja-dup/deja-dup-monitor",
    "usr/lib/aarch64-linux-gnu/deja-dup/libdeja.so",
    "usr/lib/aarch64-linux-gnu/deja-dup/libwidgets.so",
    "usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libdeja-dup.so",
):
    p = Path("$UNPACK") / rel
    assert not p.is_symlink(), rel
    assert p.read_bytes()[:4] == bytes([0x7F]) + b"ELF", rel
w = Path("$UNPACK/usr/libexec/deja-dup/duplicity")
assert not w.is_symlink()
assert w.read_bytes()[:2] == b"#!"
assert w.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_elfs_ok official_duplicity_wrapper_not_elf")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.DejaDup.desktop"
test -f "$UNPACK/etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop"
test -f "$UNPACK/usr/share/dbus-1/services/org.gnome.DejaDup.service"
test -f "$UNPACK/usr/share/polkit-1/actions/org.gnome.DejaDup.policy"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.DejaDup.svg"
test ! -L "$UNPACK/usr/share/doc/deja-dup/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/deja-dup/changelog.Debian.gz"
test -f "$ROOT/evidence/org.gnome.DejaDup-128.png"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 0
test -d "$UNPACK/usr/share/help/C/deja-dup"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/deja-dup" \
  "$STAGE/pkg/etc/xdg/autostart"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
mkdir -p "$STAGE/pkg/etc/xdg/autostart"
cp -a "$UNPACK/etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop" \
  "$STAGE/pkg/etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop"
chmod 0755 "$STAGE/pkg/usr/bin/deja-dup" \
  "$STAGE/pkg/usr/libexec/deja-dup/deja-dup-monitor" \
  "$STAGE/pkg/usr/libexec/deja-dup/duplicity"

# official mv_conffile maintainer scripts kept
for s in preinst postinst prerm postrm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done
printf '%s\n' '/etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop' \
  > "$STAGE/pkg/DEBIAN/conffiles"

REPORT="$ROOT/probe/kemi-deja-dup.json"
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
test "${#ELFS[@]}" = 5
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
if len(files) != 5:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
names = sorted(Path(f["path"]).name for f in files)
if names != ["deja-dup", "deja-dup-monitor", "libdeja-dup.so", "libdeja.so", "libwidgets.so"]:
    raise SystemExit("PROBE_NAMES:" + ",".join(names))
for f in files:
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH")
    if f.get("requiredGlibc") != "2.17":
        raise SystemExit("PROBE_GLIBC:" + str(f.get("requiredGlibc")))
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + str(f.get("requiredGlibcxx")))
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
if len(versioned) != 5 or len(nulls) != 0 or cxx or len(cxx_null) != 5:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
# official shell wrapper must not have been counted
wrap = Path("$STAGE/pkg/usr/libexec/deja-dup/duplicity")
if wrap.read_bytes()[:2] != b"#!":
    raise SystemExit("WRAPPER_MISSING")
print("PROBE_PASS n_elf=5 unique aarch64 glibc=2.17 (5 versioned, 0 null) noGLIBCXX (0 versioned, 5 null; null not ranked as a max) official duplicity wrapper is shell not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.DejaDup.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/128x128/apps/org.gnome.DejaDup.png"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.DejaDup.png"
test -f "$STAGE/pkg/usr/share/help/C/deja-dup/index.page"
test -L "$STAGE/pkg/usr/share/help/zh_CN/deja-dup/index.page"
if find "$STAGE/pkg" -name 'org.gnome.DejaDup-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/deja-dup/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/deja-dup/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

src = Path("$UNPACK/usr/share/applications/org.gnome.DejaDup.desktop")
dst = Path("$STAGE/pkg/usr/share/applications/org.gnome.DejaDup.desktop")
text = src.read_text(encoding="utf-8")
text2 = re.sub(r"^Exec=deja-dup(\s.*)?$", r"Exec=/usr/bin/deja-dup\1", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/deja-dup", text2, flags=re.M)
else:
    text2 = re.sub(r"^Exec=/usr/bin/deja-dup %u.*$", lambda m: m.group(0) + "\nTryExec=/usr/bin/deja-dup", text2, count=1, flags=re.M)
if re.search(r"^Exec=deja-dup(\s|$)", text2, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_NOT_REWRITTEN")
for expect in ("Exec=/usr/bin/deja-dup %u",
               "Exec=/usr/bin/deja-dup --backup",
               "TryExec=/usr/bin/deja-dup",
               "Icon=org.gnome.DejaDup",
               "Name=Backups",
               "DBusActivatable=true"):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
dst.write_text(text2)
print("desktop_rewritten")

auto = Path("$STAGE/pkg/etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop").read_text(encoding="utf-8")
if "Exec=/usr/libexec/deja-dup/deja-dup-monitor" not in auto:
    raise SystemExit("AUTOSTART_EXEC_CHANGED")
print("autostart_kept")

svc = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.DejaDup.service").read_text(encoding="utf-8")
if "Exec=/usr/bin/deja-dup --gapplication-service" not in svc:
    raise SystemExit("DBUS_EXEC_CHANGED")
print("dbus_kept")

pol = Path("$STAGE/pkg/usr/share/polkit-1/actions/org.gnome.DejaDup.policy").read_text(encoding="utf-8")
if 'org.freedesktop.policykit.exec.path">/usr/libexec/deja-dup/duplicity</annotate>' not in pol:
    raise SystemExit("POLKIT_EXEC_CHANGED")
print("polkit_kept")

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
PY

ln -sf /usr/bin/deja-dup "$STAGE/pkg/opt/deja-dup/deja-dup"
ln -sf /usr/libexec/deja-dup/deja-dup-monitor "$STAGE/pkg/opt/deja-dup/deja-dup-monitor"
ln -sf deja-dup "$STAGE/pkg/usr/bin/kemi-deja-dup"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://launchpad.net/deja-dup
Source: https://launchpad.net/ubuntu/+source/deja-dup
Homepage: https://launchpad.net/deja-dup
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates) Architecture: arm64 deb v${VER_UP}
(deja-dup_40.7-0ubuntu2_arm64.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 deja-dup_40.7-0ubuntu2_arm64.deb
    (focal-updates main; newer than focal Release
    40.6-1ubuntu2 and still Ubuntu 20.04 deps)
    repackaged for KEMI as ${PKG}. Official Depends
    duplicity (>= 0.7.14) and typelib / GTK / GOA /
    Nautilus / PackageKit system libraries stay Depends
    and are not bundled. Official Recommends
    (gvfs-backends, packagekit, policykit-1) stay
    Recommends. Official Suggests (python3-boto,
    python3-swiftclient, python3-pydrive) stay Suggests.
    Versioned Provides: deja-dup (= 40.7-0ubuntu2).
  * Official /usr/bin/deja-dup and
    /usr/libexec/deja-dup/deja-dup-monitor are compiled
    aarch64 ELFs with RUNPATH
    /usr/lib/aarch64-linux-gnu/deja-dup. Official private
    libs and the nautilus extension stay under /usr.
    Official /usr/libexec/deja-dup/duplicity is a shell
    wrapper, not an ELF. /opt/deja-dup/* are symlinks.
    Also /usr/bin/kemi-deja-dup.
  * Official GUI package ships no .mo. Official Yelp help
    has a real C tree plus official help-langpack
    symlinks (including zh_CN / zh_TW); keep official, do
    not invent language packs. Official app icons are
    SVG only; a 128×128 evidence PNG is used only for
    mall CREATE --icon and is not packed in the deb.
  * Official changelog is a real file and was copied with
    cp -L. Official desktop Exec=deja-dup %u rewritten to
    /usr/bin/deja-dup %u; action Exec rewritten; TryExec
    added; Icon=org.gnome.DejaDup; Name=Backups. Official
    autostart, D-Bus and PolicyKit Exec paths are already
    absolute and are kept. Official mv_conffile scripts
    and the autostart conffile are kept.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Déjà Dup ${VER_UP} — official Ubuntu 20.04
(focal-updates) main Architecture: arm64, KEMI
repack.

Official /usr/bin/deja-dup and
/usr/libexec/deja-dup/deja-dup-monitor are compiled
aarch64 ELFs (glibc 2.17, no GLIBCXX) with RUNPATH
/usr/lib/aarch64-linux-gnu/deja-dup. Official
duplicity wrapper under libexec is a shell script,
not an ELF. /opt/deja-dup/* are symlinks. Official
duplicity and typelib / GTK Depends stay Depends and
are not bundled. Official Recommends and Suggests stay
Recommends / Suggests. Official GUI package ships no
.mo. Official help C tree is kept; official
help-langpack symlinks are kept and not invented.
Probe: 5 unique ELF · requiredGlibc 2.17 (5
versioned, 0 null) · no requiredGlibcxx (0 versioned,
5 null; null not ranked as a max); GTK3 backup
utility; within Ubuntu 20.04 / glibc 2.31. Official
publication: Ubuntu 20.04 focal-updates main deja-dup
40.7-0ubuntu2 (Architecture: arm64). Official SHA256
+ size matched ports.ubuntu.com pool files and
focal-updates main arm64 Packages stanza. No
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
Depends: duplicity (>= 0.7.14), dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libglib2.0-0 (>= 2.56), libgoa-1.0-0b (>= 3.8.0), libgpg-error0 (>= 1.14), libgtk-3-0 (>= 3.22), libjson-glib-1.0-0 (>= 1.2.0), libnautilus-extension1a (>= 3.21.92-3~), libpackagekit-glib2-18 (>= 1.1.0), libpango-1.0-0 (>= 1.14.0), libsecret-1-0 (>= 0.18.6), libsoup2.4-1 (>= 2.48)
Recommends: gvfs-backends, packagekit, policykit-1
Suggests: python3-boto (>= 0.9d), python3-swiftclient, python3-pydrive
Replaces: deja-dup
Conflicts: deja-dup
Provides: deja-dup (= 40.7-0ubuntu2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://launchpad.net/deja-dup
Description: Backup utility
 Déjà Dup ${VER_UP} — official Ubuntu 20.04
 Architecture: arm64, KEMI repack.
 GTK3 backup utility (duplicity backend).
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# append desktop-database / icon-cache hooks to official postinst/postrm
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
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
HOOK
cat >> "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
chmod 0755 "$STAGE/pkg/DEBIAN/preinst" "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
echo "hooks_appended"

# official mv_conffile snippet must still be present
grep -q 'dpkg-maintscript-helper mv_conffile' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'org.gnome.DejaDup.Monitor.desktop' "$STAGE/pkg/DEBIAN/conffiles"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'Version: 40.7-0ubuntu2kemi1' "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'duplicity (>= 0.7.14)' "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'Recommends: gvfs-backends, packagekit, policykit-1' "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'Suggests: python3-boto (>= 0.9d), python3-swiftclient, python3-pydrive' "$ROOT/evidence/kemi-deja-dup-control.txt"
grep -q 'Provides: deja-dup (= 40.7-0ubuntu2)' "$ROOT/evidence/kemi-deja-dup-control.txt"

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/deja-dup",
    "./usr/bin/kemi-deja-dup",
    "./opt/deja-dup/deja-dup",
    "./usr/libexec/deja-dup/deja-dup-monitor",
    "./usr/libexec/deja-dup/duplicity",
    "./usr/lib/aarch64-linux-gnu/deja-dup/libdeja.so",
    "./usr/lib/aarch64-linux-gnu/deja-dup/libwidgets.so",
    "./usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libdeja-dup.so",
    "./usr/share/applications/org.gnome.DejaDup.desktop",
    "./etc/xdg/autostart/org.gnome.DejaDup.Monitor.desktop",
    "./usr/share/dbus-1/services/org.gnome.DejaDup.service",
    "./usr/share/polkit-1/actions/org.gnome.DejaDup.policy",
    "./usr/share/icons/hicolor/scalable/apps/org.gnome.DejaDup.svg",
    "./usr/share/help/C/deja-dup/index.page",
    "./usr/share/glib-2.0/schemas/org.gnome.DejaDup.gschema.xml",
    "./usr/share/man/man1/deja-dup.1.gz",
    "./usr/share/metainfo/org.gnome.DejaDup.appdata.xml",
    "./usr/share/doc/kemi-deja-dup/changelog.upstream.gz",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "org.gnome.DejaDup-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
found_bin = False
found_kemi = False
found_wrap = False
for line in out.splitlines():
    if "./usr/bin/deja-dup " in line or line.rstrip().endswith("./usr/bin/deja-dup"):
        if "kemi-deja-dup" not in line:
            found_bin = True
            if "->" in line:
                raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-deja-dup" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
    if "./usr/libexec/deja-dup/duplicity" in line and "->" in line:
        raise SystemExit("WRAPPER_UNEXPECTED_SYMLINK:" + line)
    if "./usr/libexec/deja-dup/duplicity" in line:
        found_wrap = True
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
if not found_wrap:
    raise SystemExit("MISSING_WRAPPER")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
