# kemi-goreleaser (t270)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.goreleaser |
| deb | kemi-goreleaser_2.20.0-1kemi1_arm64.deb |
| app_id | 258 |
| version | 2.20.0-1kemi1 / code 22000 |
| bytes | 16426012 |
| SHA256 | `b068862043ee235c544f1be3f0d1311ad4378c5a1fbce99b61a04bfc5714fb91` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794044228159_ed285088_kemi-goreleaser_2_20_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/goreleaser |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-goreleaser-kemi-deb.sh
```

Upstream: https://github.com/goreleaser/goreleaser/releases/tag/v2.20.0
