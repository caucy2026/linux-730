#!/usr/bin/env bash
# Build kemi-variety from official Ubuntu 20.04 variety.
# 验证≠编译: do not compile; official U20 files only.
# Official Source field is absent and is not defaulted.
# Official Homepage http://peterlevi.com/variety/ is copied
# exactly (http; the scheme is not upgraded).
# No exact-version same-source hard Depends; nothing is bundled.
# Official Recommends and Suggests stay official.
# Official relative Exec rewritten absolute; TryExec added;
# official Name/Icon kept; no NoDisplay invented.
# Official /usr/bin/variety exists: /opt/variety/variety and
# /usr/bin/kemi-variety are symlinks only.
# Official changelog, copyright, and man are real files and are kept.
# 合主线：gork.bot协助开发
set -euo pipefail

ROOT=/workspace/t142-20261112-variety
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-variety
VER_UP=0.8.3-1
VER_NAME=0.8.3-1kemi1
VER_DEB=0.8.3-1kemi1
ARCH=all

python3 - << 'PYLEN'
s = "0.8.3-1kemi1"
assert len(s) == 12, len(s)
# official 0.8.3-1 (7) + kemi1 (5) = 12; no padding needed
# no Debian epoch
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg"

python3 - << 'PYCOPY'
import shutil
from pathlib import Path
src = Path("/workspace/t142-20261112-variety/unpack/gui")
dst = Path("/workspace/t142-20261112-variety/stage/pkg")
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

# rewrite official relative Exec; add TryExec; keep Name/Icon/actions
python3 - << 'PYDESK'
from pathlib import Path
p = Path("/workspace/t142-20261112-variety/stage/pkg/usr/share/applications/variety.desktop")
text = p.read_text()
assert "NoDisplay=" not in text
out = []
inserted_tryexec = False
for line in text.splitlines(True):
    ending = "\n" if line.endswith("\n") else ""
    raw = line[:-1] if ending else line
    if raw.startswith("Exec="):
        val = raw[len("Exec="):]
        parts = val.split(" ", 1)
        cmd = parts[0]
        rest = parts[1] if len(parts) > 1 else ""
        assert cmd == "variety", cmd
        new = "/usr/bin/variety" + ((" " + rest) if rest else "")
        out.append("Exec=" + new + ending)
        if not inserted_tryexec:
            out.append("TryExec=/usr/bin/variety" + ending)
            inserted_tryexec = True
        continue
    out.append(line)
new_text = "".join(out)
assert "Exec=/usr/bin/variety %U\n" in new_text
assert "TryExec=/usr/bin/variety\n" in new_text
assert "Exec=/usr/bin/variety --next\n" in new_text
assert "Exec=/usr/bin/variety --previous\n" in new_text
assert "Exec=/usr/bin/variety --toggle-pause\n" in new_text
assert "Exec=/usr/bin/variety --history\n" in new_text
assert "Exec=/usr/bin/variety --preferences\n" in new_text
assert "Name=Variety\n" in new_text
assert "Icon=variety\n" in new_text
assert "NoDisplay=" not in new_text
assert sum(1 for ln in new_text.splitlines() if ln.startswith("Exec=")) == 6
assert sum(1 for ln in new_text.splitlines() if ln.startswith("TryExec=")) == 1
p.write_text(new_text)
print("desktop_rewritten")
PYDESK

# official command exists: opt + kemi symlinks only
mkdir -p "$STAGE/pkg/opt/variety"
ln -s /usr/bin/variety "$STAGE/pkg/opt/variety/variety"
ln -s /usr/bin/variety "$STAGE/pkg/usr/bin/kemi-variety"

# official changelog/copyright also copied into the kemi doc dir
mkdir -p "$STAGE/pkg/usr/share/doc/kemi-variety"
cp -a "$STAGE/pkg/usr/share/doc/variety/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/kemi-variety/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/variety/copyright" \
      "$STAGE/pkg/usr/share/doc/kemi-variety/copyright"

