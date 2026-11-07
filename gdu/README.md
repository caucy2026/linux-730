# gdu (KEMI Linux arm64)

上游：[dundee/gdu](https://github.com/dundee/gdu) v5.39.0  
产物：`kemi-gdu_5.39.0-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/gdu`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**143**
- package：`com.kemi.gdu` / `kemi-gdu` / `5.39.0-1kemi1` / version_code **539000**
- bytes：**5925168**
- SHA256：`47125adcd668ba63b77dac6930b57e1f963047e70f13308848e213787241db42`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027679234_178f5090_kemi-gdu_5_39_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-gdu-kemi-deb.sh
```

上游 tar SHA256：`95900a16b9f9dad97f975b667644ddc073a1b377e95a0b4dfdf50045bf556ad0`
