# kemi-waybackurls (t300)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.waybackurls |
| deb | kemi-waybackurls_0.1.0-1kemi1_arm64.deb |
| app_id | 288 |
| version | 0.1.0-1kemi1 / code 100 |
| bytes | 1899236 |
| SHA256 | `22816839f11c2fdf4fca9e2b9cb55cc311c21ecc9bbdc66ecfa8d90e3c7d8685` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048183699_5675e906_kemi-waybackurls_0_1_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/waybackurls |
| source | tomnomnom/waybackurls@v0.1.0 `86aeb978` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-waybackurls-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/waybackurls/releases/tag/v0.1.0
