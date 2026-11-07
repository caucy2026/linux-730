# kemi-ctop (t216)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.ctop |
| deb | kemi-ctop_0.7.7-1kemi1_arm64.deb |
| app_id | 204 |
| version | 0.7.7-1kemi1 / code 707 |
| bytes | 3200072 |
| SHA256 | `751ce98def59ab36e1b49eb4cc47ad1c7e15ac54f7d8bbf74544d66c8149e171` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794036902650_24b5044f_kemi-ctop_0_7_7-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/ctop |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-ctop-kemi-deb.sh
```

Upstream: https://github.com/bcicen/ctop/releases/tag/v0.7.7
