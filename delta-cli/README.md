# delta（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 delta（dandavison/delta）。git diff 语法高亮。上游 `aarch64-unknown-linux-gnu` 发行物原样重打包。

## 选型说明

按打包策略，不收没有 aarch64 musl/静态发行物的上游。eza 目前没有该资产（[eza#1777](https://github.com/eza-community/eza/pull/1777) 仍开放），因此本配方从 eza 改为 dandavison/delta `0.20.1`。delta 的 aarch64 发行物是 `aarch64-unknown-linux-gnu`（glibc 动态链接，依赖 libc / libgcc_s / libm / libdl / libpthread），不是 musl 静态包；101 真机冒烟已 PASS。

## 上游

- dandavison/delta `0.20.1` `delta-0.20.1-aarch64-unknown-linux-gnu.tar.gz`
- https://github.com/dandavison/delta/releases/tag/0.20.1
- tar.gz：`delta-0.20.1-aarch64-unknown-linux-gnu.tar.gz`
- tar.gz SHA256: `da7f4338f593572ff426ae153e0870e2fdc72729416eff551b40cdeb67940db8`
- 二进制 `delta` SHA256: `eb5ba9f0ba70e60543d11dc20ad8979d3565f8307055338a638d954b2a4a7062`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.delta`（商场；dpkg 名 `kemi-delta`） |
| app_id | `117` |
| deb | `kemi-delta_0.20.1-1kemi1_arm64.deb` |
| version_name / code | `0.20.1-1kemi1` / `20001` |
| bytes | `2388168` |
| sha256 | `3c71660bf28966daf329676bf810aed2a78cf7ff4c19783f194717232d732ed4` |
| 本地指针 | `/workspace/t121-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-delta-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t121 2026-11-06 Asia/Shanghai）

- `delta --version` → `0.20.1`
- mini diff highlight OK
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t121-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t121 2026-11-06 Asia/Shanghai）：

- package `com.kemi.delta`
- app_id `117`
- version `0.20.1-1kemi1` / `20001`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793958954744_f1cd9a77_kemi-delta_0_20_1-1kemi1_arm64.deb`
- SHA256 `3c71660bf28966daf329676bf810aed2a78cf7ff4c19783f194717232d732ed4`
- 四层 L1–L4 PASS
