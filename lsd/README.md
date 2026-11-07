# lsd (KEMI Linux arm64)

上游：[lsd-rs/lsd](https://github.com/lsd-rs/lsd) v1.2.0  
产物：`kemi-lsd_1.2.0-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/lsd`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**141**
- package：`com.kemi.lsd` / `kemi-lsd` / `1.2.0-1kemi1` / version_code **102000**
- bytes：**1111548**
- SHA256：`100121c577d536d0607e81cecdf03ccd1ec93b7b80f5a6297b0afc2c2f1f9d3d`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027471104_faaf17c8_kemi-lsd_1_2_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-lsd-kemi-deb.sh
```

上游 tar SHA256：`642ecb1a763b9f790a99c83a1445c117a6813ed4edb5d498d4420423c6353eb8`
