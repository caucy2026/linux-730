# openresearch（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.openresearch` |
| dpkg | `kemi-openresearch` |
| app_name | OpenResearch |
| version | `0.2.30-1kemi1` / version_code `2030` |
| upstream | alphaXiv/OpenResearch official `openresearch-cli-aarch64-unknown-linux-musl.tar.gz` v0.2.30 |
| install | `/opt/openresearch/orx` + `/usr/bin/orx` + `/usr/bin/openresearch` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（勿发明） |
| SHA256 | `919a184ab88c91039b7db37152a23109c797ac2bb0dffb647d30022a85f9af1d` |
| size | 22399956 B |
| ABI | official static aarch64 EXEC，无 PT_INTERP / 无 glibc NEEDED |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 只打官方 musl CLI tarball（本构建是静态的）。不打 Linux 桌面 AppImage（上游写明 glibc 2.35+）。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-openresearch-kemi-deb.sh`
- 用户自备上游文档中的账号或密钥。

合主线注明「gork.bot协助开发」。
