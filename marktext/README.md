# MarkText (KEMI Linux)

Simple elegant open-source Markdown editor for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **315** |
| package_name | `com.kemi.marktext` |
| dpkg | `kemi-marktext` |
| version | `0.23.0-1kemi1` / code **2300** |
| bytes | 110448452 |
| sha256 | `1c84f0d9e76a915975e8ad0962a9383ffd4af7399c9566797911e757847175c9` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794112940596_a8f0932c_kemi-marktext_0_23_0-1kemi1_arm64.deb |

Notes: official linux arm64 deb v0.23.0; install under `/opt/MarkText/` + `/usr/bin/marktext` (--no-sandbox); drop `native-keymap` `.node` (GLIBC_2.34; upstream try/catch → empty keymap); probe max glibc 2.25; 101 smoke PASS (`dpkg-query` → 0.23.0-1kemi1 arm64; ELF aarch64; vibekits PID 3569119 unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
