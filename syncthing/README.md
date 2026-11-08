# Syncthing (KEMI Linux)

Lean continuous file sync for KEMI mall (aarch64). Fallthrough after LocalSend SKIP (glibc 2.34) and Joplin (no official linux arm64).

| field | value |
|---|---|
| app_id | **312** |
| package_name | `com.kemi.syncthing` |
| dpkg | `kemi-syncthing` |
| version | `2.1.7-1kemi1` / code **20107** |
| bytes | 9890132 |
| sha256 | `352c844852eb03a2d419504489ace404799cdc6761a6eb5c7583bf9238e71840` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794111025237_6ebbf4d2_kemi-syncthing_2_1_7-1kemi1_arm64.deb |

Notes: official `syncthing_2.1.7_arm64.deb`; `/usr/bin/syncthing` static Go aarch64; probe no glibc version-needs; 101 smoke PASS (`syncthing --version` → v2.1.7; vibekits PIDs unchanged). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
