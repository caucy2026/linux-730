#!/usr/bin/env bash
# Build kemi-mate-applet-brisk-menu from official Ubuntu 20.04
# mate-applet-brisk-menu (source brisk-menu).
# 验证≠编译: do not compile; official U20 files only.
# Official Source: brisk-menu is copied exactly.
# Official Homepage http://www.mate-desktop.org/ is copied exactly
# (http; the scheme is not upgraded).
# No exact-version same-source hard Depends; nothing is bundled.
# Official package has no /usr/bin command: do not invent
# /usr/bin/kemi-mate-applet-brisk-menu or /opt/brisk-menu.
# Official package has no applications desktop: do not invent one.
# Official Location and D-Bus Exec already absolute (including the
# official double slash) are kept.
# Official changelog and copyright are real files and are kept.
# 合主线：gork.bot协助开发
set -euo pipefail

ROOT=/workspace/t142-20261112-brisk-menu
UNPACK="$ROOT/unpack/gui"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-mate-applet-brisk-menu
VER_UP=0.6.0-1ubuntu1
VER_NAME=0.6.0-1ubuntu1kemi1
VER_DEB=0.6.0-1ubuntu1kemi1
ARCH=arm64

python3 - << 'PYLEN'
s = "0.6.0-1ubuntu1kemi1"
assert len(s) == 19, len(s)
# official 0.6.0-1ubuntu1 (14) + kemi1 (5) = 19; no padding needed
# no Debian epoch
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg"

python3 - << 'PYCOPY'
import shutil
from pathlib import Path
src = Path("/workspace/t142-20261112-brisk-menu/unpack/gui")
dst = Path("/workspace/t142-20261112-brisk-menu/stage/pkg")
for p in sorted(src.rglob("*")):
    rel = p.relative_to(src)
    if rel.parts and rel.parts[0] == "DEBIAN":
        continue
    dest = dst / rel
    if p.is_dir() and not p.is_symlink():
        dest.mkdir(parents=True, exist_ok=True)
    elif p.is_symlink():
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.symlink_to(p.readlink())
    else:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest, follow_symlinks=False)
print("copied_official_tree")
PYCOPY

# official changelog/copyright also copied into the kemi doc dir
mkdir -p "$STAGE/pkg/usr/share/doc/kemi-mate-applet-brisk-menu"
cp -a "$STAGE/pkg/usr/share/doc/mate-applet-brisk-menu/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/kemi-mate-applet-brisk-menu/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/mate-applet-brisk-menu/copyright" \
      "$STAGE/pkg/usr/share/doc/kemi-mate-applet-brisk-menu/copyright"

# Official has no maintainer scripts. Append schema and hicolor
# icon-cache hooks because official schemas and a hicolor icon are packed.
mkdir -p "$STAGE/pkg/DEBIAN"
cat > "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
fi
exit 0
HOOK
cat > "$STAGE/pkg/DEBIAN/postrm" << 'HOOK'
#!/bin/sh
set -e
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  if command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas /usr/share/glib-2.0/schemas >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
fi
exit 0
HOOK
chmod 755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/postrm"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Source: brisk-menu
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: mate-panel (>= 1.22.0), libc6 (>= 2.17), libglib2.0-0 (>= 2.39.4), libgtk-3-0 (>= 3.19.12), libmate-menu2 (>= 1.22.0), libmate-panel-applet-4-1 (>= 1.22.0), libnotify4 (>= 0.7.0), libx11-6, dconf-gsettings-backend | gsettings-backend
Provides: mate-applet-brisk-menu (= ${VER_UP})
Conflicts: mate-applet-brisk-menu
Replaces: mate-applet-brisk-menu
Homepage: http://www.mate-desktop.org/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Solus Project's Brisk Menu MATE Panel Applet
 Brisk Menu 0.6.0-1ubuntu1 — official
 Ubuntu 20.04 Architecture: arm64, KEMI
 repack of mate-applet-brisk-menu. No
 exact-version same-source hard Depends
 were bundled. Official files stay under
 /usr.
 gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-brisk-menu/stage/pkg/DEBIAN/control").read_text()
