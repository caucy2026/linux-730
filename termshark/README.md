# kemi-termshark (t221)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.termshark |
| deb | kemi-termshark_2.4.0-1kemi1_arm64.deb |
| app_id | 209 |
| version | 2.4.0-1kemi1 / code 20400 |
| bytes | 3943164 |
| SHA256 | `7ea970343c8bd0d3c153a90b95d5b8ecc6a1960abb9ff9302bd263864401f9ca` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794037549244_c75a4f93_kemi-termshark_2_4_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/termshark |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-termshark-kemi-deb.sh
```

Upstream: https://github.com/gcla/termshark/releases/tag/v2.4.0
