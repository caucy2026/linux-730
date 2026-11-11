# GNOME System Monitor (KEMI Linux)

GNOME System Monitor — process viewer and system resource monitor — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). LXTask app337 already exists (different desktop / toolchain).

| field | value |
|---|---|
| app_id | **360** |
| package_name | `com.kemi.gnome-system-monitor` |
| dpkg | `kemi-gnome-system-monitor` |
| version | `3.36.1-0ubuntu0.20.04.1kemi1` / code **3361** |
| bytes | 153240 |
| sha256 | `0633f6d5dfe563394cea60420ea7626b7c9764d9782062df1629af1492ddb9c7` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794400562556_5bdb92eb_kemi-gnome-system-monitor_3_36_1-0ubuntu.deb |

Notes: official Ubuntu 20.04 (focal-updates main) `gnome-system-monitor_3.36.1-0ubuntu0.20.04.1_arm64.deb` v3.36.1 (171468 B, sha256 `6c14c73054c0a21d122ef52bb8153f029de4fc4690220cc9a8a091be82e99b3f`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/g/gnome-system-monitor/` pool files and the Ubuntu 20.04 focal-updates main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). This is newer than focal Release `3.36.0-1` and remains U20-compatible (Depends libc6 ≥ 2.29). No librarian URL is recorded this run. There is no gnome-system-monitor-common / data or typelib package; this is a single official binary package. Official binaries are `/usr/bin/gnome-system-monitor` plus pkexec helpers `/usr/libexec/gnome-system-monitor/{gsm-kill,gsm-renice}`. The official main ELF embeds compiled `/usr` prefixes (`/usr/share/locale`, `/usr/share/gnome-system-monitor/gsm.gresource`, `/usr/libexec/gnome-system-monitor`, `/usr/bin/pkexec`), so official ELFs stay at `/usr/bin` and `/usr/libexec`; `/opt/gnome-system-monitor/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks layout). Official polkit policy already points at those absolute libexec paths. Official language-pack split: these debs ship no `.mo`; desktop files use `X-Ubuntu-Gettext-Domain=gnome-system-monitor` (language packs not bundled). C help is real (26 files); other official help locales are symlinks into `/usr/share/help-langpack/` (no zh help in this deb; language packs not bundled). Desktop, gschema, gresource, man, metainfo and icons stay on standard paths. Official desktop `Icon=org.gnome.SystemMonitor` (SVG shipped). Official main desktop `NotShowIn=KDE;`; KDE variant `OnlyShowIn=KDE;`. Probe: aarch64 · 3 ELF · gnome-system-monitor requiredGlibc **2.29** · GLIBCXX **3.4.21** · gsm-kill / gsm-renice requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, gtkmm, glibmm, libgtop, librsvg, libsigc++, libsystemd, libc6 ≥ 2.29, libstdc++6). Official Recommends `gvfs` kept as Recommends and not bundled. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). Store truncated the CDN filename to `…_3_36_1-0ubuntu.deb`; SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
