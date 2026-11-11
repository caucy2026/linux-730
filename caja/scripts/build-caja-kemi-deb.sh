#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal universe)
# caja 1.24.0-1 Architecture: arm64 as kemi-caja,
# bundling official same-source exact-version hard
# Depends caja-common (= 1.24.0-1), Architecture:
# all, and libcaja-extension1 (= 1.24.0-1), arm64.
# Those bundled packages have no further
# exact-version same-source hard Depends
# (caja-common Depends only dconf-gsettings-backend
# | gsettings-backend, merged into kemi Depends).
# Newest official U20 pin: focal Release universe
# only; not in focal-updates, focal-security, or
# focal-backports. Official GUI stanza Source field
# is absent and was not defaulted; sibling stanzas
# list Source: caja. No Debian epoch, no tilde.
# Official different-source Depends stay Depends.
# Official Recommends gvfs-backends stay
# Recommends. Official Suggests engrampa,
# gstreamer1.0-tools, meld stay Suggests.
# Official same-source gir1.2-caja (transitional),
# gir1.2-caja-2.0, libcaja-extension-dev, and
# libcaja-extension-doc inspected, not packaged
# (gir / -dev / API docs, not a Depends or
# Recommends of the GUI). Official
# caja-extensions packages are a different source
# and are not Depends or Recommends of caja; not
# bundled. Versioned Provides: caja, caja-common,
# libcaja-extension1 (= 1.24.0-1), plus official
# unversioned Provides libcaja-extension.
# Official Breaks kept. Official user-facing
# binary /usr/bin/caja is an aarch64 ELF and
# stays at the official path, as do the other
# official ELFs and the bundled
# libcaja-extension.so.1.4.0. /opt/caja/* are
# symlinks only. Also /usr/bin/kemi-caja → caja.
# Official common package ships 124 official .mo;
# they are kept official and none are invented.
# Official packages ship no app icon (desktop
# Icon is the theme name system-file-manager).
# Official in-app patterns / emblems / pixmaps
# stay official and are not used as the mall
# icon. A 128×128 evidence PNG rasterized from
# official Ubuntu 20.04 humanity-icon-theme
# 0.6.15 apps/128/system-file-manager.svg via
# Chrome headless --default-background-color=00000000
# lives at evidence/system-file-manager-128.png
# and is used only as the mall CREATE --icon;
# it is not packed. The theme package is not
# bundled. Official GUI changelog.Debian.gz is a
# dangling symlink into libcaja-extension1; the
# lib is bundled so the official symlink is kept
# (resolves) and the real official changelog is
# also copied with cp -L into the kemi doc dir.
# Official desktop Name=Caja is kept. Official
# GenericName=File Manager / File Browser stay
# in the desktop files and are not used as mall
# app_name. Official appdata <name> is also Caja.
# Official desktop Exec is already absolute and
# is kept; TryExec is added when missing.
# Official NoDisplay=true is kept; no NoDisplay
# is invented where official has none. Official
# D-Bus Exec is already absolute and is kept.
# Official GUI and common have no maintainer
# scripts. Official lib triggers (ldconfig) are
# kept. glib-compile-schemas, desktop-database,
# icon-cache, and ldconfig hooks are appended.
# Probe: 5 unique aarch64 ELFs, requiredGlibc
# reported from versioned needs; PASS vs 101.
# Official SHA256 + size matched
# ports.ubuntu.com and Aliyun ubuntu-ports
# (https) pool files and the Ubuntu 20.04
# focal universe arm64 / all Packages stanzas.
# No librarian URL and no .buildinfo this run.
# KEMI mall version_name 1.24.0-1kemi1 is 13
# chars. No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-caja
DL="$ROOT/dl"
UNPACK="$ROOT/unpack"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-caja
VER_UP=1.24.0-1
VER_NAME=1.24.0-1kemi1
VER_DEB=1.24.0-1kemi1
ARCH=arm64
OFF_GUI="$DL/caja_${VER_UP}_arm64.deb"
OFF_COMMON="$DL/caja-common_${VER_UP}_all.deb"
OFF_LIB="$DL/libcaja-extension1_${VER_UP}_arm64.deb"

