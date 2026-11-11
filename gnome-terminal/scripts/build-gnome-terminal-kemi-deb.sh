#!/bin/bash
# Wrap official Ubuntu 20.04 (focal-updates main)
# gnome-terminal 3.36.2-1ubuntu1~20.04 Architecture:
# arm64 as kemi-gnome-terminal, bundling official
# arch:all same-source gnome-terminal-data
# 3.36.2-1ubuntu1~20.04. Official GUI hard Depends
# is a tight same-series range (gnome-terminal-data
# (>= 3.36), gnome-terminal-data (<< 3.37)), not
# exact-version; the matching focal-updates version
# (same official version as the GUI) is bundled
# (official -data / gnome-todo-common pattern).
# focal Release also has 3.36.1.1-1ubuntu1 in that
# range; that older package is not shipped. Official
# same-source nautilus-extension-gnome-terminal is
# only a Recommends of the GUI (not a hard Depends)
# and is inspected and not packaged; it stays
# Recommends / unbundled. Different-source Depends
# (vte, GTK, glib, dconf, uuid, X11, python3,
# python3-gi, typelib, gsettings-desktop-schemas,
# dbus session bus) stay Depends. Official
# Recommends gvfs, nautilus-extension-gnome-terminal
# and yelp stay Recommends / unbundled. Official
# control has no Suggests. Versioned Provides:
# gnome-terminal (= 3.36.2-1ubuntu1~20.04),
# gnome-terminal-data (= 3.36.2-1ubuntu1~20.04),
# plus official unversioned Provides:
# x-terminal-emulator. No Debian epoch. Official
# tilde in 3.36.2-1ubuntu1~20.04 is kept in mall
# version_name and the deb filename (GNOME Clocks
# pattern). Official /usr/bin/gnome-terminal is a
# Python 3 wrapper and
# /usr/bin/gnome-terminal.wrapper is a Perl
# x-terminal-emulator helper; they are not ELFs
# and are not counted as ELFs. Official
# /usr/bin/gnome-terminal.real and
# /usr/libexec/gnome-terminal-server are compiled
# aarch64 ELFs (requiredGlibc 2.17, no GLIBCXX,
# no RUNPATH) and stay at official paths
# (binreloc / compiled /usr prefix / XDG
# /usr/share). Official files stay on official
# paths; /opt/gnome-terminal/* are symlinks only.
# Also /usr/bin/kemi-gnome-terminal →
# gnome-terminal (the official user-facing
# launcher). Official packages ship no .mo
# (Ubuntu language-pack split); official
# help-langpack symlinks in gnome-terminal-data
# are kept as official (they may dangle without
# language packs); do not invent packs. Official
# C help (including in-help PNGs/SVG) stays
# official and is not used as a mall icon.
# Official app icons are SVG only
# (org.gnome.Terminal.svg + symbolic); no
# official 256×256 PNG. A 128×128 PNG rasterized
# from the official app SVG via Chrome headless
# --default-background-color=00000000 lives at
# evidence/org.gnome.Terminal-128.png and is used
# only as the mall CREATE --icon; it is not
# shipped in the deb. Official GUI
# changelog.Debian.gz is a real file (not a
# dangling symlink) and is copied with cp -L
# into the kemi doc dir; official NEWS.gz is a
# real file. Official desktop Name=Terminal is
# kept; mall app_name is GNOME Terminal.
# Official desktop Exec=gnome-terminal (and New
# Window / Preferences action Exec) is rewritten
# to /usr/bin/gnome-terminal …; official
# TryExec=gnome-terminal is rewritten to
# /usr/bin/gnome-terminal. Official D-Bus and
# systemd Exec paths are already absolute and
# are kept. Official Python launcher already
# calls /usr/bin/gnome-terminal.real and
# /usr/libexec/gnome-terminal-server and is
# kept official. Official postinst/prerm
# update-alternatives for x-terminal-emulator
# pointing at official
# /usr/bin/gnome-terminal.wrapper (and official
# man) are kept. Icon-cache, desktop-database
# and glib-compile-schemas hooks are appended.
# Official packages have no py3compile hooks;
# none are invented. Probe: Architecture arm64 ·
# 2 unique packaged ELFs · requiredGlibc 2.17
# (2 versioned, 0 null) · no GLIBCXX (0
# versioned, 2 null; null is not ranked as a
# max) · within 101 ≤2.31 / ≤3.4.28. Official
# SHA256 + size matched official
# ports.ubuntu.com pool files and the Ubuntu
# 20.04 focal-updates main arm64 Packages
# stanza (Aliyun ubuntu-ports mirror, streamed).
# Newer than focal Release 3.36.1.1-1ubuntu1.
# Not in focal-security / focal-backports. No
# librarian URL and no .buildinfo is recorded
# this run (pool 404). KEMI version
# 3.36.2-1ubuntu1~20.04kemi1 is 26 chars (under
# the mall version_name limit that rejected
# Remmina's 33-char string; 12–28 char siblings
# succeeded, including Nautilus 28). Tilde kept;
# no epoch; no shortening applied unless the
# mall later rejects 26. gork.bot协助开发 ·
# Verify ≠ compile

