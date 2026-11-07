# kemi-ov (t201)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.ov |
| deb | kemi-ov_0.55.0-1kemi1_arm64.deb |
| app_id | 189 |
| version | 0.55.0-1kemi1 / code 5500 |
| bytes | 5707920 |
| SHA256 | `e5cd9059ba6886c475a2ea4373efbe1fa11e97db69892b150b3e497d124f98f3` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034615907_42123436_kemi-ov_0_55_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/ov |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-ov-kemi-deb.sh
```

Upstream: https://github.com/noborus/ov/releases/tag/v0.55.0

## Notes

- t201 SKIP **fastmod**: no release binary assets
- t201 SKIP **htmlq**: x86_64 only, no aarch64
