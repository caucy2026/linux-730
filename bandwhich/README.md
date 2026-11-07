# bandwhich (KEMI Linux arm64)

上游：[imsnif/bandwhich](https://github.com/imsnif/bandwhich) v0.23.1  
产物：`kemi-bandwhich_0.23.1-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/bandwhich`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**144**
- package：`com.kemi.bandwhich` / `kemi-bandwhich` / `0.23.1-1kemi1` / version_code **2301**
- bytes：**989000**
- SHA256：`fd3e10675ec13f7e6e9c5d1c729b6fac4d85c584a3a3371bf6f6a64a9e115e64`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027788256_b5971652_kemi-bandwhich_0_23_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-bandwhich-kemi-deb.sh
```

上游 tar SHA256：`6bbf084e5280a1a10833b8f466728ff428a7d637282c0487d6fcda0c4781357a`
