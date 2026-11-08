# code-server (KEMI Linux)

VS Code in the browser for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **310** |
| package_name | `com.kemi.code-server` |
| dpkg | `kemi-code-server` |
| version | `4.145.2-1kemi1` / code **41452** |
| bytes | 149426980 |
| sha256 | `93e6bd6e54e09fe32ae8aac6424a99f2db6e0d4c514cb3e20b5911bacfddb47b` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794109792790_3a1d135d_kemi-code-server_4_145_2-1kemi1_arm64.deb |

Notes: official linux arm64 tarball v4.145.2; install under `/usr/lib/code-server/` + `/usr/bin/code-server`; cross-arch natives stripped; probe max glibc 2.28; 101 smoke PASS (`code-server --version` → 4.145.2; vibekits PIDs unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
