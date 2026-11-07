# kemi-syft (t242)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.syft |
| deb | kemi-syft_1.57.0-1kemi1_arm64.deb |
| app_id | 230 |
| version | 1.57.0-1kemi1 / code 15700 |
| bytes | 18926324 |
| SHA256 | `2aa15f0de4e2ad48ae537e0e630b97370b0abac1d9dd25a410eb0a6b542602c8` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794040569938_efa550a5_kemi-syft_1_57_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/syft |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-syft-kemi-deb.sh
```

Upstream: https://github.com/anchore/syft/releases/tag/v1.57.0
