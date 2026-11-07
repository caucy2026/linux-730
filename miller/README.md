# miller (KEMI Linux arm64)

上游：[johnkerl/miller](https://github.com/johnkerl/miller) v6.22.0  
产物：`kemi-miller_6.22.0-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/mlr`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**156**
- package：`com.kemi.miller` / `kemi-miller` / `6.22.0-1kemi1` / version_code **62200**
- bytes：**3776692**
- SHA256：`b2e8cbd5be9dfa445cc990b47d38db9892e9ef83f012b22bae770483ad35f83a`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029455353_248b75ff_kemi-miller_6_22_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-miller-kemi-deb.sh
```

上游 tar SHA256：`86dbf9078cf4cd96fef7a8306b3786a441cdf7f8526324a233e38c37c4bfe742`
