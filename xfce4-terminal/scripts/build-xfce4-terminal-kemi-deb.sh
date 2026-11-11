#!/usr/bin/env bash
# Wrap official Ubuntu 20.04 (focal Release universe) xfce4-terminal
# 0.8.9.1-1 arm64 as kemi-xfce4-terminal. There is no same-source
# common/data/typelib package (single official binary). Official
# Recommends (default-dbus-session-bus | dbus-session-bus) stay
# Recommends and are not bundled. Official Depends exo-utils is a
# different source and stays a system Depends.
# Official binary: /usr/bin/xfce4-terminal plus Debian
#   /usr/bin/xfce4-terminal.wrapper (perl, not ELF).
# Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX ·
#   PASS vs 101 ≤2.31
# Official SHA256 + size matched official ports.ubuntu.com
#   pool files and the Ubuntu 20.04 focal universe arm64
#   Packages stanzas (Aliyun ubuntu-ports mirror, streamed).
#   No newer package in focal-updates. No librarian URL and no
#   .buildinfo is recorded this run (pool 404; Launchpad TLS
#   unexpected EOF).
# ELF embeds /usr/share/locale, /usr/share/applications/xfce4-terminal.desktop,
#   and data under /usr/share/xfce4/terminal (terminal-preferences.ui,
#   colorschemes). Layout keeps official files at /usr/bin;
#   /opt/xfce4-terminal/* are symlinks (HardInfo/Xpad/qpdfview/Pluma/
#   Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME System Monitor/
#   GParted/Seahorse/Remmina/dconf-editor). Official desktop
#   Icon=utilities-terminal (theme icon; this deb ships no icons —
#   do not invent any). Official language-pack split does not
#   apply here: this deb ships 57 .mo including zh_CN. Keep the
#   official tree; do not invent/bundle language-packs.
# Official wrapper exec('xfce4-terminal') is rewritten to the
#   absolute /usr/bin/xfce4-terminal (binary stays at that path).
#   Official postinst/prerm alternatives for x-terminal-emulator
#   pointing at /usr/bin/xfce4-terminal.wrapper are kept.
# KEMI version 0.8.9.1-1kemi1 is 13 chars (under the mall
#   version_name limit that rejected Remmina's 33-char string).
# gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t142-20261111-xfce4-terminal
VER_UP=0.8.9.1
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-xfce4-terminal
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
PROBE_PY="${PROBE_PY:-$ROOT/scripts/probe_elf.py}"
UNPACK="${UNPACK:-$ROOT/probe/xfce4-terminal-0.8.9.1-focal-unpack}"
UP_DEB="$DL/xfce4-terminal_0.8.9.1-1_arm64.deb"
EXPECT_SHA=e80ac769878fa1c49838a7f69b328d6886ca244ab64a5f9b8dbe0718d4261062
EXPECT_BYTES=371884
mkdir -p "$DL" "$OUT" "$ROOT/evidence"
test -f "$UP_DEB"
test "$(stat -c%s "$UP_DEB")" = "$EXPECT_BYTES"
echo "$EXPECT_SHA  $UP_DEB" | sha256sum -c -
test -x "$UNPACK/usr/bin/xfce4-terminal"
test -x "$UNPACK/usr/bin/xfce4-terminal.wrapper"
test -f "$UNPACK/usr/share/applications/xfce4-terminal.desktop"
test -f "$UNPACK/usr/share/applications/xfce4-terminal-settings.desktop"
test -f "$UNPACK/usr/share/xfce4/terminal/terminal-preferences.ui"
test -d "$UNPACK/usr/share/xfce4/terminal/colorschemes"
test -f "$UNPACK/usr/share/locale/zh_CN/LC_MESSAGES/xfce4-terminal.mo"
test "$(find "$UNPACK" -name '*.mo' | wc -l)" = 57
test ! -d "$UNPACK/usr/share/help"
# compiled prefix bound to /usr — process substitution, no SIGPIPE
grep -qx '/usr/share/locale' < <(strings -n 8 "$UNPACK/usr/bin/xfce4-terminal")
grep -qx '/usr/share/applications/xfce4-terminal.desktop' < <(strings -n 8 "$UNPACK/usr/bin/xfce4-terminal")
grep -q 'xfce4/terminal/terminal-preferences.ui' < <(strings -n 8 "$UNPACK/usr/bin/xfce4-terminal")
# wrapper is perl, not ELF
test "$(head -c 4 "$UNPACK/usr/bin/xfce4-terminal.wrapper")" != $'\x7fELF'
grep -q "exec('xfce4-terminal'" "$UNPACK/usr/bin/xfce4-terminal.wrapper"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/man/man1" \
  "$STAGE/pkg/usr/share/xfce4/terminal" \
  "$STAGE/pkg/usr/share/gnome-control-center/default-apps" \
  "$STAGE/pkg/usr/share/locale" \
  "$STAGE/pkg/opt/xfce4-terminal"

