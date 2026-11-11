# Parole (KEMI Linux)

Media player for the Xfce desktop based on the GStreamer framework, packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **358** |
| package_name | `com.kemi.parole` |
| dpkg | `kemi-parole` |
| version | `1.0.5-1kemi1` / code **105** |
| bytes | 354360 |
| sha256 | `2cd86b8484b8bc59daf6626777a2511af4459044a4f89d6622d80be4389319d9` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794399885361_388a204e_kemi-parole_1_0_5-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `parole_1.0.5-1_arm64.deb` v1.0.5 (355100 B, sha256 `8a752b8218de210ea9dd14e542b439136f20ea320ffdf3a21a4d3d763edb4efe`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/p/parole/` pool files and the Ubuntu 20.04 focal universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates. No librarian URL is recorded this run. There is no parole-common / parole-data package; this is a single official binary package. Same-source `parole-dev` is a development-headers package and is not a hard Depends — not bundled. Official plugins (MPRIS2, tray-icon, notify) ship inside the official parole deb and stay at `/usr/lib/aarch64-linux-gnu/parole-0/`. The official ELFs embed compiled `/usr` prefixes (`/usr/share/locale`, `/usr/share/parole/pixmaps`, `/usr/share/parole/parole-plugins-0`, `/usr/lib/aarch64-linux-gnu/parole-0`, `/usr/share/applications/org.xfce.Parole.desktop`), so the launcher stays at `/usr/bin/parole`; `/opt/parole/parole` is only a symlink (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn layout). 50 locales including zh_CN / zh_TW are bundled. Desktop, man page, metainfo, icons and pixmaps stay on standard `/usr/share` paths. Official desktop `Icon=parole` (icons shipped under hicolor apps, including scalable SVG). Probe: aarch64 · 4 ELF · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, GStreamer plugins and libs, libxfce4ui-2, libxfce4util7, libxfconf, cairo, dbus, libnotify, libtagc0, libx11, libc6 ≥ 2.17). Official Suggests `gstreamer1.0-plugins-bad` / `gstreamer1.0-plugins-ugly` are kept as Suggests and not bundled. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
