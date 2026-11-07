# hrdr-cli（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.hrdr` |
| dpkg | `kemi-hrdr` |
| version | `0.18.0-1kemi1` / version_code `1800` |
| upstream | hrdr（Herder）**0.18.0** linux aarch64 musl 静态二进制（MIT） |
| upstream tar SHA256 | `63c4c1d45ea003a81a25b5a847dfc98c7cfed2421ee8fe546656d7d944d13f9d` |
| install | `/usr/bin/hrdr` |
| runtime | arm64 static musl（无 Docker、无额外 glibc 依赖；跳过需 GLIBC 2.39 的 Claurst） |
| category | 工作 |
| app_id | **132** |
| SHA256 | `3e2acd3a66def72c289de2c0866bcf06377b56aad37e51d8a4cdd044b16d571b` |
| size | 6258024 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794025642480_a0896d52_kemi-hrdr_0_18_0-1kemi1_arm64.deb` |
| CREATE | app132 已上 KEMI 商场；四层 L1–L4 PASS |
| 101 smoke | **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待目标 Vibekits 重启后补冒烟 |

## 用途

hrdr（Herder）— 开源终端 agentic coding harness。OpenAI 兼容多 Provider；用户自备 API Key。

## 上游

- hrdr `0.18.0` linux aarch64 **musl**（静态）
- https://github.com/kryptic-sh/hrdr/releases/tag/v0.18.0
- tar.gz SHA256: `63c4c1d45ea003a81a25b5a847dfc98c7cfed2421ee8fe546656d7d944d13f9d`
- **巨大二进制不进 git**；构建时从上游下载
- 跳过 Claurst（需 GLIBC 2.39）；本包 musl 对齐 101 glibc 2.31

## Artifact

见 `hrdr-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-hrdr-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。app132 `com.kemi.hrdr` `0.18.0-1kemi1` 已在 KEMI 商场（CREATE + 四层 PASS）。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
