# kemi-kubeseal (t227)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.kubeseal |
| deb | kemi-kubeseal_0.41.2-1kemi1_arm64.deb |
| app_id | 215 |
| version | 0.41.2-1kemi1 / code 4102 |
| bytes | 17915036 |
| SHA256 | `d2763b6fa7c7adcd57e81d3c0fff202df5958aefb7080c788d6bfdcd3686d945` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794038518251_4c557202_kemi-kubeseal_0_41_2-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/kubeseal |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-kubeseal-kemi-deb.sh
```

Upstream: https://github.com/bitnami/sealed-secrets/releases/tag/v0.41.2
