# Catfish (KEMI Linux)

Lightweight GTK3 file searching tool for KEMI mall (arch=all, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **335** |
| package_name | `com.kemi.catfish` |
| dpkg | `kemi-catfish` |
| version | `1.4.13-1kemi1` / code **1413** |
| bytes | 187292 |
| sha256 | `86705ad0c97a5d50a01768a5badcdc969f865d9cb82196d26c846b9e07af20b5` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794388590106_cf743cfc_kemi-catfish_1_4_13-1kemi1_all.deb |

Notes: official Ubuntu 20.04 (focal) Release `catfish_1.4.13-1_all.deb` v1.4.13 (188780 B, sha256 `043ba471620618b0ecd03de876acb2a79ee1c255374139141cd01c59a3e63bf7`). Launchpad published `catfish 1.4.13-1 in focal arm64` (universe, Release, architecture_specific=False / arch=all, binarypub 136454868, published 2020-01-15 20:48:14 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/catfish_1.4.13-1_all.deb (librarian https://launchpadlibrarian.net/460692230/catfish_1.4.13-1_all.deb; fetched via aliyun ubuntu pool; SHA matched Launchpad `.changes` and librarian in-memory hash). Installs under `/opt/catfish/` + `/usr/bin/catfish` (symlink to `/opt/catfish/bin/catfish`). Compiled-in UI data `/usr/share/catfish/` stays on that path. Locales, icons, desktop, AppStream, and man stay on standard `/usr/share` paths. Probe: arch=all · **0 ELF** · Python + GTK3 typelibs · PASS vs 101 ≤2.31 (no native glibc). No PEP 585 / PEP 604 typings (safe on Ubuntu 20.04 Python 3.8). Official launcher requires GTK 3.10 (focal has 3.24). Runtime Depends: `python3:any`, `python3-gi-cairo`, `python3-dbus`, `python3-pexpect`, `gir1.2-gtk-3.0`, `gir1.2-gdkpixbuf-2.0`, `gir1.2-glib-2.0`, `gir1.2-pango-1.0` — all in Ubuntu 20.04 focal. Recommends: `mlocate | locate`. Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
