# GitHub CLI / gh（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 GitHub CLI（`gh`）。issues/PR/repo 等命令行操作。

## 上游

- gh `2.103.3` linux_arm64
- https://github.com/cli/cli/releases/tag/v2.103.3
- tar.gz SHA256: `ee32df2323c8847f5fac6cb6b4b69ca75828e9329a8f22f677021f7b3306ce63`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.gh`（商场；dpkg 名 `kemi-gh`） |
| app_id | （CREATE 待 Vault Bearer；101 冒烟已 PASS） |
| deb | `kemi-gh_2.103.3-1kemi1_arm64.deb` |
| version_name / code | `2.103.3-1kemi1` / `2103301` |
| bytes | `9325088` |
| sha256 | `90ea913d67482059255af6aed4ddadd1af566ce9b0dfb109b63059ff82f8508e` |
| 本地指针 | `/workspace/t116-20261106/debs/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-gh-kemi-deb.sh
```


## 真机冒烟（硬门 · 已 PASS · t116 2026-11-06 Asia/Shanghai）

- 仿针 RID `7634801763` · hostname `mp730-156` · aarch64 · relay/sshReady
- upload SHA `90ea913d67482059255af6aed4ddadd1af566ce9b0dfb109b63059ff82f8508e` · bytes `9325088`
- `dpkg -i` → `kemi-gh 2.103.3-1kemi1`；`gh version 2.103.3 (2026-10-26)`；`gh help` OK
- **未杀 vibekits**：VK_BEFORE=VK_AFTER=`3569119,3569357,3569381`
- 证据：`/workspace/t116-20261106/evidence/smoke-gh-run.txt`

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。
