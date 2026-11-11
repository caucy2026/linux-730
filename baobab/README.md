# Baobab (KEMI Linux)

Lightweight GTK3 disk usage analyzer for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **346** |
| package_name | `com.kemi.baobab` |
| dpkg | `kemi-baobab` |
| version | `3.34.0-1kemi1` / code **3340** |
| bytes | 91200 |
| sha256 | `095a34ff54438fe268c278d5859df47ddb2110cb947d15b172ad0e2e477c83b2` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794393760313_e6840a03_kemi-baobab_3_34_0-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `baobab_3.34.0-1_arm64.deb` v3.34.0 (91248 B, sha256 `e7756a722943f221c8d65a42a27702fa58b476909abb3e074cc2a0d293411034`). Launchpad published `baobab 3.34.0-1 in focal arm64` (main, Release, binarypub 131884253, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/baobab_3.34.0-1_arm64.deb (librarian https://launchpadlibrarian.net/442624851/baobab_3.34.0-1_arm64.deb; SHA matched Aliyun ubuntu-ports mirror and in-memory librarian hash; Launchpad `.changes` fetch returned HTTP 503 this run). The arm64 binary was built in ubuntu eoan PROPOSED (build 17770047, Successfully built 2019-09-15 20:06:52 Asia/Shanghai) and published to focal Release (Launchpad HTML: "arm64 build of baobab 3.34.0-1 in ubuntu eoan PROPOSED produced these files"). Installs under `/opt/baobab/` + `/usr/bin/baobab` (symlink to `/opt/baobab/baobab`). Desktop, man, hicolor icons, GSettings schema, metainfo, D-Bus service and help stay on standard `/usr/share` paths. Official desktop `Icon=org.gnome.baobab` (hicolor SVG shipped). UI is compiled-in as a GResource (`/org/gnome/baobab/ui`, `resource:///org/gnome/baobab/baobab.css`). Official D-Bus service `org.gnome.baobab.service` keeps `Exec=/usr/bin/baobab --gapplication-service`. This official deb ships no locale `.mo` files (compiled locale path is `/usr/share/locale`; desktop has `X-Ubuntu-Gettext-Domain=baobab`). C help is bundled; non-C help entries are official symlinks into `/usr/share/help-langpack` (not shipped in this deb). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GLib/GIO/GObject + GTK3 + GDK3 + Pango + Cairo. Runtime Depends: `libc6 (>= 2.17)`, `libcairo2 (>= 1.2.4)`, `libglib2.0-0 (>= 2.43.92)`, `libgtk-3-0 (>= 3.19.12)`, `libpango-1.0-0 (>= 1.14.0)`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal. Recommends: `yelp`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
