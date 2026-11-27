# codewhale（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.codewhale` |
| dpkg | `kemi-codewhale` |
| app_name | Codewhale |
| version | `0.10.4-1kemi1` / version_code `10004` |
| upstream | codewhale-hq/Codewhale official `codewhale-linux-arm64.tar.gz` v0.10.4 |
| install | `/opt/codewhale` + `/usr/bin/codewhale` + `/usr/bin/codew` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `923c56ea5ea86b7f44b126dc4963a99cafd2b3e7ba7d237936f03a60ec5755a2` |
| size | 38662700 B |
| ABI | official static aarch64 EXEC，无 PT_INTERP / 无 glibc NEEDED |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 官方 tarball 里 `codew` 与 `codewhale` 是同一 sha256 的两份拷贝；包内只装一份，`/usr/bin/codew` 为符号链接。
- 未纳入官方 `install.sh`（写 `~/.local`）。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-codewhale-kemi-deb.sh`
- 用户自备 API Key。

合主线注明「gork.bot协助开发」。
