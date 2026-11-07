# pi-bolt（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.pi-bolt` |
| dpkg | `kemi-pi-bolt` |
| version | `1.1.2-1kemi1` / version_code `10102` |
| upstream | Pi-Bolt **1.1.2**（`bolt-v1.1.2`）linux arm64 AOT（MIT） |
| upstream tar SHA256 | `b4c37c4a6364334f1ec1f3eb53997c59dabe2aa95809803382b8244b35e6201a` |
| install | `/opt/kemi-pi-bolt` + `/usr/bin/pi-bolt` + `/usr/bin/pi` |
| runtime | arm64 AOT（glibc 符号最高 2.17；无 Docker、无 Node） |
| category | 工作 |
| app_id | **131** |
| SHA256 | `d9c92c20f0b8b87d6dade8e67f93e5608dc6aa96eeb44daebeb12ca471278c46` |
| size | 63488156 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794025339547_c74fe953_kemi-pi-bolt_1_1_2-1kemi1_arm64.deb` |
| CREATE | app131 已上 KEMI 商场；四层 L1–L4 PASS |
| 101 smoke | **BLOCKED_TRANSPORT**。待目标 Vibekits 重启后补冒烟 |

## 用途

Pi-Bolt — 把 Pi 编程智能体提前编译成单个原生可执行文件。会话、技能/扩展、MCP、多模型提供商；用户自备 API Key。启动更快、内存更省，无需 Node/Docker。

## 上游

- Pi-Bolt `1.1.2` / tag `bolt-v1.1.2` linux arm64 AOT
- https://github.com/opensec-git/Pi-Bolt/releases/download/bolt-v1.1.2/pi-bolt-linux-arm64.tar.xz
- tar.xz SHA256: `b4c37c4a6364334f1ec1f3eb53997c59dabe2aa95809803382b8244b35e6201a`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

见 `pi-bolt-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-pi-bolt-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。app131 `com.kemi.pi-bolt` `1.1.2-1kemi1` 已在 KEMI 商场（CREATE + 四层 PASS）。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
