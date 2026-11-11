# Transmission GTK (KEMI Linux)

Lightweight GTK3 BitTorrent client for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **352** |
| package_name | `com.kemi.transmission-gtk` |
| dpkg | `kemi-transmission-gtk` |
| version | `2.94-2ubuntu3kemi1` / code **294** |
| bytes | 523880 |
| sha256 | `e2efb4dced1dad0bedb3b35da458faea3b6e08c99132c04c2e3979edb569a78d` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794397515709_41b86e78_kemi-transmission-gtk_2_94-2ubuntu3kemi1.deb |

Notes: official Ubuntu 20.04 (focal) `transmission-gtk_2.94-2ubuntu3_arm64.deb` v2.94 (297004 B, sha256 `424a3cffc276ef11172279e105aa2366150b470a2276e6eb7699dd40df10f6c9`) plus official arch:all `transmission-common_2.94-2ubuntu3_all.deb` (236904 B, sha256 `e7afb10bde483400384d4515393eefa652250e3500aba2ac514f1886c722651d`), bundled. Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/t/transmission/transmission-gtk_2.94-2ubuntu3_arm64.deb` / `transmission-common_2.94-2ubuntu3_all.deb` and the Ubuntu 20.04 focal main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). These packages are in main (not universe). There is no newer binary in focal-updates. Launchpad HTML/API timed out this run and packages.ubuntu.com returned a site error, so no librarian URL is recorded. Layout `/opt/transmission-gtk` + `/usr/bin/transmission-gtk`. This official deb ships no locale `.mo` (compiled locale path is `/usr/share/locale`; desktop has `X-Ubuntu-Gettext-Domain=transmission`). Desktop, man, hicolor icons, pixmaps, mime and web assets stay on standard `/usr/share` and `/usr/lib/mime` paths. Official desktop `Icon=transmission` (hicolor PNG + SVG shipped). UI is compiled-in as a GResource (`.gresource.transmission`). Web UI assets from transmission-common stay at `/usr/share/transmission`. Probe: aarch64 · 1 ELF · requiredGlibc **2.29** · no GLIBCXX · GTK3 + GDK3 + GLib/GIO/GObject + Pango + GDK-Pixbuf + libappindicator3 + libevent-2.1 + libcurl + libcrypto 1.1 + libminiupnpc + libnatpmp · PASS vs 101 ≤2.31. Runtime Depends: `libappindicator3-1 (>= 0.4.90)`, `libc6 (>= 2.29)`, `libcurl4 (>= 7.18.0)`, `libevent-2.1-7 (>= 2.1.8-stable)`, `libgdk-pixbuf2.0-0 (>= 2.25.2)`, `libglib2.0-0 (>= 2.37.3)`, `libgtk-3-0 (>= 3.3.16)`, `libminiupnpc17 (>= 1.9.20140610)`, `libnatpmp1 (>= 20150609)`, `libpango-1.0-0 (>= 1.14.0)`, `libssl1.1 (>= 1.1.0)`, `zlib1g (>= 1:1.1.4)` — all in Ubuntu 20.04 focal. Recommends: `xdg-utils`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). CDN filename was truncated by the store to `_2_94-2ubuntu3kemi1.deb` (no `_arm64`); SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
