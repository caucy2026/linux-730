#!/usr/bin/env bash
# Repack official Ubuntu 20.04 gnome-system-tools 3.0.0-9ubuntu1 arm64
# as kemi-gnome-system-tools. No exact-version same-source hard Depends
# to bundle. Official Source field is absent and is not defaulted.
# Official Homepage is copied exactly. Official ELFs stay at official
# /usr paths. /opt/gnome-system-tools/* are only symlinks to official
# binaries. There is no official gnome-system-tools command, so no
# invented /usr/bin/kemi-gnome-system-tools launcher. Official desktop
# Names kept; relative Exec rewritten absolute; TryExec added; official
# NoDisplay kept. Official .mo, schemas, hicolor icons, changelog,
# copyright, conffiles, help, and man are packed as official. Evidence
# 128 PNG is CREATE-only and is not packed.
set -euo pipefail

ROOT=/workspace/t143-20261112-gnome-system-tools
UNPACK="$ROOT/unpack/official/data"
DEBDIR="$ROOT/debs"
STAGE="$ROOT/stage"
PKG=kemi-gnome-system-tools
VER_UP=3.0.0-9ubuntu1
VER_NAME=3.0.0-9ubuntu1kemi1
VER_DEB=${VER_NAME}
ARCH=arm64
OFFICIAL_DEB="$DEBDIR/gnome-system-tools_${VER_UP}_${ARCH}.deb"

python3 - << 'PYLEN'
s = "3.0.0-9ubuntu1kemi1"
assert len(s) == 19, len(s)
assert 12 <= len(s) <= 32
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE/pkg"
mkdir -p "$STAGE/pkg"
# official tree (data) copied as-is
cp -a "$UNPACK/." "$STAGE/pkg/"
mkdir -p "$STAGE/pkg/DEBIAN"
# official conffiles kept
cp -a "$ROOT/unpack/official/DEBIAN/conffiles" "$STAGE/pkg/DEBIAN/conffiles"

# /opt symlinks only, to official binaries
mkdir -p "$STAGE/pkg/opt/gnome-system-tools"
for b in users-admin time-admin shares-admin; do
  test -f "$STAGE/pkg/usr/bin/$b"
  test ! -L "$STAGE/pkg/usr/bin/$b"
  ln -s "/usr/bin/$b" "$STAGE/pkg/opt/gnome-system-tools/$b"
  test -L "$STAGE/pkg/opt/gnome-system-tools/$b"
done
# do not invent /usr/bin/kemi-gnome-system-tools
if [ -e "$STAGE/pkg/usr/bin/kemi-gnome-system-tools" ]; then
  echo "INVENTED_KEMI_LAUNCHER" >&2
  exit 1
fi

python3 - << 'PYDESK'
from pathlib import Path

root = Path("/workspace/t143-20261112-gnome-system-tools/stage/pkg")
desktops = sorted((root / "usr/share/applications").glob("*.desktop"))
assert [p.name for p in desktops] == ["shares.desktop", "time.desktop", "users.desktop"], desktops

expect = {
    "shares.desktop": {
        "Name": "Shared Folders",
        "Icon": "folder-remote",
        "Exec": "/usr/bin/shares-admin",
        "NoDisplay": "true",
    },
    "time.desktop": {
        "Name": "Time and Date",
        "Icon": "time-admin",
        "Exec": "/usr/bin/time-admin",
        "NoDisplay": None,
    },
    "users.desktop": {
        "Name": "Users and Groups",
        "Icon": "config-users",
        "Exec": "/usr/bin/users-admin",
        "NoDisplay": None,
    },
}


def rewrite_first_token(line: str, key: str) -> str:
    prefix = key + "="
    rest = line[len(prefix):]
    ending = ""
    if rest.endswith("\n"):
        ending = "\n"
        rest = rest[:-1]
    parts = rest.split(" ", 1)
    cmd = parts[0]
    args = (" " + parts[1]) if len(parts) == 2 else ""
    if cmd and not cmd.startswith("/"):
        cmd = "/usr/bin/" + cmd
    return prefix + cmd + args + ending


