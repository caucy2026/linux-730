# KEMI CLI 工具集（cli-toolkit）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

将常用开源 CLI 小工具合并为 **一个** arm64 `.deb`，商场只计 **1 个 KPI**。

| 二进制 | 来源 |
|---|---|
| `gh` | kemi-gh |
| `rg` | kemi-ripgrep |
| `jq` | kemi-jq |
| `fd` | kemi-fd |
| `bat` | kemi-bat |
| `yq` | kemi-yq |
| `fzf` | kemi-fzf |
| `delta` | kemi-delta |
| `zoxide` | kemi-zoxide |
| `hyperfine` | kemi-hyperfine |
| `dust` | kemi-dust |
| `procs` | kemi-procs |
| `sd` | kemi-sd |
| `xh` (+ `http`→xh) | kemi-xh 0.26.3 musl aarch64 |

## 商场

- app_id: **123**
- package_name: `com.kemi.cli-toolkit`
- Package: `kemi-cli-toolkit`
- Version: `1.1.0-1kemi1` · version_code `11000`
- Architecture: `arm64` · data.tar.xz（Focal）
- 分类：工作
- 变更：相对 1.0.0 **UPDATE**（非新建），新增 xh

## 构建

1. 成员 `kemi-*.deb` 路径见 `scripts/build-cli-toolkit-deb.sh`
2. `WORKROOT=/workspace/t146-20261107 ./scripts/build-cli-toolkit-deb.sh`
3. 产物：`debs/kemi-cli-toolkit_1.1.0-1kemi1_arm64.deb` + `.sha256`

本目录为配方；**勿直接 git push**（由主线 CloudAgent 合入，消息含「gork.bot协助开发」）。

## t146 制品指纹

见 `kemi-cli-toolkit_1.1.0-1kemi1_arm64.deb.sha256` 与 `toolkit-meta.env`。

| 项 | 值 |
|---|---|
| version | `1.1.0-1kemi1` / version_code `11000` |
| bytes | `27399296` |
| SHA256 | `7cfd819c976411233f18c053b2b6b8005d86134a8ac1d02bd09d8d93b185e6d8` |
| tools | 14：gh、rg、jq、fd、bat、yq、fzf、delta、zoxide、hyperfine、dust、procs、sd、xh |
| 101 smoke | **BLOCKED_TRANSPORT** |

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**。待目标 Vibekits 恢复连通后补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。
