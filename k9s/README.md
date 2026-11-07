# kemi-k9s (t222)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.k9s |
| deb | kemi-k9s_0.51.0-1kemi1_arm64.deb |
| app_id | 210 |
| version | 0.51.0-1kemi1 / code 5100 |
| bytes | 23600252 |
| SHA256 | `93e8ba2effafd7bce7e78146d8b3e0b8115f93763bd5eb6ffab5ad0ffe16b9bc` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794037680130_8df8649b_kemi-k9s_0_51_0-1kemi1_arm64.deb |
| binary | Linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/k9s |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-k9s-kemi-deb.sh
```

Upstream: https://github.com/derailed/k9s/releases/tag/v0.51.0
