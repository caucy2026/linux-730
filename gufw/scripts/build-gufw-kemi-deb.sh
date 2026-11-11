#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates universe) gufw
# 20.04.1-1ubuntu1 Architecture: all as kemi-gufw.
# Newer than focal Release 20.04.1-1; no package in
# focal-security or focal-backports. Source package is
# gui-ufw; only this one binary package ships in focal
# (no same-source -data/-common to bundle). Official
# typelib / GTK / WebKit / PolicyKit / Python / ufw
# (>= 0.34~rc) Depends stay Depends, unbundled (ufw is
# a different-source hard Depends). Official control
# has no Recommends and no Suggests. Versioned
# Provides: gufw (= 20.04.1-1ubuntu1). No Debian epoch,
# no tilde. Official /usr/bin/gufw (bash) and
# /usr/bin/gufw-pkexec (bash) are wrappers, not ELFs,
# and are not counted as ELFs. Official .py modules
# under /usr/share/gufw are not ELFs. Official files
# stay on official paths; /opt/gufw/* are symlinks.
# Also /usr/bin/kemi-gufw → gufw (the user-facing
# launcher). Official package ships 74 .mo including
# zh_CN / zh_TW (keep official; do not invent extra
# language packs). Official package ships no Yelp help
# and no appdata. Official app icons are a 48×48
# hicolor PNG plus scalable SVG (and an official
# gufw.xcf); there is no official 256×256. Official
# 48×48 PNG and in-app shield / tutorial PNGs stay in
# the official tree and are not used as the mall 256
# icon. A 128×128 evidence PNG rasterized from the
# official scalable SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/gufw-128.png and is used only as the mall
# CREATE --icon; it is not shipped in the deb.
# Official changelog.Debian.gz is a real file and is
# copied with cp -L. Official 256 /etc/gufw/app_profiles
# conffiles stay official. Official desktop Exec=gufw
# is rewritten to /usr/bin/gufw; TryExec is added;
# Icon=gufw; official Name=Firewall Configuration is
# kept (mall app_name is Gufw). Official PolicyKit
# exec.path=/usr/bin/gufw-pkexec is already absolute
# and is kept. Official wrappers stay official.
# Official py3compile / py3clean / dpkg -L and the
# python3 rtupdate hook targeting /usr/share/gufw are
# retargeted to kemi-gufw (rtupdate file renamed).
# Probe: Architecture: all · 0 unique packaged ELF
# (vacuous PASS; official wrappers and .py modules are
# not ELFs and were not counted) · requiredGlibc none
# (0 versioned, 0 null; do not invent a max; null is
# not ranked as a max) · no GLIBCXX (0 versioned, 0
# null) · Python 3 GTK3 typelib ufw front end · within
# 101 ≤2.31 / ≤3.4.28 (vacuous). Official SHA256 +
# size matched official ports.ubuntu.com pool files
# and the Ubuntu 20.04 focal-updates universe arm64
# Packages stanza (Aliyun ubuntu-ports mirror,
# streamed; Architecture: all is listed in the arm64
# index). No librarian URL and no .buildinfo is
# recorded this run (pool 404). KEMI version
# 20.04.1-1ubuntu1kemi1 is 21 chars (under the mall
# version_name limit that rejected Remmina's 33-char
# string; 12–28 char siblings succeeded, including
# GNOME Screenshot at 20). No epoch, no tilde, no
# shortening needed. gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-gufw
VER_UP=20.04.1-1ubuntu1
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-gufw
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-kemi}"
UP_DEB="$DL/gufw_20.04.1-1ubuntu1_all.deb"
EXPECT_SHA=8931efdf1be9e925583e1736cf5b073c29c60dad87f4fe753ac9681f24bb3ea9
EXPECT_BYTES=860360
python3 - << PY
s="${VER_DEB}"
assert len(s) == 21, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -

rm -rf "$UNPACK"
mkdir -p "$UNPACK"
dpkg-deb -x "$UP_DEB" "$UNPACK"
dpkg-deb -e "$UP_DEB" "$UNPACK/DEBIAN"

