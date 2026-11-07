# skim (KEMI Linux arm64)

上游：[skim-rs/skim](https://github.com/skim-rs/skim) v5.9.0  
产物：`kemi-skim_5.9.0-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/sk`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**172**
- package：`com.kemi.skim` / `kemi-skim` / `5.9.0-1kemi1` / version_code **50900**
- bytes：**1999932**
- SHA256：`66243ff3c88676337a87fcab1be11108c2d2d2b0df5b72daa5be4eefd9fc9deb`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031759516_f2cc3b0d_kemi-skim_5_9_0-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）
- 命令：`sk`

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-skim-kemi-deb.sh
```

上游 tar SHA256：`651fa4314223e3c32478f32cab22cf046943c6852caa220c73f211f785bc257a`
