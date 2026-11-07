# tokei (KEMI Linux arm64)

上游：[XAMPPRocky/tokei](https://github.com/XAMPPRocky/tokei) v12.1.2  
产物：`kemi-tokei_12.1.2-1kemi1_arm64.deb`（aarch64 gnu，GLIBC≤2.18，`/usr/bin/tokei`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

注：上游 v13+/v14+/v15+ 无预编译资产；本包取最后公开发布的 aarch64 二进制。

## 商场指纹（CREATE 后钉死）

- app_id：**151**
- package：`com.kemi.tokei` / `kemi-tokei` / `12.1.2-1kemi1` / version_code **120102**
- bytes：**1358112**
- SHA256：`15b52b0a19262ae0d3fc5894f207ff43bfd451ce913815ba5cb5958f74024c71`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028784671_b39ca0cb_kemi-tokei_12_1_2-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-tokei-kemi-deb.sh
```

上游 tar SHA256：`ef514fd12cfc3ee2d1725e5ecb866ee1123163004879ec285b22f3323389ebe2`  
ELF：需 libc；MAX GLIBC_2.18（≤2.31）。
