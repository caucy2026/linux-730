#!/usr/bin/env bash
# Build kemi-caja-admin from official Ubuntu 20.04 caja-admin.
# 验证≠编译: do not compile; official U20 files only.
# Official Source field is absent and is not defaulted.
# No exact-version same-source hard Depends; nothing is bundled.
# Official package has no /usr/bin command: do not invent
# /usr/bin/kemi-caja-admin or /opt/caja-admin.
# Official package has no applications desktop: do not invent one.
# Official changelog and copyright are real files and are kept.
# 合主线：gork.bot协助开发
set -euo pipefail

ROOT=/workspace/t142-20261112-caja-admin
UNPACK="$ROOT/unpack/gui"
STAGE="$ROOT/stage"
DEBDIR="$ROOT/debs"
PKG=kemi-caja-admin
VER_UP=0.0.1-3build1
VER_NAME=0.0.1-3build1kemi1
VER_DEB=0.0.1-3build1kemi1
ARCH=all

python3 - << 'PYLEN'
s = "0.0.1-3build1kemi1"
assert len(s) == 18, len(s)
# official 0.0.1-3build1 (13) + kemi1 (5) = 18; no padding needed
# no Debian epoch
print("version_name_len", len(s))
PYLEN

rm -rf "$STAGE"
mkdir -p "$STAGE/pkg"

# official tree minus DEBIAN (control will be rewritten)
python3 - << 'PYCOPY'
import shutil
from pathlib import Path
src = Path("/workspace/t142-20261112-caja-admin/unpack/gui")
dst = Path("/workspace/t142-20261112-caja-admin/stage/pkg")
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
mkdir -p "$STAGE/pkg/usr/share/doc/kemi-caja-admin"
cp -a "$STAGE/pkg/usr/share/doc/caja-admin/changelog.Debian.gz" "$STAGE/pkg/usr/share/doc/kemi-caja-admin/changelog.Debian.gz"
cp -a "$STAGE/pkg/usr/share/doc/caja-admin/copyright" "$STAGE/pkg/usr/share/doc/kemi-caja-admin/copyright"

# no official maintainer scripts; no desktops, hicolor icons,
# schemas, or bundled shared libs — invent no hooks.

mkdir -p "$STAGE/pkg/DEBIAN"
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOF
Package: ${PKG}
Version: ${VER_DEB}
Section: misc
Priority: optional
Architecture: ${ARCH}
Installed-Size: ${INSTALLED_SIZE}
Depends: python3-gi, gir1.2-gtk-3.0, caja, policykit-1, python3-caja (>= 1.23.0)
Recommends: pluma, mate-terminal
Provides: caja-admin (= ${VER_UP})
Conflicts: caja-admin
Replaces: caja-admin
Homepage: https://github.com/infirit/caja-admin/
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Description: Add administrative actions to Caja's right-click menu
 Caja Admin 0.0.1-3build1 — official
 Ubuntu 20.04 Architecture: all, KEMI
 repack of caja-admin. No exact-version
 same-source hard Depends were bundled.
 Official files stay under /usr.
 gork.bot协助开发.
EOF

python3 - << 'PYCTL'
from pathlib import Path
c = Path("/workspace/t142-20261112-caja-admin/stage/pkg/DEBIAN/control").read_text()
assert "Homepage: https://github.com/infirit/caja-admin/\n" in c
assert "Version: 0.0.1-3build1kemi1\n" in c
assert "Architecture: all\n" in c
assert "Package: kemi-caja-admin\n" in c
assert "Source:" not in c
assert "Depends: python3-gi, gir1.2-gtk-3.0, caja, policykit-1, python3-caja (>= 1.23.0)\n" in c
assert "Recommends: pluma, mate-terminal\n" in c
assert "Provides: caja-admin (= 0.0.1-3build1)\n" in c
assert "Conflicts: caja-admin\n" in c
assert "Replaces: caja-admin\n" in c
assert "Suggests:" not in c
print("control_text_ok")
PYCTL

