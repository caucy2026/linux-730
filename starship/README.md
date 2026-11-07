# starship（com.kemi.starship）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

- 上游：https://github.com/starship/starship v1.27.0（`aarch64-unknown-linux-musl` 静态）
- 包装：`scripts/build-starship-kemi-deb.sh` → `/usr/bin/starship`
- 商场：app_id **136** · `1.27.0-1kemi1` / version_code **127000**
- 产物 SHA256：`69d425014ee19b1c7ce3b61c7d9e9682abbcb91c774be8edd83c84eceeea2651`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794026817343_30b04473_kemi-starship_1_27_0-1kemi1_arm64.deb
- 上游 tar SHA256：`341f5cbf24699fa0b27ec88965ad25f862ea09e15d35a543fd6ffdff1d2aa00d`
- ABI：静态 aarch64（适合 101 glibc 2.31）
- 选型：helix 25.07.1 官方 aarch64-linux 需 GLIBC_2.34，不适配设备 glibc 2.31，故改选 starship musl
- 冒烟：BLOCKED_TRANSPORT（禁止 connect RID 7634801763）

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-starship-kemi-deb.sh
```