set -euo pipefail
ROOT=/workspace/t142-20261112-gnome-terminal
VER_UP=3.36.2-1ubuntu1~20.04
VER_DEB="${VER_UP}kemi1"
ARCH=arm64
PKG=kemi-gnome-terminal
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
UNPACK="${UNPACK:-$ROOT/unpack-official/gnome-terminal_3.36.2-1ubuntu1~20.04_arm64}"
DATA="${DATA:-$ROOT/unpack-official/gnome-terminal-data_3.36.2-1ubuntu1~20.04_all}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UP_DEB="$DL/gnome-terminal_3.36.2-1ubuntu1~20.04_arm64.deb"
UP_DATA="$DL/gnome-terminal-data_3.36.2-1ubuntu1~20.04_all.deb"
EXPECT_SHA=d014573a2ca7f849283bd837d5076a969b5b5a9b6cb9ff80d53c6c52f6f418fe
EXPECT_BYTES=161776
EXPECT_DATA_SHA=970cdf3a63b3c239cedd4232b15ea2c0a1d51210551ff077c8d99a510f9072f3
EXPECT_DATA_BYTES=30288
python3 - << PY
s="${VER_DEB}"
assert len(s) == 26, len(s)
assert ":" not in s, s
assert "~" in s, s
assert s == "3.36.2-1ubuntu1~20.04kemi1"
print("version_name_len", len(s), s)
PY
mkdir -p "$DL" "$OUT" "$ROOT/evidence" "$ROOT/probe"
test -f "$UP_DEB" && test -f "$UP_DATA"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
test "$(stat -c%s "$UP_DATA")" = "$EXPECT_DATA_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
echo "$EXPECT_DATA_SHA  $UP_DATA" | sha256sum -c -
test -x "$UNPACK/usr/bin/gnome-terminal"
test -x "$UNPACK/usr/bin/gnome-terminal.real"
test -x "$UNPACK/usr/bin/gnome-terminal.wrapper"
test -x "$UNPACK/usr/libexec/gnome-terminal-server"
python3 - << PY
from pathlib import Path
import hashlib
launcher = Path("$UNPACK/usr/bin/gnome-terminal")
wrapper = Path("$UNPACK/usr/bin/gnome-terminal.wrapper")
real = Path("$UNPACK/usr/bin/gnome-terminal.real")
server = Path("$UNPACK/usr/libexec/gnome-terminal-server")
assert not launcher.is_symlink() and not wrapper.is_symlink()
assert launcher.read_bytes()[:2] == b"#!"
assert wrapper.read_bytes()[:2] == b"#!"
assert b"ELF" not in launcher.read_bytes()[:4]
assert launcher.read_text().startswith("#!/usr/bin/python3")
assert "perl" in wrapper.read_text().splitlines()[0]
assert not real.is_symlink() and real.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert not server.is_symlink() and server.read_bytes()[:4] == bytes([0x7F]) + b"ELF"
assert real.stat().st_size == 101432
assert hashlib.sha256(real.read_bytes()).hexdigest() == "322687cae8659a5d3cd0bcc7b77ca1b8953d76d5f02e6e99edc16c1bfd54ff89"
assert server.stat().st_size == 358560
assert hashlib.sha256(server.read_bytes()).hexdigest() == "01e69ac4e50e4f4b68df508e5678d041df2aa760993bb1d48b05c8aa28abf862"
print("official_binaries_ok")
PY
test -f "$UNPACK/usr/share/applications/org.gnome.Terminal.desktop"
test -f "$UNPACK/usr/share/icons/hicolor/scalable/apps/org.gnome.Terminal.svg"
test ! -f "$UNPACK/usr/share/icons/hicolor/256x256/apps/org.gnome.Terminal.png"
test ! -f "$DATA/usr/share/icons/hicolor/256x256/apps/org.gnome.Terminal.png"
test -f "$UNPACK/usr/share/glib-2.0/schemas/org.gnome.Terminal.gschema.xml"
test ! -L "$UNPACK/usr/share/doc/gnome-terminal/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-terminal/changelog.Debian.gz"
test -f "$UNPACK/usr/share/doc/gnome-terminal/NEWS.gz"
test ! -L "$UNPACK/usr/share/doc/gnome-terminal/NEWS.gz"
test -f "$DATA/usr/share/doc/gnome-terminal-data/changelog.Debian.gz"
test -f "$UNPACK/DEBIAN/postinst"
test -f "$UNPACK/DEBIAN/prerm"
test -f "$ROOT/evidence/org.gnome.Terminal-128.png"
python3 - << PY
from pathlib import Path
from struct import unpack
import hashlib
p = Path("$ROOT/evidence/org.gnome.Terminal-128.png")
data = p.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n"
assert data[12:16] == b"IHDR"
w, h = unpack(">II", data[16:24])
assert (w, h) == (128, 128), (w, h)
assert hashlib.sha256(data).hexdigest() == "c068a98f6f8db0fb177c741556da4f5d004180b59ffa90c65c037de8407bdd75"
print("evidence_128_ok", w, h, p.stat().st_size)
for root in ("$UNPACK", "$DATA"):
    mos = list(Path(root).rglob("*.mo"))
    assert mos == [], mos
