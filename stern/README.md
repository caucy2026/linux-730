# kemi-stern (t219)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.stern |
| deb | kemi-stern_1.35.0-1kemi1_arm64.deb |
| app_id | 207 |
| version | 1.35.0-1kemi1 / code 13500 |
| bytes | 8114680 |
| SHA256 | `cae8f6d5b242376cb3ae84389289710a711d0186e38b9ab9bb35319ad4b928ea` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794037301464_1ecdea93_kemi-stern_1_35_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/stern |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-stern-kemi-deb.sh
```

Upstream: https://github.com/stern/stern/releases/tag/v1.35.0
