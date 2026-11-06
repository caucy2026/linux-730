# yq（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 yq（mikefarah/yq）。命令行 YAML 处理器。上游 linux arm64 静态发行物原样重打包。

## 上游

- mikefarah/yq `v4.54.2` `yq_linux_arm64`
- https://github.com/mikefarah/yq/releases/tag/v4.54.2
- tar.gz：`yq_linux_arm64.tar.gz`
- tar.gz SHA256: `46583da045a14b8b369510d59c5754201a49c1ca887b0a9ddae2823e21fad177`
- 二进制 `yq_linux_arm64` SHA256: `bd44211dcd29a5f0eb701d4b7eb5ccd0cfff3bd3966cb4f7f9bd5b13701d997e`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.yq`（商场；dpkg 名 `kemi-yq`） |
| app_id | `115` |
| deb | `kemi-yq_4.54.2-1kemi1_arm64.deb` |
| version_name / code | `4.54.2-1kemi1` / `4054002` |
| bytes | `4081236` |
| sha256 | `614256a95ff38ab45355c60ffec56aed993607e265008dd054136e9af63ea061` |
| 本地指针 | `/workspace/t119-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-yq-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t119 2026-11-06 Asia/Shanghai）

- `yq --version` → `v4.54.2`
- `echo 'a: 1' | yq .a` → `1`
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t119-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t119 2026-11-06 Asia/Shanghai）：

- package `com.kemi.yq`
- app_id `115`
- version `4.54.2-1kemi1` / `4054002`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793958059414_ec4e5e7d_kemi-yq_4_54_2-1kemi1_arm64.deb`
- SHA256 `614256a95ff38ab45355c60ffec56aed993607e265008dd054136e9af63ea061`
- 四层 L1–L4 PASS
