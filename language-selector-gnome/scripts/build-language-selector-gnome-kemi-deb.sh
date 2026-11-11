#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# language-selector-gnome 0.204.2 Architecture: all
# as kemi-language-selector-gnome, bundling official
# same-source exact-version hard Depends
# language-selector-common (= 0.204.2). Common has
# no exact-version same-source Depends to bundle
# further. Newer than focal Release 0.204; not in
# focal-security or focal-backports. No Debian
# epoch, no tilde. Official different-source
# Depends stay Depends, unbundled. Official
# Recommends yelp stay Recommends. Official
# control has no Suggests. Versioned Provides:
# language-selector-gnome and
# language-selector-common (= 0.204.2). Official
# Conflicts/Replaces language-selector (<< 0.17)
# kept (old transitional name, not packaged).
# Official user-facing launcher
# /usr/bin/gnome-language-selector is a Python 3
# wrapper (shebang "#! /usr/bin/python3") and
# stays at the official path, as does bundled
# /usr/bin/check-language-support.
# /opt/language-selector-gnome/* are symlinks
# only. Also /usr/bin/kemi-language-selector-gnome
# → gnome-language-selector. Official common
# package ships 134 .mo including zh_CN, zh_HK
# and zh_TW; they are kept official and none are
# invented. Official desktop Icon is the theme
# name preferences-desktop-locale; official
# 32×32 language-selector.png pixmaps stay at
# official paths and are not used as the mall
# icon. A 128×128 evidence PNG rasterized from
# official Ubuntu 20.04 humanity-icon-theme
# 0.6.15 preferences-desktop-locale.svg (48)
# via Chrome headless
# --default-background-color=00000000 lives at
# evidence/preferences-desktop-locale-128.png
# and is used only as the mall CREATE --icon;
# it is not shipped in the deb. The theme
# package is not bundled. Official help is C
# only (index.docbook; empty figures dir).
# Official GUI changelog.gz is a symlink into
# bundled language-selector-common and is kept
# (it resolves after bundling); the real
# official changelog is also copied with cp -L
# into the kemi doc dir. Official desktop
# Name=Language Support is kept. Official
# desktop Exec is already
# /usr/bin/gnome-language-selector and is kept;
# TryExec is added. Official dh_python3
# postinst/prerm are retargeted to
# kemi-language-selector-gnome. Official common
# maintainer scripts (font conffile helpers and
# /etc/environment cleanup) are kept. Official
# conffiles list is kept. Desktop-database hook
# is appended. Probe: Architecture all · 0
# unique packaged ELFs · vacuous PASS vs 101
# (None-safe; do not invent a max from null;
# probe_elf.py is not called with no --elf).
# Official SHA256 + size of both official debs
# matched official ports.ubuntu.com and Aliyun
# ubuntu-ports pool files and the Ubuntu 20.04
# focal-updates main arm64 Packages stanza
# (streamed; arch:all appears in the arm64
# index). No librarian URL and no .buildinfo
# is recorded this run (pool 404). KEMI mall
# version_name 0.204.2kemi1 is 12 chars (under
# the mall version_name limit that rejected
# Remmina's 33-char string; 12–28 char siblings
# succeeded). No epoch, no tilde, no shortening
# needed.
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261112-language-selector-gnome
VER_UP=0.204.2
VER_DEB="${VER_UP}kemi1"
ARCH=all
PKG=kemi-language-selector-gnome
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK_GUI="${UNPACK_GUI:-$ROOT/unpack-official/language-selector-gnome}"
UNPACK_COMMON="${UNPACK_COMMON:-$ROOT/unpack-official/language-selector-common}"
GUI_DEB="$DL/language-selector-gnome_0.204.2_all.deb"
COMMON_DEB="$DL/language-selector-common_0.204.2_all.deb"
python3 - << PY
s="${VER_DEB}"
assert len(s) == 12, len(s)
assert ":" not in s, s
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$GUI_DEB" && test "$(stat -c%s "$GUI_DEB")" = 18984
echo "87fa5f0136db7aec8ca89a2f63ce557a0c22a6007125e262a47d62fe66357a11  $GUI_DEB" | sha256sum -c -
test -f "$COMMON_DEB" && test "$(stat -c%s "$COMMON_DEB")" = 224340
echo "2a16047f66aa6934daf716265af469f7061cbe96931edbb9a597e099ab726563  $COMMON_DEB" | sha256sum -c -
test -x "$UNPACK_GUI/usr/bin/gnome-language-selector"
test -x "$UNPACK_COMMON/usr/bin/check-language-support"
python3 - << PY
from pathlib import Path
for rel in [
    "$UNPACK_GUI/usr/bin/gnome-language-selector",
    "$UNPACK_COMMON/usr/bin/check-language-support",
]:
    p = Path(rel)
    assert not p.is_symlink()
    first = p.read_bytes().splitlines()[0]
    assert b"python3" in first, first
    assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("official_python_wrappers_ok")
