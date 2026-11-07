# doggo (KEMI Linux arm64)

上游：[mr-karan/doggo](https://github.com/mr-karan/doggo) v1.4.2  
产物：`kemi-doggo_1.4.2-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/doggo`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**153**
- package：`com.kemi.doggo` / `kemi-doggo` / `1.4.2-1kemi1` / version_code **10402**
- bytes：**3945624**
- SHA256：`11bf0bfd25eb3de63cefe4aa67165bb1022bffbccabfc8a23ac5ef5c823ae9a2`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029079913_d6023242_kemi-doggo_1_4_2-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-doggo-kemi-deb.sh
```

上游 tar SHA256：`87f876e7c7f78282b4ceb5cfef119a82f9bfa54ef7e6ab916e5a6edb5f1cb878`
