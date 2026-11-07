# pastel (KEMI Linux arm64)

上游：[sharkdp/pastel](https://github.com/sharkdp/pastel) v0.12.0  
产物：`kemi-pastel_0.12.0-1kemi1_arm64.deb`（aarch64-gnu MAX GLIBC 2.18，`/usr/bin/pastel`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**161**
- package：`com.kemi.pastel` / `kemi-pastel` / `0.12.0-1kemi1` / version_code **1200**
- bytes：**378088**
- SHA256：`1b38ffbd4f46a7b36df76edb7918e0c4f64b9ba12b911842a42b31f7d9ab5b27`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030130004_24f20ce3_kemi-pastel_0_12_0-1kemi1_arm64.deb
- MAX_GLIBC：2.18

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-pastel-kemi-deb.sh
```

上游 tar SHA256：`f437e19974399ab7ae99fa52b76a2cdfad4fafafde3b48243100d371894935ba`
