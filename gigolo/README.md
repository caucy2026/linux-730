# Gigolo (KEMI Linux)

Lightweight GTK3 GIO/GVfs remote-filesystem frontend for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **339** |
| package_name | `com.kemi.gigolo` |
| dpkg | `kemi-gigolo` |
| version | `0.5.1-1kemi1` / code **51** |
| bytes | 138672 |
| sha256 | `4c189e02ee813e462589deff6cfcfae80992f1c7b562d1eee2ef2cb5c7e21a69` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794390402715_36d97f31_kemi-gigolo_0_5_1-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `gigolo_0.5.1-1_arm64.deb` v0.5.1 (138980 B, sha256 `0ddf9f86fcbe8bca2621d43cab97b47dd64e5aa2d3696c64b5a7f825104d3bf4`). Launchpad published `gigolo 0.5.1-1 in focal arm64` (universe, Release, binarypub 139439471, published 2020-03-22 05:53:27 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/gigolo_0.5.1-1_arm64.deb (librarian https://launchpadlibrarian.net/470025816/gigolo_0.5.1-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu focal PROPOSED and published to Release. Installs under `/opt/gigolo/` + `/usr/bin/gigolo` (symlink to `/opt/gigolo/gigolo`). Locales, desktop and man stay on standard `/usr/share` paths. Official desktop `Icon=gtk-network` (GTK stock; this deb ships no pixmap). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3 + GDK3 + GIO/GVfs + GLib + libX11. Runtime Depends: `libc6 (>= 2.17)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.21.5)`, `libx11-6` — all in Ubuntu 20.04 focal. Recommends `libglib2.0-bin` kept. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
