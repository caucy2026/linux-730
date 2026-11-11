# Zed (KEMI Linux)

High-performance multiplayer code editor for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **322** |
| package_name | `com.kemi.zed` |
| dpkg | `kemi-zed` |
| version | `1.27.0-1kemi1` / code **12700** |
| bytes | 58913784 |
| sha256 | `41040a55152c2d542ab173fabceaa2990b912bf6881ddbf9b7c2af58cbf3dbd5` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794383372221_f58ec09c_kemi-zed_1_27_0-1kemi1_arm64.deb |

Notes: official linux aarch64 tarball v1.27.0; install under `/opt/zed.app/` + `/usr/bin/zed` (symlink). Probe max glibc 2.30 (11 ELFs). Official docs mention aarch64 glibc ≥2.35, but this artifact's version-needs are 2.30. Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
