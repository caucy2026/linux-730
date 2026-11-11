# GPicView (KEMI Linux)

Lightweight GTK2/LXDE image viewer for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **332** |
| package_name | `com.kemi.gpicview` |
| dpkg | `kemi-gpicview` |
| version | `0.2.5-3kemi1` / code **100** |
| bytes | 104556 |
| sha256 | `7a9ba2d2b3135b1617e71fd00409c329dd26a7f3a9db0f189c662f4cf61a0a85` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794387676851_f61c3205_kemi-gpicview_0_2_5-3kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `gpicview_0.2.5-3_arm64.deb` v0.2.5 (105488 B, sha256 `b648d393f3e3eccf79e2f35cb87f1d2fd33803a5d3b55e7c6a0167d173cd3d9e`). Launchpad published `gpicview 0.2.5-3 in focal arm64` (universe, Release, binarypub 131888481, published 2019-10-18 17:15 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/gpicview_0.2.5-3_arm64.deb (librarian https://launchpadlibrarian.net/434170416/gpicview_0.2.5-3_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in eoan and copied unchanged into focal Release. Installs under `/opt/gpicview/` + `/usr/bin/gpicview` (symlink to `/opt/gpicview/gpicview`). Compiled-in data `/usr/share/gpicview/{pixmaps,ui}` stays on that path. Locales, icons, desktop, and man stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.29** (1 ELF) · no GLIBCXX · GTK2 + libjpeg. Runtime Depends: `libc6 (>= 2.29)`, `libcairo2 (>= 1.2.4)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk2.0-0 (>= 2.20.0)`, `libjpeg8 (>= 8c)`, `libx11-6` — all in Ubuntu 20.04 focal arm64. Recommends: `xdg-utils`. Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
