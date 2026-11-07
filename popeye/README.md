# kemi-popeye (t225)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.popeye |
| deb | kemi-popeye_0.22.1-1kemi1_arm64.deb |
| app_id | 213 |
| version | 0.22.1-1kemi1 / code 2201 |
| bytes | 12016340 |
| SHA256 | `a181ce4ac86d148cc61ebccef1a590497d5dda00324e13ce4c0c54452808d5bc` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794038104919_18919f67_kemi-popeye_0_22_1-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/popeye |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-popeye-kemi-deb.sh
```

Upstream: https://github.com/derailed/popeye/releases/tag/v0.22.1

Note: four_layer L3 paginates store list (app_id 213 landed on page 2).
