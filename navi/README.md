# navi (KEMI Linux arm64)

上游：[denisidoro/navi](https://github.com/denisidoro/navi) v2.24.0  
产物：`kemi-navi_2.24.0-1kemi1_arm64.deb`（aarch64 静态，`/usr/bin/navi`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**146**
- package：`com.kemi.navi` / `kemi-navi` / `2.24.0-1kemi1` / version_code **22400**
- bytes：**1236464**
- SHA256：`400a06731d1ff13821edde9a8811a6ea10a903220e86cf410c0f4323e42d2085`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028167891_ca949d70_kemi-navi_2_24_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-navi-kemi-deb.sh
```

上游 tar SHA256：`de99e69906a0e06ffd30a329645e15f9e96a6b42c49eaac8baccac9bc314768a`  
说明：发布资产名为 `aarch64-unknown-linux-gnu`，但 ELF 为静态（无 PT_INTERP / no NEEDED / 无 GLIBC_*），适配 101 glibc≤2.31。
