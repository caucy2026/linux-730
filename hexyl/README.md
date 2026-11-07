# hexyl (KEMI Linux arm64)

上游：[sharkdp/hexyl](https://github.com/sharkdp/hexyl) v0.17.0  
产物：`kemi-hexyl_0.17.0-1kemi1_arm64.deb`（aarch64-gnu MAX GLIBC 2.17，`/usr/bin/hexyl`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**160**
- package：`com.kemi.hexyl` / `kemi-hexyl` / `0.17.0-1kemi1` / version_code **1700**
- bytes：**380348**
- SHA256：`9faaa062e916de89100a030dc0feae825f29935f04e8c3d4426a3a07dca09ed7`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029886833_421903d5_kemi-hexyl_0_17_0-1kemi1_arm64.deb
- MAX_GLIBC：2.17

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-hexyl-kemi-deb.sh
```

上游 tar SHA256：`70b97648935f98801fd3c3e4758ff4e92afcf7e75316ff65d4e4f5d2e321b658`
