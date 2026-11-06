# ripgrep / rg（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 ripgrep（`rg`）。按正则递归搜索当前目录。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- BurntSushi/ripgrep `15.2.0` `aarch64-unknown-linux-musl`
- https://github.com/BurntSushi/ripgrep/releases/tag/15.2.0
- tar.gz：`ripgrep-15.2.0-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `800b1e7206afe799dfb5a6901f23147cfaabe0e52210538100f61e86e1740915`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.ripgrep`（商场；dpkg 名 `kemi-ripgrep`） |
| app_id | `111` |
| deb | `kemi-ripgrep_15.2.0-1kemi1_arm64.deb` |
| version_name / code | `15.2.0-1kemi1` / `1502001` |
| bytes | `1342200` |
| sha256 | `dd79c0574f3ea73faf3b1f92b7a3fa506d3daa3b2ae62ed902eb66912fb49bc6` |
| 本地指针 | `/workspace/t116-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-ripgrep-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t116 2026-11-06 Asia/Shanghai）

- `rg --version` / `rg --help` OK
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t116-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t116 2026-11-06 Asia/Shanghai）：

- package `com.kemi.ripgrep`
- app_id `111`
- version `15.2.0-1kemi1` / `1502001`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793931594251_2aa10a2f_kemi-ripgrep_15_2_0-1kemi1_arm64.deb`
- SHA256 `dd79c0574f3ea73faf3b1f92b7a3fa506d3daa3b2ae62ed902eb66912fb49bc6`
- 四层 L1–L4 PASS