test -x "$UNPACK/usr/bin/gufw"
test -x "$UNPACK/usr/bin/gufw-pkexec"
python3 - << PY
from pathlib import Path
for rel in ("usr/bin/gufw", "usr/bin/gufw-pkexec"):
    p = Path("$UNPACK") / rel
    assert not p.is_symlink(), rel
    assert p.read_bytes()[:2] == b"#!"
    assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_wrappers_not_elf")
PY
test -f "$UNPACK/usr/share/applications/gufw.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/gufw.svg"
test -f "$UNPACK/usr/share/icons/hicolor/48x48/apps/gufw.png"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/gufw.png"
test ! -L "$UNPACK/usr/share/doc/gufw/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gufw/changelog.Debian.gz"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 74
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/gufw.mo"
test -f "$UNPACK/usr/share/locale/zh_TW/LC_MESSAGES/gufw.mo"
test -f "$UNPACK/DEBIAN/conffiles"
test "$(wc -l < "$UNPACK/DEBIAN/conffiles")" = 256
test -f "$ROOT/evidence/gufw-128.png"
python3 - << PY
import struct
from pathlib import Path
p = Path("$ROOT/evidence/gufw-128.png")
b = p.read_bytes()
assert b[:8] == b"\x89PNG\r\n\x1a\n"
w, h = struct.unpack(">II", b[16:24])
assert (w, h) == (128, 128), (w, h)
print("evidence_128_for_create", w, h, p.stat().st_size)
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gufw"

cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/etc" "$STAGE/pkg/etc"
chmod 0755 "$STAGE/pkg/usr/bin/gufw" "$STAGE/pkg/usr/bin/gufw-pkexec"
cp -a "$UNPACK/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

for s in postinst prerm; do
  cp -a "$UNPACK/DEBIAN/$s" "$STAGE/pkg/DEBIAN/$s"
  chmod 0755 "$STAGE/pkg/DEBIAN/$s"
done

export STAGE_PKG="$STAGE/pkg"
python3 - << 'END_GUFW_HOOKS'
from pathlib import Path
import os, re
root = Path(os.environ["STAGE_PKG"])
for name in ("postinst", "prerm"):
    p = root / "DEBIAN" / name
    t = p.read_text()
    t = t.replace("py3compile -p gufw", "py3compile -p kemi-gufw")
    t = t.replace("pypy3compile -p gufw", "pypy3compile -p kemi-gufw")
    t = t.replace("py3clean -p gufw", "py3clean -p kemi-gufw")
    t = re.sub(r"dpkg -L gufw\b", "dpkg -L kemi-gufw", t)
    p.write_text(t)
    p.chmod(0o755)
rt_old = root / "usr/share/python3/runtime.d/gufw.rtupdate"
rt_new = root / "usr/share/python3/runtime.d/kemi-gufw.rtupdate"
t = rt_old.read_text()
t = t.replace("py3clean -p gufw", "py3clean -p kemi-gufw")
t = t.replace("py3compile -p gufw", "py3compile -p kemi-gufw")
rt_new.write_text(t)
rt_new.chmod(0o755)
rt_old.unlink()
post = (root/"DEBIAN/postinst").read_text()
prerm = (root/"DEBIAN/prerm").read_text()
rt = rt_new.read_text()
if "py3compile -p gufw" in post or "pypy3compile -p gufw" in post:
    raise SystemExit("PY3_NOT_RETARGETED_POSTINST")
if "py3compile -p kemi-gufw" not in post:
    raise SystemExit("PY3_MISSING_KEMI_POSTINST")
if "py3clean -p gufw " in prerm or "py3clean -p gufw\n" in prerm:
    raise SystemExit("PY3_NOT_RETARGETED_PRERM")
if "dpkg -L gufw" in prerm:
    raise SystemExit("DPKG_L_NOT_RETARGETED")
if "dpkg -L kemi-gufw" not in prerm:
    raise SystemExit("DPKG_L_MISSING")
if "py3clean -p gufw" in rt or "py3compile -p gufw" in rt:
    raise SystemExit("RTUPDATE_NOT_RETARGETED")
if "py3compile -p kemi-gufw" not in rt:
    raise SystemExit("RTUPDATE_MISSING_KEMI")
