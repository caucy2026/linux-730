# LXTask (KEMI Linux)

Lightweight GTK2 LXDE task / process manager for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **337** |
| package_name | `com.kemi.lxtask` |
| dpkg | `kemi-lxtask` |
| version | `0.1.9-1kemi1` / code **19** |
| bytes | 57364 |
| sha256 | `ade57e1d756be4c16964bade5b7d85236f9e7bd2481bbd7f20aaa153077aa3e3` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794389816775_6dc4bf87_kemi-lxtask_0_1_9-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `lxtask_0.1.9-1_arm64.deb` v0.1.9 (58180 B, sha256 `e75e5fc36f04c672f17c700ae300acfa779212b6871c330eb75cf14ed560d852`). Launchpad published `lxtask 0.1.9-1 in focal arm64` (universe, Release, binarypub 131890114, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/lxtask_0.1.9-1_arm64.deb (librarian https://launchpadlibrarian.net/420390374/lxtask_0.1.9-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in eoan and copied unchanged into focal Release. Installs under `/opt/lxtask/` + `/usr/bin/lxtask` (symlink to `/opt/lxtask/lxtask`). Locales, desktop and man stay on standard `/usr/share` paths. Official desktop `Icon=utilities-system-monitor` (freedesktop theme icon); the official deb ships no pixmap. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK2 + GLib. Runtime Depends: `libc6 (>= 2.17)`, `libglib2.0-0 (>= 2.14.0)`, `libgtk2.0-0 (>= 2.14.0)` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
