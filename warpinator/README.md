# Warpinator (KEMI Linux)

Lean LAN file share for KEMI mall (aarch64). Preferred after LocalSend SKIP (glibc 2.34); fills same niche.

| field | value |
|---|---|
| app_id | **313** |
| package_name | `com.kemi.warpinator` |
| dpkg | `kemi-warpinator` |
| version | `1.8.8-1kemi1` / code **10808** |
| bytes | 4056700 |
| sha256 | `04c26f0c250e475e85e069dff6b88bae10eb30d3645e678716775117a5e5e7f2` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794111846221_f8db9718_kemi-warpinator_1_8_8-1kemi1_arm64.deb |

Notes: Wasta/Linux Mint `warpinator_1.8.8-…~ubuntu20.04.1_arm64.deb` + bundled `libxapp1`/`gir1.2-xapp`/`python3-xapp`/`xapps-common` for stock Ubuntu 20.04; probe requiredGlibc ≤2.30 PASS; 101 smoke PASS (install + ELF aarch64 + config import; vibekits PID unchanged). Recipe-only; no `.deb` in git. **Not croc** (croc is in toolkit-ops).

合主线：gork.bot协助开发