print("official_no_mo")
PY

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/opt/gnome-terminal"

# bundle official matching -data first, then official GUI
cp -a "$DATA/usr/." "$STAGE/pkg/usr/"
cp -a "$UNPACK/usr/." "$STAGE/pkg/usr/"
chmod 0755 "$STAGE/pkg/usr/bin/gnome-terminal" \
  "$STAGE/pkg/usr/bin/gnome-terminal.real" \
  "$STAGE/pkg/usr/bin/gnome-terminal.wrapper" \
  "$STAGE/pkg/usr/libexec/gnome-terminal-server"
# official alternatives maintainer scripts kept (official wrapper path)
cp -a "$UNPACK/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postinst"
cp -a "$UNPACK/DEBIAN/prerm" "$STAGE/pkg/DEBIAN/prerm"
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"
test -f "$STAGE/pkg/usr/share/doc/gnome-terminal/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/doc/gnome-terminal-data/changelog.Debian.gz"
test -f "$STAGE/pkg/usr/share/help/C/gnome-terminal/index.page"

REPORT="$ROOT/probe/kemi-gnome-terminal.json"
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
test "${#ELFS[@]}" = 2
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
if len(files) != 2:
    raise SystemExit(f"PROBE_UNEXPECTED_COUNT:{len(files)}")
by_name = {Path(f["path"]).name: f for f in files}
expect = {
    "gnome-terminal.real": ("322687cae8659a5d3cd0bcc7b77ca1b8953d76d5f02e6e99edc16c1bfd54ff89", 101432, "2.17"),
    "gnome-terminal-server": ("01e69ac4e50e4f4b68df508e5678d041df2aa760993bb1d48b05c8aa28abf862", 358560, "2.17"),
}
if set(by_name) != set(expect):
    raise SystemExit("PROBE_NAMES:" + ",".join(sorted(by_name)))
for name, (sha, nbytes, glibc) in expect.items():
    f = by_name[name]
    if f.get("architecture") != "aarch64":
        raise SystemExit("PROBE_ARCH:" + name)
    if f.get("requiredGlibc") != glibc:
        raise SystemExit("PROBE_GLIBC:" + name + ":" + str(f.get("requiredGlibc")))
    if f.get("requiredGlibcxx") is not None:
        raise SystemExit("PROBE_UNEXPECTED_GLIBCXX:" + name)
    if f.get("sha256") != sha:
        raise SystemExit("PROBE_SHA:" + name)
    if int(f.get("bytes") or 0) != nbytes:
        raise SystemExit("PROBE_BYTES:" + name)