cp -al "$UNPACK/usr/bin/xfce4-terminal" "$STAGE/pkg/usr/bin/xfce4-terminal"
chmod 0755 "$STAGE/pkg/usr/bin/xfce4-terminal"

# official wrapper stays at /usr/bin; rewrite bare exec to absolute path
cp -a --remove-destination "$UNPACK/usr/bin/xfce4-terminal.wrapper" \
  "$STAGE/pkg/usr/bin/xfce4-terminal.wrapper"
python3 - << PY
from pathlib import Path
p = Path("$STAGE/pkg/usr/bin/xfce4-terminal.wrapper")
text = p.read_text(encoding="utf-8")
old = "exec('xfce4-terminal',@args);"
new = "exec('/usr/bin/xfce4-terminal',@args);"
if old not in text:
    raise SystemExit("WRAPPER_EXEC_MISSING")
text = text.replace(old, new, 1)
if "exec('xfce4-terminal'" in text:
    raise SystemExit("WRAPPER_LEFTOVER_RELATIVE_EXEC")
if "exec('/usr/bin/xfce4-terminal',@args);" not in text:
    raise SystemExit("WRAPPER_ABS_EXEC_MISSING")
p.write_text(text, encoding="utf-8")
print("wrapper_rewritten", p)
PY
chmod 0755 "$STAGE/pkg/usr/bin/xfce4-terminal.wrapper"

REPORT="$ROOT/probe/kemi-xfce4-terminal.json"
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
python3 "$PROBE_PY" --elf "${ELFS[0]}" --target-arch arm64 --max-glibc 2.31 --report "$REPORT"
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
if Path(f["path"]).name != "xfce4-terminal":
    raise SystemExit("PROBE_MISSING_MAIN")
if f.get("architecture") != "aarch64":
    raise SystemExit("PROBE_ARCH")
if f.get("requiredGlibc") != "2.17":
    raise SystemExit("PROBE_GLIBC")
if f.get("requiredGlibcxx") is not None:
    raise SystemExit("PROBE_GLIBCXX")
needed = set(f.get("neededLibraries") or [])
for lib in ("libvte-2.91.so.0", "libxfce4ui-2.so.0", "libgtk-3.so.0",
            "libgdk-3.so.0", "libxfce4util.so.7", "libxfconf-0.so.3",
            "libutempter.so.0", "libX11.so.6", "libc.so.6"):
    if lib not in needed:
        raise SystemExit(f"PROBE_MISSING_{lib}")
print("PROBE_PASS requiredGlibc=2.17 noGLIBCXX arch=aarch64 n_elf=1")
PY

cp -a "$UNPACK/usr/share/xfce4/terminal/." "$STAGE/pkg/usr/share/xfce4/terminal/"
test -f "$STAGE/pkg/usr/share/xfce4/terminal/terminal-preferences.ui"
test -f "$STAGE/pkg/usr/share/xfce4/terminal/colorschemes/solarized-dark.theme"
# official locales (57 .mo including zh_CN) — keep official tree
cp -a "$UNPACK/usr/share/locale/." "$STAGE/pkg/usr/share/locale/"
test "$(find "$STAGE/pkg" -name '*.mo' | wc -l)" = 57
test -f "$STAGE/pkg/usr/share/locale/zh_CN/LC_MESSAGES/xfce4-terminal.mo"
cp -a --remove-destination \
  "$UNPACK/usr/share/gnome-control-center/default-apps/xfce4-terminal-default-apps.xml" \
  "$STAGE/pkg/usr/share/gnome-control-center/default-apps/xfce4-terminal-default-apps.xml"
cp -a --remove-destination "$UNPACK/usr/share/man/man1/xfce4-terminal.1.gz" \
  "$STAGE/pkg/usr/share/man/man1/xfce4-terminal.1.gz"

