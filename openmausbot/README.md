# openmausbot (KEMI Linux)

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.openmausbot` |
| dpkg | `kemi-openmausbot` |
| version | `0.1.142-1kemi1` / version_code `10142` |
| upstream | OpenMausBot **0.1.142** npm tgz |
| install | `/opt/kemi-openmausbot` + `/usr/bin/openmausbot` |
| runtime | 复用 `/opt/openclaw-node` Node ≥24（101 已有 v26.13.0） |
| category | 工作 |
| app_id | **126** |
| SHA256 | `cc5f405a5b2ef75c2184caafae7cd2501ecdca79eae87bca93c670705d44cfda` |
| size | 13156500 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793972424581_96b0c4cf_kemi-openmausbot_0_1_142-1kemi1_arm64.deb` |
| CREATE | **DONE**（t137 2026-11-06 Asia/Shanghai）四层 L1–L4 PASS |
| 101 smoke | CDN curl + dpkg -i + `openmausbot --help` PASS；VK_PIDS 前后不变 |

## 边界

- **headless 服务包**，非官方 Electron 桌面壳（官方无 Linux aarch64 Electron）。
- UI：`openmausbot serve --port 8799 --no-pair` 后用本机浏览器打开 `http://127.0.0.1:8799`。
- 需用户自备引擎 CLI / LLM 密钥；冒烟不塞 key。
- 依赖 Node≥24；优先 `/opt/openclaw-node`。

## 构建

见 `scripts/build-openmausbot-kemi-deb.sh`（箱侧）。勿把 appstore token 写入本树。勿 git push（由合主线另开）。
