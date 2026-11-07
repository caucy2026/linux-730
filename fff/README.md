# kemi-fff (t306)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.fff |
| deb | kemi-fff_0.0.20210805-1kemi1_arm64.deb |
| app_id | 294 |
| version | 0.0.20210805-1kemi1 / code 20210805 |
| bytes | 1784680 |
| SHA256 | `33b7164375b9944734316da86f024a3be4486672ce67e0e4424e8094e6f90064` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048954947_e9de0a04_kemi-fff_0_0_20210805-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译；无 tag，版本取 commit 日期） |
| install | /usr/bin/fff |
| source | tomnomnom/fff@master `544f7e59` (2021-08-05) |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-fff-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/fff