for p in desktops:
    exp = expect[p.name]
    text = p.read_text()
    exec_abs = exp["Exec"]
    new_lines = []
    seen_try = False
    seen_exec = False
    for raw in text.splitlines(keepends=True):
        line = raw
        if raw.startswith("Exec="):
            line = rewrite_first_token(raw, "Exec")
            seen_exec = True
        elif raw.startswith("TryExec="):
            line = rewrite_first_token(raw, "TryExec")
            seen_try = True
        new_lines.append(line)
        if raw.startswith("Exec=") and not seen_try:
            # add TryExec immediately after the first Exec if missing
            pass
    if not seen_try:
        out = []
        added = False
        for line in new_lines:
            out.append(line)
            if (not added) and line.startswith("Exec="):
                ending = "\n" if line.endswith("\n") else ""
                out.append("TryExec=" + exec_abs + ending)
                added = True
        new_lines = out
    new = "".join(new_lines)
    assert sum(1 for ln in new.splitlines() if ln.startswith("Exec=")) == 1, p
    assert sum(1 for ln in new.splitlines() if ln.startswith("TryExec=")) == 1, p
    assert f"Exec={exec_abs}" in new, (p, new)
    assert f"TryExec={exec_abs}" in new, p
    assert f"Name={exp['Name']}" in new, p
    assert f"Icon={exp['Icon']}" in new, p
    if exp["NoDisplay"] is None:
        assert "NoDisplay=" not in new, p
    else:
        assert f"NoDisplay={exp['NoDisplay']}" in new, p
    # official relative Exec gone
    assert "Exec=shares-admin\n" not in new
    assert "Exec=time-admin\n" not in new
    assert "Exec=users-admin\n" not in new
    p.write_text(new)
    print("desktop_ok", p.name)
print("desktop_rewrite_ok")
PYDESK

mkdir -p "$STAGE/pkg/usr/share/doc/$PKG"
cp -a "$STAGE/pkg/usr/share/doc/gnome-system-tools/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/$PKG/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/gnome-system-tools/copyright" \
      "$STAGE/pkg/usr/share/doc/$PKG/copyright"

KEMI_DATE=$(TZ=Asia/Shanghai date "+%a, %d %b %Y %H:%M:%S %z")
cat > "$STAGE/pkg/usr/share/doc/$PKG/changelog.kemi" << EOT
kemi-gnome-system-tools (${VER_DEB}) focal; urgency=medium

  * Official Ubuntu 20.04 (focal universe)
    gnome-system-tools 3.0.0-9ubuntu1 arm64,
    KEMI mall linuxpkg repack. No same-source
    exact-version hard Depends to bundle.
    Official ELFs stay under /usr.
    Official desktop Names kept; mall
    app_name=GNOME System Tools.
    合主线：gork.bot协助开发.

 -- KEMI / gork.bot <noreply@kemi.local>  ${KEMI_DATE}
EOT

# no official maintainer scripts; write hooks (quoted so $1 is not expanded)
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK

cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
# Automatically added by kemi packaging
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK
chmod 0755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

# leftover-x86: text files only; skip comments and official
# copyright / DEBIAN/control Description / official lintian /
# official ELF / official hardware-ID strings
python3 - << 'PYX86'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-gnome-system-tools/stage/pkg")
pat = re.compile(r"x86_64-linux-gnu|x86_64|amd64|i386|x86-64", re.I)
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    # skip official ELF / binary-ish
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw[:4] == b"\x7fELF":
        continue
    # skip compressed / images / mo / typical binaries
    if p.suffix.lower() in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".ico"}:
        continue
    # skip official copyright
    if p.name == "copyright":
        continue
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        continue
    rel = str(p.relative_to(root))
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        # official lintian overrides
        if "lintian" in rel or p.name == "overrides":
            continue
        # official Description in control will be written later; skip if already
        if p.name == "control" and ("Description:" in text or line.startswith(" ")):
            # still check non-Description fields later after control write
            continue
        if pat.search(line):
            bad.append((rel, i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86_pre_control")
PYX86

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.29), libcairo2 (>= 1.2.4), libdbus-1-3 (>= 1.9.14), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3), libgtk-3-0 (>= 3.0.0), liboobs-1-5 (>= 3.0.0), libpango-1.0-0 (>= 1.14.0), libpolkit-gobject-1-0 (>= 0.99), policykit-1-gnome | mate-polkit
Recommends: packagekit, xdg-utils
Suggests: ntp
Provides: gnome-system-tools (= ${VER_UP}), gnome-network-admin
Conflicts: gnome-system-tools, gnome-network-admin
Replaces: gnome-system-tools, gnome-network-admin, ximian-setup-tools
Homepage: https://github.com/LStranger/gnome-system-tools
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Cross-platform configuration utilities
 GNOME System Tools ${VER_UP} — official Ubuntu
 20.04 arm64, KEMI repack of gnome-system-tools.
 Official liboobs-1-5 and system-tools-backends
 stay Depends (different-source / range, not bundled).
 glibc<=2.31 (Ubuntu 20.04).
 gork.bot协助开发.
