# gping (KEMI Linux arm64)

上游：[orf/gping](https://github.com/orf/gping) gping-v1.21.0  
产物：`kemi-gping_1.21.0-1kemi1_arm64.deb`（Linux-musl-arm64 静态，`/usr/bin/gping`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**170**
- package：`com.kemi.gping` / `kemi-gping` / `1.21.0-1kemi1` / version_code **12100**
- bytes：**957520**
- SHA256：`6dce1c7012c095eb252114c4f8221359a53149f3312e141683d36a9eac17e1d4`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031535270_ee317885_kemi-gping_1_21_0-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-gping-kemi-deb.sh
```

上游 tar SHA256：`75e485e9ae081b4478b7c9fea0585a125dd7e640334cdbdec852af6238c3f1f1`
