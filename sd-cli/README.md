# sd（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 sd（chmln/sd）。直观查找替换（`sed` 的替代，正则与字面量）。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- chmln/sd `v1.1.0` `sd-v1.1.0-aarch64-unknown-linux-musl.tar.gz`
- https://github.com/chmln/sd/releases/tag/v1.1.0
- tar.gz：`sd-v1.1.0-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `ec8c93c0533ff21f4851d11566808d4082544baf063d9b96ea77c27e98b7cd99`
- 二进制 `sd` SHA256: `376d61e1f5e776a770ab832ec7be6d39a46cded8d0efdb119b458329295e7622`
- **巨大二进制不进 git**；构建时从上游下载
- 注：上游 musl 资产 `sd --version` 自报 `sd 1.0.0`（v1.1.0 tag 的 `workspace.package.version` 仍为 `1.0.0`）；包版本与 tag 为 **1.1.0**

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.sd`（商场；dpkg 名 `kemi-sd`） |
| app_id | （CREATE pending；留空，父任务可回填） |
| deb | `kemi-sd_1.1.0-1kemi1_arm64.deb` |
| version_name / code | `1.1.0-1kemi1` / `10100` |
| bytes | `647056` |
| sha256 | `c21394be7f2390459d77ff72d25a1e083a0a2dd87bcb32a335385065493feb91` |
| 本地指针 | `/workspace/t127-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-sd-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t127 2026-11-06 Asia/Shanghai）

- stdin replace PASS
- inplace replace PASS
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t127-20261106/`（box，勿提交）
- 注：`sd --version` 自报 `sd 1.0.0`；包版本与 tag 为 1.1.0

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **pending**（app_id 留空；父任务可回填）：

- package `com.kemi.sd`
- app_id （blank）
- version `1.1.0-1kemi1` / `10100`
- deb SHA256 `c21394be7f2390459d77ff72d25a1e083a0a2dd87bcb32a335385065493feb91`
- bytes `647056`
