# HexChat (KEMI Linux)

Lightweight GTK2 IRC client (based on X-Chat 2) for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **351** |
| package_name | `com.kemi.hexchat` |
| dpkg | `kemi-hexchat` |
| version | `2.14.3-3ubuntu0.20.04.2kemi1` / code **2143** |
| bytes | 1028028 |
| sha256 | `5ddc08c22290cd65e2ad9bc5a00499a03e320fde0c7dd7b24d3f0aabcb911eaa` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794397084419_c25af783_kemi-hexchat_2_14_3-3ubuntu0_20_04_2kemi.deb |

Notes: official Ubuntu 20.04 (focal-updates) `hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb` v2.14.3 (297544 B, sha256 `f4ffa3993e584bf3da3de14f9999309043bcc6a4759e89a57e6c97ae25268c2e`) plus official arch:all `hexchat-common_2.14.3-3ubuntu0.20.04.2_all.deb` (748712 B, sha256 `563b4b5225b5c54128a1c2cb060b4daddd1cf08fb021dfa704332af2d04d48de`), bundled. Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/h/hexchat/hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb` / `hexchat-common_2.14.3-3ubuntu0.20.04.2_all.deb` and the Ubuntu 20.04 focal-updates universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). Launchpad `getPublishedSources` / `getPublishedBinaries` and source-version HTML timed out this run after the source-package API returned 200, so no librarian URL is recorded. packages.ubuntu.com pages returned a site error. The focal Release pocket still has `2.14.3-3` (Pango Depends ≥ 1.29.4); this package is the current official focal-updates arm64 build (LP: #1920974 font-height with Pango ≥ 1.44; also carries 20.04.1 Libera.Chat default server, LP: #1933681). Layout `/opt/hexchat` + `/usr/bin/hexchat`. 53 locales including zh_CN / zh_TW are bundled from hexchat-common (compiled locale path is `/usr/share/locale`). Desktop, man, hicolor icons, metainfo and D-Bus service stay on standard `/usr/share` paths. Official desktop `Icon=hexchat` (hicolor PNG + SVG shipped). UI is compiled-in as a GResource (`.gresource.hexchat`). Official D-Bus service already `Exec=/usr/bin/hexchat`. Official plugin packages remain Recommends and are not bundled (plugin search path `/usr/lib/aarch64-linux-gnu/hexchat/plugins`). Probe: aarch64 · 1 ELF · requiredGlibc **2.28** · no GLIBCXX · GTK2 + GDK2 + GLib/GIO/GObject/GModule + Pango + GDK-Pixbuf + X11 + libnotify + OpenSSL 1.1 + libproxy + libcanberra + libdbus-glib · PASS vs 101 ≤2.31. Runtime Depends: `libc6 (>= 2.28)`, `libcanberra0 (>= 0.2)`, `libdbus-glib-1-2 (>= 0.88)`, `libgdk-pixbuf2.0-0 (>= 2.25.2)`, `libglib2.0-0 (>= 2.51.0)`, `libgtk2.0-0 (>= 2.24.0)`, `libnotify4 (>= 0.7.0)`, `libpango-1.0-0 (>= 1.44.3)`, `libproxy1v5 (>= 0.4.14)`, `libssl1.1 (>= 1.1.0)`, `libx11-6` — all in Ubuntu 20.04 focal. Recommends: `hexchat-perl`, `hexchat-plugins`, `hexchat-python3`, `libglib2.0-bin`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). CDN filename was truncated by the store to `_2_14_3-3ubuntu0_20_04_2kemi.deb`; SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
