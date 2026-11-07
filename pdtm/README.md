# kemi-pdtm (t296)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.pdtm |
| deb | kemi-pdtm_0.1.5-1kemi1_arm64.deb |
| app_id | 284 |
| version | 0.1.5-1kemi1 / code 105 |
| bytes | 5204836 |
| SHA256 | `ede9dabf4b12c371b8542b6d1c45aa505dfb2a11c5d1fa429310bacd8a6430cb` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794047697727_c5a58bfb_kemi-pdtm_0_1_5-1kemi1_arm64.deb |
| binary | linux-arm64 **glibc** (libdl/libc/libpthread；requiredGlibc null；probe PASS max 2.31) |
| install | /usr/bin/pdtm |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-pdtm-kemi-deb.sh
```

Upstream: https://github.com/projectdiscovery/pdtm/releases/tag/v0.1.5
