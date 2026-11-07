# kemi-qsreplace (t299)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.qsreplace |
| deb | kemi-qsreplace_0.0.3-1kemi1_arm64.deb |
| app_id | 287 |
| version | 0.0.3-1kemi1 / code 3 |
| bytes | 565928 |
| SHA256 | `af45561c566e2f779c0f9baeccffa9a7787e93b90b4215ca29d3b360c6a54852` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048052267_8a7d0776_kemi-qsreplace_0_0_3-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/qsreplace |
| source | tomnomnom/qsreplace@v0.0.3 `320475be` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-qsreplace-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/qsreplace/releases/tag/v0.0.3
