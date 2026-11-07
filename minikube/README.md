# kemi-minikube (t232)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.minikube |
| deb | kemi-minikube_1.39.0-1kemi1_arm64.deb |
| app_id | 220 |
| version | 1.39.0-1kemi1 / code 13900 |
| bytes | 39412140 |
| SHA256 | `16c1c70081f459a331343472012b7dd1878fdd9cd5ea9cad3405814b2b687a52` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794039213098_f9062cf9_kemi-minikube_1_39_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/minikube |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-minikube-kemi-deb.sh
```

Upstream: https://github.com/kubernetes/minikube/releases/tag/v1.39.0
