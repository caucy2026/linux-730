# Xpad (KEMI Linux)

Lightweight GTK3 sticky-note / post-it app for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **348** |
| package_name | `com.kemi.xpad` |
| dpkg | `kemi-xpad` |
| version | `5.4.0-1kemi1` / code **540** |
| bytes | 88252 |
| sha256 | `7fa4403aececb37ac8d8dd9e39f8065b4b9e96d3599a5d91e1f44050aa163273` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794395176975_3b773b0b_kemi-xpad_5_4_0-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `xpad_5.4.0-1_arm64.deb` v5.4.0 (88092 B, sha256 `8e6c27741b886779a110b9489f3064dcc61d09a84d7bc5f3642f75ece161f181`). Launchpad published `xpad 5.4.0-1 in focal arm64` (universe, Release, Focal release on 2019-10-18). Official file URLs: https://launchpad.net/ubuntu/+archive/primary/+files/xpad_5.4.0-1_arm64.deb and librarian https://launchpadlibrarian.net/436304758/xpad_5.4.0-1_arm64.deb; fetched via Aliyun ubuntu-ports (`https://mirrors.aliyun.com/ubuntu-ports/pool/universe/x/xpad/xpad_5.4.0-1_arm64.deb`); SHA + size matched official Launchpad `.buildinfo` (`https://launchpadlibrarian.net/436304755/xpad_5.4.0-1_arm64.buildinfo`: `8e6c2774… 88092 xpad_5.4.0-1_arm64.deb`) and the in-memory librarian / `+files` hashes. The arm64 binary was built in ubuntu eoan PROPOSED (build 17381069, Successfully built 2019-08-07 13:15:10 Asia/Shanghai on bos02-arm64-042; duration 3m49.9s) and published to focal Release (Launchpad HTML: "arm64 build of xpad 5.4.0-1 in ubuntu eoan PROPOSED"). Official ELF stays at `/usr/bin/xpad` because the binary embeds binreloc (`br_extract_prefix`, `%s/share/applications`) plus compiled-in prefixes `/usr/share/xpad/help`, `/usr/share/locale` and `/usr/share/icons`. Help, 28 locales (including zh_CN / zh_TW), hicolor scalable `xpad.svg`, desktop, man and metainfo stay on standard `/usr/share` paths. `/opt/xpad/xpad` is a symlink to `/usr/bin/xpad`. Official desktop `Icon=xpad` (hicolor svg shipped). KEMI desktop uses `Exec=/usr/bin/xpad` and `TryExec=/usr/bin/xpad`. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · no GLIBCXX · libSM + libICE + GTK3 + GDK3 + Pango + GIO + GObject + GLib + GtkSourceView 3. Runtime Depends: `libc6 (>= 2.17)`, `libglib2.0-0 (>= 2.56)`, `libgtk-3-0 (>= 3.22)`, `libgtksourceview-3.0-1 (>= 3.22)`, `libice6 (>= 1:1.0.0)`, `libpango-1.0-0 (>= 1.14.0)`, `libsm6` — all in Ubuntu 20.04 focal. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
