# eza (KEMI Linux arm64)

上游：[eza-community/eza](https://github.com/eza-community/eza) v0.23.5  
产物：`kemi-eza_0.23.5-1kemi1_arm64.deb`（`/usr/bin/eza`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

官方无 aarch64 musl；采用 `aarch64-unknown-linux-gnu_no_libgit`（最高需 GLIBC_2.18，适配设备 glibc 2.31）。

## 商场指纹（CREATE 后钉死）

- app_id：**140**
- package：`com.kemi.eza` / `kemi-eza` / `0.23.5-1kemi1` / version_code **2305**
- bytes：**570296**
- SHA256：`32dbd82b99d9ea7be844c17753711b35cd03a8d0edc51a9f655f6b6553040f83`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027372143_b3115a6b_kemi-eza_0_23_5-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-eza-kemi-deb.sh
```

上游 tar SHA256：`1c01b578b5bd3f23b7de5a4b41936cde20fb16ff16a03e63266317ac1eb821e0`
