# sad (KEMI Linux arm64)

上游：[ms-jpq/sad](https://github.com/ms-jpq/sad) v0.4.33  
产物：`kemi-sad_0.4.33-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/sad`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**169**
- package：`com.kemi.sad` / `kemi-sad` / `0.4.33-1kemi1` / version_code **433**
- bytes：**996104**
- SHA256：`3d07618e4500b8c2e6464dda410937ac50f3c20dac7dec1ad44249a78f1edba8`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031408481_1c77cf51_kemi-sad_0_4_33-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-sad-kemi-deb.sh
```

上游 zip SHA256：`81546b7fa93a8b5928fc2b780ccb84e51cdc463d9a635cc835b9dab2d3ad5e46`
