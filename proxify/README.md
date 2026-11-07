# kemi-proxify (t294)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.proxify |
| deb | kemi-proxify_0.0.16-1kemi1_arm64.deb |
| app_id | 282 |
| version | 0.0.16-1kemi1 / code 16 |
| bytes | 7734716 |
| SHA256 | `8e47d84c0e9b7cabb685d668193caf7a35fa7764ba67995ccc5c72de31198d3e` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794047344102_4e4938cf_kemi-proxify_0_0_16-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/proxify（单 CLI；omit replay/mitmrelay） |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-proxify-kemi-deb.sh
```

Upstream: https://github.com/projectdiscovery/proxify/releases/tag/v0.0.16
