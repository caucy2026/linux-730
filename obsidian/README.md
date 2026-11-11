# Obsidian (KEMI Linux)

Local-first Markdown knowledge base for KEMI mall (aarch64).

| field | value |
|---|---|
| app_id | **321** |
| package_name | `com.kemi.obsidian` |
| dpkg | `kemi-obsidian` |
| version | `1.15.0-1kemi1` / code **11500** |
| bytes | 93098852 |
| sha256 | `3a8abd18bb1797d5b87d72a30cea13447195e8df751389c09d6050b7bff796fe` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794381404629_6514cb1e_kemi-obsidian_1_15_0-1kemi1_arm64.deb |

Notes: official linux arm64 tarball v1.15.0; install under `/opt/Obsidian/` + `/usr/bin/obsidian` (--no-sandbox); dropped `obsidian-cli` (GLIBC_2.34) and wrong-arch x86_64 `btime`/`get-fonts` natives (upstream try/catch). Probe max glibc 2.25 (8 ELFs). Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: ONE connect → **transport_timeout** (no retry; vibekits not touched).

合主线：gork.bot协助开发