# official maintainer scripts, retarget python hooks to kemi-variety
mkdir -p "$STAGE/pkg/DEBIAN"
python3 - << 'PYHOOK'
from pathlib import Path
src = Path("/workspace/t142-20261112-variety/unpack/gui/DEBIAN")
dst = Path("/workspace/t142-20261112-variety/stage/pkg/DEBIAN")
for name in ("postinst", "prerm"):
    t = (src / name).read_text()
    t = t.replace("py3compile -p variety", "py3compile -p kemi-variety")
    t = t.replace("pypy3compile -p variety", "pypy3compile -p kemi-variety")
    t = t.replace("py3clean -p variety", "py3clean -p kemi-variety")
    t = t.replace("dpkg -L variety", "dpkg -L kemi-variety")
    assert " -p variety" not in t
    assert "dpkg -L variety" not in t
    (dst / name).write_text(t)
print("scripts_retargeted")
PYHOOK

# append desktop-database + gtk-update-icon-cache (quoted so $1 is not expanded)
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'

# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK

cat >> "$STAGE/pkg/DEBIAN/prerm" << 'HOOK'

# Automatically added by kemi packaging
if [ "$1" = "remove" ] || [ "$1" = "deconfigure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
fi
# End automatically added section
HOOK
chmod 755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: gir1.2-gdkpixbuf-2.0, gir1.2-gexiv2-0.10, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-notify-0.7, gir1.2-pango-1.0, imagemagick, python3-bs4, python3-lxml, python3-cairo, python3-configobj, python3-dbus, python3-gi, python3-gi-cairo, python3-pil, python3-pkg-resources, python3-requests, python3:any
Recommends: gir1.2-ayatanaappindicator3-0.1 | gir1.2-appindicator3-0.1, python3-httplib2, fortune-mod
Suggests: feh | nitrogen, gnome-shell-extension-appindicator
Provides: variety (= ${VER_UP})
Conflicts: variety
Replaces: variety
Homepage: http://peterlevi.com/variety/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Wallpaper changer, downloader and manager
 Variety 0.8.3-1 — official Ubuntu 20.04
 Architecture: all, KEMI repack of
 variety. No exact-version same-source
 hard Depends were bundled. Official
 files stay under /usr.
 gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-variety/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: http://peterlevi.com/variety/\n" in c
assert "https://peterlevi.com/variety/" not in c
assert "Version: 0.8.3-1kemi1\n" in c
assert "Architecture: all\n" in c
assert "Package: kemi-variety\n" in c
assert "Source:" not in c
assert "Depends: gir1.2-gdkpixbuf-2.0, gir1.2-gexiv2-0.10, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-notify-0.7, gir1.2-pango-1.0, imagemagick, python3-bs4, python3-lxml, python3-cairo, python3-configobj, python3-dbus, python3-gi, python3-gi-cairo, python3-pil, python3-pkg-resources, python3-requests, python3:any\n" in c
assert "Recommends: gir1.2-ayatanaappindicator3-0.1 | gir1.2-appindicator3-0.1, python3-httplib2, fortune-mod\n" in c
assert "Suggests: feh | nitrogen, gnome-shell-extension-appindicator\n" in c
assert "Provides: variety (= 0.8.3-1)\n" in c
assert "Conflicts: variety\n" in c
assert "Replaces: variety\n" in c
print("control_text_ok")
PYCTL

python3 - << 'PYMD5'
import hashlib
from pathlib import Path
root = Path("/workspace/t142-20261112-variety/stage/pkg")
lines = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    rel = p.relative_to(root)
    if rel.parts[0] == "DEBIAN":
        continue
    h = hashlib.md5(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {rel.as_posix()}\n")
Path("/workspace/t142-20261112-variety/stage/pkg/DEBIAN/md5sums").write_text("".join(lines))
print("md5sums", len(lines))
PYMD5

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-variety/stage/pkg")
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
root = Path("/workspace/t142-20261112-variety/stage/pkg")
assert (root / "usr/bin/variety").is_file() and not (root / "usr/bin/variety").is_symlink()
assert (root / "usr/bin/kemi-variety").is_symlink()
assert (root / "usr/bin/kemi-variety").readlink().as_posix() == "/usr/bin/variety"
assert (root / "opt/variety/variety").is_symlink()
assert (root / "opt/variety/variety").readlink().as_posix() == "/usr/bin/variety"
assert (root / "usr/share/applications/variety.desktop").is_file()
assert (root / "usr/share/icons/hicolor/scalable/apps/variety.svg").is_file()
assert not list(root.rglob("variety-128.png"))
mos = list((root / "usr/share/locale").rglob("variety.mo"))
assert len(mos) == 13, len(mos)
post = (root / "DEBIAN/postinst").read_text()
prerm = (root / "DEBIAN/prerm").read_text()
assert "py3compile -p kemi-variety" in post
assert "pypy3compile -p kemi-variety" in post
assert "py3compile -p variety" not in post
assert "update-desktop-database" in post
assert "gtk-update-icon-cache" in post
assert "ldconfig" not in post
assert "glib-compile-schemas" not in post
assert "py3clean -p kemi-variety" in prerm
assert "dpkg -L kemi-variety" in prerm
assert "dpkg -L variety" not in prerm
print("layout_pre_ok mo_count", len(mos))
PYPRE

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, json, subprocess
from pathlib import Path

p = Path("/workspace/t142-20261112-variety/debs/kemi-variety_0.8.3-1kemi1_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")

out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/bin/variety" in ln and ln.startswith("-rw") for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-variety" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./opt/variety/variety" in ln for ln in out.splitlines())
assert any("./usr/share/applications/variety.desktop" in ln for ln in out.splitlines())
assert any("./usr/share/metainfo/variety.appdata.xml" in ln for ln in out.splitlines())
assert any("./usr/share/icons/hicolor/scalable/apps/variety.svg" in ln for ln in out.splitlines())
assert any("./usr/share/doc/variety/changelog.Debian.gz" in ln for ln in out.splitlines())
assert any("./usr/share/doc/variety/copyright" in ln for ln in out.splitlines())
assert any("./usr/share/man/man1/variety.1.gz" in ln for ln in out.splitlines())
assert any("./usr/share/locale/zh_CN/LC_MESSAGES/variety.mo" in ln for ln in out.splitlines())
assert not any("variety-128.png" in ln for ln in out.splitlines())
print("deb_contents_ok")

ctl = subprocess.check_output(["dpkg-deb", "-I", str(p)], text=True)
Path("/workspace/t142-20261112-variety/evidence/kemi-variety-control.txt").write_text(ctl)
assert "Architecture: all" in ctl
assert "Source:" not in ctl
assert "Homepage: http://peterlevi.com/variety/" in ctl
assert "Version: 0.8.3-1kemi1" in ctl
print("control_ok")

# vacuous 0-ELF probe PASS — do not call probe_elf.py with zero --elf
root = Path("/workspace/t142-20261112-variety/stage/pkg")
elfs = []
for f in root.rglob("*"):
    if f.is_file() and not f.is_symlink() and "DEBIAN" not in f.parts:
        if f.read_bytes()[:4] == b"\x7fELF":
            elfs.append(str(f))
assert elfs == [], elfs
print("ELF_COUNT", 0)

probe = {
  "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
  "note": "vacuous 0-ELF PASS: official Architecture: all Python/GTK wallpaper-changer GUI; no packaged ELF; probe_elf.py not invoked with zero --elf",
  "configuredArchitecture": "arm64",
  "configuredMaxGlibc": "2.31",
  "runtimeLoadedOrExecuted": False,
  "files": [],
  "errors": [],
  "configuredLimitsSatisfied": True,
  "n_elf": 0,
  "requiredGlibc": None,
  "requiredGlibc_versioned": 0,
  "requiredGlibc_null": 0,
  "requiredGlibcxx": None,
  "requiredGlibcxx_versioned": 0,
  "requiredGlibcxx_null": 0,
}
Path("/workspace/t142-20261112-variety/probe/kemi-variety.json").write_text(json.dumps(probe, indent=2) + "\n")
print("PROBE_PASS n_elf=0 requiredGlibc=None (0 versioned, 0 null); requiredGlibcxx=None (0 versioned, 0 null, nulls not ranked as a max); configuredLimitsSatisfied=true; vacuous=yes")
print("BUILD_OK", p)
PYHASH
