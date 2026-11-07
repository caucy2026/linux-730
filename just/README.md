# just (KEMI Linux arm64)

上游：[casey/just](https://github.com/casey/just) v1.59.0  
产物：`kemi-just_1.59.0-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/just`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**150**
- package：`com.kemi.just` / `kemi-just` / `1.59.0-1kemi1` / version_code **15900**
- bytes：**1572224**
- SHA256：`781785df4c2d39be62c4c700589006bff14bf187b7080a85f205be9d7d1219bf`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028669448_42fd6b79_kemi-just_1_59_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-just-kemi-deb.sh
```

上游 tar SHA256：`23871b1702bfd550fb5f901778fd4290ecf2ee034a45a889fbe96d89b188086d`
