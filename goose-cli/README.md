# goose-cli（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.goose` |
| dpkg | `kemi-goose` |
| version | `1.57.0-1kemi1` / version_code `157000` |
| upstream | Block Goose **1.57.0** linux aarch64 musl 静态二进制（Apache-2.0） |
| upstream tar SHA256 | `00a32522f0421ed72fc06f36bfc44c8e51cffefb4daf22a81bb84ccd29d1a1ce` |
| install | `/usr/bin/goose` |
| runtime | arm64 static musl（无 Docker、无额外 glibc 依赖） |
| category | 工作 |
| app_id | **130** |
| SHA256 | `1439d6fb4c7ab3d4e38609cc8878b44d020665e357d20783204882d484bffffe` |
| size | 28755776 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794025022256_a359256d_kemi-goose_1_57_0-1kemi1_arm64.deb` |
| CREATE | app130 已上 KEMI 商场 |
| 101 smoke | **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待目标 Vibekits 重启后补冒烟 |

## 用途

Block Goose — 开源终端 AI agent。多 Provider；用户自备 API Key。

## 上游

- Goose `1.57.0` linux aarch64 **musl**（静态）
- https://github.com/aaif-goose/goose/releases/tag/v1.57.0
- tar.gz SHA256: `00a32522f0421ed72fc06f36bfc44c8e51cffefb4daf22a81bb84ccd29d1a1ce`
- **巨大二进制不进 git**；构建时从上游下载
- 选用 musl CLI（~46MiB tar / ~28MiB deb）而非官方桌面 arm64.deb（~137MiB），完整 agent、无 Docker、日后更易装 101

## Artifact

见 `goose-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-goose-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。app130 `com.kemi.goose` `1.57.0-1kemi1` 已在 KEMI 商场。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
