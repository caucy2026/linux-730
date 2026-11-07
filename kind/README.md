# kemi-kind (t230)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.kind |
| deb | kemi-kind_0.33.0-1kemi1_arm64.deb |
| app_id | 218 |
| version | 0.33.0-1kemi1 / code 3300 |
| bytes | 2763300 |
| SHA256 | `80465b432a980ff98afbcf81b368a824eee1e63c3b63fddff9470f6797c71332` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794038969291_76149488_kemi-kind_0_33_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/kind |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-kind-kemi-deb.sh
```

Upstream: https://github.com/kubernetes-sigs/kind/releases/tag/v0.33.0
