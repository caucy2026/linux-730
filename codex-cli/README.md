# Codex CLI（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

OpenAI Codex 命令行（`codex`）。官方 `aarch64-unknown-linux-musl` 发行物原样重打包。

## 上游

- Codex CLI `0.166.0`（rust-v0.166.0）
- 官方资产：https://github.com/openai/codex/releases（`codex-aarch64-unknown-linux-musl.tar.gz`）
- 二进制 SHA256 见 `SHA256SUMS-upstream.txt` / deb `.sha256`（**巨大二进制不进 git**）

## Artifact（已上架，本目录只存配方）

| 项 | 值 |
|---|---|
| package_name | `com.openai.codex` |
| app_id | **103** |
| deb | `codex-cli_0.166.0-1kemi1_arm64.deb` |
| version_name / code | `0.166.0-1kemi1` / `166001` |
| bytes | `71331036` |
| sha256 | `f33b7f5cf220db74d1c1a1c65c608d324589f1080fec9707d8c19cfddc4073ae` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793828582585_f2b300e6_codex-cli_0_166_0-1kemi1_arm64.deb |
| 本地指针 | `/workspace/t82-20261104/pkg/codex-cli_0.166.0-1kemi1_arm64.deb`（box 证据，勿提交） |

## 构建

```bash
# 先下载上游 musl arm64 tar 到 upstream/，核对 SHA256SUMS-upstream.txt
./scripts/build-codex-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t82）

- dpkg -i PASS；`/usr/bin/codex --version`（或等价）OK
- Ubuntu 20.04 aarch64（101）；未杀 vibekits
- **box qemu ≠ 真机 PASS**

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。CREATE 已在真机冒烟 PASS 后完成（t82）。
