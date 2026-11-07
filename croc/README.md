# croc (KEMI Linux arm64)

上游：[schollz/croc](https://github.com/schollz/croc) v11.6.4  
产物：`kemi-croc_11.6.4-1kemi1_arm64.deb`（Linux-ARM64 静态，`/usr/bin/croc`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**165**
- package：`com.kemi.croc` / `kemi-croc` / `11.6.4-1kemi1` / version_code **110604**
- bytes：**8201492**
- SHA256：`6fda9cf436678bf576975ca695a3da451c00044b80b94fb53b1ff887b7e7a52d`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794030795766_ec94c282_kemi-croc_11_6_4-1kemi1_arm64.deb
- STATIC：yes（无 NEEDED）

## 包含二进制

`croc` · `croc-update`

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-croc-kemi-deb.sh
```

上游 tar SHA256：`e98ec8edd339fd0a272d7b37a0f0e464199efafac03a6dedee0f4dc71449fd53`
