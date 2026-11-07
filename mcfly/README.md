# mcfly (KEMI Linux arm64)

上游：[cantino/mcfly](https://github.com/cantino/mcfly) v0.9.4  
产物：`kemi-mcfly_0.9.4-1kemi1_arm64.deb`（aarch64-musl 静态，`/usr/bin/mcfly`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**175**
- package：`com.kemi.mcfly` / `kemi-mcfly` / `0.9.4-1kemi1` / version_code **904**
- bytes：**1721832**
- SHA256：`949d078788aabc0b45d58c187d1ce4224a5892078122c41085eeb6545359cd86`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032198196_62a3d045_kemi-mcfly_0_9_4-1kemi1_arm64.deb
- STATIC/MUSL：yes（无 NEEDED）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-mcfly-kemi-deb.sh
```

上游 tar SHA256：`57eb23c3c40b3a7675dc1fe3b785501a6a41598b9b3cbe35d80f8d65267cf1cd`
