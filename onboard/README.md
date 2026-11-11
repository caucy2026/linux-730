# Onboard (KEMI Linux)

Flexible on-screen keyboard for KEMI mall (arm64, Ubuntu 20.04 / 101, Python 3.8).

| field | value |
|---|---|
| app_id | **353** |
| package_name | `com.kemi.onboard` |
| dpkg | `kemi-onboard` |
| version | `1.4.1-2ubuntu7kemi1` / code **141** |
| bytes | 4639956 |
| sha256 | `a06c7f112d02c3895a60bd9e2f05d3cda1e1fd6c91dc78abd52d2fc052539b93` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794397866450_9cbad263_kemi-onboard_1_4_1-2ubuntu7kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `onboard_1.4.1-2ubuntu7_arm64.deb` v1.4.1 (343944 B, sha256 `92f8945e2758e74deae7dfcbe796a08e56229d5d080b40edbd59d70f2f10eac4`) plus official arch:all `onboard-common_1.4.1-2ubuntu7_all.deb` (529504 B, sha256 `4572affbcc7c581010917dd12631d67257372dd4a0d194c551abd6780726ae7d`; hard Depends — layouts, themes, locales, icons, help) and official Recommends `onboard-data_1.4.1-2ubuntu7_all.deb` (3803292 B, sha256 `001d2c3fef408fefc3ae22582372224b58c2ccfd60d38ea03e95a68ee5458ad1`; 29 language models for word suggestion; no zh_* model in this official set), both bundled. Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/o/onboard/` pool files and the Ubuntu 20.04 focal universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates. No librarian URL is recorded this run. Layout `/opt/onboard` + `/usr/bin/onboard` and `/usr/bin/onboard-settings`. Python 3.8 modules and the two cpython-38 extension ELFs stay on `/usr/lib/python3/dist-packages/Onboard` (do not relocate; imports would break). `INSTALL_DIR` is compiled as `/usr/share/onboard`. 98 locales including zh_CN / zh_HK / zh_TW are bundled from onboard-common. Desktop, man, icons, GSettings schema, D-Bus service, C help, layouts/themes/UI and language models stay on standard `/usr/share` and `/etc/xdg` paths. Official desktop `Icon=onboard`. Official D-Bus service already `Exec=/usr/bin/onboard`. Official autostart remains `OnlyShowIn=Unity;MATE`. Probe: aarch64 · 2 ELF · osk requiredGlibc **2.17** (no GLIBCXX) · lm requiredGlibc **2.29** + GLIBCXX **3.4.21**. Runtime Depends match official Ubuntu 20.04 (Python 3.8, GTK3 typelibs, cairo, hunspell, dconf, libcanberra, X11/Xi/Xtst/xkbfile, udev, libstdc++6, libc6 ≥ 2.29, gsettings backend). Recommends: `gir1.2-appindicator3-0.1`, `gir1.2-atspi-2.0`, `xdg-utils`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
