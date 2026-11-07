# kemi-mods (t204)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.mods |
| deb | kemi-mods_1.8.1-1kemi1_arm64.deb |
| app_id | 192 |
| version | 1.8.1-1kemi1 / code 10801 |
| bytes | 6694692 |
| SHA256 | `d1aac82690bd3e001c090ebb9ed31f22eb87ae2450d4a05ad5d30d9f728445de` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794035023280_3877527c_kemi-mods_1_8_1-1kemi1_arm64.deb |
| binary | Linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/mods |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-mods-kemi-deb.sh
```

Upstream: https://github.com/charmbracelet/mods/releases/tag/v1.8.1

## Notes

- t204: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
