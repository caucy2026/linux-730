# LXTerminal (KEMI Linux)

Lightweight VTE-based GTK3 LXDE terminal emulator for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **338** |
| package_name | `com.kemi.lxterminal` |
| dpkg | `kemi-lxterminal` |
| version | `0.3.2-1kemi1` / code **32** |
| bytes | 86076 |
| sha256 | `cd5085e075287e26b681e41746fc57167c8a839345fdb1da7492a6f7c5b63753` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794390133964_2d39f233_kemi-lxterminal_0_3_2-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `lxterminal_0.3.2-1_arm64.deb` v0.3.2 (87584 B, sha256 `39c2981d3dd275b4deba0e35220546c756815743ab96009715eabe2229f8c1d9`). Launchpad published `lxterminal 0.3.2-1 in focal arm64` (universe, Release, binarypub 131890525, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/lxterminal_0.3.2-1_arm64.deb (librarian https://launchpadlibrarian.net/390445325/lxterminal_0.3.2-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in cosmic and copied unchanged into focal Release. Installs under `/opt/lxterminal/` + `/usr/bin/lxterminal` (symlink to `/opt/lxterminal/lxterminal`). Compiled-in `/usr/share/lxterminal/` data and `/usr/share/icons/hicolor/128x128/apps/lxterminal.png`, plus locales, desktop and man, stay on standard `/usr/share` paths. Official desktop `Icon=lxterminal` (hicolor 128x128 pixmap shipped in the official deb). Ubuntu apport hook omitted. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3 + VTE + gdk-pixbuf + pango + GLib. Runtime Depends: `libc6 (>= 2.17)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.28.0)`, `libgtk-3-0 (>= 3.3.16)`, `libpango-1.0-0 (>= 1.14.0)`, `libvte-2.91-0` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
