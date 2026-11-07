# kemi-html-tool (t307)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.html-tool |
| deb | kemi-html-tool_0.0.20220725-1kemi1_arm64.deb |
| app_id | 295 |
| version | 0.0.20220725-1kemi1 / code 20220725 |
| bytes | 1800244 |
| SHA256 | `fb8a9f43b93f324b24160569325ae386340aec03e92cec81067c57c33a04ed59` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794049109242_55655be9_kemi-html-tool_0_0_20220725-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译；版本取 html-tool 路径 commit 日期） |
| install | /usr/bin/html-tool |
| source | tomnomnom/hacks/html-tool@`6fd7870` (2022-07-25) |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-html-tool-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/hacks/tree/master/html-tool
