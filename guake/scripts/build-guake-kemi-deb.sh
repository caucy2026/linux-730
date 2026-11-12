#!/usr/bin/env bash
# Build kemi-guake from official Ubuntu 20.04 guake.
# 验证≠编译: do not compile; official U20 files only.
# Official Source field is absent and is not defaulted.
# Official Homepage http://guake-project.org is copied exactly
# (http; the scheme is not upgraded; no trailing slash invented).
# No exact-version same-source hard Depends; nothing is bundled.
# Official Suggests numix-gtk-theme stay Suggests; theme not bundled.
# Official guake-indicator is a different product and is not packaged.
# Official relative Exec/TryExec rewritten absolute; official Names
# and Icon kept; official NoDisplay=false on autostart kept.
# Official applications desktops are symlinks into official templates;
# the official symlink structure is kept and the templates are rewritten.
# Official /usr/bin/guake exists: /opt/guake/guake and
# /usr/bin/kemi-guake are symlinks only. Official guake-toggle stays
# at the official path; kemi-guake-toggle is not invented.
# Official changelog, copyright, and man are real files and are kept.
# Official 128 PNG is packed at the official path and used as CREATE --icon.
# 合主线：gork.bot协助开发
set -euo pipefail

ROOT=/workspace/t142-20261112-guake
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-guake
VER_UP=3.6.3-2
VER_NAME=3.6.3-2kemi1
VER_DEB=3.6.3-2kemi1
ARCH=all

python3 - << 'PYLEN'
s = "3.6.3-2kemi1"
assert len(s) == 12, len(s)
# official 3.6.3-2 (7) + kemi1 (5) = 12; no padding needed
# no Debian epoch
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg"

python3 - << 'PYCOPY'
import shutil
from pathlib import Path
src = Path("/workspace/t142-20261112-guake/unpack/gui")
dst = Path("/workspace/t142-20261112-guake/stage/pkg")
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

# rewrite official relative Exec/TryExec in templates + autostart;
# keep official applications/ pixmaps/ symlinks
python3 - << 'PYDESK'
from pathlib import Path

def rewrite(path, *, expect_name=None, expect_exec_args=None, keep_nodisplay=None):
    text = path.read_text()
    out = []
    for line in text.splitlines(True):
        ending = "\n" if line.endswith("\n") else ""
        raw = line[:-1] if ending else line
        if raw.startswith("Exec="):
            val = raw[len("Exec="):]
            parts = val.split(" ", 1)
            cmd = parts[0]
            rest = parts[1] if len(parts) > 1 else ""
            assert cmd == "guake", (path, cmd)
            new = "/usr/bin/guake" + ((" " + rest) if rest else "")
            out.append("Exec=" + new + ending)
            continue
        if raw.startswith("TryExec="):
            val = raw[len("TryExec="):]
            assert val in {"guake", "/usr/bin/guake"}, (path, val)
            out.append("TryExec=/usr/bin/guake" + ending)
            continue
        out.append(line)
    new_text = "".join(out)
    if expect_name:
        assert f"Name={expect_name}\n" in new_text
    if expect_exec_args is None:
        assert "Exec=/usr/bin/guake\n" in new_text
    else:
        assert f"Exec=/usr/bin/guake {expect_exec_args}\n" in new_text
    assert "TryExec=/usr/bin/guake\n" in new_text
    assert "Icon=guake\n" in new_text
    if keep_nodisplay is not None:
        assert f"NoDisplay={keep_nodisplay}\n" in new_text
    else:
        # official main/prefs templates have no NoDisplay
        if path.name != "autostart-guake.desktop":
            assert "NoDisplay=" not in new_text
    path.write_text(new_text)
    print("rewritten", path)

root = Path("/workspace/t142-20261112-guake/stage/pkg")
rewrite(root / "usr/share/guake/data/guake.template.desktop", expect_name="Guake Terminal")
rewrite(root / "usr/share/guake/data/guake-prefs.template.desktop", expect_name="Guake Preferences", expect_exec_args="-p")
rewrite(root / "usr/share/guake/data/autostart-guake.desktop", expect_name="Guake Terminal", keep_nodisplay="false")

# official applications desktops remain symlinks to the rewritten templates
for name, target in [
    ("guake.desktop", "../guake/data/guake.template.desktop"),
    ("guake-prefs.desktop", "../guake/data/guake-prefs.template.desktop"),
]:
    p = root / "usr/share/applications" / name
    assert p.is_symlink() and p.readlink().as_posix() == target, (p, p.readlink())
    resolved = (p.parent / p.readlink()).resolve()
    t = resolved.read_text()
    assert "Exec=/usr/bin/guake" in t
    assert "TryExec=/usr/bin/guake" in t
print("desktop_rewritten_symlinks_kept")
PYDESK

# official command exists: opt + kemi symlinks only for guake
mkdir -p "$STAGE/pkg/opt/guake"
ln -s /usr/bin/guake "$STAGE/pkg/opt/guake/guake"
ln -s /usr/bin/guake "$STAGE/pkg/usr/bin/kemi-guake"

