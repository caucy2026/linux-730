# Xfce4 Dict (KEMI Linux)

Lightweight GTK3 dictionary client and Xfce panel plugin for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **341** |
| package_name | `com.kemi.xfce4-dict` |
| dpkg | `kemi-xfce4-dict` |
| version | `0.8.3-1kemi1` / code **83** |
| bytes | 147200 |
| sha256 | `588258646b699c82aac78931635c130141d525768c2805aa9396c80e809251b2` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794391133835_77244d8d_kemi-xfce4-dict_0_8_3-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `xfce4-dict_0.8.3-1_arm64.deb` v0.8.3 (147964 B, sha256 `f397846d0f4ff27292431b8600003e1e2c904d9d734c98db029f4fd02562625d`). Launchpad published `xfce4-dict 0.8.3-1 in focal arm64` (universe, Release, binarypub 132713581, published 2019-10-26 18:03:27 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/xfce4-dict_0.8.3-1_arm64.deb (librarian https://launchpadlibrarian.net/448545521/xfce4-dict_0.8.3-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu focal PROPOSED (build 17974220) and published to Release. Installs under `/opt/xfce4-dict/` + `/usr/bin/xfce4-dict` (symlink to `/opt/xfce4-dict/xfce4-dict`). XFCE panel plugin stays on standard `/usr/lib/aarch64-linux-gnu/xfce4/panel/plugins/libxfce4dict.so` and `/usr/share/xfce4/panel/plugins/xfce4-dict-plugin.desktop` paths. Locales, desktop, man and hicolor icon stay on standard `/usr/share` paths. Official desktop `Icon=xfce4-dict`. Probe: aarch64 · requiredGlibc **2.17** (2 ELF: main binary + panel plugin) · no GLIBCXX · GTK3 + GDK3 + Pango + GdkPixbuf + GIO/GObject/GLib + libxfce4ui + libxfce4util + (plugin) libX11 + libxfce4panel. Runtime Depends: `libc6 (>= 2.17)`, `libgdk-pixbuf2.0-0 (>= 2.25.2)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.19.12)`, `libpango-1.0-0 (>= 1.14.0)`, `libx11-6`, `libxfce4panel-2.0-4 (>= 4.13.0)`, `libxfce4ui-2-0 (>= 4.13.0)`, `libxfce4util7 (>= 4.9.0)` — all in Ubuntu 20.04 focal. Recommends: `aspell | ispell`. Provides: `dict-client`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