if (root / "usr/share/python3/runtime.d/gufw.rtupdate").exists():
    raise SystemExit("OLD_RTUPDATE_STILL_PRESENT")
conf = (root/"DEBIAN/conffiles").read_text().splitlines()
if len(conf) != 256:
    raise SystemExit(f"CONFFILES_COUNT:{len(conf)}")
if any(not line.startswith("/etc/gufw/") for line in conf if line.strip()):
    raise SystemExit("CONFFILES_PATH_UNEXPECTED")
print("py3_hooks_and_rtupdate_retargeted")
END_GUFW_HOOKS

REPORT="$ROOT/probe/kemi-gufw.json"
python3 - << PY
import json
from pathlib import Path
root = Path("$STAGE/pkg")
magic = bytes([0x7F]) + b"ELF"
elfs = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    with p.open("rb") as f:
        if f.read(4) == magic:
            elfs.append(str(p))
if elfs:
    raise SystemExit("UNEXPECTED_ELF:" + ",".join(elfs))
for rel in ("usr/bin/gufw", "usr/bin/gufw-pkexec"):
    w = root / rel
    if w.read_bytes()[:2] != b"#!":
        raise SystemExit("WRAPPER_MISSING:" + rel)
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "maxVersionedGlibc": None,
    "maxVersionedGlibcxx": None,
    "nUniqueElf": 0,
    "glibcVersioned": 0,
    "glibcNull": 0,
    "glibcxxVersioned": 0,
    "glibcxxNull": 0,
    "note": "0 unique packaged ELF; official /usr/bin/gufw and /usr/bin/gufw-pkexec are bash wrappers; official gufw.py and .py modules are not ELFs and were not counted; vacuous PASS vs 101; null requiredGlibc/requiredGlibcxx is not ranked as a max",
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
print("PROBE_PASS n_elf=0 unique vacuous PASS Architecture: all glibc none (0 versioned, 0 null; no max invented) noGLIBCXX (0 versioned, 0 null; null not ranked as a max) official wrappers are bash/Python not ELF configuredLimitsSatisfied=true")
PY

test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 74
test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/gufw.svg"
test -f "$STAGE/pkg/usr/share/icons/hicolor/48x48/apps/gufw.png"
if find "$STAGE/pkg" -name 'gufw-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gufw/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gufw/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export UNPACK_DESKTOP="$UNPACK/usr/share/applications/gufw.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/gufw.desktop"
export STAGE_PKG
python3 - << 'END_GUFW_DESKTOP'
from pathlib import Path
import os, re