assert "Source: brisk-menu\n" in c
assert "Homepage: http://www.mate-desktop.org/\n" in c
assert "https://www.mate-desktop.org/" not in c
assert "Version: 0.6.0-1ubuntu1kemi1\n" in c
assert "Architecture: arm64\n" in c
assert "Package: kemi-mate-applet-brisk-menu\n" in c
assert "Depends: mate-panel (>= 1.22.0), libc6 (>= 2.17), libglib2.0-0 (>= 2.39.4), libgtk-3-0 (>= 3.19.12), libmate-menu2 (>= 1.22.0), libmate-panel-applet-4-1 (>= 1.22.0), libnotify4 (>= 0.7.0), libx11-6, dconf-gsettings-backend | gsettings-backend\n" in c
assert "Provides: mate-applet-brisk-menu (= 0.6.0-1ubuntu1)\n" in c
assert "Conflicts: mate-applet-brisk-menu\n" in c
assert "Replaces: mate-applet-brisk-menu\n" in c
assert "Recommends:" not in c
assert "Suggests:" not in c
print("control_text_ok")
PYCTL

python3 - << 'PYMD5'
import hashlib
from pathlib import Path
root = Path("/workspace/t142-20261112-brisk-menu/stage/pkg")
lines = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    rel = p.relative_to(root)
    if rel.parts[0] == "DEBIAN":
        continue
    h = hashlib.md5(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {rel.as_posix()}\n")
Path("/workspace/t142-20261112-brisk-menu/stage/pkg/DEBIAN/md5sums").write_text("".join(lines))
print("md5sums", len(lines))
PYMD5

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-brisk-menu/stage/pkg")
bad = []
for p in root.rglob("*"):
    if not p.is_file() or p.is_symlink():
        continue
    if p.suffix in {".png", ".gz", ".mo", ".so", ".svg", ".xml", ".xpm", ".ui", ".jpg", ".jpeg", ".gif", ".glade", ".policy"}:
        continue
    if "lintian/overrides" in str(p.as_posix()):
        continue
    if p.name in {"control", "copyright"}:
        continue
    try:
        raw = p.read_bytes()
    except Exception:
        continue
    if b"x86_64-linux-gnu" not in raw:
        continue
    if raw[:4] == bytes([0x7F]) + b"ELF":
        continue
    text = raw.decode("utf-8", "replace")
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

python3 - << 'PYPRE'
from pathlib import Path
root = Path("/workspace/t142-20261112-brisk-menu/stage/pkg")
assert not list(root.glob("usr/share/applications/*.desktop"))
assert not (root / "usr/bin/kemi-mate-applet-brisk-menu").exists()
assert not (root / "usr/bin/kemi-brisk-menu").exists()
assert not (root / "opt").exists()
assert not list(root.rglob("brisk-menu-128.png"))
assert not list(root.rglob("humanity-start-here-64.svg"))
elf = root / "usr/lib/aarch64-linux-gnu/brisk-menu/brisk-menu"
assert elf.is_file() and not elf.is_symlink()
assert elf.read_bytes()[:4] == b"\x7fELF"
applet = (root / "usr/share/mate-panel/applets/com.solus_project.brisk.BriskMenu.mate-panel-applet").read_text()
assert "Name=Brisk Menu\n" in applet
assert "Icon=start-here\n" in applet
assert "Location=/usr/lib/aarch64-linux-gnu/brisk-menu//brisk-menu\n" in applet
dbus = (root / "usr/share/dbus-1/services/org.mate.panel.applet.BriskMenuFactory.service").read_text()
assert "Exec=/usr/lib/aarch64-linux-gnu/brisk-menu//brisk-menu\n" in dbus
mos = list((root / "usr/share/locale").rglob("brisk-menu.mo"))
assert len(mos) == 43, len(mos)
post = (root / "DEBIAN/postinst").read_text()
assert "glib-compile-schemas /usr/share/glib-2.0/schemas" in post
assert "gtk-update-icon-cache" in post
assert "ldconfig" not in post
assert "update-desktop-database" not in post
print("layout_pre_ok mo_count", len(mos))
PYPRE

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, json, subprocess
from pathlib import Path

p = Path("/workspace/t142-20261112-brisk-menu/debs/kemi-mate-applet-brisk-menu_0.6.0-1ubuntu1kemi1_arm64.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")

out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/lib/aarch64-linux-gnu/brisk-menu/brisk-menu" in ln and ln.startswith("-rw") for ln in out.splitlines())
assert any("./usr/share/mate-panel/applets/com.solus_project.brisk.BriskMenu.mate-panel-applet" in ln for ln in out.splitlines())
assert any("./usr/share/dbus-1/services/org.mate.panel.applet.BriskMenuFactory.service" in ln for ln in out.splitlines())
assert any("./usr/share/glib-2.0/schemas/com.solus-project.brisk-menu.gschema.xml" in ln for ln in out.splitlines())
assert any("./usr/share/icons/hicolor/scalable/actions/brisk_system-log-out-symbolic.svg" in ln for ln in out.splitlines())
assert any("./usr/share/doc/mate-applet-brisk-menu/changelog.Debian.gz" in ln for ln in out.splitlines())
assert any("./usr/share/doc/mate-applet-brisk-menu/copyright" in ln for ln in out.splitlines())
assert any("./usr/share/locale/zh_CN/LC_MESSAGES/brisk-menu.mo" in ln for ln in out.splitlines())
assert not any("/usr/bin/" in ln and "kemi-" in ln for ln in out.splitlines())
assert not any("./opt/" in ln or "/opt/brisk-menu" in ln for ln in out.splitlines())
assert not any("usr/share/applications/" in ln and ln.endswith(".desktop") for ln in out.splitlines())
assert not any("brisk-menu-128.png" in ln for ln in out.splitlines())
assert not any("Humanity/" in ln or "humanity-icon-theme" in ln or "humanity-start-here" in ln for ln in out.splitlines())
print("deb_contents_ok")

ctl = subprocess.check_output(["dpkg-deb", "-I", str(p)], text=True)
Path("/workspace/t142-20261112-brisk-menu/evidence/kemi-mate-applet-brisk-menu-control.txt").write_text(ctl)
assert "Architecture: arm64" in ctl
assert "Source: brisk-menu" in ctl
assert "Homepage: http://www.mate-desktop.org/" in ctl
assert "Version: 0.6.0-1ubuntu1kemi1" in ctl
print("control_ok")

# re-probe the unique packaged ELF (same official bytes) and write n_elf fields
import shutil
report = Path("/workspace/t142-20261112-brisk-menu/probe/kemi-mate-applet-brisk-menu.json")
report.unlink(missing_ok=True)
elf = Path("/workspace/t142-20261112-brisk-menu/stage/pkg/usr/lib/aarch64-linux-gnu/brisk-menu/brisk-menu")
assert hashlib.sha256(elf.read_bytes()).hexdigest() == "2d926008fa16a21fb94744992d00dccb7d357658f4f33ab9d3cc5d6085fd824a"
subprocess.check_call([
    "python3", "/workspace/t142-20261112-brisk-menu/scripts/probe_elf.py",
    "--target-arch", "arm64",
    "--max-glibc", "2.31",
    "--elf", str(elf),
    "--report", str(report),
])
d = json.loads(report.read_text())
files = d.get("files") or []
assert len(files) == 1
glibcs = [f.get("requiredGlibc") for f in files]
glibcxxs = [f.get("requiredGlibcxx") for f in files]
def nmax(vals):
    versioned = [v for v in vals if v]
    return (max(versioned, key=lambda s: tuple(int(x) for x in s.split("."))) if versioned else None), len(versioned), len(vals) - len(versioned)
rg, rg_v, rg_n = nmax(glibcs)
rx, rx_v, rx_n = nmax(glibcxxs)
d["n_elf"] = 1
d["requiredGlibc"] = rg
d["requiredGlibc_versioned"] = rg_v
d["requiredGlibc_null"] = rg_n
d["requiredGlibcxx"] = rx
d["requiredGlibcxx_versioned"] = rx_v
d["requiredGlibcxx_null"] = rx_n
assert d.get("configuredLimitsSatisfied") is True
assert rg == "2.17" and rg_v == 1 and rg_n == 0
assert rx is None and rx_v == 0 and rx_n == 1
report.write_text(json.dumps(d, indent=2) + "\n")
print("ELF_COUNT 1")
print("PROBE_PASS n_elf=1 requiredGlibc=2.17 (1 versioned, 0 null); requiredGlibcxx=None (0 versioned, 1 null, nulls not ranked as a max); configuredLimitsSatisfied=true")
print("BUILD_OK", p)
PYHASH