if [[ -f "$UNPACK/usr/share/doc/xfce4-terminal/copyright" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfce4-terminal/copyright" \
    "$STAGE/pkg/usr/share/doc/$PKG/copyright.upstream"
fi
if [[ -f "$UNPACK/usr/share/doc/xfce4-terminal/changelog.Debian.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfce4-terminal/changelog.Debian.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
fi
if [[ -f "$UNPACK/usr/share/doc/xfce4-terminal/NEWS.gz" ]]; then
  cp --remove-destination -L "$UNPACK/usr/share/doc/xfce4-terminal/NEWS.gz" \
    "$STAGE/pkg/usr/share/doc/$PKG/NEWS.upstream.gz"
fi
test -f "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"
test ! -L "$STAGE/pkg/usr/share/doc/$PKG/changelog.upstream.gz"

python3 - << PY
from pathlib import Path
import re

def rewrite(src, dst, expect_exec_plain=True, expect_pref=False):
    text = src.read_text(encoding="utf-8")
    text2 = re.sub(r"^Exec=xfce4-terminal(\s.*)?$", r"Exec=/usr/bin/xfce4-terminal\1", text, flags=re.M)
    text2 = re.sub(r"^TryExec=xfce4-terminal$", "TryExec=/usr/bin/xfce4-terminal", text2, flags=re.M)
    if not re.search(r"^TryExec=", text2, flags=re.M):
        text2 = re.sub(r"^(Exec=/usr/bin/xfce4-terminal(?:\s.*)?)$",
                       r"\1\nTryExec=/usr/bin/xfce4-terminal", text2, count=1, flags=re.M)
    if re.search(r"^Exec=xfce4-terminal(\s|$)", text2, flags=re.M):
        raise SystemExit(f"LEFTOVER_RELATIVE_EXEC:{src.name}")
    if expect_exec_plain and not re.search(r"^Exec=/usr/bin/xfce4-terminal$", text2, flags=re.M):
        raise SystemExit(f"MISSING_EXEC:{src.name}")
    if expect_pref and not re.search(r"^Exec=/usr/bin/xfce4-terminal --preferences$", text2, flags=re.M):
        raise SystemExit(f"MISSING_PREF_EXEC:{src.name}")
    if "TryExec=/usr/bin/xfce4-terminal" not in text2:
        raise SystemExit(f"MISSING_TRYEXEC:{src.name}")
    if not re.search(r"^Icon=utilities-terminal$", text2, flags=re.M):
        raise SystemExit(f"MISSING_ICON:{src.name}")
    if "Name=Xfce Terminal" not in text2:
        raise SystemExit(f"MISSING_NAME:{src.name}")
    dst.write_text(text2, encoding="utf-8")
    print("desktop_rewritten", dst)

base = Path("$UNPACK/usr/share/applications")
out = Path("$STAGE/pkg/usr/share/applications")
rewrite(base / "xfce4-terminal.desktop", out / "xfce4-terminal.desktop",
        expect_exec_plain=True, expect_pref=True)
rewrite(base / "xfce4-terminal-settings.desktop", out / "xfce4-terminal-settings.desktop",
        expect_exec_plain=False, expect_pref=True)
PY

ln -sf /usr/bin/xfce4-terminal "$STAGE/pkg/opt/xfce4-terminal/xfce4-terminal"
ln -sf /usr/bin/xfce4-terminal.wrapper "$STAGE/pkg/opt/xfce4-terminal/xfce4-terminal.wrapper"
ln -sf xfce4-terminal "$STAGE/pkg/usr/bin/kemi-xfce4-terminal"

cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: http://goodies.xfce.org/projects/applications/terminal
Source: https://launchpad.net/ubuntu/+source/xfce4-terminal
Homepage: http://goodies.xfce.org/projects/applications/terminal
License: see copyright.upstream
Official Ubuntu 20.04 (focal) arm64 deb v${VER_UP}
(xfce4-terminal_0.8.9.1-1_arm64.deb) repackaged for KEMI
as ${PKG}.
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
${PKG} (${VER_DEB}) kemi; urgency=medium

  * Official Ubuntu 20.04 xfce4-terminal_0.8.9.1-1_arm64.deb
    (focal universe; no newer package in focal-updates) repackaged
    for KEMI as ${PKG}. No same-source common/data/typelib package.
  * Official ELF stays at /usr/bin/xfce4-terminal (compiled
    /usr/share/locale and /usr/share/xfce4/terminal data).
    /opt/xfce4-terminal/* are symlinks.
  * Official Debian wrapper stays at
    /usr/bin/xfce4-terminal.wrapper; bare exec is rewritten to
    /usr/bin/xfce4-terminal. Official x-terminal-emulator
    alternatives (postinst/prerm) are kept.
  * Desktop, man, official 57 .mo (including zh_CN),
    terminal-preferences.ui, colorschemes and gnome-control-center
    default-apps stay on standard paths. Official desktop
    Exec=xfce4-terminal rewritten to /usr/bin/xfce4-terminal;
    Icon=utilities-terminal (theme icon; this deb ships no icons).
  * Conflicts/Replaces xfce4-terminal. Official Depends kept for
    Ubuntu 20.04 (GTK3, VTE, libxfce4ui, exo-utils, libc6 >= 2.17).
    Official Recommends dbus-session-bus kept as Recommends.

 -- KEMI / gork.bot <noreply@kemi.local>  Wed, 11 Nov 2026 21:10:00 +0800
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Xfce Terminal ${VER_UP}-1 — official Ubuntu 20.04 (focal)
universe arm64, KEMI repack.

Official ELF stays at /usr/bin/xfce4-terminal (compiled
/usr/share/locale and /usr/share/xfce4/terminal).
/opt/xfce4-terminal/* are symlinks.
Desktop, man, official locales, UI and colorschemes remain
on standard paths.
Official desktop Icon=utilities-terminal (theme icon; no
icons shipped in this deb — do not invent any).
Official language-pack split does not apply: this deb ships
57 .mo including zh_CN.
Probe: aarch64 · 1 ELF · requiredGlibc 2.17 · no GLIBCXX;
Ubuntu 20.04 / glibc 2.31 OK.
Runtime: official Depends (GTK3, VTE, libxfce4ui, exo-utils,
libc6 >= 2.17). Official Recommends dbus-session-bus kept
as Recommends.
Official publication: Ubuntu 20.04 focal universe arm64
xfce4-terminal 0.8.9.1-1. Official SHA256 + size matched
ports.ubuntu.com pool files and focal universe arm64
Packages stanzas. No librarian URL this run.
合主线：gork.bot协助开发
EOT

INSTALLED_SIZE=$(du -sk --apparent-size "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: xfce
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: exo-utils, libc6 (>= 2.17), libcairo2 (>= 1.2.4), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.21.5), libpango-1.0-0 (>= 1.14.0), libutempter0 (>= 1.1.5), libvte-2.91-0 (>= 0.51.90), libx11-6, libxfce4ui-2-0 (>= 4.11.0), libxfce4util7 (>= 4.9.0), libxfconf-0-3 (>= 4.6.0)
Recommends: default-dbus-session-bus | dbus-session-bus
Provides: x-terminal-emulator
Conflicts: xfce4-terminal
Replaces: xfce4-terminal
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: http://goodies.xfce.org/projects/applications/terminal
Description: Xfce terminal emulator (arm64)
 Xfce Terminal ${VER_UP} — official Ubuntu 20.04 arm64,
 KEMI repack.
 Lightweight terminal emulator for X11, designed for Xfce.
 glibc≤2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOT

cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
  if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --install /usr/bin/x-terminal-emulator \
      x-terminal-emulator /usr/bin/xfce4-terminal.wrapper 40 \
      --slave /usr/share/man/man1/x-terminal-emulator.1.gz \
      x-terminal-emulator.1.gz /usr/share/man/man1/xfce4-terminal.1.gz
  fi
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
if [ "$1" = "remove" ]; then
  if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --remove x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
  fi
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/prerm"

cat > "$STAGE/pkg/DEBIAN/postrm" << 'EOT'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postrm"

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
( cd "$OUT" && sha256sum "${PKG}_${VER_DEB}_${ARCH}.deb" | tee "${PKG}_${VER_DEB}_${ARCH}.deb.sha256" )
ls -la "$DEB"
stat -c%s "$DEB"
dpkg-deb -I "$DEB" | tee "$ROOT/evidence/kemi-xfce4-terminal-control.txt"
