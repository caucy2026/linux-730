# gitui (KEMI Linux arm64)

上游：[gitui-org/gitui](https://github.com/gitui-org/gitui) v0.28.1  
产物：`kemi-gitui_0.28.1-1kemi1_arm64.deb`（linux-aarch64 gnu MAX GLIBC 2.28，`/usr/bin/gitui`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**171**
- package：`com.kemi.gitui` / `kemi-gitui` / `0.28.1-1kemi1` / version_code **2801**
- bytes：**5493248**
- SHA256：`af216338fd2793695fc35e9188fcaea9807477bb4dc7dbcca8b09b8e27ceef28`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794031648243_fa842945_kemi-gitui_0_28_1-1kemi1_arm64.deb
- MAX_GLIBC：2.28（无 musl 资产）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-gitui-kemi-deb.sh
```

上游 tar SHA256：`2a640da05b73e9152a7bf92bfd7c23acd9d60438f4f2cabb62357014a5fd7c28`
