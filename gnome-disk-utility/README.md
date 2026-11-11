# GNOME Disks (KEMI Linux)

GNOME Disks (gnome-disk-utility) — manage and configure disk drives and media — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **359** |
| package_name | `com.kemi.gnome-disk-utility` |
| dpkg | `kemi-gnome-disk-utility` |
| version | `3.36.3-0ubuntu1kemi1` / code **3363** |
| bytes | 156524 |
| sha256 | `b37a3f636ae0cc1c909bfa7b75a25e71b49e79545987e821b373eb0bb69f1cd2` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794400217173_d47bb00f_kemi-gnome-disk-utility_3_36_3-0ubuntu1k.deb |

Notes: official Ubuntu 20.04 (focal-updates main) `gnome-disk-utility_3.36.3-0ubuntu1_arm64.deb` v3.36.3 (172072 B, sha256 `bb7ee1bb1d95a856b9a5df548b37ba726c5ec6de40be6ae12667568ef43ebab6`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/g/gnome-disk-utility/` pool files and the Ubuntu 20.04 focal-updates main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). This is newer than focal Release `3.36.1-1ubuntu1` and remains U20-compatible (same Depends, libc6 ≥ 2.17). No librarian URL is recorded this run. There is no gnome-disk-utility-common / data or typelib package; this is a single official binary package. Official binaries are `gnome-disks`, `gnome-disk-image-mounter` and `/usr/libexec/gsd-disk-utility-notify`. The official ELFs embed compiled `/usr/share/locale` (gettext); UI files are GResource paths under `/org/gnome/Disks/ui/` (embedded in gnome-disks). Strings `/usr`, `/usr/local` and `/opt` inside gnome-disks are fstab mount-point suggestions, not the install prefix. Official ELFs therefore stay at `/usr/bin` and `/usr/libexec`; `/opt/gnome-disk-utility/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole layout). Official language-pack split: these debs ship no `.mo`; desktop files use `X-Ubuntu-Gettext-Domain=gnome-disk-utility` (language packs not bundled). Desktop, official D-Bus service (`Exec=/usr/bin/gnome-disks --gapplication-service`), official autostart conffile (`OnlyShowIn=GNOME;`, `NoDisplay=true`), gschema, man and metainfo stay on standard paths. Official desktop `Icon=org.gnome.DiskUtility` (SVG shipped). Probe: aarch64 · 3 ELF · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (udisks2, GTK3, libcanberra-gtk3, pango, cairo, libnotify, libsecret, libpwquality, liblzma, libsystemd, libudisks2, dconf/gsettings backend, libc6 ≥ 2.17). Official Breaks `gnome-settings-daemon (<< 3.24)` kept. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). Store truncated the CDN filename to `…_3_36_3-0ubuntu1k.deb`; SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
