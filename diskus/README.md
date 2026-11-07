# diskus (KEMI Linux arm64)

上游：[sharkdp/diskus](https://github.com/sharkdp/diskus) v0.9.0  
产物：`kemi-diskus_0.9.0-1kemi1_arm64.deb`（aarch64-gnu MAX GLIBC 2.18，`/usr/bin/diskus`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**159**
- package：`com.kemi.diskus` / `kemi-diskus` / `0.9.0-1kemi1` / version_code **900**
- bytes：**292688**
- SHA256：`46b952d13504e8fc8eab16de00841ad4d7884b18ee0560f56a64834f99909e71`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029770695_303d35db_kemi-diskus_0_9_0-1kemi1_arm64.deb
- MAX_GLIBC：2.18

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-diskus-kemi-deb.sh
```

上游 tar SHA256：`de8d7b4147911ed228fffeb49e4d19bc42c23a65eb4e3db98058ad9778a835cb`
