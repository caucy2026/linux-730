# Zettlr (KEMI Linux)

Markdown publication workbench / Zettelkasten editor for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **316** |
| package_name | `com.kemi.zettlr` |
| dpkg | `kemi-zettlr` |
| version | `4.9.0-1kemi1` / code **4900** |
| bytes | 122277240 |
| sha256 | `ea911482c5e3291c2f68b79e723f218bb9204b16ca17961c9adc1b253eafa255` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794113493083_cdd64026_kemi-zettlr_4_9_0-1kemi1_arm64.deb |

Notes: official linux arm64 deb v4.9.0; install under `/usr/lib/zettlr/` + `/usr/bin/zettlr` (--no-sandbox); probe max glibc 2.25; 101 smoke PASS (`dpkg-query` → 4.9.0-1kemi1 arm64; ELF aarch64; vibekits PID 3569119 unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
