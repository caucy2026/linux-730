# kemi-devspace (t252)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.devspace |
| deb | kemi-devspace_6.3.21-1kemi1_arm64.deb |
| app_id | 240 |
| version | 6.3.21-1kemi1 / code 60321 |
| bytes | 20227028 |
| SHA256 | `24e70541eeae1f88da2a4a95a57af0d3c3e4e6dee8deccd28de75b0a40b3beac` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794041989363_ab1daf15_kemi-devspace_6_3_21-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/devspace |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-devspace-kemi-deb.sh
```

Upstream: https://github.com/devspace-sh/devspace/releases/tag/v6.3.21

Note: t252 preferred tilt v0.37.8 but SKIP (GLIBC_2.34 > 2.31).
