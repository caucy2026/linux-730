# kemi-kustomize (t234)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.kustomize |
| deb | kemi-kustomize_5.8.3-1kemi1_arm64.deb |
| app_id | 222 |
| version | 5.8.3-1kemi1 / code 50803 |
| bytes | 3298232 |
| SHA256 | `752f47e56495921dd1002ff62926a7a2fa52d5d544fe86cb8ff294229a01d45a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794039509252_78d146e0_kemi-kustomize_5_8_3-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/kustomize |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-kustomize-kemi-deb.sh
```

Upstream: https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.8.3