python3 - << 'PYCHECK'
s = "1.24.0-1kemi1"
assert len(s) == 13, len(s)
print("version_name_len", len(s))
PYCHECK

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg" "$UNPACK/gui" "$UNPACK/common" "$UNPACK/lib" "$DEBDIR" "$ROOT/probe" "$ROOT/evidence"

if [ ! -x "$UNPACK/gui/usr/bin/caja" ]; then
  rm -rf "$UNPACK/gui" "$UNPACK/common" "$UNPACK/lib"
  mkdir -p "$UNPACK/gui" "$UNPACK/common" "$UNPACK/lib"
  dpkg-deb -x "$OFF_GUI" "$UNPACK/gui"
  dpkg-deb -e "$OFF_GUI" "$UNPACK/gui/DEBIAN"
  dpkg-deb -x "$OFF_COMMON" "$UNPACK/common"
  dpkg-deb -e "$OFF_COMMON" "$UNPACK/common/DEBIAN"
  dpkg-deb -x "$OFF_LIB" "$UNPACK/lib"
  dpkg-deb -e "$OFF_LIB" "$UNPACK/lib/DEBIAN"
fi

# merge official trees (common, lib, then GUI)
cp -a "$UNPACK/common/." "$STAGE/pkg/"
cp -a "$UNPACK/lib/." "$STAGE/pkg/"
cp -a "$UNPACK/gui/." "$STAGE/pkg/"
rm -rf "$STAGE/pkg/DEBIAN"
mkdir -p "$STAGE/pkg/DEBIAN"

# official ELF stays at official path; /opt and kemi-* are symlinks only
mkdir -p "$STAGE/pkg/opt/caja"
ln -s /usr/bin/caja "$STAGE/pkg/opt/caja/caja"
ln -s caja "$STAGE/pkg/usr/bin/kemi-caja"
test -x "$STAGE/pkg/usr/bin/caja"
test -L "$STAGE/pkg/opt/caja/caja"
test -L "$STAGE/pkg/usr/bin/kemi-caja"
# official changelog symlink now resolves because lib is bundled
test -L "$STAGE/pkg/usr/share/doc/caja/changelog.Debian.gz"
test -e "$STAGE/pkg/usr/share/doc/caja/changelog.Debian.gz"

# desktop: keep official absolute Exec; add TryExec if missing;
# keep official Name, Icon, official NoDisplay; do not invent NoDisplay
python3 - << 'PYDESK'
from pathlib import Path
apps = Path("/workspace/t142-20261112-caja/stage/pkg/usr/share/applications")

def untranslated_keys(src: str):
    keys = []
    for ln in src.splitlines():
        if not ln or ln.startswith("#") or "=" not in ln:
            continue
        k = ln.split("=", 1)[0]
        if "[" not in k:
            keys.append(k)
    return keys

def first_exec_cmd(text: str):
    for ln in text.splitlines():
        if ln.startswith("Exec=") and "[" not in ln.split("=",1)[0]:
            return ln.split("=",1)[1].split()[0]
    return None

for p in sorted(apps.glob("*.desktop")):
    text = p.read_text()
    keys = untranslated_keys(text)
    # official Exec must stay absolute; do not invent a relative rewrite group
    for ln in text.splitlines():
        if ln.startswith("Exec=") and "[" not in ln.split("=",1)[0]:
            cmd = ln.split("=",1)[1].split()[0]
            assert cmd.startswith("/"), (p.name, ln)
    new = text
    if "TryExec" not in keys:
        cmd = first_exec_cmd(text)
        assert cmd and cmd.startswith("/"), p.name
        # insert TryExec after the untranslated Name or before Exec
        lines = text.splitlines(keepends=True)
        out = []
        inserted = False
        for line in lines:
            raw = line[:-1] if line.endswith("\n") else line
            key = raw.split("=",1)[0] if "=" in raw and not raw.lstrip().startswith("#") else ""
            if key == "Exec" and not inserted:
                out.append("TryExec=" + cmd + ("\n" if line.endswith("\n") else ""))
                inserted = True
            out.append(line)
        new = "".join(out)
        assert "TryExec=" + cmd in new
    assert r"\1" not in new
    p.write_text(new)
    print("desktop_ok", p.name, "TryExec", "TryExec" in untranslated_keys(new), "NoDisplay", "NoDisplay" in untranslated_keys(new))

