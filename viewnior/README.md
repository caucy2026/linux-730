# Viewnior (KEMI Linux)

Lightweight GTK2 image viewer for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **330** |
| package_name | `com.kemi.viewnior` |
| dpkg | `kemi-viewnior` |
| version | `1.6-1build2kemi1` / code **16** |
| bytes | 115244 |
| sha256 | `0a20d22a9d2ea228df383aba887194c8a5501b0674c72838a035fd8cd2e334bf` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794387163256_8d3f5c91_kemi-viewnior_1_6-1build2kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `viewnior_1.6-1build2_arm64.deb` v1.6 (115732 B, sha256 `d6fd4aa6b5572b1364e4c1aa03ac67852d858d7f34bef2eed44d3af7db9b8e9f`). Launchpad published `viewnior 1.6-1build2 in focal arm64` (universe, binarypub 137820446, published 2020-02-13 21:58 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/viewnior_1.6-1build2_arm64.deb (librarian https://launchpadlibrarian.net/463543901/viewnior_1.6-1build2_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad librarian). Installs under `/opt/viewnior/` + `/usr/bin/viewnior` (symlink to `/opt/viewnior/viewnior`). UI and pixmaps stay at compiled-in `/usr/share/viewnior/*.ui` and `/usr/share/viewnior/pixmaps/`; locales, icons, pixmap, and man page stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · requiredGlibcxx **3.4.21** · GTK2. Runtime Depends: `libc6 (>= 2.17)`, `libexiv2-27 (>= 0.27.2)`, `libgcc-s1 (>= 3.0)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk2.0-0 (>= 2.20.0)`, `libstdc++6 (>= 5.2)` — all in Ubuntu 20.04 focal arm64. Recipe-only; no `.deb` in git. L1–L4 PASS (L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
