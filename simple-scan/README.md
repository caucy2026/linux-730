# Simple Scan (KEMI Linux)

Lightweight GTK3 document scanner (SANE frontend) for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **350** |
| package_name | `com.kemi.simple-scan` |
| dpkg | `kemi-simple-scan` |
| version | `3.36.3-0ubuntu0.20.04.0kemi1` / code **3363** |
| bytes | 169508 |
| sha256 | `3cde6b046673ae284d9d47aaba3477155b8a5d53570f7f97908181dad96bb0a7` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794396569760_8a4a9b95_kemi-simple-scan_3_36_3-0ubuntu0_20_04_0.deb |

Notes: official Ubuntu 20.04 (focal-updates) `simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb` v3.36.3 (170116 B, sha256 `9444d1407873a810ebbc9c09e0ca5606e10b63e952c50e1be3eaece94c1af4bc`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/s/simple-scan/simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb` and the Ubuntu 20.04 focal-updates main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). Launchpad HTML/API were retried this run but Launchpad returned 503, so no librarian URL is recorded. The focal Release pocket still has `3.36.0-0ubuntu1` with the same Depends; this package is the current official focal-updates arm64 build (LP: #1883819). Layout `/opt/simple-scan` + `/usr/bin/simple-scan`. Official C help is bundled; non-C help entries remain official symlinks into `/usr/share/help-langpack` (zh_TW is a langpack symlink; this deb has no zh_CN help dir). This official deb ships no locale `.mo` (compiled locale path is `/usr/share/locale`). Desktop, man, hicolor icons, GSettings schema and metainfo stay on standard `/usr/share` paths. Official desktop `Icon=org.gnome.SimpleScan` (hicolor SVG shipped). UI is compiled-in as a GResource (`/org/gnome/SimpleScan/*.ui`). Probe: aarch64 · 1 ELF · requiredGlibc **2.17** · no GLIBCXX · GTK3 + GLib + Cairo + GDK-Pixbuf + SANE + colord + PackageKit + libgusb + libwebp. Runtime Depends: `default-dbus-session-bus | dbus-session-bus`, `xdg-utils`, `dconf-gsettings-backend | gsettings-backend`, `libc6 (>= 2.17)`, `libcairo2 (>= 1.4.10)`, `libcolord2 (>= 0.1.10)`, `libgdk-pixbuf2.0-0 (>= 2.22.0)`, `libglib2.0-0 (>= 2.43.92)`, `libgtk-3-0 (>= 3.21.5)`, `libgusb2 (>= 0.2.2)`, `libpackagekit-glib2-18 (>= 0.9.4)`, `libsane (>= 1.0.24)`, `libwebp6 (>= 0.5.1)`, `libwebpmux3 (>= 0.6.1-2)`, `zlib1g (>= 1:1.1.4)` — all in Ubuntu 20.04 focal. Recommends: `yelp`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). CDN filename was truncated by the store to `_3_36_3-0ubuntu0_20_04_0.deb`; SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
