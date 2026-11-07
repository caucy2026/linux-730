# kemi-naabu (t277)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.naabu |
| deb | kemi-naabu_2.7.0-1kemi1_arm64.deb |
| app_id | 265 |
| version | 2.7.0-1kemi1 / code 20700 |
| bytes | 7340308 |
| SHA256 | `de4a4d6d564a6d7c3d6dd9d8c13d97a057e88ce4104ebacf16373194d047a9ec` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794045097167_0d48bbc1_kemi-naabu_2_7_0-1kemi1_arm64.deb |
| binary | linux-arm64 **gnu** (NEEDED libc; glibc≤2.31 OK; musl skipped) |
| install | /usr/bin/naabu |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-naabu-kemi-deb.sh
```

Upstream: https://github.com/projectdiscovery/naabu/releases/tag/v2.7.0
