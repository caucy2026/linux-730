# grex (KEMI Linux arm64)

上游：[pemistahl/grex](https://github.com/pemistahl/grex) v1.4.6  
产物：`kemi-grex_1.4.6-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/grex`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**168**
- package：`com.kemi.grex` / `kemi-grex` / `1.4.6-1kemi1` / version_code **10406**
- bytes：**855444**
- SHA256：`3e038823329a474bb45c4dc7e5aea2a7faf31cdceba4d6667e188a3cf1ab96d4`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031236764_93001c50_kemi-grex_1_4_6-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-grex-kemi-deb.sh
```

上游 tar SHA256：`65ac2010ffc4a02690b091819f2971c0b26081b2ce7cb717a0de3f10409010b9`
