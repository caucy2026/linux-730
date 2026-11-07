# kemi-cosign (t241)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.cosign |
| deb | kemi-cosign_3.1.4-1kemi1_arm64.deb |
| app_id | 229 |
| version | 3.1.4-1kemi1 / code 30104 |
| bytes | 45118216 |
| SHA256 | `564d80d5a543f87bfc1decfa8f6426bc8809e70f174c21c44c3f5e5dcaf368f3` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794040467611_e5a40a00_kemi-cosign_3_1_4-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/cosign |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-cosign-kemi-deb.sh
```

Upstream: https://github.com/sigstore/cosign/releases/tag/v3.1.4
