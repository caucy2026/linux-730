# GHex (KEMI Linux)

Lightweight GTK3 hex/ASCII file editor for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **344** |
| package_name | `com.kemi.ghex` |
| dpkg | `kemi-ghex` |
| version | `3.18.4-1kemi1` / code **3184** |
| bytes | 228696 |
| sha256 | `a878f77e0136fd10f2c71a417e9e67ee9ef020de7ceef0799fbee2a5a0cdff43` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794392103025_8ad002d4_kemi-ghex_3_18_4-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `ghex_3.18.4-1_arm64.deb` v3.18.4 (234188 B, sha256 `71092110d9afecdb46043bc93ea06c3f5c1fe540d87912494a0f69cb309a269e`). Launchpad published `ghex 3.18.4-1 in focal arm64` (universe, Release, binarypub 131878893, published 2019-10-18 17:15:30 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/ghex_3.18.4-1_arm64.deb (librarian https://launchpadlibrarian.net/443808330/ghex_3.18.4-1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu eoan PROPOSED (build 17805238) and copied to focal Release (Launchpad HTML: Copied from ubuntu eoan-proposed arm64). Installs under `/opt/ghex/` + `/usr/bin/ghex` (symlink to `/opt/ghex/ghex`). Help, desktop, man, hicolor icons, GSettings schema and metainfo stay on standard `/usr/share` paths. Official desktop `Icon=org.gnome.GHex` (hicolor shipped in this deb). UI is compiled-in as a GResource (`/org/gnome/ghex/ghex-ui.xml`). This official deb ships no locale `.mo` files (compiled locale path is `/usr/share/locale`). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · libgtkhex-3 + ATK + GObject/GLib/GIO + GTK3 + GDK3 + PangoCairo + Pango + Cairo. Runtime Depends: `libatk1.0-0 (>= 1.12.4)`, `libc6 (>= 2.17)`, `libcairo2 (>= 1.2.4)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.3.16)`, `libgtkhex-3-0 (>= 3.0.0)`, `libpango-1.0-0 (>= 1.14.0)`, `libpangocairo-1.0-0 (>= 1.14.0)`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
