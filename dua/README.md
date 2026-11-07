# dua (KEMI Linux arm64)

上游：[Byron/dua-cli](https://github.com/Byron/dua-cli) v3.0.0  
产物：`kemi-dua_3.0.0-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/dua`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**157**
- package：`com.kemi.dua` / `kemi-dua` / `3.0.0-1kemi1` / version_code **30000**
- bytes：**1547436**
- SHA256：`9fc31f20de8cb0d61026947b490ebcb70bc53f3b266a6117f84ee4211247a873`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029574020_1d1830ca_kemi-dua_3_0_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-dua-kemi-deb.sh
```

上游 tar SHA256：`642ce5d1ca43ec7504c9452d1d662a02aeb5f451d7fc0093c81c1580f50577f2`
