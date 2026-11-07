# ouch (KEMI Linux arm64)

上游：[ouch-org/ouch](https://github.com/ouch-org/ouch) 0.8.3  
产物：`kemi-ouch_0.8.3-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/ouch`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**155**
- package：`com.kemi.ouch` / `kemi-ouch` / `0.8.3-1kemi1` / version_code **803**
- bytes：**1849024**
- SHA256：`3b4b4a95bcf0e7d84446084da228e0eadad18900d56a4668ee7c248806083434`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029325847_c59958f2_kemi-ouch_0_8_3-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-ouch-kemi-deb.sh
```

上游 tar SHA256：`4619158de69e65e8d23147c3d8b46b116feb0259c8a1704df7d792394c2b5847`
