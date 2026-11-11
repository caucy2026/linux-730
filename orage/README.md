# Orage (KEMI Linux)

Lightweight GTK2 desktop calendar for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **345** |
| package_name | `com.kemi.orage` |
| dpkg | `kemi-orage` |
| version | `4.12.1-7kemi1` / code **4121** |
| bytes | 1466780 |
| sha256 | `119c3f3f6a9d42916dc33054a7ca5283f88609eaea01fd569a6a45306b9f5358` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794393005662_5f31695c_kemi-orage_4_12_1-7kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `orage_4.12.1-7_arm64.deb` v4.12.1 (166748 B, sha256 `9199c28d6d08d86fd812ded4679fddfa0f9a12652c59aa172f7b6f1ab100de1b`) plus official arch:all `orage-data_4.12.1-7_all.deb` (1320344 B, sha256 `db322265d7b2e5d7b10a750e7c4e3d2bb45018224d9f0d3695cfd907cf2ae28f`), bundled into one KEMI deb. Launchpad published `orage 4.12.1-7 in focal arm64` (universe, Release, binarypub 134550228, published 2019-12-02 18:28:13 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/orage_4.12.1-7_arm64.deb (librarian https://launchpadlibrarian.net/453840980/orage_4.12.1-7_arm64.deb; SHA matched Launchpad arm64 `.changes` and Aliyun ubuntu-ports mirror). The arm64 binary was built in ubuntu focal PROPOSED (build 18188688) and copied to focal Release (Launchpad HTML: Copied from ubuntu focal-proposed arm64). orage-data was built in ubuntu focal PROPOSED amd64 (build 18188687, arch:all, librarian https://launchpadlibrarian.net/453836674/orage-data_4.12.1-7_all.deb; SHA matched amd64 `.changes`) and published to focal arm64 Release (binarypub 134550222). Installs under `/opt/orage/` + `/usr/bin/orage`, `/usr/bin/globaltime`, `/usr/bin/tz_convert` (symlinks into `/opt/orage`). Locales, desktop, man, hicolor icons, HTML help and alarm sounds stay on standard `/usr/share` and `/usr/share/orage` paths. Official desktop `Icon=xfcalendar` / `orage_globaltime` (hicolor shipped in orage-data). 53 locales including zh_CN. Panel plugin `liborageclock.so` is shipped on the standard XFCE path but links `libxfce4panel-1.0.so.4` (GTK2), which is not published in focal arm64 (Launchpad total=0); `xfce4-panel` is Recommends only. Official orage-data does not ship `/usr/share/orage/zoneinfo`. Probe: aarch64 · requiredGlibc **2.17** (4 ELF) · no GLIBCXX · GTK2 + libical + libnotify + GdkPixbuf + Pango + X11 + (plugin) libxfce4panel-1.0 + libxfce4util. Runtime Depends: `libc6 (>= 2.17)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.35.9)`, `libgtk2.0-0 (>= 2.16.0)`, `libical3 (>= 3.0.0)`, `libnotify4 (>= 0.7.0)`, `libpango-1.0-0 (>= 1.14.0)`, `libpopt0 (>= 1.14)`, `libx11-6`, `libxfce4util7 (>= 4.9.0)` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
