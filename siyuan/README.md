# SiYuan / 思源笔记 (KEMI Linux)

Privacy-first personal knowledge management for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **311** |
| package_name | `com.kemi.siyuan` |
| dpkg | `kemi-siyuan` |
| version | `3.8.9-1kemi1` / code **30809** |
| bytes | 192991964 |
| sha256 | `703dfcdeb3a9399c460016b37c7629fa68e7e5ad6867532402417246e9257df0` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794110446948_cab8a4e9_kemi-siyuan_3_8_9-1kemi1_arm64.deb |

Notes: official linux arm64 .deb v3.8.9; install under `/opt/SiYuan/` + `/usr/bin/siyuan` (--no-sandbox); probe max glibc 2.27; 101 smoke PASS (`dpkg-query` → 3.8.9-1kemi1 arm64; ELF aarch64; vibekits PIDs unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
