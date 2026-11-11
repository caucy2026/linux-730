# Gucharmap (KEMI Linux)

Lightweight GTK3 Unicode character picker and font browser for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **342** |
| package_name | `com.kemi.gucharmap` |
| dpkg | `kemi-gucharmap` |
| version | `13.0.1-1kemi1` / code **1301** |
| bytes | 915980 |
| sha256 | `78991f99821cab80d0127056f17e83844edaa46a13780c12d57a651b83eb22c5` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794391541639_7036e83d_kemi-gucharmap_13_0_1-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `gucharmap_13.0.1-1_arm64.deb` v13.0.1 / epoch `1:13.0.1-1` (918884 B, sha256 `dba92a92154b7f4c3cb4767be08613ce63a0f90871cfc3efa57b0a71516d91bc`). Launchpad published `gucharmap 1:13.0.1-1 in focal arm64` (universe, Release, binarypub 139908108, published 2020-03-30 09:28:15 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/gucharmap_13.0.1-1_arm64.deb (librarian https://launchpadlibrarian.net/471575161/gucharmap_13.0.1-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu focal PROPOSED (build 19085699) and published to Release. Installs under `/opt/gucharmap/` + `/usr/bin/gucharmap` (symlink to `/opt/gucharmap/gucharmap`). Locales, help, desktop, man, metainfo and GSettings schema stay on standard `/usr/share` paths. Official desktop `Icon=accessories-character-map` (theme icon; not shipped in this deb). Official `changelog.Debian.gz` was a dangling symlink into `libgucharmap-2-90-7` and was not copied. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · libgucharmap_2_90.so.7 + GTK3 + GDK3 + Pango/PangoCairo + ATK + Cairo + GIO/GObject/GLib. Runtime Depends: `libatk1.0-0 (>= 1.12.4)`, `libc6 (>= 2.17)`, `libcairo2 (>= 1.2.4)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.4.0)`, `libgucharmap-2-90-7 (= 1:13.0.1-1)`, `libpango-1.0-0 (>= 1.14.0)`, `libpangocairo-1.0-0 (>= 1.14.0)`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal. Recommends: `yelp`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
