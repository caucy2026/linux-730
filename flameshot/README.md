# Flameshot (KEMI Linux)

Powerful yet simple-to-use screenshot tool for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **324** |
| package_name | `com.kemi.flameshot` |
| dpkg | `kemi-flameshot` |
| version | `12.1.0-1kemi1` / code **1210** |
| bytes | 643404 |
| sha256 | `febec10d55be89a4057bd05c7f3aeb137834614773fe0e61b08567dc3c671b7a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794385126972_b84e9287_kemi-flameshot_12_1_0-1kemi1_arm64.deb |

Notes: official `flameshot-12.1.0-1.debian-10.arm64.deb` v12.1.0 (652648 B, sha256 `840a1615e30e9225b0484ed63e317a46243acb60f20f0ef6dc723f899b0f9048`); install under `/opt/flameshot/` + `/usr/bin/flameshot` (symlink to `/opt/flameshot/flameshot`). Probe max glibc 2.17 (1 ELF), GLIBCXX 3.4.21, Qt_5. Runtime depends on system Qt5 (Ubuntu 20.04 Qt 5.12 satisfies official debian-10 Depends). Latest official arm64 (v15 Ubuntu 24.04) needs GLIBC_2.38 + Qt6 and was not used. Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
