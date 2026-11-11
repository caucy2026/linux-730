# Pluma (KEMI Linux)

Official text editor of the MATE desktop for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **354** |
| package_name | `com.kemi.pluma` |
| dpkg | `kemi-pluma` |
| version | `1.24.0-1kemi1` / code **1240** |
| bytes | 2263708 |
| sha256 | `5833545525842dd4b72fa46a0a8bcab55240f7ae6757fc262ca4a4bc1d676519` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794398407004_0c30abb2_kemi-pluma_1_24_0-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `pluma_1.24.0-1_arm64.deb` v1.24.0 (392936 B, sha256 `f8f27a21899d3d2cceb4c918f17754344db6feebb552c89604a4bdd8438124cb`) plus official arch:all `pluma-common_1.24.0-1_all.deb` (1817508 B, sha256 `f63c8ed3498b6316fc97d3850371268e5e8ac11083aa3f91bafb339d6a7898ce`; hard Depends — locales, help, UI, schemas) and official same-source `gir1.2-pluma-1.0_1.24.0-1_arm64.deb` (20788 B, sha256 `d7dd21131bc76d7aed73914e4076dc6573b61933bda4ca71a7b57844f9e3cffe`; typelib, exact-version Depends), both bundled. Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/p/pluma/` pool files and the Ubuntu 20.04 focal universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates. No librarian URL is recorded this run. The official ELF embeds compiled `/usr` prefixes (`/usr/share/pluma`, `/usr/lib/aarch64-linux-gnu`), so the ELF stays at `/usr/bin/pluma` and `/opt/pluma/pluma` is only a symlink (HardInfo/Xpad/qpdfview layout). Plugin `.so` files stay at `/usr/lib/aarch64-linux-gnu/pluma/plugins`; typelib stays at `/usr/lib/aarch64-linux-gnu/girepository-1.0/Pluma-1.0.typelib`. 119 locales including zh_CN / zh_TW are bundled from pluma-common. Desktop, man, GSettings schemas, metainfo, UI and help stay on standard `/usr/share` paths. Official desktop `Icon=accessories-text-editor` (theme icon, not shipped in this deb). Probe: aarch64 · 10 ELF (pluma + 9 plugin `.so`) · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, GtkSourceView 3, libpeas, gir1.2-peas-1.0, iso-codes, mate-desktop-common, python3, enchant, cairo, pango, X11, gsettings backend, libc6 ≥ 2.17). Official mate-desktop-common remains a Depends (different source, not bundled). Recommends: `zenity`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
