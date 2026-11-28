# kilo-code（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.kilo-code` |
| dpkg | `kemi-kilo-code` |
| app_name | Kilo Code |
| version | `7.8.40-1kemi1` / version_code `70840` |
| upstream | Kilo-Org/kilocode official `kilo-linux-arm64.tar.gz` v7.8.40 |
| install | `/opt/kilo-code` + `/usr/bin/kilo` + `/usr/bin/kilo-code` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（勿发明） |
| SHA256 | `bd02d520324e2e8b57f7185f9b90c868569c9973666101ddb51d80d489da82ad` |
| size | 57446560 B |
| ABI | official gnu aarch64 EXEC，INTERP `/lib/ld-linux-aarch64.so.1`，MAX_GLIBC 2.17 |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 只打官方 gnu CLI tarball，不打 `kilo-vscode-*.vsix`，不打官方 musl tarball（动态 ld-musl，101 不可跑）。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-kilo-code-kemi-deb.sh`
- Kilo CLI 是 OpenCode 的下游增强产品，但品牌、仓库与已上架 `ai.opencode.cli`（app104）不是同一标题。
- 用户自备模型或平台账号。

合主线注明「gork.bot协助开发」。