PY
test -f "$UNPACK_GUI/usr/share/applications/gnome-language-selector.desktop"
test ! -d "$UNPACK_GUI/usr/share/icons"
test -f "$UNPACK_COMMON/usr/share/pixmaps/language-selector.png"
test ! -L "$UNPACK_COMMON/usr/share/doc/language-selector-common/changelog.gz"
test -f "$UNPACK_COMMON/usr/share/doc/language-selector-common/changelog.gz"
test -L "$UNPACK_GUI/usr/share/doc/language-selector-gnome/changelog.gz"
test -f "$ROOT/evidence/preferences-desktop-locale-128.png"
test -f "$ROOT/evidence/preferences-desktop-locale.svg"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/preferences-desktop-locale-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "f59bb8bd1e6fcbbd4ae33c865a5be1be12e2e3c3704d303be3900043af31f155"
print("evidence_128_ok", w, h, p.stat().st_size)
svg = Path("$ROOT/evidence/preferences-desktop-locale.svg")
assert hashlib.sha256(svg.read_bytes()).hexdigest() == "aa49241d90a8313bc962fbc054cb8a6a6cf416ce4f5ffd36c8331cdde2924349"
pix = Path("$UNPACK_COMMON/usr/share/pixmaps/language-selector.png")
pdata = pix.read_bytes()
assert pdata[:8] == b"\x89PNG\r\n\x1a\n"
pw, ph = unpack(">II", pdata[16:24])
assert (pw, ph) == (32, 32), (pw, ph)
mos = list(Path("$UNPACK_GUI").rglob("*.mo")) + list(Path("$UNPACK_COMMON").rglob("*.mo"))
assert len(mos) == 134, len(mos)
langs = {p.parts[p.parts.index("locale")+1] for p in mos if "locale" in p.parts}
assert "zh_CN" in langs and "zh_HK" in langs and "zh_TW" in langs
print("official_mo_134_zh_CN_HK_TW")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/language-selector-gnome"

cp -a "$UNPACK_COMMON/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK_COMMON/etc" "$STAGE/pkg/etc"
cp -a "$UNPACK_GUI/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-language-selector" \
  "$STAGE/pkg/usr/bin/check-language-support"
cp -a "$UNPACK_COMMON/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

# official GUI changelog symlink must resolve after bundling common
test -L "$STAGE/pkg/usr/share/doc/language-selector-gnome/changelog.gz"
test -e "$STAGE/pkg/usr/share/doc/language-selector-gnome/changelog.gz"
test -f "$STAGE/pkg/usr/share/doc/language-selector-common/changelog.gz"
test -f "$STAGE/pkg/usr/share/pixmaps/language-selector.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 134
if find "$STAGE/pkg" -name 'preferences-desktop-locale-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_STAGED" >&2
  exit 1
fi

# 0-ELF vacuous probe: do not call probe_elf.py with no --elf
REPORT="$ROOT/probe/kemi-language-selector-gnome.json"
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
test "${#ELFS[@]}" = 0
python3 - << PY
import json
from pathlib import Path
report = {
    "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
    "configuredArchitecture": "arm64",
    "configuredMaxGlibc": "2.31",
    "runtimeLoadedOrExecuted": False,
    "files": [],
    "errors": [],
    "configuredLimitsSatisfied": True,
    "note": "0 unique packaged ELFs (official launchers are Python 3, Architecture: all); vacuous PASS vs 101. None-safe: no requiredGlibc/requiredGlibcxx values exist, so none are ranked as a max.",
    "n_elf": 0,
    "requiredGlibc_versioned": 0,
    "requiredGlibc_null": 0,
    "requiredGlibcxx_versioned": 0,
    "requiredGlibcxx_null": 0,
}
Path("$REPORT").write_text(json.dumps(report, indent=2) + "\n")
files = report["files"]
glibcs = [f.get("requiredGlibc") for f in files]
cxxs = [f.get("requiredGlibcxx") for f in files]
if any(v is None for v in glibcs) or any(v is None for v in cxxs):
    raise SystemExit("PROBE_UNEXPECTED_NULL_IN_EMPTY")
