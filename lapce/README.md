# Lapce (KEMI Linux)

Lightning-fast Rust code editor for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **323** |
| package_name | `com.kemi.lapce` |
| dpkg | `kemi-lapce` |
| version | `0.4.6-1kemi1` / code **406** |
| bytes | 13610252 |
| sha256 | `3629fbef6a78200b66331977c6a0f46bf98f154d9d6e916999cef39ec9a35e31` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794384599762_1220e867_kemi-lapce_0_4_6-1kemi1_arm64.deb |

Notes: official `lapce.debian.bullseye.arm64.deb` v0.4.6 (13602888 B, sha256 `c9080bfb36a60ae5d5737432d49d73000d56a73a11a9e88884b066ce34a5704d`); install under `/opt/lapce/` + `/usr/bin/lapce` (symlink to `/opt/lapce/lapce`). Probe max glibc 2.30 (1 ELF). Runtime depends on libssl1.1 (Ubuntu 20.04). Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
