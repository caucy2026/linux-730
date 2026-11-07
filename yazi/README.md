# yazi (KEMI Linux arm64)

上游：[sxyazi/yazi](https://github.com/sxyazi/yazi) v26.9.1  
产物：`kemi-yazi_26.9.1-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/yazi` + `/usr/bin/ya`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**139**
- package：`com.kemi.yazi` / `kemi-yazi` / `26.9.1-1kemi1` / version_code **260901**
- bytes：**9555980**
- SHA256：`0560c0d8805509532ca206f69e9fc6379339ee432a1176fd343c87d6d5a25956`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027258664_7490cf03_kemi-yazi_26_9_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-yazi-kemi-deb.sh
```

上游 zip SHA256：`dd569daecaae914185f295634109295ccd25c1b42b02eb89a74f651970024f2e`
