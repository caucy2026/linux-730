# OpenCode CLI（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

OpenCode 命令行（`opencode`）。官方 linux-arm64 发行物原样重打包（Debian 包名 `opencode-cli`，避免与桌面 Package:opencode 撞名）。

## 上游

- OpenCode `1.19.5` linux-arm64
- 官方：https://opencode.ai / https://github.com/sst/opencode/releases
- 二进制 SHA256 见 `SHA256SUMS-upstream.txt` / deb `.sha256`（**巨大二进制不进 git**）

## Artifact（已上架，本目录只存配方）

| 项 | 值 |
|---|---|
| package_name | `ai.opencode.cli` |
| app_id | **104** |
| deb | `opencode-cli_1.19.5-1kemi1_arm64.deb` |
| version_name / code | `1.19.5-1kemi1` / `119501` |
| bytes | `55045672` |
| sha256 | `93be530d6b6c2f0a7230ce77a23ce1c31745df87c82140007b6e2d9fcf7c88ec` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793828636951_7be0ffd5_opencode-cli_1_19_5-1kemi1_arm64.deb |
| 本地指针 | `/workspace/t82-20261104/pkg/opencode-cli_1.19.5-1kemi1_arm64.deb`（box 证据，勿提交） |

## 构建

```bash
# 先解压上游 linux-arm64 tar 到 upstream/，核对 SHA
./scripts/build-opencode-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t82）

- dpkg -i PASS；`/usr/bin/opencode --version`（或等价）OK
- Ubuntu 20.04 aarch64（101）；未杀 vibekits

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。CREATE 已在真机冒烟 PASS 后完成（t82）。
