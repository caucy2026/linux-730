# watchexec (KEMI Linux arm64)

上游：[watchexec/watchexec](https://github.com/watchexec/watchexec) v2.8.0  
产物：`kemi-watchexec_2.8.0-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/watchexec`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**167**
- package：`com.kemi.watchexec` / `kemi-watchexec` / `2.8.0-1kemi1` / version_code **20800**
- bytes：**2593988**
- SHA256：`44150fe573419efe7c0960dafd7ec344a842e52f32e5bc62462074831800c8ab`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031130817_4867c6b4_kemi-watchexec_2_8_0-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-watchexec-kemi-deb.sh
```

上游 tar SHA256：`3961878b21e3c1729279322f4007dd5bbf0032110fbcb5e7b983946a9ceb3bf6`
