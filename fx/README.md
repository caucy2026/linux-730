# fx (KEMI Linux arm64)

上游：[antonmedv/fx](https://github.com/antonmedv/fx) v40.0.1  
产物：`kemi-fx_40.0.1-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/fx`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**152**
- package：`com.kemi.fx` / `kemi-fx` / `40.0.1-1kemi1` / version_code **400001**
- bytes：**7846840**
- SHA256：`51c08bff8ab730c71759bc91b1a08d7c6f8b6bd8b489b2cfb5aaa281958577ca`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028913678_ea6c5cfe_kemi-fx_40_0_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-fx-kemi-deb.sh
```

上游 binary SHA256：`90377fbdbe3a01f791032a289986867ff1f8fe20ce94b45f20ecb399f7b69411`
