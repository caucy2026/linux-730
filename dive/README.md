# dive (KEMI Linux arm64)

上游：[wagoodman/dive](https://github.com/wagoodman/dive) v0.13.1  
产物：`kemi-dive_0.13.1-1kemi1_arm64.deb`（linux_arm64 静态，`/usr/bin/dive`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**164**
- package：`com.kemi.dive` / `kemi-dive` / `0.13.1-1kemi1` / version_code **1301**
- bytes：**2630464**
- SHA256：`a6c37d59e14078e585b702bacea6213294e1a9317c83addc64aca453af585adf`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030661993_132f4d62_kemi-dive_0_13_1-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-dive-kemi-deb.sh
```

上游 tar SHA256：`2fcd2cf20f634ccdb41efac44048b204bfc867c115641f37a7420693ed480a18`
