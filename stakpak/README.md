# stakpak（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.stakpak` |
| dpkg | `kemi-stakpak` |
| app_name | Stakpak |
| version | `0.3.88-1kemi1` / version_code `3088` |
| upstream | stakpak/agent official `stakpak-linux-aarch64.tar.gz` v0.3.88 |
| install | `/opt/stakpak/stakpak` + `/usr/bin/stakpak` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（勿发明） |
| SHA256 | `7e537f224c807423e31eb2eb3460134c799e868ea1317a8f3625a6e78cc13115` |
| size | 17805564 B |
| ABI | official static aarch64 EXEC，无 PT_INTERP / 无动态节 / 无 glibc NEEDED |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 只打官方 linux-aarch64 CLI tarball。配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-stakpak-kemi-deb.sh`
- 用户自备上游文档中的账号或密钥。

合主线注明「gork.bot协助开发」。
