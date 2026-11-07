# fselect (KEMI Linux arm64)

上游：[jhspetersson/fselect](https://github.com/jhspetersson/fselect) 0.10.4  
产物：`kemi-fselect_0.10.4-1kemi1_arm64.deb`（aarch64-linux-musl 静态，`/usr/bin/fselect`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**178**
- package：`com.kemi.fselect` / `kemi-fselect` / `0.10.4-1kemi1` / version_code **1004**
- bytes：**2808816**
- SHA256：`a0c56836a1755555ac1e7fe3b6b48251c8681fe379cc9f3f638d62dd27fc296e`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032780008_b1056c69_kemi-fselect_0_10_4-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-fselect-kemi-deb.sh
```

上游 gz SHA256：`8719132405679e609fc548d2746f53de3e8c20220a8c453f00a91256dda31eb6`
