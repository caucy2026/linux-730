# kemi-k3d (t231)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.k3d |
| deb | kemi-k3d_5.9.0-1kemi1_arm64.deb |
| app_id | 219 |
| version | 5.9.0-1kemi1 / code 50900 |
| bytes | 5662688 |
| SHA256 | `f14d6e3bfea509e6b830e44e215973c337e35a29c1b59597d2da425fb016d383` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794039082955_4016e06d_kemi-k3d_5_9_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/k3d |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-k3d-kemi-deb.sh
```

Upstream: https://github.com/k3d-io/k3d/releases/tag/v5.9.0
