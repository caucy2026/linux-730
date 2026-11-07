# kemi-unfurl (t298)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.unfurl |
| deb | kemi-unfurl_0.4.3-1kemi1_arm64.deb |
| app_id | 286 |
| version | 0.4.3-1kemi1 / code 403 |
| bytes | 1978340 |
| SHA256 | `c6f1a1f6452a99a6c39645ddaaad9c9d73477e9eff59a9982f70bb270c9dc24d` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794047927727_fb7ad60d_kemi-unfurl_0_4_3-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/unfurl |
| source | tomnomnom/unfurl@v0.4.3 `8f10d050` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-unfurl-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/unfurl/releases/tag/v0.4.3