# md5sums of packed files (not DEBIAN)
python3 - << 'PYMD5'
import hashlib
from pathlib import Path
root = Path("/workspace/t142-20261112-caja-admin/stage/pkg")
lines = []
for p in sorted(root.rglob("*")):
    if not p.is_file() or p.is_symlink():
        continue
    rel = p.relative_to(root)
    if rel.parts[0] == "DEBIAN":
        continue
    h = hashlib.md5(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {rel.as_posix()}\n")
Path("/workspace/t142-20261112-caja-admin/stage/pkg/DEBIAN/md5sums").write_text("".join(lines))
print("md5sums", len(lines))
PYMD5

# leftover-x86: skip comments, official copyright, DEBIAN/control Description, binaries
python3 - << 'PYX86'
from pathlib import Path
root = Path("/workspace/t142-20261112-caja-admin/stage/pkg")
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

# no applications desktop, no theme, no invented launcher
python3 - << 'PYPRE'
from pathlib import Path
root = Path("/workspace/t142-20261112-caja-admin/stage/pkg")
desktops = list(root.glob("usr/share/applications/*.desktop"))
assert not desktops, desktops
assert not (root / "usr/bin/kemi-caja-admin").exists()
assert not (root / "opt").exists()
assert not list(root.rglob("caja-admin-128.png"))
assert not list(root.rglob("humanity-system-file-manager-128.svg"))
assert (root / "usr/share/caja-python/extensions/caja-admin.py").is_file()
assert (root / "usr/share/polkit-1/actions/org.freedesktop.caja-admin.policy").is_file()
mos = list((root / "usr/share/locale").rglob("caja-admin.mo"))
assert len(mos) == 11, len(mos)
print("layout_pre_ok mo_count", len(mos))
PYPRE

OUT="$DEBDIR/${PKG}_${VER_NAME}_${ARCH}.deb"
rm -f "$OUT"
dpkg-deb --build --root-owner-group "$STAGE/pkg" "$OUT"

python3 - << 'PYHASH'
import hashlib, io, json, subprocess
from pathlib import Path

p = Path("/workspace/t142-20261112-caja-admin/debs/kemi-caja-admin_0.0.1-3build1kemi1_all.deb")
h = hashlib.sha256(p.read_bytes()).hexdigest()
print("KEMI_DEB", p, p.stat().st_size, h)
Path(str(p) + ".sha256").write_text(h + "  " + p.name + "\n")

out = subprocess.check_output(["dpkg-deb", "-c", str(p)], text=True)
assert any("./usr/share/caja-python/extensions/caja-admin.py" in ln for ln in out.splitlines())
assert any("./usr/share/polkit-1/actions/org.freedesktop.caja-admin.policy" in ln for ln in out.splitlines())
assert any("./usr/share/doc/caja-admin/changelog.Debian.gz" in ln for ln in out.splitlines())
assert any("./usr/share/doc/caja-admin/copyright" in ln for ln in out.splitlines())
assert any("./usr/share/doc/kemi-caja-admin/changelog.Debian.gz" in ln for ln in out.splitlines())
assert any("./usr/share/doc/kemi-caja-admin/copyright" in ln for ln in out.splitlines())
assert any("./usr/share/locale/zh_CN/LC_MESSAGES/caja-admin.mo" in ln for ln in out.splitlines())
assert not any("kemi-caja-admin" in ln and "/usr/bin/" in ln for ln in out.splitlines())
assert not any("./opt/" in ln or ln.endswith(" ./opt") or "/opt/caja-admin" in ln for ln in out.splitlines())
assert not any("usr/share/applications/" in ln and ln.endswith(".desktop") for ln in out.splitlines())
assert not any("caja-admin-128.png" in ln for ln in out.splitlines())
assert not any("Humanity" in ln or "humanity-icon-theme" in ln for ln in out.splitlines())
print("deb_contents_ok")

# control listing
ctl = subprocess.check_output(["dpkg-deb", "-I", str(p)], text=True)
Path("/workspace/t142-20261112-caja-admin/evidence/kemi-caja-admin-control.txt").write_text(ctl)
assert "Architecture: all" in ctl
assert "Source:" not in ctl
assert "Homepage: https://github.com/infirit/caja-admin/" in ctl
assert "Version: 0.0.1-3build1kemi1" in ctl
print("control_ok")

# vacuous 0-ELF probe PASS — do not call probe_elf.py with zero --elf
# confirm 0 packaged unique non-symlink ELFs
import tarfile
# extract file list already from dpkg-deb -c; also scan stage
root = Path("/workspace/t142-20261112-caja-admin/stage/pkg")
elfs = []
for f in root.rglob("*"):
    if f.is_file() and not f.is_symlink() and "DEBIAN" not in f.parts:
        if f.read_bytes()[:4] == b"\x7fELF":
            elfs.append(str(f))
assert elfs == [], elfs
print("ELF_COUNT", 0)

probe = {
  "scope": "selected ELF headers, DT_NEEDED and version-needs only; not complete compatibility or package acceptance",
  "note": "vacuous 0-ELF PASS: official Architecture: all Python Caja extension GUI; no packaged ELF; probe_elf.py not invoked with zero --elf",
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
outp = Path("/workspace/t142-20261112-caja-admin/probe/kemi-caja-admin.json")
outp.write_text(json.dumps(probe, indent=2) + "\n")
print("PROBE_PASS n_elf=0 requiredGlibc=None (0 versioned, 0 null); requiredGlibcxx=None (0 versioned, 0 null, nulls not ranked as a max); configuredLimitsSatisfied=true; vacuous=yes")
print("BUILD_OK", p)
PYHASH
