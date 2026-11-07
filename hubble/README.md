# kemi-hubble (t229)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.hubble |
| deb | kemi-hubble_1.20.4-1kemi1_arm64.deb |
| app_id | 217 |
| version | 1.20.4-1kemi1 / code 12004 |
| bytes | 12566164 |
| SHA256 | `8144fa1772893d3dd5da1f3a96209fb1ceac6fa9d7b5709d345650d497e6a3f6` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794038836613_4c64f48f_kemi-hubble_1_20_4-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/hubble |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-hubble-kemi-deb.sh
```

Upstream: https://github.com/cilium/hubble/releases/tag/v1.20.4
