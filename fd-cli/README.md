# fd（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 fd（sharkdp/fd）。按模式快速查找文件。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- sharkdp/fd `v10.5.1` `aarch64-unknown-linux-musl`
- https://github.com/sharkdp/fd/releases/tag/v10.5.1
- tar.gz：`fd-v10.5.1-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `64c20b9b154c9d4b36d4b7df3521de771c499c4768b4b5b045ef6b01532117be`
- 二进制 `fd` SHA256: `fee1f8195a2ff2fe894236cd7c045a26b91f47e5300bf31d7be050561b4e188f`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.fd`（商场；dpkg 名 `kemi-fd`） |
| app_id | `113` |
| deb | `kemi-fd_10.5.1-1kemi1_arm64.deb` |
| version_name / code | `10.5.1-1kemi1` / `1005001` |
| bytes | `1129604` |
| sha256 | `09dc9ad1cc17ac260b52670625f9fd630a0339a2a516fc868b271688bae399a8` |
| 本地指针 | `/workspace/t117-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-fd-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t117 2026-11-06 Asia/Shanghai）

- `fd --version` / `fd --help` OK
- `fd -e txt` OK
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t117-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t117 2026-11-06 Asia/Shanghai）：

- package `com.kemi.fd`
- app_id `113`
- version `10.5.1-1kemi1` / `1005001`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793955861107_e541a205_kemi-fd_10_5_1-1kemi1_arm64.deb`
- SHA256 `09dc9ad1cc17ac260b52670625f9fd630a0339a2a516fc868b271688bae399a8`
- 四层 L1–L4 PASS
