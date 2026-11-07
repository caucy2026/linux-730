# riff (KEMI Linux arm64)

上游：[walles/riff](https://github.com/walles/riff) 3.7.0  
产物：`kemi-riff_3.7.0-1kemi1_arm64.deb`（aarch64-linux 静态，`/usr/bin/riff`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**179**
- package：`com.kemi.riff` / `kemi-riff` / `3.7.0-1kemi1` / version_code **30700**
- bytes：**1356216**
- SHA256：`338a8f0957fc302afc276312e0d25924329d416f3191bdcee1debcb680a54cc2`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032889009_f3aa00f0_kemi-riff_3_7_0-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-riff-kemi-deb.sh
```

上游 bin SHA256：`1acbe244b18a4d60b7ef5aafb5f8c538548817ab528c52bccabf27737e3698df`
