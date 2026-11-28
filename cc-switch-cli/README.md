# cc-switch-cli（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.cc-switch-cli` |
| dpkg | `kemi-cc-switch-cli` |
| app_name | CC Switch CLI |
| version | `5.11.4-1kemi1` / version_code `51104` |
| upstream | SaladDay/cc-switch-cli official `cc-switch-cli-linux-arm64-musl.tar.gz` v5.11.4 |
| install | `/opt/cc-switch-cli/cc-switch` + `/usr/bin/cc-switch` + `/usr/bin/cc-switch-cli` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `969dcc4d15c5e0b487bb0da9a4613eae97630343561a0a3cdebf77a2176ee366` |
| size | 5692320 B |
| ABI | official static musl aarch64 EXEC，无 PT_INTERP / 无 glibc NEEDED |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 与桌面版 farion1231/cc-switch（SKIP：glibc 2.35+ / WebKitGTK 4.1）不是同一货架。
- 官方 gnu `cc-switch-cli-linux-arm64.tar.gz` 探测 MAX_GLIBC 2.39，未打包。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-cc-switch-cli-kemi-deb.sh`

合主线注明「gork.bot协助开发」。
