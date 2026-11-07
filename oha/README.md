# oha (KEMI Linux arm64)

上游：[hatoo/oha](https://github.com/hatoo/oha) v1.16.0  
产物：`kemi-oha_1.16.0-1kemi1_arm64.deb`（linux-arm64 静态，`/usr/bin/oha`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**173**
- package：`com.kemi.oha` / `kemi-oha` / `1.16.0-1kemi1` / version_code **11600**
- bytes：**3304736**
- SHA256：`c713ec15ee9023193392235faa802434fdc8977e59c52ee1f43d7fc854164904`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031927040_44e0c031_kemi-oha_1_16_0-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-oha-kemi-deb.sh
```

上游 bin SHA256：`99a790eb8c3e0feaca974bd6b32f0f8d4426a0c5b289f39e833e5b2c7529cd39`
