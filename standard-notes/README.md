# Standard Notes (KEMI Linux)

End-to-end encrypted notes for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **317** |
| package_name | `com.kemi.standard-notes` |
| dpkg | `kemi-standard-notes` |
| version | `3.202.11-1kemi1` / code **320211** |
| bytes | 107963512 |
| sha256 | `7a165f554072e8e1b91e3e7f0ffbeb2c9415ad80c427f6d2f7a0e87c2bb8ccb3` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794114281114_da9b29d1_kemi-standard-notes_3_202_11-1kemi1_arm6.deb |

Notes: official linux arm64 deb v3.202.11; install under `/opt/Standard Notes/` + `/usr/bin/standard-notes` (--no-sandbox); drop microtime `linux-arm`/`linux-x64` and musl `@cbor-extract` for glibc 2.25; CDN key truncates to `arm6.deb`; Notesnook SKIP (`better_sqlite3.node` GLIBC_2.34); probe max glibc 2.25; 101 smoke PASS. Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