# assertions on official titles kept
browser = (apps / "caja-browser.desktop").read_text()
assert "Name=Caja" in browser
assert "GenericName=File Browser" in browser
assert "Icon=system-file-manager" in browser
assert "Exec=/usr/bin/caja --no-desktop --browser %U" in browser
assert "TryExec=/usr/bin/caja" in browser
assert "NoDisplay" not in untranslated_keys(browser)

main = (apps / "caja.desktop").read_text()
assert "Name=Caja" in main
assert "GenericName=File Manager" in main
assert "NoDisplay=true" in main
assert "TryExec=/usr/bin/caja" in main
assert "Exec=/usr/bin/caja" in main

props = (apps / "caja-file-management-properties.desktop").read_text()
assert "Name=File Management" in props
assert "TryExec=/usr/bin/caja-file-management-properties" in props
assert "NoDisplay" not in untranslated_keys(props)

autorun = (apps / "caja-autorun-software.desktop").read_text()
assert "NoDisplay=true" in autorun
print("desktop_rewrite_ok")
PYDESK

# official changelogs: keep official symlink (now resolves) and cp -L real file into kemi doc
mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -L "$STAGE/pkg/usr/share/doc/caja/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -L "$UNPACK/gui/usr/share/doc/caja/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright"
test -f "$STAGE/pkg/usr/share/doc/libcaja-extension1/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/caja-common/changelog.Debian.gz"
test -L "$STAGE/pkg/usr/share/doc/caja/changelog.Debian.gz"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-caja (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    caja 1.24.0-1 arm64, KEMI mall linuxpkg
    repack. Bundled official same-source
    exact-version caja-common (= 1.24.0-1)
    and libcaja-extension1 (= 1.24.0-1).
    Official ELF stays under /usr. Official
    desktop Name=Caja kept; mall
    app_name=Caja. 合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# official lib triggers (ldconfig); no official GUI/common maintainer scripts
cp -a "$UNPACK/lib/DEBIAN/triggers" "$STAGE/pkg/DEBIAN/triggers"
grep -q 'activate-noawait ldconfig' "$STAGE/pkg/DEBIAN/triggers"

# hooks with quoted heredoc (do not expand $1)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if command -v ldconfig >/dev/null 2>&1; then
	ldconfig || true
fi
if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
	glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
	gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
# End automatically added section
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
	if command -v ldconfig >/dev/null 2>&1; then
		ldconfig || true
	fi
	if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
		glib-compile-schemas /usr/share/glib-2.0/schemas || true
	fi
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database -q /usr/share/applications || true
	fi
	if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
		gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
	fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'gtk-update-icon-cache' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'ldconfig' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_ok"

if find "$STAGE/pkg" \( -name 'system-file-manager-128.png' -o -name 'humanity-icon-theme*' \) | grep -q .; then
  echo "EVIDENCE_OR_THEME_PACKED" >&2
  exit 1
fi
MO_COUNT=$(find "$STAGE/pkg" -name '*.mo' | wc -l)
test "$MO_COUNT" = 124
echo "mo_count $MO_COUNT"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: desktop-file-utils, gvfs, libglib2.0-bin, libglib2.0-data, mate-desktop, shared-mime-info, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.10.0), libexempi8 (>= 2.5.0), libexif12 (>= 0.6.21-1~), libgail-3-0 (>= 3.0.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.57.2), libgtk-3-0 (>= 3.21.5), libice6 (>= 1:1.0.0), libmate-desktop-2-17 (>= 1.24), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.44.6), libpangocairo-1.0-0 (>= 1.14.0), libselinux1 (>= 1.32), libsm6, libx11-6, libxml2 (>= 2.7.4), dconf-gsettings-backend | gsettings-backend
Recommends: gvfs-backends
Suggests: engrampa, gstreamer1.0-tools, meld
Provides: caja (= ${VER_UP}), caja-common (= ${VER_UP}), libcaja-extension1 (= ${VER_UP}), libcaja-extension
Conflicts: caja, caja-common, libcaja-extension1
Replaces: caja, caja-common, libcaja-extension1
Breaks: caja-common (<< 1.20.0-2~), libcaja-extension (<< 1.10.0), libcaja-extension1 (<< 1.10.0), mate-session-manager (<< 1.8.1-7)
Homepage: https://mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: file manager for the MATE desktop
 Caja 1.24.0-1 — official Ubuntu 20.04
 arm64, KEMI repack of caja, bundling
 official caja-common and
 libcaja-extension1. glibc≤2.31
 (Ubuntu 20.04). gork.bot协助开发.
