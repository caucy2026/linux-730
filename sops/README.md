# sops (KEMI Linux arm64)

上游：[getsops/sops](https://github.com/getsops/sops) v3.13.3  
产物：`kemi-sops_3.13.3-1kemi1_arm64.deb`（linux.arm64 静态，`/usr/bin/sops`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**163**
- package：`com.kemi.sops` / `kemi-sops` / `3.13.3-1kemi1` / version_code **31303**
- bytes：**9679216**
- SHA256：`27a983fce614795c84eee56f307659e0e183f8e7e98920532853f1e2e511d97a`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030367187_2c9ae696_kemi-sops_3_13_3-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-sops-kemi-deb.sh
```

上游 bin SHA256：`53b0abacd38ef1b12a66d6c100956691b9cefce018d91f81e73ddf7438b94d77`
