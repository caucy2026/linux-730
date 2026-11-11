# GtkHash (KEMI Linux)

Lightweight GTK3 checksum / message-digest calculator for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **340** |
| package_name | `com.kemi.gtkhash` |
| dpkg | `kemi-gtkhash` |
| version | `1.2-1build1kemi1` / code **12** |
| bytes | 91640 |
| sha256 | `a042370461171bdc87f233e0e07bed4029e266075ee0b164080f5cc5a6f361f6` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794390761117_c0b35566_kemi-gtkhash_1_2-1build1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `gtkhash_1.2-1build1_arm64.deb` v1.2 (91516 B, sha256 `07a0e285e7a6fb06443ac48061feaf5240b88404b344d9acb7578db0141b022b`). Launchpad published `gtkhash 1.2-1build1 in focal arm64` (universe, Release, binarypub 133323897, published 2019-11-07 17:58:21 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/gtkhash_1.2-1build1_arm64.deb (librarian https://launchpadlibrarian.net/449391385/gtkhash_1.2-1build1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu focal PROPOSED (no-change rebuild against libnettle7, build 18005769) and published to Release. Installs under `/opt/gtkhash/` + `/usr/bin/gtkhash` (symlink to `/opt/gtkhash/gtkhash`). Locales, desktop, man, hicolor/pixmap icons, metainfo and GSettings schemas stay on standard `/usr/share` paths. Official desktop `Icon=gtkhash`. File-manager plugins (caja/nautilus/nemo/thunar-gtkhash) not bundled. `gtkhash-common` is not in focal (data lives in this deb; Breaks/Replaces `gtkhash-common (<< 1.0-1)` kept). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · libb2 + libgcrypt + libnettle.so.7 + zlib + GTK3 + GDK3 + GIO/GObject/GLib. Runtime Depends: `libb2-1 (>= 0.98.1)`, `libc6 (>= 2.17)`, `libgcrypt20 (>= 1.8.0)`, `libglib2.0-0 (>= 2.35.8)`, `libgtk-3-0 (>= 3.21.5)`, `libnettle7`, `zlib1g (>= 1:1.1.4)`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
