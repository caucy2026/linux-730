# kemi-helm (t233)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.helm |
| deb | kemi-helm_4.3.1-1kemi1_arm64.deb |
| app_id | 221 |
| version | 4.3.1-1kemi1 / code 40301 |
| bytes | 11481036 |
| SHA256 | `bea378935d0ae3f9b35337ba0912070188ecda769bd97ae15835619ec4e2afb6` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794039405392_74faafae_kemi-helm_4_3_1-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/helm |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-helm-kemi-deb.sh
```

Upstream: https://get.helm.sh/helm-v4.3.1-linux-arm64.tar.gz (helm/helm v4.3.1)
