# kemi-anew (t297)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.anew |
| deb | kemi-anew_0.2.0-1kemi1_arm64.deb |
| app_id | 285 |
| version | 0.2.0-1kemi1 / code 200 |
| bytes | 518492 |
| SHA256 | `3009102c8e0a7172b467a5d212e98899f312212e587c0876d090e082e54d1a27` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794047816655_ad1297fb_kemi-anew_0_2_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/anew |
| source | tomnomnom/anew@v0.2 `26ebc8ce` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-anew-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/anew/tree/v0.2