versioned = [x for x in files if x.get("requiredGlibc") is not None]
nulls = [x for x in files if x.get("requiredGlibc") is None]
cxx = [x for x in files if x.get("requiredGlibcxx") is not None]
cxx_null = [x for x in files if x.get("requiredGlibcxx") is None]
glibcs = sorted({x.get("requiredGlibc") for x in versioned})
if None in glibcs:
    raise SystemExit("PROBE_NULL_RANKED_AS_MAX")
if len(versioned) != 2 or len(nulls) != 0 or cxx or len(cxx_null) != 2:
    raise SystemExit(f"PROBE_NONE_SAFE_COUNTS v={len(versioned)} n={len(nulls)} cxx={len(cxx)} cxxn={len(cxx_null)}")
if glibcs != ["2.17"]:
    raise SystemExit("PROBE_GLIBC_SET:" + ",".join(glibcs))
# official wrappers must remain non-ELF
for rel in ("usr/bin/gnome-terminal", "usr/bin/gnome-terminal.wrapper"):
    p = Path("$STAGE/pkg") / rel
    if p.read_bytes()[:4] == bytes([0x7F]) + b"ELF":
        raise SystemExit("WRAPPER_COUNTED_AS_ELF:" + rel)
print("PROBE_PASS n_elf=2 unique aarch64 requiredGlibc 2.17 (2 versioned, 0 null) noGLIBCXX (0 versioned, 2 null; null not ranked as a max) official python/perl wrappers not ELF configuredLimitsSatisfied=true")
PY

test -f "$STAGE/pkg/usr/share/icons/hicolor/scalable/apps/org.gnome.Terminal.svg"
test ! -f "$STAGE/pkg/usr/share/icons/hicolor/256x256/apps/org.gnome.Terminal.png"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 0
if find "$STAGE/pkg" -name 'org.gnome.Terminal-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_STAGED" >&2
  exit 1
fi
# nautilus extension / typelib / -dev must not be staged
test ! -e "$STAGE/pkg/usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libterminal-nautilus.so"
test ! -d "$STAGE/pkg/usr/include"
# official help-langpack dangling symlinks kept
test -L "$STAGE/pkg/usr/share/help/fr/gnome-terminal/index.page"
test -f "$STAGE/pkg/usr/share/help/C/gnome-terminal/figures/gnome-terminal.png"

cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-terminal/copyright" \
  "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
cp --remove-destination -L \
  "$UNPACK/usr/share/doc/gnome-terminal/changelog.Debian.gz" \
  "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

export STAGE_DESKTOP="$STAGE/pkg/usr/share/applications/org.gnome.Terminal.desktop"
python3 - << 'PY'
import os, re
from pathlib import Path

def rewrite_prefix(text, kind):
    out = []
    for line in text.splitlines(True):
        if kind == "Exec" and line.startswith("Exec=gnome-terminal"):
            out.append("Exec=/usr/bin/" + line[len("Exec="):])
        elif kind == "TryExec" and line.startswith("TryExec=gnome-terminal"):
            out.append("TryExec=/usr/bin/" + line[len("TryExec="):])
        else:
            out.append(line)
    return "".join(out)

src = Path("/workspace/t142-20261112-gnome-terminal/unpack-official/gnome-terminal_3.36.2-1ubuntu1~20.04_arm64/usr/share/applications/org.gnome.Terminal.desktop")
text = src.read_text()
if not re.search(r"^Name=Terminal\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_NAME")
if not re.search(r"^Exec=gnome-terminal\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_EXEC_UNEXPECTED")
if not re.search(r"^TryExec=gnome-terminal\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_TRYEXEC_UNEXPECTED")
text = rewrite_prefix(text, "TryExec")
text = rewrite_prefix(text, "Exec")
if "Exec=/usr/bin/gnome-terminal\n" not in text and not re.search(r"^Exec=/usr/bin/gnome-terminal\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_REWRITE_FAIL")
if not re.search(r"^Exec=/usr/bin/gnome-terminal --window\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ACTION_WINDOW")
if not re.search(r"^Exec=/usr/bin/gnome-terminal --preferences\s*$", text, flags=re.M):
    raise SystemExit("DESKTOP_ACTION_PREFS")
