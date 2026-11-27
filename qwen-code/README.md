# qwen-code（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.qwen-code` |
| dpkg | `kemi-qwen-code` |
| app_name | Qwen Code |
| version | `0.28.7-1kemi1` / version_code `28007` |
| upstream | QwenLM/qwen-code official `qwen-code-linux-arm64.tar.gz` v0.28.7（T154 时为 v0.28.4；本包用当前稳定版） |
| install | `/opt/qwen-code` + `/usr/bin/qwen` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `94240b805c372dbb6d48405b61411ccadbb6be2d1aa6ab9941043b3cec64c943` |
| size | 50792256 B |
| ABI | probe PASS：仅 aarch64，MAX_GLIBC 2.28，MAX_GLIBCXX 3.4.22 |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 去掉非 linux-arm64 的 vendor ripgrep / landlock。
- 去掉 optionalDependency `@qwen-code/audio-capture` 的 linux-arm64 预编译（GLIBC_2.34）；CLI 可启动，语音采集在 U20 不可用。
- 未使用 v1.0.0-preview.2 musl（gnu 在剥离后即过 ABI）。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-qwen-code-kemi-deb.sh`
- 用户自备 API Key。

合主线注明「gork.bot协助开发」。