EOF

# leftover-x86 after control (skip official Description / copyright)
python3 - << 'PYX86B'
import re
from pathlib import Path
root = Path("/workspace/t143-20261112-gnome-system-tools/stage/pkg")
pat = re.compile(r"x86_64-linux-gnu", re.I)
bad = []
in_desc = False
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if raw[:4] == b"\x7fELF":
        continue
    if p.suffix.lower() in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".ico"}:
        continue
    if p.name == "copyright":
        continue
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        continue
    rel = str(p.relative_to(root))
    in_desc = False
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if p.name == "control":
            if line.startswith("Description:"):
                in_desc = True
                continue
            if in_desc and (line.startswith(" ") or line.startswith("\t")):
                continue
            if in_desc and line and not line.startswith(" "):
                in_desc = False
        if "lintian" in rel or p.name == "overrides":
            continue
        if pat.search(line):
            bad.append((rel, i, line))
if bad:
    raise SystemExit("LEFTOVER_X86:" + repr(bad))
print("no_leftover_x86")
PYX86B

( cd "$STAGE/pkg" && find . -type f ! -path './DEBIAN/*' -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums )

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << PYHASH
import hashlib
from pathlib import Path
p = Path("$OUT")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")
off = Path("$OFFICIAL_DEB")
oh = hashlib.sha256(off.read_bytes()).hexdigest()
assert h != oh
assert p.stat().st_size != off.stat().st_size
print("differs_from_official", off.stat().st_size, oh)
PYHASH

dpkg-deb -I "$OUT" > "$ROOT/evidence/kemi-gnome-system-tools-control.txt"

python3 - << 'PYASSERT'
import subprocess
from pathlib import Path
deb = Path("/workspace/t143-20261112-gnome-system-tools/debs/kemi-gnome-system-tools_3.0.0-9ubuntu1kemi1_arm64.deb")
out = subprocess.check_output(["dpkg-deb", "-c", str(deb)], text=True)
lines = out.splitlines()
need = [
    "./usr/bin/users-admin",
    "./usr/bin/time-admin",
    "./usr/bin/shares-admin",
    "./opt/gnome-system-tools/users-admin",
    "./opt/gnome-system-tools/time-admin",
    "./opt/gnome-system-tools/shares-admin",
    "./usr/share/applications/users.desktop",
    "./usr/share/applications/time.desktop",
    "./usr/share/applications/shares.desktop",
    "./usr/share/icons/hicolor/scalable/apps/time-admin.svg",
    "./usr/share/glib-2.0/schemas/org.gnome.system-tools.gschema.xml",
    "./usr/share/doc/gnome-system-tools/changelog.Debian.gz",
    "./usr/share/doc/gnome-system-tools/copyright",
    "./etc/gnome-system-tools/user-profiles.conf",
]
for n in need:
    assert any(n in ln for ln in lines), n
# official bins are real files, opt are symlinks, no invented kemi launcher
assert any(ln.startswith("-rw") and "./usr/bin/users-admin" in ln for ln in lines)
assert any(ln.startswith("lrwxrwxrwx") and "./opt/gnome-system-tools/users-admin" in ln for ln in lines)
assert not any("kemi-gnome-system-tools" in ln and "/usr/bin/" in ln for ln in lines)
# evidence PNG / theme not packed
assert not any("time-admin-128" in ln or "humanity-icon-theme" in ln or "evidence" in ln for ln in lines)
# official mo packed
assert any("./usr/share/locale/" in ln and ln.endswith("gnome-system-tools.mo") for ln in lines)
print("content_asserts_ok", "entries", len(lines))
PYASSERT

echo BUILD_OK
