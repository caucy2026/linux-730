# kemi-cdncheck (t291)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.cdncheck |
| deb | kemi-cdncheck_1.4.0-1kemi1_arm64.deb |
| app_id | 279 |
| version | 1.4.0-1kemi1 / code 10400 |
| bytes | 4933188 |
| SHA256 | `32e5fdb110e9e9f7b08a1ef730da890d413cab5b445b34f1baa963bf1c3ae2b0` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794046972437_e80657f9_kemi-cdncheck_1_4_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/cdncheck |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-cdncheck-kemi-deb.sh
```

Upstream: https://github.com/projectdiscovery/cdncheck/releases/tag/v1.4.0
