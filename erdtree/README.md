# erdtree (KEMI Linux arm64)

上游：[solidiquis/erdtree](https://github.com/solidiquis/erdtree) v3.1.2  
产物：`kemi-erdtree_3.1.2-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/erd`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**158**
- package：`com.kemi.erdtree` / `kemi-erdtree` / `3.1.2-1kemi1` / version_code **30102**
- bytes：**1731508**
- SHA256：`f75a8b809c807ceefc5941dec0ee9b6ec7b9f4c6c5a8f950b3356284759eab20`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029656239_6c6f8e50_kemi-erdtree_3_1_2-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-erdtree-kemi-deb.sh
```

上游 tar SHA256：`5ad6d70a7ba9636f80a724e669e7ffe9daf2370f8a3f6095e33779e166ced4c2`
