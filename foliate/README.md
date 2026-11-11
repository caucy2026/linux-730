# Foliate (KEMI Linux)

Simple and modern GTK eBook viewer for KEMI mall (arch=all, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **325** |
| package_name | `com.kemi.foliate` |
| dpkg | `kemi-foliate` |
| version | `2.6.4-1kemi1` / code **264** |
| bytes | 913136 |
| sha256 | `f0e23af711af38d21cab2e78fd4d42f8949fedf28fed45f13eaa15b33259ae14` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794385463722_d052e343_kemi-foliate_2_6_4-1kemi1_all.deb |

Notes: official `com.github.johnfactotum.foliate_2.6.4_all.deb` v2.6.4 (914108 B, sha256 `fdc7d45a0b357c4a58aa08ddadf581dd21f3761bc6c74a80e39174ce77b75d66`); last official GTK3 line. Installs under `/opt/foliate/` + `/usr/bin/com.github.johnfactotum.Foliate` and `/usr/bin/foliate` (symlinks). Official launcher libdir was baked as `/usr/lib/x86_64-linux-gnu`; rewritten to `/opt/foliate/lib` + `datadir=/opt/foliate/share`. Probe: 0 ELF (GJS + data + 2× libarchive.wasm). Runtime Depends: `gjs (>= 1.52)`, `gir1.2-webkit2-4.0`, `dconf-gsettings-backend | gsettings-backend`, `python3` — all in Ubuntu 20.04 focal arm64 main (gjs 1.64.5, WebKitGTK 4.0 2.38.6). Foliate 3.x official all.deb needs GTK4 / WebKitGTK 6 and was not used. Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
