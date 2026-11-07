# duf (KEMI Linux arm64)

上游：[muesli/duf](https://github.com/muesli/duf) v0.9.1  
产物：`kemi-duf_0.9.1-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/duf`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**142**
- package：`com.kemi.duf` / `kemi-duf` / `0.9.1-1kemi1` / version_code **901**
- bytes：**855516**
- SHA256：`c17d8a8e0aa5847be667a32be772a797f3eb4e604ece1b80b9771fc0718a6156`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027573331_3a0d9617_kemi-duf_0_9_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-duf-kemi-deb.sh
```

上游 tar SHA256：`22ea0ad29f6610bf443aa351e600de97e47a9b380ef58316606a84bb8f595216`
