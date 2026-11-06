# fzf（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 fzf（junegunn/fzf）。命令行模糊查找器。上游 linux arm64 静态发行物原样重打包。

## 上游

- junegunn/fzf `v0.74.5` `fzf-0.74.5-linux_arm64.tar.gz`
- https://github.com/junegunn/fzf/releases/tag/v0.74.5
- tar.gz：`fzf-0.74.5-linux_arm64.tar.gz`
- tar.gz SHA256: `cf058001da21724a469b714a29cf4aab9cbe860d218a0d6c1b5b661efad7784c`
- 二进制 `fzf` SHA256: `886c80fa9a66b8687d1b072b8a956b8a4eb3311f03e4bea6a9cae39bf402a519`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.fzf`（商场；dpkg 名 `kemi-fzf`） |
| app_id | （CREATE pending；留空，父任务可回填） |
| deb | `kemi-fzf_0.74.5-1kemi1_arm64.deb` |
| version_name / code | `0.74.5-1kemi1` / `74005` |
| bytes | `1507084` |
| sha256 | `0c53bba52df2be086ab2d323c2b3f5788d839e3b64ba54a07d7c3b5213865be4` |
| 本地指针 | `/workspace/t120-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-fzf-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t120 2026-11-06 Asia/Shanghai）

- `fzf --version` → `0.74.5`
- `printf 'apple\nbanana\n' | fzf --filter=ban` → `banana`
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t120-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **pending**（app_id 留空；父任务可回填）：

- package `com.kemi.fzf`
- app_id （blank）
- version `0.74.5-1kemi1` / `74005`
- deb SHA256 `0c53bba52df2be086ab2d323c2b3f5788d839e3b64ba54a07d7c3b5213865be4`
- bytes `1507084`