if files:
    raise SystemExit("PROBE_UNEXPECTED_FILES")
if not report["configuredLimitsSatisfied"]:
    raise SystemExit("PROBE_FAIL")
print("PROBE_PASS n_elf=0 vacuous Architecture:all Python official launchers; None-safe (0 versioned, 0 null; no max invented) configuredLimitsSatisfied=true")
PY

cp --remove-destination -L \
  "$UNPACK_GUI/usr/share/doc/language-selector-gnome/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK_COMMON/usr/share/doc/language-selector-common/changelog.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
python3 - << PY
import hashlib
from pathlib import Path
p = Path("$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz")
assert hashlib.sha256(p.read_bytes()).hexdigest() == "cf2ba918e51e3253a0d2cd62c30a5af60d871f31728c275fd4917a8a28dd7912"
print("changelog_upstream_ok")
PY

export UNPACK_DESKTOP="$UNPACK_GUI/usr/share/applications/gnome-language-selector.desktop"
export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/gnome-language-selector.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path
text = Path(os.environ["UNPACK_DESKTOP"]).read_text()
if not re.search(r"^Name=Language Support\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if re.search(r"^GenericName=", text, flags=re.M):
    raise SystemExit("DESKTOP_GENERICNAME_UNEXPECTED")
if not re.search(r"^Exec=/usr/bin/gnome-language-selector\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if not re.search(r"^Icon=preferences-desktop-locale\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ICON")
if re.search(r"^TryExec=", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_ALREADY")
text = re.sub(
    r"^Exec=/usr/bin/gnome-language-selector.*$",
    lambda m: m.group(0) + "\nTryExec=/usr/bin/gnome-language-selector",
    text,
    count=1,
    flags=re.M,
)
if "Exec=/usr/bin/gnome-language-selector" not in text:
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if "TryExec=/usr/bin/gnome-language-selector" not in text:
    raise SystemExit("DESKTOP_TRYEXEC_FAIL")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-language-selector"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-language-selector":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_kept_absolute_tryexec_added")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-language-selector-gnome/scripts/build-language-selector-gnome-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-language-selector\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/gnome-language-selector" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

ln -sf /usr/bin/gnome-language-selector "$STAGE/pkg/opt/language-selector-gnome/gnome-language-selector"
ln -sf /usr/bin/check-language-support "$STAGE/pkg/opt/language-selector-gnome/check-language-support"
ln -sf gnome-language-selector "$STAGE/pkg/usr/bin/kemi-language-selector-gnome"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        bad.append(("elf", str(p)))
        continue
    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        bad.append(("bin", str(p)))
        continue
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "x86_64" in line:
            bad.append((str(p), i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PY

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-language-selector-gnome (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    language-selector-gnome 0.204.2 all, KEMI
    mall linuxpkg repack. Bundles official
    same-source exact-version
    language-selector-common (= 0.204.2).
    Official different-source Depends stay
    Depends. Official Recommends yelp stay
    Recommends. Official control has no
    Suggests. Versioned Provides for both
    official packages (= 0.204.2). Official
    /usr/bin/gnome-language-selector stays at
    the official path; /opt/language-selector-gnome/*
    are symlinks. Also
    /usr/bin/kemi-language-selector-gnome →
    gnome-language-selector. Official desktop
    Name=Language Support kept;
    already-absolute Exec kept; TryExec added.
    Official GUI changelog symlink into bundled
    language-selector-common is kept and
    resolves; the real official changelog was
    also copied with cp -L. Official package
    ships no app icon (theme name
    preferences-desktop-locale); official 32×32
    pixmaps stay official. A 128×128 evidence
    PNG rasterized from official Ubuntu 20.04
    humanity-icon-theme 0.6.15 is used only as
    mall CREATE --icon and is not packed. Theme
    package is not bundled. Official common
    package ships 134 .mo including zh_CN /
    zh_HK / zh_TW; none invented. Official
    dh_python3 hooks retargeted to
    kemi-language-selector-gnome; official
    common maintainer scripts and conffiles
    kept; desktop-database hook appended.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
Language Support — official Ubuntu 20.04
(focal-updates main) language-selector-gnome
0.204.2 Architecture: all, KEMI repack.
Official user-facing launcher
/usr/bin/gnome-language-selector is a Python 3
wrapper and stays under /usr.
/opt/language-selector-gnome/* are symlinks.
Bundles official same-source exact-version
language-selector-common (= 0.204.2). Official
different-source Depends stay Depends and are
not bundled. Official Recommends yelp stay
Recommends. Official control has no Suggests.
Official common package ships 134 .mo including
zh_CN / zh_HK / zh_TW (keep official; do not
invent language packs). Official package ships
no app icon (theme name
preferences-desktop-locale); official 32×32
pixmaps stay official. A 128×128 evidence PNG
rasterized from official Ubuntu 20.04
humanity-icon-theme 0.6.15 is used only as
mall CREATE --icon and is not packed. Theme
package is not bundled. Official desktop
Name=Language Support is kept; mall app_name
is Language Support (official desktop Name;
no appdata <name> and no GenericName). Probe:
0 unique ELF (Architecture: all, official
launchers are Python); vacuous PASS vs Ubuntu
20.04 / glibc 2.31; None-safe (no max invented
from null). Official publication: Ubuntu 20.04
focal-updates main language-selector-gnome
0.204.2 (all), newer than focal Release 0.204.
Official SHA256 + size of both official debs
matched ports.ubuntu.com and Aliyun
ubuntu-ports pool files and the focal-updates
main Packages stanza. No librarian URL this
run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: admin
Priority: optional
Architecture: $ARCH
Pre-Depends: dpkg (>= 1.15.7.2)
Installed-Size: $INSTALLED_SIZE
Depends: python3:any, python3-gi, gir1.2-gtk-3.0, python3-apt (>= 0.7.12.0), aptdaemon (>= 0.40+bzr527), python3-aptdaemon.gtk3widgets, im-config (>= 0.29-1ubuntu10~), iso-codes, python3-dbus, dbus, accountsservice (>= 0.6.29-1ubuntu6)
Recommends: yelp
Conflicts: language-selector (<< 0.17), language-selector-gnome, language-selector-common
Replaces: language-selector (<< 0.17), language-selector-gnome, language-selector-common
Provides: language-selector-gnome (= 0.204.2), language-selector-common (= 0.204.2)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Language selector for Ubuntu
 Language Support ${VER_UP} — official Ubuntu
 20.04 all, KEMI repack of
 language-selector-gnome. Bundles official
 language-selector-common.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# Official common maintainer scripts kept; dh_python3 hooks
# retargeted to the kemi package name. Desktop-database hook
# appended before official postinst exit 0.
python3 - << 'PY'
from pathlib import Path
import re
common = Path("/workspace/t142-20261112-language-selector-gnome/unpack-official/language-selector-common/DEBIAN")
stage = Path("${STAGE}/pkg/DEBIAN".replace("${STAGE}", open("/dev/null","w").name))  # placeholder
PY
# Use env for STAGE path
export STAGE_DEBIAN="$STAGE/pkg/DEBIAN"
export COMMON_DEBIAN="$UNPACK_COMMON/DEBIAN"
python3 - << 'PY'
import os, re
from pathlib import Path
src = Path(os.environ["COMMON_DEBIAN"])
dst = Path(os.environ["STAGE_DEBIAN"])

def retarget_python(text):
    # Only retarget dh_python3 package-name arguments, not comments
    # or D-Bus names.
    text = text.replace("py3compile -p language-selector-common", "py3compile -p kemi-language-selector-gnome")
    text = text.replace("pypy3compile -p language-selector-common", "pypy3compile -p kemi-language-selector-gnome")
    text = text.replace("py3clean -p language-selector-common", "py3clean -p kemi-language-selector-gnome")
    text = text.replace("dpkg -L language-selector-common", "dpkg -L kemi-language-selector-gnome")
    text = text.replace("py3compile -p language-selector-gnome", "py3compile -p kemi-language-selector-gnome")
    text = text.replace("pypy3compile -p language-selector-gnome", "pypy3compile -p kemi-language-selector-gnome")
    text = text.replace("py3clean -p language-selector-gnome", "py3clean -p kemi-language-selector-gnome")
    text = text.replace("dpkg -L language-selector-gnome", "dpkg -L kemi-language-selector-gnome")
    return text

for name in ("preinst", "postinst", "prerm", "postrm"):
    text = (src / name).read_text()
    text = retarget_python(text)
    if name == "postinst":
        hook = (
            "\n# kemi hooks\n"
            "if command -v update-desktop-database >/dev/null 2>&1; then\n"
            "	update-desktop-database -q /usr/share/applications || true\n"
            "fi\n"
        )
        # Insert before a trailing exit 0, else append.
        if re.search(r"^exit 0\s*$", text, flags=re.M):
            text = re.sub(r"\nexit 0\s*$", hook + "\nexit 0\n", text, count=1)
        else:
            text = text.rstrip() + hook
    (dst / name).write_text(text)
    (dst / name).chmod(0o755)

# sanity
post = (dst / "postinst").read_text()
prerm = (dst / "prerm").read_text()
assert "py3compile -p kemi-language-selector-gnome" in post
assert "py3clean -p kemi-language-selector-gnome" in prerm
assert "dpkg -L kemi-language-selector-gnome" in prerm
assert "py3compile -p language-selector-common" not in post
assert "py3compile -p language-selector-gnome" not in post
assert "dpkg -L language-selector-common" not in prerm
assert "update-desktop-database" in post
assert "dpkg-maintscript-helper" in post
assert "exit 0" in post
print("hooks_retargeted")
PY
grep -q 'py3compile -p kemi-language-selector-gnome' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'py3clean -p kemi-language-selector-gnome' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'dpkg-maintscript-helper' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p language-selector-gnome' "$STAGE/pkg/DEBIAN/postinst"
! grep -q 'py3compile -p language-selector-common' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_written"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
echo "$DEB" | grep -q 'kemi-language-selector-gnome_0.204.2kemi1_all.deb'
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'Version: 0.204.2kemi1' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'Architecture: all' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'language-selector-gnome (= 0.204.2)' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'language-selector-common (= 0.204.2)' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'python3-apt (>= 0.7.12.0)' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'accountsservice (>= 0.6.29-1ubuntu6)' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
grep -q 'Recommends: yelp' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"
! grep -q 'Depends:.*language-selector-common' "$ROOT/evidence/kemi-language-selector-gnome-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
import re
from pathlib import Path
desk = Path("$CHECK/usr/share/applications/gnome-language-selector.desktop").read_text()
if r"\\1" in desk or r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if "Name=Language Support" not in desk:
    raise SystemExit("BUILT_NAME")
if "Exec=/usr/bin/gnome-language-selector" not in desk:
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-language-selector" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if "Icon=preferences-desktop-locale" not in desk:
    raise SystemExit("BUILT_ICON")
if re.search(r"^Exec=gnome-language-selector\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-language-selector"
python3 - << PY
from pathlib import Path
p = Path("$CHECK/usr/bin/gnome-language-selector")
assert not p.is_symlink()
assert b"python3" in p.read_bytes().splitlines()[0]
assert p.read_bytes()[:4] != bytes([0x7F]) + b"ELF"
print("built_launcher_is_python")
PY
test -L "$CHECK/usr/bin/kemi-language-selector-gnome"
test "$(readlink "$CHECK/usr/bin/kemi-language-selector-gnome")" = "gnome-language-selector"
test -L "$CHECK/opt/language-selector-gnome/gnome-language-selector"
test "$(readlink "$CHECK/opt/language-selector-gnome/gnome-language-selector")" = "/usr/bin/gnome-language-selector"
test -x "$CHECK/usr/bin/check-language-support"
test -f "$CHECK/usr/lib/python3/dist-packages/LanguageSelector/__init__.py"
test -f "$CHECK/usr/lib/python3/dist-packages/LanguageSelector/gtk/GtkLanguageSelector.py"
test -f "$CHECK/usr/share/pixmaps/language-selector.png"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 134
test -f "$CHECK/usr/share/locale/zh_CN/LC_MESSAGES/language-selector.mo"
test -f "$CHECK/etc/fonts/conf.avail/56-language-selector-ar.conf"
test -L "$CHECK/etc/fonts/conf.d/56-language-selector-ar.conf"
if find "$CHECK" -name 'preferences-desktop-locale-128.png' -o -path '*Humanity*' | grep -q .; then
  echo "THEME_OR_EVIDENCE_IN_DEB" >&2
  exit 1
fi
test -L "$CHECK/usr/share/doc/language-selector-gnome/changelog.gz"
test -e "$CHECK/usr/share/doc/language-selector-gnome/changelog.gz"
test -f "$CHECK/usr/share/doc/language-selector-common/changelog.gz"
test -f "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$CHECK/usr/share/doc/$PKG/changelog.upstream.gz"
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
