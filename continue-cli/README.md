# continue-cli (KEMI Linux)

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.continue-cli` |
| dpkg | `kemi-continue-cli` |
| version | `1.5.47-1kemi1` / version_code `10547` |
| upstream | npm **@continuedev/cli 1.5.47**（Apache-2.0） |
| install | `/opt/kemi-continue-cli` + `/usr/bin/cn` |
| runtime | 复用 `/opt/openclaw-node` Node ≥20（101 已有 v26） |
| category | 工作 |
| app_id | **127** |
| SHA256 | `216b0ca6f52edcc13ae111ed0bd605523b5715d6803d30d26686eb096c2f8797` |
| size | 8720280 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793973078797_165c33b9_kemi-continue-cli_1_5_47-1kemi1_arm64.deb` |
| CREATE | **DONE**（t138 2026-11-06 Asia/Shanghai）四层 L1–L4 PASS |
| 101 smoke | CDN curl + dpkg -i + `cn --help` / `cn --version` PASS；VK_PIDS 前后不变 |

## 边界

- 终端写码 Agent；需 Continue 账号或 Anthropic key；冒烟不塞 key。
- 上游仓只读/终版风险；本包钉 npm 1.5.47 可再分发物。
- 无 Docker；优先复用 `/opt/openclaw-node`。

## 构建

见 `scripts/build-continue-cli-kemi-deb.sh`（箱侧）。勿把 appstore token 写入本树。勿 git push（由合主线另开）。
