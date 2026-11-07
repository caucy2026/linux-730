# zellij (KEMI Linux arm64)

上游：[zellij-org/zellij](https://github.com/zellij-org/zellij) v0.45.1  
产物：`kemi-zellij_0.45.1-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/zellij`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**138**
- package：`com.kemi.zellij` / `kemi-zellij` / `0.45.1-1kemi1` / version_code **4501**
- bytes：**10171936**
- SHA256：`38409d2253848f3596be32898a70dbfad9de7d1abfe2f1f4e64ec90e5c31ca06`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794027088709_a36c511e_kemi-zellij_0_45_1-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-zellij-kemi-deb.sh
```

上游 tar SHA256：`05f0802afadd53f8db9514e7cae53c9ae8432fed1b35b8294aa816ee3044a16b`  
上游 binary SHA256：`2a2c0621e6f3b11ecbb05d66939a48000a2508604620aa20727a5fd61c49f451`