EOF

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-caja/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "x86_64-linux-gnu" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86

python3 - << 'PYLIT'
from pathlib import Path
apps = Path("/workspace/t142-20261112-caja/stage/pkg/usr/share/applications")
for p in apps.glob("*.desktop"):
    t = p.read_text()
    assert r"\1" not in t, p.name
print("no_literal_group")
PYLIT

# official D-Bus Exec kept absolute
grep -q 'Exec=/usr/bin/caja --no-default-window' \
  "$STAGE/pkg/usr/share/dbus-1/services/org.mate.freedesktop.FileManager1.service"

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib
from pathlib import Path
p = Path("/workspace/t142-20261112-caja/debs/kemi-caja_1.24.0-1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("/workspace/t142-20261112-caja/dl/caja_1.24.0-1_arm64.deb")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
print("differs_from_official", off.stat().st_size, oh)
PYHASH
dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-caja-control.txt"
if dpkg-deb -c "$OUT" | grep -E 'system-file-manager-128|humanity-icon-theme'; then
  echo PACKED_BAD >&2
  exit 1
fi
echo "evidence_not_packed"

mapfile -t ELFS < <(python3 - << 'PYELF'
from pathlib import Path
root = Path("/workspace/t142-20261112-caja/stage/pkg")
magic = bytes([0x7F]) + b"ELF"
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            print(p)
PYELF
)
echo "ELF_COUNT ${#ELFS[@]}"
test "${#ELFS[@]}" -ge 1
PROBE_ARGS=()
for e in "${ELFS[@]}"; do
  PROBE_ARGS+=(--elf "$e")
done
REPORT="$ROOT/probe/kemi-caja.json"
rm -f "$REPORT"
python3 "$ROOT/scripts/probe_elf.py" --target-arch arm64 --max-glibc 2.31 \
  "${PROBE_ARGS[@]}" --report "$REPORT"
N_ELF=${#ELFS[@]}
export N_ELF REPORT
python3 - << 'PYPROBE'
import json, os
from pathlib import Path
report = Path(os.environ["REPORT"])
n = int(os.environ["N_ELF"])
d = json.loads(report.read_text())
files = d.get("files") or []
assert len(files) == n, (len(files), n)
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
gv = sum(1 for v in glibcs if v is not None)
gn = sum(1 for v in glibcs if v is None)
cv = sum(1 for v in cxxs if v is not None)
cn = sum(1 for v in cxxs if v is None)
gver = [v for v in glibcs if v is not None]
def verkey(s):
    return tuple(int(x) for x in s.split("."))
gmax = max(gver, key=verkey) if gver else None
cver = [v for v in cxxs if v is not None]
cmax = max(cver, key=verkey) if cver else None
assert d.get("configuredLimitsSatisfied") is True
print("PROBE_PASS n_elf=%s requiredGlibc=%s (%s versioned, %s null); requiredGlibcxx=%s (%s versioned, %s null, nulls not ranked as a max); configuredLimitsSatisfied=true" % (n, gmax, gv, gn, cmax, cv, cn))
if cmax is not None:
    assert verkey(cmax) <= (3, 4, 28), cmax
if gmax is not None:
    assert verkey(gmax) <= (2, 31), gmax
d["n_elf"] = n
d["requiredGlibc_versioned"] = gv
d["requiredGlibc_null"] = gn
d["requiredGlibcxx_versioned"] = cv
d["requiredGlibcxx_null"] = cn
report.write_text(json.dumps(d, indent=2) + "\n")
PYPROBE

echo "BUILD_OK $OUT"
