# kemi-meg (t304)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.meg |
| deb | kemi-meg_0.3.0-1kemi1_arm64.deb |
| app_id | 292 |
| version | 0.3.0-1kemi1 / code 300 |
| bytes | 1718504 |
| SHA256 | `e38fe51bd2d8d6004c214c15318a30e14d378c556e9f7a555d854aa10b0f64b2` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048693322_6f98d2e9_kemi-meg_0_3_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/meg |
| source | tomnomnom/meg@v0.3.0 `20e5bfea` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-meg-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/meg/releases/tag/v0.3.0
