# Xfburn (KEMI Linux)

CD/DVD burner for the Xfce desktop, packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **357** |
| package_name | `com.kemi.xfburn` |
| dpkg | `kemi-xfburn` |
| version | `0.6.2-1kemi1` / code **62** |
| bytes | 409708 |
| sha256 | `3eb507184973fa9426cd96ff27597f7280f2539e7d539cd8af76a532c524cd68` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794399513306_69feda44_kemi-xfburn_0_6_2-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `xfburn_0.6.2-1_arm64.deb` v0.6.2 (419576 B, sha256 `dc56ae4b5db13e99434a5f4989956198e8089cd79d5f64bcfa229dcf14a8c61c`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/x/xfburn/` pool files and the Ubuntu 20.04 focal universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates. No librarian URL is recorded this run. There is no xfburn-common / xfburn-data package; this is a single official binary package. The official ELF embeds compiled `/usr` prefixes (`/usr/share/locale`; UI files looked up as `xfburn/xfburn.ui` under `/usr/share`), so it stays at `/usr/bin/xfburn`; `/opt/xfburn/xfburn` is only a symlink (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes layout). 57 locales including zh_CN / zh_TW are bundled. Desktop, official Thunar sendto, man page, metainfo and icons stay on standard `/usr/share` paths. Official desktop `Icon=stock_xfburn` (icons shipped under hicolor stock/media, including scalable SVG). Probe: aarch64 · 1 ELF · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, libexo-2, libxfce4ui-2, libxfce4util7, libburn4, libisofs6, GStreamer 1.0, libgudev, libc6 ≥ 2.17). Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
