# Gedit (KEMI Linux)

Official text editor of the GNOME desktop for KEMI mall (arm64, Ubuntu 20.04 / 101, Python 3.8).

| field | value |
|---|---|
| app_id | **355** |
| package_name | `com.kemi.gedit` |
| dpkg | `kemi-gedit` |
| version | `3.36.2-0ubuntu1kemi1` / code **3362** |
| bytes | 468544 |
| sha256 | `573616e0ee3a733d9b6514f831f098b2ed48b07f4dc15a0bff1ade245e364334` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794398842884_3f948b81_kemi-gedit_3_36_2-0ubuntu1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal-updates) `gedit_3.36.2-0ubuntu1_arm64.deb` v3.36.2 (385740 B, sha256 `b6671760cf1a489f58a9ce6f55ba7320b2330b559d63d6e2cf646598d50d28f6`) plus official arch:all `gedit-common_3.36.2-0ubuntu1_all.deb` (94748 B, sha256 `65ecc1153c0778b19fc2c1589bbd9433e1e3ca573b66d935026e55f3c4f659a9`; hard Depends — schemas, help, plugin data, icons), bundled. Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/g/gedit/` pool files and the Ubuntu 20.04 focal-updates main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). Newer than the focal Release 3.36.1-1 binary. No librarian URL is recorded this run. There is no separate `gir1.2-gedit` typelib deb; `Gedit-3.0.typelib` ships inside the official gedit package at `/usr/lib/aarch64-linux-gnu/gedit/girepository-1.0/`. The official launcher ELF embeds compiled `/usr` prefixes and `RUNPATH=/usr/lib/aarch64-linux-gnu/gedit`, so the ELF stays at `/usr/bin/gedit` and `/opt/gedit/gedit` is only a symlink (HardInfo/Xpad/qpdfview/Pluma layout). Private `libgedit-3.36.so`, typelib and plugin `.so` files stay under that `/usr/lib` path. GI override stays at `/usr/lib/python3/dist-packages/gi/overrides/Gedit.py`. Official language-pack split: these debs ship no `.mo` files. C help pages are real files; zh_CN / zh_HK / zh_TW (and other non-C) help pages are official symlinks into `/usr/share/help-langpack/` (language packs not bundled). Desktop, D-Bus service, man, GSettings schemas, metainfo, icons, plugin data and help stay on standard `/usr/share` paths. Official desktop `Icon=org.gnome.gedit` (SVG shipped). Official D-Bus service already `Exec=/usr/bin/gedit --gapplication-service`. Probe: aarch64 · 9 ELF (launcher + libgedit-3.36.so + 7 plugin `.so`) · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, GtkSourceView 4, libtepl-4, libamtk-5, libgspell, libpeas, typelibs, python3.8, python3-gi, gsettings-desktop-schemas, iso-codes, gsettings backend, libc6 ≥ 2.17). Recommends: `yelp`, `zenity`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
