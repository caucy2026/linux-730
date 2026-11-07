# dasel (KEMI Linux arm64)

上游：[TomWright/dasel](https://github.com/TomWright/dasel) v3.11.2  
产物：`kemi-dasel_3.11.2-1kemi1_arm64.deb`（linux_arm64 静态，`/usr/bin/dasel`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**176**
- package：`com.kemi.dasel` / `kemi-dasel` / `3.11.2-1kemi1` / version_code **31102**
- bytes：**2558784**
- SHA256：`58992e31e13ae70595f202931588cbb36acf95cb09a9f6d75ef57c19bbe59d1b`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032346463_b376af82_kemi-dasel_3_11_2-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-dasel-kemi-deb.sh
```

上游 bin SHA256：`df33920a792cd8ee5573cec3632a710cd2178d7bc4fc3892c6be78f35e7cbcc6`
