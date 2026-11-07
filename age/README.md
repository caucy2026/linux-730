# age (KEMI Linux arm64)

上游：[FiloSottile/age](https://github.com/FiloSottile/age) v1.3.2  
产物：`kemi-age_1.3.2-1kemi1_arm64.deb`（linux-arm64 静态，`/usr/bin/age` 等）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**162**
- package：`com.kemi.age` / `kemi-age` / `1.3.2-1kemi1` / version_code **10302**
- bytes：**12288964**
- SHA256：`8d779851497c1e7ce603aa9ef2c98822b37aa6f530e75545d5d457cce4201e6e`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030244463_0283245c_kemi-age_1_3_2-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 包含二进制

`age` · `age-keygen` · `age-inspect` · `age-plugin-batchpass` · `age-plugin-pq` · `age-plugin-tag` · `age-plugin-tagpq`

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-age-kemi-deb.sh
```

上游 tar SHA256：`6b8dc4333c53a5a57c9e5834e3a48f92605d7154014cd07269ff3327db5d37f4`
