# reasonix-cli（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.reasonix` |
| dpkg | `kemi-reasonix` |
| app_name | Reasonix |
| version | `2.61.0-1kemi1` / version_code `26100` |
| upstream | esengine/DeepSeek-Reasonix official `reasonix-linux-arm64.tar.gz` v2.61.0 |
| install | `/opt/reasonix` + `/usr/bin/reasonix` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `4129a969da3864e7966d3dab24821f13fc19d63f723d0fea9365d977e4412526` |
| size | 31056040 B |
| ABI | official static aarch64 EXEC，无 PT_INTERP / 无 glibc NEEDED |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 只打官方 CLI tarball，不打 Reasonix Studio desktop deb/AppImage。
- frontend-next 随官方 tarball 安装到 `/opt/reasonix/frontend-next`，供 `reasonix serve --page /opt/reasonix/frontend-next/dist`。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-reasonix-kemi-deb.sh`
- 用户自备 LLM API Key。

合主线注明「gork.bot协助开发」。
