# Xfce4 Screenshooter (KEMI Linux)

Lightweight GTK3/XFCE screenshot utility for KEMI mall (arm64, Ubuntu 20.04 / 101). Distinct from Flameshot (app324).

| field | value |
|---|---|
| app_id | **333** |
| package_name | `com.kemi.xfce4-screenshooter` |
| dpkg | `kemi-xfce4-screenshooter` |
| version | `1.9.7-1kemi1` / code **100** |
| bytes | 130256 |
| sha256 | `8d26914c8b4d47517a26c9f526b290c510a59758835935e9a2801da7a17cba1a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794387964763_086c0e20_kemi-xfce4-screenshooter_1_9_7-1kemi1_ar.deb |

Notes: official Ubuntu 20.04 (focal) Release `xfce4-screenshooter_1.9.7-1_arm64.deb` v1.9.7 (130612 B, sha256 `a81a3cd6266613b59fbf9adb8bb5018ea90e39de2f2bba7f0cc1ce4e20f09856`). Launchpad published `xfce4-screenshooter 1.9.7-1 in focal arm64` (universe, Release, binarypub 135649868, published 2019-12-26 14:33 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/xfce4-screenshooter_1.9.7-1_arm64.deb (librarian https://launchpadlibrarian.net/457323667/xfce4-screenshooter_1.9.7-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). Installs under `/opt/xfce4-screenshooter/` + `/usr/bin/xfce4-screenshooter` (symlink to `/opt/xfce4-screenshooter/xfce4-screenshooter`). XFCE panel plugin stays on standard `/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins` and `/usr/share/xfce4/panel/plugins` paths. Locales, icons, desktop, man, and AppStream metainfo stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.17** (2 ELF: main binary + panel plugin) · no GLIBCXX · GTK3 + libxfce4*. Runtime Depends: `libc6 (>= 2.17)`, `libcairo2 (>= 1.10.0)`, `libexo-2-0 (>= 0.11.0)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.21.4)`, `libsoup2.4-1 (>= 2.41.90)`, `libx11-6`, `libxext6`, `libxfce4ui-2-0 (>= 4.13.5)`, `libxfce4util7 (>= 4.9.0)`, `libxfixes3`, `libxml2 (>= 2.7.4)` — all in Ubuntu 20.04 focal arm64. Recommends: `libxfce4panel-2.0-4` (optional panel plugin). Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth). CDN object key filename is truncated by the store to `..._ar.deb` (not `..._arm64.deb`); L2 SHA/size and L4 Content-Length both match local 130256 B.

合主线：gork.bot协助开发
