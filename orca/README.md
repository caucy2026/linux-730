# orca (KEMI Linux)

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.orca` |
| dpkg | `kemi-orca` |
| app_name | Orca |
| version | `1.4.277-1kemi1` / version_code `14277` |
| upstream | stablyai/orca official `orca-ide_1.4.277_arm64.deb` |
| install | `/opt/Orca` + `/usr/bin/orca-ide`（不用 `/usr/bin/orca`，避免与 GNOME Orca 冲突） |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `da56591a64cc27171e60511c9cc7a9b1383c20aab0e71fd365014d531e5080f1` |
| size | 178645428 B |
| ABI | probe PASS：aarch64，MAX_GLIBC 2.28，MAX_GLIBCXX 3.4.22 |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 官方桌面包；去掉非 linux-arm64-glibc 的 orcad-template 与非 linux-arm64 的 ripgrep（含 linux-arm64-musl 中 GLIBCXX_3.4.29 的 watcher.node，101 不用该槽）。
- 用户自备 Claude Code / Codex 等订阅；冒烟不塞 key。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-orca-kemi-deb.sh`

合主线注明「gork.bot协助开发」。
