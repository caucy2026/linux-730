# kemi-cilium-cli (t228)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.cilium-cli |
| deb | kemi-cilium-cli_0.20.2-1kemi1_arm64.deb |
| app_id | 216 |
| version | 0.20.2-1kemi1 / code 2002 |
| bytes | 52752972 |
| SHA256 | `e3cb5129710ded3f4ee90a1811d12ccc933e2ac073ab19e3fd4b73a890f1894b` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794038688490_a8f0b7c0_kemi-cilium-cli_0_20_2-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/cilium |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-cilium-cli-kemi-deb.sh
```

Upstream: https://github.com/cilium/cilium-cli/releases/tag/v0.20.2
