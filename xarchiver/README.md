# Xarchiver (KEMI Linux)

Lightweight GTK3 archive manager for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **334** |
| package_name | `com.kemi.xarchiver` |
| dpkg | `kemi-xarchiver` |
| version | `0.5.4.14-1kemi1` / code **100** |
| bytes | 438160 |
| sha256 | `30f42729c16e9b47b8d35b8f6568b47e0cc24ea8557398b2cb10ab6b669d9b28` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794388279203_1809025d_kemi-xarchiver_0_5_4_14-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `xarchiver_0.5.4.14-1_arm64.deb` v0.5.4.14 (upstream version `1:0.5.4.14-1`, 439360 B, sha256 `208c1f99b453ef3e0e706c93bf666d161cee7aebbb855b03f91643263a043c70`). Launchpad published `xarchiver 1:0.5.4.14-1 in focal arm64` (universe, Release, binarypub 131885786, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/xarchiver_0.5.4.14-1_arm64.deb (librarian https://launchpadlibrarian.net/405101127/xarchiver_0.5.4.14-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). Installs under `/opt/xarchiver/` + `/usr/bin/xarchiver` (symlink to `/opt/xarchiver/xarchiver`). Compiled-in help `/usr/share/doc/xarchiver/index.html` and toolbar pixmaps `/usr/share/pixmaps/xarchiver` stay on those paths. Thunar archive plugin stays at `/usr/lib/thunar-archive-plugin/xarchiver.tap`; mailcap helper stays at `/usr/lib/mime/packages/xarchiver`. Locales, icons, desktop, and man stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3. Runtime Depends: `libc6 (>= 2.17)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.35.9)`, `libgtk-3-0 (>= 3.0.0)` — all in Ubuntu 20.04 focal arm64. Recommends: `bzip2`, `p7zip-full`, `unzip`, `xdg-utils`, `xz-utils`. Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
