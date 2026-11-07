# viddy (KEMI Linux arm64)

上游：[sachaos/viddy](https://github.com/sachaos/viddy) v1.3.1  
产物：`kemi-viddy_1.3.1-1kemi1_arm64.deb`（linux-arm64 静态，`/usr/bin/viddy`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**166**
- package：`com.kemi.viddy` / `kemi-viddy` / `1.3.1-1kemi1` / version_code **10301**
- bytes：**2691184**
- SHA256：`b1c0575966ba6e3dd7d3fa2d704acd1ecbd68d8ffa6f7019353e1cf218350ed5`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030965956_78e811df_kemi-viddy_1_3_1-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-viddy-kemi-deb.sh
```

上游 tar SHA256：`4bf88aa5443b09a49e8af55c1e92ff6148486856703b8f886e1984b0e541af4d`
