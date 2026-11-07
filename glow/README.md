# glow (KEMI Linux arm64)

上游：[charmbracelet/glow](https://github.com/charmbracelet/glow) v3.0.0  
产物：`kemi-glow_3.0.0-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/glow`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**148**
- package：`com.kemi.glow` / `kemi-glow` / `3.0.0-1kemi1` / version_code **30000**
- bytes：**4392700**
- SHA256：`90d0c6ec1a593090074af833e9f40e51ee1444ff0dc2722ca42395d485a7db11`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028388567_1aaa4c3d_kemi-glow_3_0_0-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-glow-kemi-deb.sh
```

上游 tar SHA256：`810c39f4691feb75e675a5f5f54b9fa091354e7599d9cf9c9fc9b97e47a99759`
