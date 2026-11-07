# tealdeer (KEMI Linux arm64)

上游：[tealdeer-rs/tealdeer](https://github.com/tealdeer-rs/tealdeer) v1.9.1  
产物：`kemi-tealdeer_1.9.1-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/tldr`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**147**
- package：`com.kemi.tealdeer` / `kemi-tealdeer` / `1.9.1-1kemi1` / version_code **10901**
- bytes：**1271576**
- SHA256：`e59d1d306eecdfe005967a630857f1fe2c92146e81880b32c69f3ce639f1188e`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028291517_49cf14ef_kemi-tealdeer_1_9_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-tealdeer-kemi-deb.sh
```

上游 binary SHA256：`247746dd2d18f0135da79b849bb6b49e45262e2fe4318adfc3082dc6ce3ee968`
