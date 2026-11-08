# Logseq (KEMI Linux)

Privacy-first open-source knowledge base / outliner for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **314** |
| package_name | `com.kemi.logseq` |
| dpkg | `kemi-logseq` |
| version | `2.0.2-1kemi1` / code **20002** |
| bytes | 115523456 |
| sha256 | `bfda1a8375b5f0707af3d5c861d9a52ec54214561792e155c973dd58a80431c6` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794112395825_544a2570_kemi-logseq_2_0_2-1kemi1_arm64.deb |

Notes: official linux arm64 zip v2.0.2; install under `/opt/Logseq/` + `/usr/bin/logseq` (--no-sandbox); drop wrong-arch `@zvec/bindings-linux-x64`; probe max glibc 2.25; 101 smoke PASS (`dpkg-query` → 2.0.2-1kemi1 arm64; ELF aarch64; vibekits PID 3569119 unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
