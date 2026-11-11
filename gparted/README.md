# GParted (KEMI Linux)

GParted — GNOME partition editor — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **361** |
| package_name | `com.kemi.gparted` |
| dpkg | `kemi-gparted` |
| version | `1.0.0-0.1build1kemi1` / code **100** |
| bytes | 414912 |
| sha256 | `9b1353456bcd3bb8065f7fe5746661b94d0c3c681a335ac8e8ac6439c0ac7a1f` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794400884163_ac885a89_kemi-gparted_1_0_0-0_1build1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal main) `gparted_1.0.0-0.1build1_arm64.deb` v1.0.0 (343672 B, sha256 `0b4f4190b1add58463e75c7b7a7d575fc826a01c05ded39a4aa989e890435514`) plus bundled same-source hard-Depends `gparted-common_1.0.0-0.1build1_all.deb` (80776 B, sha256 `4328f648fd01cd2de485740b202bf754d4262ac493e2f06ea1c0542414af7897`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/g/gparted/` pool files and the Ubuntu 20.04 focal main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates (streamed universe/main updates indexes had 0 gparted stanzas). No librarian URL is recorded this run. Changelog: 1.0.0-0.1build1 uploaded Sat, 21 Mar 2020 13:27:27 +0100 (2020-03-21 20:27:27 Asia/Shanghai). Official launcher is the `/usr/sbin/gparted` POSIX shell wrapper; the ELF is `/usr/sbin/gpartedbin`. The wrapper hardcodes `BASE_CMD="/usr/sbin/gpartedbin $*"` and, for non-root, `pkexec --disable-internal-agent '/usr/sbin/gparted'`. Official polkit already has `org.freedesktop.policykit.exec.path=/usr/sbin/gparted`. The ELF embeds compiled `/usr/share/locale`. Official files therefore stay at `/usr/sbin/gparted` and `/usr/sbin/gpartedbin`; `/opt/gparted/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME System Monitor layout). Also `/usr/bin/kemi-gparted` → `/usr/sbin/gparted`. Official language-pack split: these debs ship no `.mo`; the desktop file itself includes Name/GenericName/Comment/X-GNOME-FullName translations including zh_CN / zh_TW (language packs not bundled). C help is real (2 files: `index.docbook` + figure); other official help locales are symlinks into `/usr/share/help-langpack/` (no zh help in this deb; language packs not bundled). Desktop, official polkit, man, metainfo and icons stay on standard paths. Official desktop already `Exec=/usr/sbin/gparted %f`; KEMI desktop adds `TryExec=/usr/sbin/gparted`. Official desktop `Icon=gparted` (PNG sizes + scalable SVG shipped). Probe: aarch64 · 1 ELF (`/usr/sbin/gpartedbin`) · requiredGlibc **2.17** · GLIBCXX **3.4.21**. Runtime Depends match official Ubuntu 20.04 minus bundled `gparted-common` (GTK3, gtkmm, glibmm, libparted, policykit-1, libc6 ≥ 2.17, libstdc++6). Official Suggests filesystem tools (dosfstools, e2fsprogs, ntfs-3g, xfsprogs, yelp, …) kept as Suggests and not bundled. Official Breaks `udisks2 (<< 2.1.5)` kept. Conflicts/Replaces gparted and gparted-common. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). CDN filename is complete (not truncated). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
