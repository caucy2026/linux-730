# mtPaint (KEMI Linux)

Lightweight GTK2 pixel-art and photo editor for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **336** |
| package_name | `com.kemi.mtpaint` |
| dpkg | `kemi-mtpaint` |
| version | `3.40-3kemi1` / code **3403** |
| bytes | 471488 |
| sha256 | `eb4652cafebb78317fa8f2010f46f634c3bf3d5bc4b58ced423952d623b22512` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794388905702_ea66ac1e_kemi-mtpaint_3_40-3kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `mtpaint_3.40-3_arm64.deb` v3.40 (471572 B, sha256 `6440875684c8145a84b9bb6e213c71e9d79b6f6c16a3342b3b3d79e76a1c1adf`). Launchpad published `mtpaint 3.40-3 in focal arm64` (universe, Release, binarypub 131887801, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/mtpaint_3.40-3_arm64.deb (librarian https://launchpadlibrarian.net/256588308/mtpaint_3.40-3_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in yakkety and copied unchanged into focal Release. Installs under `/opt/mtpaint/` + `/usr/bin/mtpaint` (symlink to `/opt/mtpaint/mtpaint`). No compiled-in `/usr/share/mtpaint` data directory; locales, pixmap, desktop and man stay on standard `/usr/share` paths. Optional handbook `/usr/share/doc/mtpaint/index.html` is not shipped by the official deb. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK2 + gif/tiff/jpeg/png/freetype. Runtime Depends: `libc6 (>= 2.17)`, `libfreetype6 (>= 2.2.1)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libgif7 (>= 5.1)`, `libglib2.0-0 (>= 2.31.8)`, `libgtk2.0-0 (>= 2.24.0)`, `libjpeg8 (>= 8c)`, `libpango-1.0-0 (>= 1.14.0)`, `libpng16-16 (>= 1.6.2-1)`, `libtiff5 (>= 4.0.3)`, `libx11-6`, `zlib1g (>= 1:1.2.0)`, `gtklp` — all in Ubuntu 20.04 focal (`gtklp` is universe). Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