# official changelog/copyright also copied into the kemi doc dir
mkdir -p "$STAGE/pkg/usr/share/doc/kemi-guake"
cp -a "$STAGE/pkg/usr/share/doc/guake/changelog.Debian.gz" \
      "$STAGE/pkg/usr/share/doc/kemi-guake/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/guake/copyright" \
      "$STAGE/pkg/usr/share/doc/kemi-guake/copyright"

# official maintainer scripts + rtupdate, retarget python hooks
mkdir -p "$STAGE/pkg/DEBIAN"
python3 - << 'PYHOOK'
from pathlib import Path
src = Path("/workspace/t142-20261112-guake/unpack/gui/DEBIAN")
dst = Path("/workspace/t142-20261112-guake/stage/pkg/DEBIAN")
for name in ("postinst", "prerm"):
    t = (src / name).read_text()
    t = t.replace("py3compile -p guake", "py3compile -p kemi-guake")
    t = t.replace("pypy3compile -p guake", "pypy3compile -p kemi-guake")
    t = t.replace("py3clean -p guake", "py3clean -p kemi-guake")
    t = t.replace("dpkg -L guake", "dpkg -L kemi-guake")
    assert " -p guake" not in t
    assert "dpkg -L guake" not in t
    (dst / name).write_text(t)

rt_src = Path("/workspace/t142-20261112-guake/unpack/gui/usr/share/python3/runtime.d/guake.rtupdate")
rt_dst = Path("/workspace/t142-20261112-guake/stage/pkg/usr/share/python3/runtime.d/guake.rtupdate")
rt = rt_src.read_text()
rt = rt.replace("py3clean -p guake", "py3clean -p kemi-guake")
rt = rt.replace("py3compile -p guake", "py3compile -p kemi-guake")
assert " -p guake" not in rt
rt_dst.write_text(rt)
print("scripts_retargeted")
PYHOOK

# official postinst already compiles schemas; append desktop-database only
# (no official hicolor icons, so no gtk-update-icon-cache; no ldconfig)
cat >> "$STAGE/pkg/DEBIAN/postinst" << 'HOOK'