if text.count("TryExec=/usr/bin/gnome-terminal") != 1:
    raise SystemExit("DESKTOP_TRYEXEC_COUNT")
if r"\1" in text:
    raise SystemExit("DESKTOP_LITERAL_GROUP")
if "OnlyShowIn=GNOME;Unity;" not in text:
    raise SystemExit("DESKTOP_ONLYSHOWIN")
for line in text.splitlines():
    if line.startswith("Exec=") and not line.startswith("Exec=/usr/bin/gnome-terminal"):
        raise SystemExit("DESKTOP_LEFTOVER_EXEC:" + line)
    if line.startswith("TryExec=") and line != "TryExec=/usr/bin/gnome-terminal":
        raise SystemExit("DESKTOP_BAD_TRYEXEC:" + line)
Path(os.environ["STAGE_DESKTOP"]).write_text(text)
print("desktop_exec_rewritten_tryexec_rewritten")
PY

python3 - << PY
from pathlib import Path
text = Path("/workspace/t142-20261112-gnome-terminal/scripts/build-gnome-terminal-kemi-deb.sh").read_text()
if 'r"Exec=/usr/bin/gnome-terminal\\1"' in text:
    raise SystemExit("SCRIPT_HAS_GROUP_REPL")
if "Exec=/usr/bin/" not in text:
    raise SystemExit("SCRIPT_MISSING_REWRITE")
print("desktop_script_replacements_ok")
PY

python3 - << PY
from pathlib import Path
dbus = Path("$STAGE/pkg/usr/share/dbus-1/services/org.gnome.Terminal.service").read_text()
if "Exec=/usr/libexec/gnome-terminal-server" not in dbus:
    raise SystemExit("DBUS_EXEC")
unit = Path("$STAGE/pkg/usr/lib/systemd/user/gnome-terminal-server.service").read_text()
if "ExecStart=/usr/libexec/gnome-terminal-server" not in unit:
    raise SystemExit("SYSTEMD_EXEC")
print("dbus_systemd_exec_kept_absolute")
PY

ln -sf /usr/bin/gnome-terminal "$STAGE/pkg/opt/gnome-terminal/gnome-terminal"
ln -sf /usr/bin/gnome-terminal.real "$STAGE/pkg/opt/gnome-terminal/gnome-terminal.real"
ln -sf /usr/bin/gnome-terminal.wrapper "$STAGE/pkg/opt/gnome-terminal/gnome-terminal.wrapper"
ln -sf /usr/libexec/gnome-terminal-server "$STAGE/pkg/opt/gnome-terminal/gnome-terminal-server"
ln -sf gnome-terminal "$STAGE/pkg/usr/bin/kemi-gnome-terminal"

