# bottom (KEMI Linux arm64)

上游：[ClementTsang/bottom](https://github.com/ClementTsang/bottom) 0.15.0  
产物：`kemi-bottom_0.15.0-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/btm`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**137**
- package：`com.kemi.bottom` / `kemi-bottom` / `0.15.0-1kemi1` / version_code **1500**
- bytes：**1316068**
- SHA256：`1df8acec5ccd74398a0c6426e37b438e0a694a590d6ecc327fc3bf3b8238a28d`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794026969229_83f95f93_kemi-bottom_0_15_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-bottom-kemi-deb.sh
```

上游 tar SHA256：`78e03e96d02e946be1f94066cd78f1adc3bb8c0db5f53fdf24d70a3ab351e05c`
