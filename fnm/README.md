# kemi-fnm (t205)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.fnm |
| deb | kemi-fnm_1.39.0-1kemi1_arm64.deb |
| app_id | 193 |
| version | 1.39.0-1kemi1 / code 13900 |
| bytes | 2520692 |
| SHA256 | `f3dd493feb3886d653a13000e2aa687f43723039a001d7dc2d222148bcc9ca7c` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794035166412_16dd1ab4_kemi-fnm_1_39_0-1kemi1_arm64.deb |
| binary | linux arm64 **static** (NO_NEEDED) |
| install | /usr/bin/fnm |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-fnm-kemi-deb.sh
```

Upstream: https://github.com/Schniz/fnm/releases/tag/v1.39.0

## Notes

- t205: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
