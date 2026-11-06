# hyperfine（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 hyperfine（sharkdp/hyperfine）。命令行基准测试。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- sharkdp/hyperfine `v2.0.0` `hyperfine-v2.0.0-aarch64-unknown-linux-musl.tar.gz`
- https://github.com/sharkdp/hyperfine/releases/tag/v2.0.0
- tar.gz：`hyperfine-v2.0.0-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `f0591c2cb8f66f2d2624d23979cf96dc99a67cb935f9925c82b9a4e3ffe5b2e1`
- 二进制 `hyperfine` SHA256: `1817d2374db766607bf18992a031638c92b31d53d3cc2328a9a3451b8d12391a`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.hyperfine`（商场；dpkg 名 `kemi-hyperfine`） |
| app_id | （CREATE pending；留空，父任务可回填） |
| deb | `kemi-hyperfine_2.0.0-1kemi1_arm64.deb` |
| version_name / code | `2.0.0-1kemi1` / `20000` |
| bytes | `493488` |
| sha256 | `9878665a768f927c5f6f204c9b8723ecf75be5d7192e4f157d166851b94a4653` |
| 本地指针 | `/workspace/t124-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-hyperfine-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t124 2026-11-06 Asia/Shanghai）

- `hyperfine --version` → `hyperfine 2.0.0`
- `hyperfine -w 0 -r 2 --style basic 'true'` PASS
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t124-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **pending**（app_id 留空；父任务可回填）：

- package `com.kemi.hyperfine`
- app_id （blank）
- version `2.0.0-1kemi1` / `20000`
- deb SHA256 `9878665a768f927c5f6f204c9b8723ecf75be5d7192e4f157d166851b94a4653`
- bytes `493488`
