# jq（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 jq。命令行 JSON 处理器。上游 linux arm64 二进制原样重打包。

## 上游

- jqlang/jq `1.8.2` linux arm64
- https://github.com/jqlang/jq/releases/tag/jq-1.8.2
- 二进制：`jq-linux-arm64`
- 二进制 SHA256: `8b85c817833814ddca00a144c33705546355afccf0cf39b188f3cdb48b852309`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.jq`（商场；dpkg 名 `kemi-jq`） |
| app_id | （CREATE pending；合入时未知，parent 可后补） |
| deb | `kemi-jq_1.8.2-1kemi1_arm64.deb` |
| version_name / code | `1.8.2-1kemi1` / `1082001` |
| bytes | `595396` |
| sha256 | `0b91643f06a8e2f3fb1fa33e33d87b0ded658f133e14261ba1c68f3bb88cac6b` |
| 本地指针 | `/workspace/t116-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-jq-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t116 2026-11-06 Asia/Shanghai）

- `jq --version` OK
- `echo '{"a":1}' | jq .a` → `1`
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t116-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。CREATE pending（app_id 合入时未知，parent 可后补）。
