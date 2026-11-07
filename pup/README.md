# pup (KEMI Linux arm64)

上游：[ericchiang/pup](https://github.com/ericchiang/pup) v0.4.0  
产物：`kemi-pup_0.4.0-1kemi1_arm64.deb`（linux_arm64 静态，`/usr/bin/pup`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**180**
- package：`com.kemi.pup` / `kemi-pup` / `0.4.0-1kemi1` / version_code **400**
- bytes：**1157092**
- SHA256：`bfaffe1071f9ad5ec4cd557bba5e9c5e8122ed1c2b79d437271107cc09355ed3`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032986946_b8010779_kemi-pup_0_4_0-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-pup-kemi-deb.sh
```

上游 zip SHA256：`c09b669fa8240f4f869dee7d34ee3c7ea620a0280cee1ea7d559593bcdd062c9`
