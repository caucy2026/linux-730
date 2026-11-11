# HardInfo (KEMI Linux)

Lightweight GTK2 system profiler and benchmark for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **347** |
| package_name | `com.kemi.hardinfo` |
| dpkg | `kemi-hardinfo` |
| version | `0.5.1+git20180227-2kemi1` / code **20180227** |
| bytes | 306936 |
| sha256 | `34ab2f9398a7fb4f2bb47b28b13241734fcd7abbbf83cc15f078b996e58c1b2d` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794394505039_2384059c_kemi-hardinfo_0_5_1_git20180227-2kemi1_a.deb |

Notes: official Ubuntu 20.04 (focal) Release `hardinfo_0.5.1+git20180227-2_arm64.deb` v0.5.1+git20180227-2 (308068 B, sha256 `2c176cff53480e177cfcdf4c7a8e6de9ec3ae990bb2ed3f9bd5c7fc823de5a5b`). Launchpad published `hardinfo 0.5.1+git20180227-2 in focal arm64` (universe, Release, binarypub 131879191, published 2019-10-18 17:15:30 Asia/Shanghai; copied from ubuntu disco-proposed arm64). Official file URL: https://launchpad.net/ubuntu/+source/hardinfo/0.5.1+git20180227-2/+build/16201624/+files/hardinfo_0.5.1+git20180227-2_arm64.deb (librarian https://launchpadlibrarian.net/403204812/hardinfo_0.5.1+git20180227-2_arm64.deb; official `.changes` SHA256 matched Aliyun ubuntu-ports mirror and in-memory librarian hash). The arm64 binary was built in ubuntu disco PROPOSED (build 16201624, Successfully built 2018-12-25 03:14:59 Asia/Shanghai) and published to focal Release (Launchpad HTML: "arm64 build of hardinfo 0.5.1+git20180227-2 in ubuntu disco PROPOSED"). Official ELF stays at `/usr/bin/hardinfo` because the binary embeds binreloc (`/proc/self/exe`, `/proc/self/maps`) plus compiled-in prefixes `/usr/lib/aarch64-linux-gnu/hardinfo`, `/usr/share/hardinfo` and `/usr/share/locale`. Modules, pixmaps, benchmark data, help and locales stay on those standard paths. `/opt/hardinfo/hardinfo` is a symlink to `/usr/bin/hardinfo`. Official desktop `Exec=/usr/bin/hardinfo`; `Icon=/usr/share/hardinfo/pixmaps/logo.png` (pixmap shipped). Official locales: de, es, fr, ru (this deb ships no zh `.mo`). Probe: aarch64 · 5 ELF · requiredGlibc **2.27** (main) / **2.17** (4 modules) · no GLIBCXX · GTK2 + GDK-Pixbuf + Pango + GLib. Runtime Depends: `pciutils (>= 1:2.1.11-10)`, `zlib1g-dev`, `libc6 (>= 2.27)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.43.2)`, `libgtk2.0-0 (>= 2.18.0)`, `libpango-1.0-0 (>= 1.14.0)` — all in Ubuntu 20.04 focal. Recommends: `lm-sensors`. Suggests: `mesa-utils`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
