# tabby (KEMI Linux)

Tabby terminal for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **309** |
| package_name | `com.kemi.tabby` |
| dpkg | `kemi-tabby` |
| version | `1.0.238-1kemi1` / code **10238** |
| bytes | 104041848 |
| sha256 | `1ed24210e277c7a1ccd5bbe3d6e1065278a6c1b0e76a550a1cc2e3004f8288a0` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794109341100_ccca8309_kemi-tabby_1_0_238-1kemi1_arm64.deb |

Notes: official linux arm64 v1.0.238; node-pty patched to prebuilds/linux-arm64 (glibc≤2.28) replacing Release/bin that needed 2.34; cross-arch natives stripped; launcher `/usr/bin/tabby` passes `--no-sandbox`; 101 smoke PASS (CDN install + ELF + PTY_GLIBC_OK + remove; vibekits PIDs unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