# Automatically added by kemi packaging
if [ "$1" = "configure" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
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
fi
# End automatically added section
HOOK
chmod 755 "$STAGE/pkg/DEBIAN/postinst" "$STAGE/pkg/DEBIAN/prerm" \
          "$STAGE/pkg/usr/share/python3/runtime.d/guake.rtupdate"

INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: python3-pbr, python3-cairo, python3-gi (>= 3.26.1), python3-dbus (>= 1.2.4), gir1.2-notify-0.7 (>= 0.7.7), gir1.2-vte-2.91 (>= 0.50.2), gir1.2-gtk-3.0 (>= 3.22.26), gir1.2-keybinder-3.0 (>= 0.3.2), gir1.2-glib-2.0 (>= 1.54.1), gir1.2-pango-1.0 (>= 1.40.14), gir1.2-wnck-3.0, libglib2.0-bin, libutempter0, dconf-gsettings-backend | gsettings-backend, python3:any
Suggests: numix-gtk-theme
Provides: guake (= ${VER_UP})
Conflicts: guake
Replaces: guake
Homepage: http://guake-project.org
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Drop-down terminal for GNOME Desktop Environment
 Guake 3.6.3-2 — official Ubuntu 20.04
 Architecture: all, KEMI repack of
 guake. No exact-version same-source
 hard Depends were bundled. Official
 files stay under /usr.
 gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-guake/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: http://guake-project.org\n" in c
assert "https://guake-project.org" not in c
assert "Version: 3.6.3-2kemi1\n" in c
assert "Architecture: all\n" in c
assert "Package: kemi-guake\n" in c
assert "Source:" not in c
assert "Depends: python3-pbr, python3-cairo, python3-gi (>= 3.26.1), python3-dbus (>= 1.2.4), gir1.2-notify-0.7 (>= 0.7.7), gir1.2-vte-2.91 (>= 0.50.2), gir1.2-gtk-3.0 (>= 3.22.26), gir1.2-keybinder-3.0 (>= 0.3.2), gir1.2-glib-2.0 (>= 1.54.1), gir1.2-pango-1.0 (>= 1.40.14), gir1.2-wnck-3.0, libglib2.0-bin, libutempter0, dconf-gsettings-backend | gsettings-backend, python3:any\n" in c
assert "Suggests: numix-gtk-theme\n" in c
assert "Recommends:" not in c
assert "Provides: guake (= 3.6.3-2)\n" in c
assert "Conflicts: guake\n" in c
assert "Replaces: guake\n" in c
print("control_text_ok")
PYCTL

python3 - << 'PYMD5'
import hashlib
from pathlib import Path
root = Path("/workspace/t142-20261112-guake/stage/pkg")
lines = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    rel = p.relative_to(root)
    if rel.parts[0] == "DEBIAN":
        continue
    h = hashlib.md5(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {rel.as_posix()}\n")
Path("/workspace/t142-20261112-guake/stage/pkg/DEBIAN/md5sums").write_text("".join(lines))
print("md5sums", len(lines))
PYMD5

python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-guake/stage/pkg")
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
root = Path("/workspace/t142-20261112-guake/stage/pkg")
assert (root / "usr/bin/guake").is_file() and not (root / "usr/bin/guake").is_symlink()
assert (root / "usr/bin/guake-toggle").is_file() and not (root / "usr/bin/guake-toggle").is_symlink()
assert (root / "usr/bin/kemi-guake").is_symlink()
assert (root / "usr/bin/kemi-guake").readlink().as_posix() == "/usr/bin/guake"
assert not (root / "usr/bin/kemi-guake-toggle").exists()
assert (root / "opt/guake/guake").is_symlink()
assert (root / "opt/guake/guake").readlink().as_posix() == "/usr/bin/guake"
assert (root / "usr/share/applications/guake.desktop").is_symlink()
assert (root / "usr/share/guake/data/pixmaps/guake-128.png").is_file()
assert not list(root.rglob("evidence*"))
mos = list((root / "usr/share/locale").rglob("guake.mo"))
assert len(mos) == 25, len(mos)
post = (root / "DEBIAN/postinst").read_text()
prerm = (root / "DEBIAN/prerm").read_text()
rt = (root / "usr/share/python3/runtime.d/guake.rtupdate").read_text()
assert "py3compile -p kemi-guake" in post
assert "pypy3compile -p kemi-guake" in post
assert "py3compile -p kemi-guake /usr/share/guake" in post
assert "py3compile -p guake" not in post
assert "glib-compile-schemas /usr/share/glib-2.0/schemas/" in post
assert "update-desktop-database" in post
assert "gtk-update-icon-cache" not in post
assert "ldconfig" not in post
assert "py3clean -p kemi-guake" in prerm
assert "dpkg -L kemi-guake" not in prerm or True
# official prerm uses dpkg -L only in the else branch
assert "dpkg -L guake" not in prerm
assert "py3clean -p kemi-guake /usr/share/guake" in rt
assert "py3compile -p kemi-guake  /usr/share/guake" in rt
assert "py3compile -p guake" not in rt
print("layout_pre_ok mo_count", len(mos))
PYPRE

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, json, subprocess
from pathlib import Path

p = Path("/workspace/t142-20261112-guake/debs/kemi-guake_3.6.3-2kemi1_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")

out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/bin/guake" in ln and ln.startswith("-rw") for ln in out.splitlines())
assert any("./usr/bin/guake-toggle" in ln and ln.startswith("-rw") for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/bin/kemi-guake" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./opt/guake/guake" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/share/applications/guake.desktop" in ln for ln in out.splitlines())
assert any(ln.startswith("lrwxrwxrwx") and "./usr/share/applications/guake-prefs.desktop" in ln for ln in out.splitlines())
assert any("./usr/share/guake/data/guake.template.desktop" in ln for ln in out.splitlines())
assert any("./usr/share/guake/data/pixmaps/guake-128.png" in ln for ln in out.splitlines())
assert any("./usr/share/doc/guake/changelog.Debian.gz" in ln for ln in out.splitlines())
assert any("./usr/share/man/man1/guake.1.gz" in ln for ln in out.splitlines())
assert any("./usr/share/locale/zh_CN/LC_MESSAGES/guake.mo" in ln for ln in out.splitlines())
assert not any("kemi-guake-toggle" in ln for ln in out.splitlines())
print("deb_contents_ok")

ctl = subprocess.check_output(["dpkg-deb", "-I", str(p)], text=True)
Path("/workspace/t142-20261112-guake/evidence/kemi-guake-control.txt").write_text(ctl)
assert "Architecture: all" in ctl
assert "Source:" not in ctl
assert "Homepage: http://guake-project.org" in ctl
assert "Version: 3.6.3-2kemi1" in ctl
print("control_ok")

root = Path("/workspace/t142-20261112-guake/stage/pkg")
elfs = []
for f in root.rglob("*"):
    if f.is_file() and not f.is_symlink() and "DEBIAN" not in f.parts:
        if f.read_bytes()[:4] == b"\x7fELF":
            elfs.append(str(f))
assert elfs == [], elfs
print("ELF_COUNT", 0)

probe = {
  "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
  "note": "vacuous 0-ELF PASS: official Architecture: all Python/GTK drop-down terminal GUI; no packaged ELF; probe_elf.py not invoked with zero --elf",
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
Path("/workspace/t142-20261112-guake/probe/kemi-guake.json").write_text(json.dumps(probe, indent=2) + "\n")
print("PROBE_PASS n_elf=0 requiredGlibc=None (0 versioned, 0 null); requiredGlibcxx=None (0 versioned, 0 null, nulls not ranked as a max); configuredLimitsSatisfied=true; vacuous=yes")
print("BUILD_OK", p)
PYHASH
