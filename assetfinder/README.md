# kemi-assetfinder (t305)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.assetfinder |
| deb | kemi-assetfinder_0.1.1-1kemi1_arm64.deb |
| app_id | 293 |
| version | 0.1.1-1kemi1 / code 101 |
| bytes | 1902968 |
| SHA256 | `f37aed4b05e475ac594d709d11337713d0324abe6788ba081afe49c21f0c8e80` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048831265_5f170978_kemi-assetfinder_0_1_1-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/assetfinder |
| source | tomnomnom/assetfinder@v0.1.1 `4e95d870` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-assetfinder-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/assetfinder/releases/tag/v0.1.1
