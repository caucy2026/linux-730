# kemi-hakrawler (t301)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.hakrawler |
| deb | kemi-hakrawler_2.1.0-1kemi1_arm64.deb |
| app_id | 289 |
| version | 2.1.0-1kemi1 / code 20100 |
| bytes | 3349928 |
| SHA256 | `b6cc186c4e7c187f84931e229611e064933b8ebd9c36c5a971b359e75da9ca3b` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048291719_2704bfef_kemi-hakrawler_2_1_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 release 资产） |
| install | /usr/bin/hakrawler |
| source | hakluke/hakrawler@2.1 `61905593` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-hakrawler-kemi-deb.sh
```

Upstream: https://github.com/hakluke/hakrawler/tree/2.1
