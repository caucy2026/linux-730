# crush-cli（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.crush` |
| dpkg | `kemi-crush` |
| version | `0.100.0-1kemi1` / version_code `100000` |
| upstream | Charm Crush **0.100.0** linux arm64 静态二进制（FSL-1.1-MIT） |
| upstream tar SHA256 | `095e3ab19710508e9ae41919e5f179f69bac390aeb7c06a14ef999c78dde705a` |
| install | `/usr/bin/crush`（+ man / completions） |
| runtime | arm64 static（无额外 glibc 依赖） |
| category | 工作 |
| app_id | **129** |
| SHA256 | `675bddc1cb20a3ee11636d72d8f4b699570986a7abe8c63db31a840abfda9ac1` |
| size | 16602996 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794024792855_7de8fd59_kemi-crush_0_100_0-1kemi1_arm64.deb` |
| CREATE | app129 已上 KEMI 商场；四层 L1–L4 PASS |
| 101 smoke | **BLOCKED_TRANSPORT**（newlink→101 `transport_timeout` / silent peer）。待目标 Vibekits 重启后补冒烟 |

## 用途

Charm Crush — 终端 AI coding agent。多模型；用户自备 API Key。

## 上游

- Crush `0.100.0` linux arm64（静态）
- https://github.com/charmbracelet/crush/releases/tag/v0.100.0
- tar.gz SHA256: `095e3ab19710508e9ae41919e5f179f69bac390aeb7c06a14ef999c78dde705a`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

见 `crush-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-crush-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（newlink→101 `transport_timeout` / silent peer）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。app129 `com.kemi.crush` `0.100.0-1kemi1` 已在 KEMI 商场（CREATE + 四层 PASS）。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
