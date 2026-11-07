# kemi-argocd (t237)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.argocd |
| deb | kemi-argocd_3.6.1-1kemi1_arm64.deb |
| app_id | 225 |
| version | 3.6.1-1kemi1 / code 30601 |
| bytes | 73109472 |
| SHA256 | `b8723fbc5e4b423b2eab3d9ca12798345ed28b30b6eac1cee5d4e382f1531e23` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794039844989_2c7a0294_kemi-argocd_3_6_1-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/argocd |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-argocd-kemi-deb.sh
```

Upstream: https://github.com/argoproj/argo-cd/releases/tag/v3.6.1
