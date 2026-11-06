# aider-cli (KEMI Linux)

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.aider` |
| dpkg | `kemi-aider` |
| version | `0.86.2-1kemi1` / version_code `862` |
| upstream | PyPI **aider-chat 0.86.2** |
| install | `/opt/kemi-aider`（CPython 3.12 aarch64 + site-packages）+ `/usr/bin/aider` |
| category | 工作 |
| app_id | **125** |
| SHA256 | `cdde1889b1224fc9d256c25f2603b9e574377b1e551fe9105e590fd38d6f52b2` |
| size | 111258600 B |
| CDN | `…/1793971927153_e093582b_kemi-aider_0_86_2-1kemi1_arm64.deb` |
| CREATE | **DONE**（t132 2026-11-06 Asia/Shanghai）四层 L1–L4 PASS |
| 101 smoke | CDN curl + dpkg -i + `aider --help` PASS；VK 未变 |

## 边界

- 结对写码 CLI Agent；需用户自备 LLM 密钥；冒烟不塞 key。
- 无 Docker；系统 Py3.8 不够 → 包内自带 3.12。
- 控机弱于 Open Interpreter（偏仓库结对）。

## 构建

见 `scripts/build-aider-kemi-deb.sh`（箱侧）。勿把 appstore token 写入本树。勿 git push（由合主线另开）。
