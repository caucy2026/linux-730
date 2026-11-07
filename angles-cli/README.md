# angles-cli（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.angles` |
| dpkg | `kemi-angles` |
| version | `0.6.3-1kemi1` / version_code `603` |
| upstream | angles-cli **0.6.3** linux arm64 静态二进制（MIT） |
| upstream tar SHA256 | `d7337f01d39b00e13e781e345714cc2ace697a37183e64629efbc914f2af0183` |
| install | `/usr/bin/angles` |
| runtime | arm64 static（无 Docker、无额外 glibc 依赖；跳过需 GLIBC 2.39 的 Claurst/nca） |
| category | 工作 |
| app_id | **133** |
| SHA256 | `901dc3eb2e4748a0719f9b34aa93d00eb12ef4240e44a0a3c3a0ba8ffb0311d6` |
| size | 1486800 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794025911556_f03cc51d_kemi-angles_0_6_3-1kemi1_arm64.deb` |
| CREATE | app133 已上 KEMI 商场；四层 L1–L4 PASS |
| 101 smoke | **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待目标 Vibekits 重启后补冒烟 |

## 用途

Angles Code CLI — 开源终端 agentic coding tool（30+ 内置工具、多 Provider）。用户自备 API Key。

## 上游

- angles-cli `0.6.3` linux arm64 **static**
- https://github.com/angleschina/angles-cli/releases/tag/v0.6.3
- tar.gz SHA256: `d7337f01d39b00e13e781e345714cc2ace697a37183e64629efbc914f2af0183`
- **巨大二进制不进 git**；构建时从上游下载
- 跳过 Claurst/nca（需 GLIBC 2.39）；本包静态对齐 101 glibc 2.31

## Artifact

见 `angles-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-angles-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。app133 `com.kemi.angles` `0.6.3-1kemi1` 已在 KEMI 商场（CREATE + 四层 PASS）。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
