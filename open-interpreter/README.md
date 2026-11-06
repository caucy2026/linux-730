# Open Interpreter（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

Open Interpreter（openinterpreter/openinterpreter）Rust 终端 Agent。官方 `open-interpreter-package` aarch64 musl 发行物原样重打包。读改文件、跑命令、对接 LLM。

## 上游

- openinterpreter/openinterpreter `rust-v0.0.59`
- https://github.com/openinterpreter/openinterpreter/releases/tag/rust-v0.0.59
- tar.gz：`open-interpreter-package-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `636fc5e8b76cd4d0fcabcaa53cfa87322da49d7a9b085c2ab23c069baef13718`（与上游 `codex-package_SHA256SUMS` 一致）
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.open-interpreter`（商场；dpkg 名 `kemi-open-interpreter`） |
| app_id | `124` |
| deb | `kemi-open-interpreter_0.0.59-1kemi1_arm64.deb` |
| version_name / code | `0.0.59-1kemi1` / `59` |
| bytes | `83387384` |
| sha256 | `0bbbb9a42c6e566aadcb90bffedc96a59085800f238b86378cdaa4bf7f2eae36` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793970016427_13ac98bc_kemi-open-interpreter_0_0_59-1kemi1_arm6.deb |
| 本地指针 | `/workspace/t131-20261106/`（box 证据，勿提交） |

CDN 对象文件名截成 `arm6.deb`（`arm64` 被截断）。Content-Length 与 SHA256 和本地 `kemi-open-interpreter_0.0.59-1kemi1_arm64.deb` 一致。

## 安装布局

- `/opt/kemi-open-interpreter`：上游 package 树（`codex-package.json` 的 entrypoint 为 `bin/interpreter`）
- `/usr/bin/open-interpreter`、`/usr/bin/interpreter`：包装脚本，转去上述 entrypoint
- `bin/i`：指向上游 `bin/interpreter` 的符号链接（上游包里的同名重复二进制不入库、不打进 deb）

## 边界

- 需自备 LLM 密钥（`interpreter login`）。冒烟不携带密钥
- 非 Electron（终端 / app-server Agent）

## 构建

```bash
./scripts/build-open-interpreter-kemi-deb.sh
```

产出写到 `open-interpreter/debs/`（已 gitignore）。Ubuntu 20.04 的 dpkg 不能解 zstd，脚本固定 `dpkg-deb -Zxz`。

核对已发布字节（不入库）：

```bash
curl -fL -o /tmp/kemi-open-interpreter_0.0.59-1kemi1_arm64.deb \
  https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793970016427_13ac98bc_kemi-open-interpreter_0_0_59-1kemi1_arm6.deb
sha256sum -c kemi-open-interpreter_0.0.59-1kemi1_arm64.deb.sha256
```

`dpkg-deb` 跨版本不保证与商场包逐字节相同。已发布 SHA256 以本目录 `kemi-open-interpreter_0.0.59-1kemi1_arm64.deb.sha256` 为准。

## 真机冒烟（硬门 · 已 PASS · t131 2026-11-06 Asia/Shanghai）

- 101 smoke PASS
- KD CREATE PASS
- 四层 L1–L4 PASS
- 证据：`/workspace/t131-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t131 2026-11-06 Asia/Shanghai）：

- package `com.kemi.open-interpreter`
- app_id `124`
- version `0.0.59-1kemi1` / `59`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793970016427_13ac98bc_kemi-open-interpreter_0_0_59-1kemi1_arm6.deb`（文件名截断为 `arm6.deb`；CL/SHA 与 arm64 包一致）
- SHA256 `0bbbb9a42c6e566aadcb90bffedc96a59085800f238b86378cdaa4bf7f2eae36`
- bytes `83387384`
- 101 冒烟 PASS · KD CREATE PASS · 四层 L1–L4 PASS
