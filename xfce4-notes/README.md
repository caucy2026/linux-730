# XFCE Notes (KEMI Linux)

Notes application for the Xfce desktop, packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **356** |
| package_name | `com.kemi.xfce4-notes` |
| dpkg | `kemi-xfce4-notes` |
| version | `1.8.1-3kemi1` / code **181** |
| bytes | 94576 |
| sha256 | `b9610ba12e3b0a7065a52d1fdff96006eb1b4aef806064d369fbbc37a037db80` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794399212576_90de4674_kemi-xfce4-notes_1_8_1-3kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `xfce4-notes_1.8.1-3_arm64.deb` v1.8.1 (96036 B, sha256 `6b49e0cf9fd79aaf6e6ddd1f2663192be1a8dc9b788e102ee9fc9535e39de54e`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/x/xfce4-notes-plugin/` pool files and the Ubuntu 20.04 focal universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates. No librarian URL is recorded this run. There is no notes-common / notes-data package. Same-source `xfce4-notes-plugin` is a panel plugin that Depends on `xfce4-notes` and `xfce4-panel` (>= 4.13, << 4.15); it is not a hard Depends of xfce4-notes and is not bundled. The official ELFs embed compiled `/usr` prefixes (`/usr/share/locale`, `/usr/share/xfce4-notes-plugin`), so they stay at `/usr/bin/xfce4-notes`, `/usr/bin/xfce4-notes-settings` and `/usr/bin/xfce4-popup-notes`; `/opt/xfce4-notes/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit layout). 48 locales including zh_CN / zh_TW are bundled (gettext domain `xfce4-notes-plugin.mo`). Desktop, official autostart conffile (`Hidden=true`), icons and GTK2 theme data stay on standard `/usr/share` and `/etc/xdg` paths. Official desktop `Icon=xfce4-notes-plugin` (icons shipped). Official desktop `OnlyShowIn=XFCE;GNOME;` is kept. Probe: aarch64 · 3 ELF · xfce4-notes / settings requiredGlibc **2.29** · popup requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK2, libunique, libxfce4ui-1, libxfce4util7, libxfconf, cairo, pango, gdk-pixbuf, libc6 ≥ 2.29). Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
