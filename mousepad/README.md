# Mousepad (KEMI Linux)

Lightweight Xfce-oriented GTK3 text editor for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **328** |
| package_name | `com.kemi.mousepad` |
| dpkg | `kemi-mousepad` |
| version | `0.4.2-1kemi1` / code **42** |
| bytes | 259220 |
| sha256 | `65211ddf0fbe885cd4fcf31e49b1d03b46d32fedad5299da810513035d141dd1` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794386554104_ab8d37fa_kemi-mousepad_0_4_2-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `mousepad_0.4.2-1_arm64.deb` v0.4.2 (262616 B, sha256 `9196953da1f1a9fc6dceebaea005d5b2456ef155d39f55d9182eed7a5e5af6bf`). Launchpad published `mousepad 0.4.2-1 in focal arm64` (universe). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/mousepad_0.4.2-1_arm64.deb (fetched via ubuntu-ports mirror). Installs under `/opt/mousepad/` + `/usr/bin/mousepad` (symlink to `/opt/mousepad/mousepad`). GSettings schema stays at `/usr/share/glib-2.0/schemas/org.xfce.mousepad.gschema.xml`; locales, man page, and polkit policy stay on standard `/usr/share` paths. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · GTK3. Runtime Depends: `libc6 (>= 2.17)`, `libgtk-3-0 (>= 3.16.2)`, `libgtksourceview-3.0-1 (>= 2.91.4)`, `libglib2.0-0 (>= 2.41.1)`, `libpango-1.0-0 (>= 1.14.0)`, `libxfconf-0-3 (>= 4.6.0)`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal arm64. Desktop icon is the stock `accessories-text-editor` (no bundled icon). Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
