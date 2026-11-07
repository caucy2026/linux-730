# kemi-typos (t198)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.typos |
| deb | kemi-typos_1.52.0-1kemi1_arm64.deb |
| app_id | 186 |
| version | 1.52.0-1kemi1 / code 15200 |
| bytes | 4860700 |
| SHA256 | `b61340775b0ddc6209c4261d63206f4524b3cae27c2aa9936e135a559f30595f` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034098678_257649ab_kemi-typos_1_52_0-1kemi1_arm64.deb |
| binary | aarch64-unknown-linux-musl **static** (NO_NEEDED) |
| install | /usr/bin/typos |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-typos-kemi-deb.sh
```

Upstream: https://github.com/crate-ci/typos/releases/tag/v1.52.0

## Notes

- t198 first pick **onefetch** SKIP: onefetch-linux.tar.gz is x86-64 only; no aarch64/musl assets in recent releases.
- Fallback **typos** musl static PASS.
