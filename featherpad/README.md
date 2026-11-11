# FeatherPad (KEMI Linux)

Lightweight Qt5 plain-text editor for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **327** |
| package_name | `com.kemi.featherpad` |
| dpkg | `kemi-featherpad` |
| version | `0.12.1-1kemi1` / code **121** |
| bytes | 359192 |
| sha256 | `275f912c35ea19e3be48e99b8bc63ac72f65693fc6476f328cddcb8ff1943742` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794386194785_21449320_kemi-featherpad_0_12_1-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) `featherpad_0.12.1-1build1_arm64.deb` v0.12.1 (359060 B, sha256 `bdc80323103f2bb7bec995877bf3e1d85fa825871a78f2829b237838a6a6d582`). Installs under `/opt/featherpad/` + `/usr/bin/featherpad` (symlink to `/opt/featherpad/featherpad`); also `/usr/bin/fpad`. Help data stays at `/usr/share/featherpad/help`. Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · GLIBCXX 3.4.21 · Qt_5. Runtime Depends: `libc6 (>= 2.17)`, `libqt5core5a (>= 5.12.2)`, `libqt5gui5`, `libqt5widgets5`, `libqt5network5`, `libqt5printsupport5`, `libqt5svg5`, `libqt5x11extras5`, `libhunspell-1.7-0`, `libx11-6` — all in Ubuntu 20.04 focal arm64. Official GitHub `tsujan/FeatherPad` releases are source-only (no linux aarch64). Debian bullseye official `featherpad_0.17.1-1_arm64.deb` was not used (`libqt5core5a >= 5.15.1` would not install on Ubuntu 20.04 Qt 5.12). Xournal++ official `xournalpp-1.3.8-Ubuntu-jammy-aarch64.deb` was probed and SKIP (requiredGlibc 2.35 / GLIBCXX 3.4.30; also `qpdf >= 10.6.0` / `libqpdf.so.28`); no official GitHub aarch64 deb exists for Ubuntu-focal / Debian-bullseye / Debian-buster (those are x86_64 only). Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