python3 - << PY
from pathlib import Path
root = Path("$STAGE/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".woff"} or p.name.endswith(".typelib"):
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

python3 - << PY
import subprocess
from pathlib import Path
root = Path("$STAGE/pkg")
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.read_bytes()[:4] != bytes([0x7F]) + b"ELF":
        continue
    out = subprocess.check_output(["readelf", "-d", str(p)], text=True, errors="replace")
    if "RPATH" in out or "RUNPATH" in out:
        raise SystemExit("UNEXPECTED_RUNPATH:" + str(p))
print("no_runpath")
PY

cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-terminal (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal-updates main)
    gnome-terminal 3.36.2-1ubuntu1~20.04 arm64,
    KEMI mall linuxpkg repack. Newer than focal
    Release 3.36.1.1-1ubuntu1. Official
    arch:all same-source gnome-terminal-data
    3.36.2-1ubuntu1~20.04 bundled (GUI hard
    Depends is gnome-terminal-data (>= 3.36)
    (<< 3.37); matching official version
    bundled). Official
    nautilus-extension-gnome-terminal inspected
    and not packaged; official Recommends gvfs /
    nautilus-extension-gnome-terminal / yelp
    stay Recommends. Different-source Depends
    stay Depends. Official control has no
    Suggests. Versioned Provides:
    gnome-terminal (= 3.36.2-1ubuntu1~20.04),
    gnome-terminal-data
    (= 3.36.2-1ubuntu1~20.04); official
    x-terminal-emulator Provide kept. No Debian
    epoch. Official tilde kept in mall
    version_name and the deb filename. Official
    /usr/bin/gnome-terminal (Python) and
    .wrapper (Perl) stay official and are not
    ELFs; official .real and
    gnome-terminal-server ELFs stay at official
    paths; /opt/gnome-terminal/* are symlinks.
    Also /usr/bin/kemi-gnome-terminal →
    gnome-terminal. Official desktop
    Name=Terminal kept; Exec/TryExec rewritten
    to /usr/bin/gnome-terminal. Official
    changelog is a real file and was copied
    with cp -L. Official icons are SVG only; a
    128×128 evidence PNG rasterized from the
    official SVG is used only as mall CREATE
    --icon and is not packed. Official packages
    ship no .mo; official help-langpack
    symlinks kept; none invented. Official
    update-alternatives for
    x-terminal-emulator at official
    /usr/bin/gnome-terminal.wrapper kept.
    Icon-cache, desktop-database and
    glib-compile-schemas hooks added.
    gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  Thu, 12 Nov 2026 03:05:00 +0800
EOT

cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi" << 'EOT'
GNOME Terminal — official Ubuntu 20.04
(focal-updates main) gnome-terminal
3.36.2-1ubuntu1~20.04 arm64, KEMI repack.
Official /usr/bin/gnome-terminal.real and
/usr/libexec/gnome-terminal-server are aarch64
ELFs and stay under /usr. Official
/usr/bin/gnome-terminal is a Python 3 wrapper
and gnome-terminal.wrapper is a Perl helper;
they are not ELFs. /opt/gnome-terminal/* are
symlinks. Same-source gnome-terminal-data
3.36.2-1ubuntu1~20.04 is bundled. Official
nautilus-extension-gnome-terminal / gvfs /
yelp Recommends stay Recommends and are not
bundled. Different-source Depends stay Depends.
Official packages ship no .mo. Official icons
are SVG only; a 128×128 evidence PNG is used
only as mall CREATE --icon and is not packed.
No Debian epoch; official tilde is kept in mall
version_name. Probe: 2 unique ELFs ·
requiredGlibc 2.17 (2 versioned, 0 null; no max
invented from null) · no requiredGlibcxx (0
versioned, 2 null; null not ranked as a max) ·
no RUNPATH; within Ubuntu 20.04 / glibc 2.31.
Official publication: Ubuntu 20.04
focal-updates main gnome-terminal
3.36.2-1ubuntu1~20.04 (arm64). Official SHA256
+ size matched ports.ubuntu.com pool files and
the focal-updates main arm64 Packages stanza.
No librarian URL this run.
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
Depends: libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.2.4), libdconf1 (>= 0.14.0), libglib2.0-0 (>= 2.50.0), libgtk-3-0 (>= 3.22.27), libpango-1.0-0 (>= 1.14.0), libuuid1 (>= 2.16), libvte-2.91-0 (>= 0.60.2), libx11-6, dconf-gsettings-backend | gsettings-backend, default-dbus-session-bus | dbus-session-bus, python3, python3-gi, gir1.2-glib-2.0, gsettings-desktop-schemas (>= 0.1.0)
Recommends: gvfs, nautilus-extension-gnome-terminal, yelp
Replaces: gnome-terminal, gnome-terminal-data
Conflicts: gnome-terminal, gnome-terminal-data
Provides: x-terminal-emulator, gnome-terminal (= 3.36.2-1ubuntu1~20.04), gnome-terminal-data (= 3.36.2-1ubuntu1~20.04)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://wiki.gnome.org/Apps/Terminal
Description: GNOME terminal emulator application
 GNOME Terminal ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack. Bundles official
 gnome-terminal-data.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

# append hooks after official alternatives postinst; new postrm for hook cleanup
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
if [ "$1" = "configure" ] || [ "$1" = "abort-upgrade" ] || [ "$1" = "abort-deconfigure" ] || [ "$1" = "abort-remove" ] ; then
	if command -v glib-compile-schemas >/dev/null 2>&1; then
		glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
	fi
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
if command -v glib-compile-schemas >/dev/null 2>&1; then
	glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
fi
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
grep -q 'update-alternatives --install /usr/bin/x-terminal-emulator' "$STAGE/pkg/DEBIAN/postinst"
grep -q '/usr/bin/gnome-terminal.wrapper' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-alternatives --remove x-terminal-emulator /usr/bin/gnome-terminal.wrapper' "$STAGE/pkg/DEBIAN/prerm"
grep -q 'glib-compile-schemas' "$STAGE/pkg/DEBIAN/postinst"
grep -q 'update-desktop-database' "$STAGE/pkg/DEBIAN/postinst"
echo "hooks_appended"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
dpkg-deb --root-owner-group -b "$STAGE/pkg" "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'Version: 3.36.2-1ubuntu1~20.04kemi1' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'Architecture: arm64' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'libc6 (>= 2.17)' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'libvte-2.91-0 (>= 0.60.2)' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'gnome-terminal (= 3.36.2-1ubuntu1~20.04)' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'gnome-terminal-data (= 3.36.2-1ubuntu1~20.04)' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'Provides: x-terminal-emulator' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'Conflicts: gnome-terminal, gnome-terminal-data' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
grep -q 'Recommends: gvfs, nautilus-extension-gnome-terminal, yelp' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
! grep -q '^ Suggests:' "$ROOT/evidence/kemi-gnome-terminal-control.txt"
! grep -E 'Depends:.*gnome-terminal-data' "$ROOT/evidence/kemi-gnome-terminal-control.txt"

CHECK=$(mktemp -d)
trap 'rm -rf "$STAGE" "$CHECK"' EXIT
dpkg-deb -x "$DEB" "$CHECK"
python3 - << PY
from pathlib import Path
import re
desk = Path("$CHECK/usr/share/applications/org.gnome.Terminal.desktop").read_text()
if r"\1" in desk:
    raise SystemExit("BUILT_DESKTOP_LITERAL_GROUP")
if not re.search(r"^Name=Terminal\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_NAME")
if not re.search(r"^Exec=/usr/bin/gnome-terminal\s*$", desk, flags=re.M):
    raise SystemExit("BUILT_EXEC")
if "TryExec=/usr/bin/gnome-terminal" not in desk:
    raise SystemExit("BUILT_TRYEXEC")
if re.search(r"^Exec=gnome-terminal\b", desk, flags=re.M):
    raise SystemExit("BUILT_RELATIVE_EXEC")
print("built_desktop_ok")
PY
test -x "$CHECK/usr/bin/gnome-terminal"
test -x "$CHECK/usr/bin/gnome-terminal.real"
test -x "$CHECK/usr/bin/gnome-terminal.wrapper"
test -x "$CHECK/usr/libexec/gnome-terminal-server"
test -L "$CHECK/usr/bin/kemi-gnome-terminal"
test "$(readlink "$CHECK/usr/bin/kemi-gnome-terminal")" = "gnome-terminal"
test -L "$CHECK/opt/gnome-terminal/gnome-terminal"
test "$(readlink "$CHECK/opt/gnome-terminal/gnome-terminal")" = "/usr/bin/gnome-terminal"
test -f "$CHECK/usr/share/glib-2.0/schemas/org.gnome.Terminal.gschema.xml"
test -f "$CHECK/usr/share/icons/hicolor/scalable/apps/org.gnome.Terminal.svg"
test -f "$CHECK/usr/share/help/C/gnome-terminal/index.page"
test -L "$CHECK/usr/share/help/fr/gnome-terminal/index.page"
if find "$CHECK" -name 'org.gnome.Terminal-128.png' | grep -q .; then
  echo "EVIDENCE_PNG_IN_DEB" >&2
  exit 1
fi
test ! -e "$CHECK/usr/lib/aarch64-linux-gnu/nautilus/extensions-3.0/libterminal-nautilus.so"
test "$(find "$CHECK" -name '*.mo' | wc -l)" = 0
# wrappers still official interpreters, not ELF
python3 - << PY
from pathlib import Path
assert Path("$CHECK/usr/bin/gnome-terminal").read_text().startswith("#!/usr/bin/python3")
assert "perl" in Path("$CHECK/usr/bin/gnome-terminal.wrapper").read_text().splitlines()[0]
print("wrappers_kept_official")
PY
# hash the published deb by explicit path, never find|head
sha256sum "$CHECK/usr/bin/gnome-terminal.real"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
echo "built_ok $DEB"
stat -c '%s' "$DEB"
sha256sum "$DEB"
echo "$DEB"
