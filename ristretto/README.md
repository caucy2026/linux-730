# Ristretto (KEMI Linux)

Lightweight GTK3/XFCE image viewer for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **331** |
| package_name | `com.kemi.ristretto` |
| dpkg | `kemi-ristretto` |
| version | `0.10.0-1ubuntu0.1kemi1` / code **100** |
| bytes | 223060 |
| sha256 | `9c115e2f65402e45e492fa553511a87ce7ccbdcaebe513e94ebaf1dc30e38dae` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794387419796_ca8458c1_kemi-ristretto_0_10_0-1ubuntu0_1kemi1_ar.deb |

Notes: official Ubuntu 20.04 (focal) updates `ristretto_0.10.0-1ubuntu0.1_arm64.deb` v0.10.0 (221604 B, sha256 `874af2033f122bfdb01b7e78d723610cf0059e57c7b7b45dba38d5b7f86f58c9`). Launchpad published `ristretto 0.10.0-1ubuntu0.1 in focal arm64` (universe, updates, binarypub 197374412, published 2023-09-23 03:13 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/ristretto_0.10.0-1ubuntu0.1_arm64.deb (librarian https://launchpadlibrarian.net/671453145/ristretto_0.10.0-1ubuntu0.1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). Installs under `/opt/ristretto/` + `/usr/bin/ristretto` (symlink to `/opt/ristretto/ristretto`). Locales, icons, desktop, man, and AppStream metainfo stay on standard `/usr/share` paths (no compiled-in `/usr/share/ristretto` data dir). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3 + libxfce4*. Runtime Depends: `libc6 (>= 2.17)`, `libcairo2 (>= 1.2.4)`, `libexif12 (>= 0.6.21-1~)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.21.5)`, `libmagic1 (>= 5.12)`, `libpango-1.0-0 (>= 1.14.0)`, `libpangocairo-1.0-0 (>= 1.14.0)`, `libx11-6`, `libxfce4ui-2-0 (>= 4.11.0)`, `libxfce4util7 (>= 4.9.0)`, `libxfconf-0-3 (>= 4.12.1)` — all in Ubuntu 20.04 focal arm64. Recommends: `tumbler`. Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
