# Galculator (KEMI Linux)

Lightweight GTK3 scientific calculator for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **329** |
| package_name | `com.kemi.galculator` |
| dpkg | `kemi-galculator` |
| version | `2.1.4-1build1kemi1` / code **214** |
| bytes | 142968 |
| sha256 | `2763cbd2a7c89bd90f32f0afd1bfb9b4647be483946520d8a6aff05c89d92669` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794386906806_b5347532_kemi-galculator_2_1_4-1build1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `galculator_2.1.4-1build1_arm64.deb` v2.1.4 (144124 B, sha256 `79f10042654a049fc77c523bef6c645a2fdba2f5f91d1ad5fd11a265ea9c1f9b`). Launchpad published `galculator 2.1.4-1build1 in focal arm64` (universe). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/galculator_2.1.4-1build1_arm64.deb (fetched via ubuntu-ports mirror; SHA matched Launchpad librarian). Installs under `/opt/galculator/` + `/usr/bin/galculator` (symlink to `/opt/galculator/galculator`). UI files stay at compiled-in `/usr/share/galculator/ui/*.ui`; locales, icons, pixmaps, man page, appdata, and menu stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3. Runtime Depends: `libc6 (>= 2.17)`, `libgtk-3-0 (>= 3.3.16)`, `libglib2.0-0 (>= 2.16.0)`, `libpango-1.0-0 (>= 1.14.0)` — all in Ubuntu 20.04 focal arm64. Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