text = Path(os.environ["UNPACK_DESKTOP"]).read_text(encoding="utf-8")
if not re.search(r"^Exec=gufw\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if "Name=Firewall Configuration" not in text or "Icon=gufw" not in text:
    raise SystemExit("DESKTOP_OFFICIAL_FIELDS_UNEXPECTED")
text2 = re.sub(r"^Exec=gufw\b", "Exec=/usr/bin/gufw", text, flags=re.M)
if re.search(r"^TryExec=", text2, flags=re.M):
    text2 = re.sub(r"^TryExec=.*$", "TryExec=/usr/bin/gufw", text2, flags=re.M)
else:
    text2 = re.sub(
        r"^Exec=/usr/bin/gufw.*$",
        lambda m: m.group(0) + "\nTryExec=/usr/bin/gufw",
        text2,
        count=1,
        flags=re.M,
    )
for expect in (
    "Exec=/usr/bin/gufw",
    "TryExec=/usr/bin/gufw",
    "Icon=gufw",
    "Name=Firewall Configuration",
):
    if expect not in text2:
        raise SystemExit("DESKTOP_MISSING:" + expect)
if "\\1" in text2:
    raise SystemExit("DESKTOP_LITERAL_BACKSLASH_ONE")
Path(os.environ["STAGE_DESKTOP"]).write_text(text2)
print("desktop_exec_rewritten_tryexec_added")

pol = Path(os.environ["STAGE_PKG"]) / "usr/share/polkit-1/actions/com.ubuntu.pkexec.gufw.policy"
pt = pol.read_text()
if "> /usr/bin/gufw-pkexec<" not in pt.replace("\n",""):
    if "/usr/bin/gufw-pkexec" not in pt:
        raise SystemExit("POLICY_EXEC_UNEXPECTED")
print("policy_exec_kept_absolute")

leftover = []
for p in Path(os.environ["STAGE_PKG"]).rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix.lower() in {".png", ".svg", ".mo", ".gz", ".xcf"}:
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
END_GUFW_DESKTOP

# official PolicyKit path kept
grep -q '/usr/bin/gufw-pkexec' \
  "$STAGE/pkg/usr/share/polkit-1/actions/com.ubuntu.pkexec.gufw.policy"

ln -sf /usr/bin/gufw "$STAGE/pkg/opt/gufw/gufw"
ln -sf /usr/bin/gufw-pkexec "$STAGE/pkg/opt/gufw/gufw-pkexec"
ln -sf gufw "$STAGE/pkg/usr/bin/kemi-gufw"

KEMI_DATE=$(TZ=Asia/Shanghai date -R)

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://costales.github.io/projects/gufw/
Source: https://launchpad.net/ubuntu/+source/gui-ufw
Homepage: https://costales.github.io/projects/gufw/
License: see copyright.upstream
Official Ubuntu 20.04 (focal-updates universe) Architecture: all deb v${VER_UP}
(gufw_20.04.1-1ubuntu1_all.deb), repackaged for KEMI as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 gufw_20.04.1-1ubuntu1_all.deb
    (focal-updates universe; newer than focal Release
    20.04.1-1; no package in focal-security or
    focal-backports) repackaged for KEMI as ${PKG}.
    Official typelib / GTK / WebKit / PolicyKit /
    Python / ufw Depends stay Depends and are not
    bundled. Official control has no Recommends and no
    Suggests. Versioned Provides: gufw (= 20.04.1-1ubuntu1).
  * Official /usr/bin/gufw and /usr/bin/gufw-pkexec are
    bash wrappers, not ELFs. Official files stay under
    /usr and /etc. /opt/gufw/* are symlinks. Also
    /usr/bin/kemi-gufw → gufw.
  * Official package ships 74 .mo including zh_CN /
    zh_TW and no Yelp help. Official 48×48 hicolor PNG
    and in-app / tutorial PNGs stay official. Official
    icons have no 256×256; a 128×128 evidence PNG
    rasterized from the official scalable SVG is used
    only for mall CREATE --icon and is not packed.
  * Official changelog is a real file and was copied
    with cp -L. Official 256 /etc/gufw/app_profiles
    conffiles stay official. Official desktop Exec=gufw
    is rewritten to /usr/bin/gufw; TryExec added;
    Icon=gufw; Name=Firewall Configuration. Official
    PolicyKit exec.path is already absolute and is
    kept. Official py3 hooks and the rtupdate hook are
    retargeted to kemi-gufw.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Gufw ${VER_UP} — official Ubuntu 20.04
(focal-updates universe) Architecture: all, KEMI
repack.

Official /usr/bin/gufw and /usr/bin/gufw-pkexec are
bash wrappers (not ELFs). /opt/gufw/* are symlinks.
Official typelib / GTK / WebKit / PolicyKit / Python /
ufw Depends stay Depends and are not bundled.
Official control has no Recommends and no Suggests.
Official package ships 74 .mo including zh_CN.
Official 48×48 hicolor PNG and in-app PNGs stay
official. A 128×128 evidence PNG is used only as mall
CREATE --icon and is not packed. Probe: 0 unique ELF ·
vacuous PASS · no requiredGlibc (0 versioned, 0 null;
no max invented) · no requiredGlibcxx (0 versioned, 0
null; null not ranked as a max); Python 3 GTK3 typelib
ufw front end; within Ubuntu 20.04 / glibc 2.31
(vacuous). Official publication: Ubuntu 20.04
focal-updates universe gufw 20.04.1-1ubuntu1
(Architecture: all). Official SHA256 + size matched
ports.ubuntu.com pool files and focal-updates universe
arm64 Packages stanza. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: gir1.2-gtk-3.0, gir1.2-webkit2-4.0, policykit-1, python3-gi, ufw (>= 0.34~rc), python3:any
Replaces: gufw
Conflicts: gufw
Provides: gufw (= 20.04.1-1ubuntu1)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://costales.github.io/projects/gufw/
Description: graphical user interface for ufw
 Gufw ${VER_UP} — official Ubuntu 20.04
 Architecture: all, KEMI repack.
 Python 3 GTK3 typelib ufw front end.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

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
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
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
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/postrm"
grep -q 'py3compile -p kemi-gufw' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg -L kemi-gufw' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'py3compile -p kemi-gufw' "$STAGE/pkg/usr/share/python3/runtime.d/kemi-gufw.rtupdate"
test ! -e "$STAGE/pkg/usr/share/python3/runtime.d/gufw.rtupdate"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gufw-control.txt"
grep -q 'Version: 20.04.1-1ubuntu1kemi1' "$ROOT/evidence/kemi-gufw-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-gufw-control.txt"
grep -q 'ufw (>= 0.34~rc)' "$ROOT/evidence/kemi-gufw-control.txt"
grep -q 'Provides: gufw (= 20.04.1-1ubuntu1)' "$ROOT/evidence/kemi-gufw-control.txt"
! grep -q '^ Recommends:' "$ROOT/evidence/kemi-gufw-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gufw-control.txt"
grep -q 'Conffiles:' "$ROOT/evidence/kemi-gufw-control.txt" || dpkg-deb -I "$DEB" conffiles | head -n 3

python3 - << PY
import subprocess
from pathlib import Path
deb = Path("$DEB")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
need = [
    "./usr/bin/gufw",
    "./usr/bin/gufw-pkexec",
    "./usr/bin/kemi-gufw",
    "./opt/gufw/gufw",
    "./usr/share/applications/gufw.desktop",
    "./usr/share/icons/hicolor/scalable/apps/gufw.svg",
    "./usr/share/icons/hicolor/48x48/apps/gufw.png",
    "./usr/share/locale/zh_CN/LC_MESSAGES/gufw.mo",
    "./usr/share/gufw/gufw/gufw.py",
    "./usr/share/polkit-1/actions/com.ubuntu.pkexec.gufw.policy",
    "./usr/share/man/man8/gufw.8.gz",
    "./usr/share/python3/runtime.d/kemi-gufw.rtupdate",
    "./usr/share/doc/kemi-gufw/changelog.upstream.gz",
    "./etc/gufw/app_profiles/",
]
for n in need:
    if not any(n in line for line in out.splitlines()):
        raise SystemExit("MISSING_IN_DEB:" + n)
if "gufw-128.png" in out:
    raise SystemExit("EVIDENCE_PNG_PACKED")
if "runtime.d/gufw.rtupdate" in out:
    raise SystemExit("OLD_RTUPDATE_PACKED")
found_bin = found_pk = found_kemi = False
for line in out.splitlines():
    if ("./usr/bin/gufw " in line or line.rstrip().endswith("./usr/bin/gufw")) and "kemi-gufw" not in line and "gufw-pkexec" not in line:
        found_bin = True
        if "->" in line:
            raise SystemExit("BIN_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/gufw-pkexec" in line:
        found_pk = True
        if "->" in line:
            raise SystemExit("PKEXEC_UNEXPECTED_SYMLINK:" + line)
    if "./usr/bin/kemi-gufw" in line:
        found_kemi = True
        if "->" not in line:
            raise SystemExit("KEMI_BIN_NOT_SYMLINK:" + line)
if not found_bin:
    raise SystemExit("MISSING_BIN")
if not found_pk:
    raise SystemExit("MISSING_PKEXEC")
if not found_kemi:
    raise SystemExit("MISSING_KEMI_BIN")
info = subprocess.check_output(["dpkg-deb", "-I", str(deb), "conffiles"], text=True)
nconf = len([ln for ln in info.splitlines() if ln.strip().startswith("/etc/gufw/")])
if nconf != 256:
    raise SystemExit(f"DEB_CONFFILES:{nconf}")
print("DEB_TREE_OK")
PY
echo "BUILD_OK $DEB"
