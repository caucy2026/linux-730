# trippy (KEMI Linux arm64)

上游：[fujiapple852/trippy](https://github.com/fujiapple852/trippy) 0.13.0  
产物：`kemi-trippy_0.13.0-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/trip`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**174**
- package：`com.kemi.trippy` / `kemi-trippy` / `0.13.0-1kemi1` / version_code **1300**
- bytes：**2252992**
- SHA256：`6124dce1d6def9bcc31a5679b860d9e6049f0f2de92198a4edab76b2b14fef30`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032087564_903c1f65_kemi-trippy_0_13_0-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）
- 命令：`trip`

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-trippy-kemi-deb.sh
```

上游 tar SHA256：`73af939aa94e9e0f07cac2b3c8177e02a6b1c3be88299d85988e02be81ae7004`
