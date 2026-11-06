# CLI Toolkit（KEMI / 101 aarch64）

合主线：gork.bot协助开发。

合主线注明：**gork.bot协助开发**。

## 用途

把十三件已验证的 KEMI arm64 CLI 合并为一个 Focal xz deb，供商场单一货架安装。成员二进制沿用各单包内容，不在本目录重编译。

成员（13）：gh、ripgrep、jq、fd、bat、yq、fzf、delta、zoxide、hyperfine、dust、procs、sd。

## 成员

| 成员 | 命令 | 原 dpkg | 原 deb | 原 app_id |
|---|---|---|---|---|
| gh | `/usr/bin/gh` | `kemi-gh` | `kemi-gh_2.103.3-1kemi1_arm64.deb` | `110` |
| ripgrep | `/usr/bin/rg` | `kemi-ripgrep` | `kemi-ripgrep_15.2.0-1kemi1_arm64.deb` | `111` |
| jq | `/usr/bin/jq` | `kemi-jq` | `kemi-jq_1.8.2-1kemi1_arm64.deb` | `112` |
| fd | `/usr/bin/fd` | `kemi-fd` | `kemi-fd_10.5.1-1kemi1_arm64.deb` | `113` |
| bat | `/usr/bin/bat` | `kemi-bat` | `kemi-bat_0.26.1-1kemi1_arm64.deb` | `114` |
| yq | `/usr/bin/yq` | `kemi-yq` | `kemi-yq_4.54.2-1kemi1_arm64.deb` | `115` |
| fzf | `/usr/bin/fzf` | `kemi-fzf` | `kemi-fzf_0.74.5-1kemi1_arm64.deb` | `116` |
| delta | `/usr/bin/delta` | `kemi-delta` | `kemi-delta_0.20.1-1kemi1_arm64.deb` | `117` |
| zoxide | `/usr/bin/zoxide` | `kemi-zoxide` | `kemi-zoxide_0.10.0-1kemi1_arm64.deb` | `118` |
| hyperfine | `/usr/bin/hyperfine` | `kemi-hyperfine` | `kemi-hyperfine_2.0.0-1kemi1_arm64.deb` | `119` |
| dust | `/usr/bin/dust` | `kemi-dust` | `kemi-dust_1.2.7-1kemi1_arm64.deb` | `120` |
| procs | `/usr/bin/procs` | `kemi-procs` | `kemi-procs_0.14.12-1kemi1_arm64.deb` | `121` |
| sd | `/usr/bin/sd` | `kemi-sd` | `kemi-sd_1.1.0-1kemi1_arm64.deb` | `122` |

各单包配方仍在对应的 `*-cli/` 目录。本包上架后，这些单应用商场条目已删除。

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.cli-toolkit`（商场；dpkg 名 `kemi-cli-toolkit`） |
| app_id | `123` |
| deb | `kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb` |
| version_name / code | `1.0.0-1kemi1` / `10000` |
| bytes | `24595556` |
| sha256 | `2d021d1adddbe6ec013341ad86e3666562319ac40211100c23b91fe4261d61c0` |
| 本地指针 | `/workspace/t129-20261106/`（box 证据，勿提交） |

**巨大二进制不进 git**；构建时从既有单包 deb 合并，或按脚本重建。

## 构建

合并已有 arm64 单包（在各 `*-cli/debs/`，或 `MEMBER_DEB_DIR`）：

```bash
./scripts/build-cli-toolkit-kemi-deb.sh
```

缺单包时按各配方从上游重建后再合并（二进制仍不进 git）：

```bash
REBUILD_MISSING=1 ./scripts/build-cli-toolkit-kemi-deb.sh
```

产出写到 `cli-toolkit/debs/`（已 gitignore）。Ubuntu 20.04 的 dpkg 不能解 zstd，脚本固定 `dpkg-deb -Zxz`。

核对已发布字节（不入库）：

```bash
curl -fL -o /tmp/kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb \
  https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793966637391_0a5c2c2a_kemi-cli-toolkit_1_0_0-1kemi1_arm64.deb
sha256sum -c kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb.sha256
```

`dpkg-deb` 跨版本不保证与商场包逐字节相同。已发布 SHA256 以本目录 `kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb.sha256` 为准。

## 真机冒烟（硬门 · 已 PASS · t129 2026-11-06 Asia/Shanghai）

- KEMI 101 冒烟 PASS
- KD CREATE PASS
- 四层 L1–L4 PASS
- 证据：`/workspace/t129-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t129 2026-11-06 Asia/Shanghai）：

- package `com.kemi.cli-toolkit`
- app_id `123`
- version `1.0.0-1kemi1` / `10000`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793966637391_0a5c2c2a_kemi-cli-toolkit_1_0_0-1kemi1_arm64.deb`
- SHA256 `2d021d1adddbe6ec013341ad86e3666562319ac40211100c23b91fe4261d61c0`
- bytes `24595556`
- 101 冒烟 PASS · KD CREATE PASS · 四层 L1–L4 PASS

注：本包取代原单应用商场条目 app110–122（已通过 POST /api/apps/delete 删除）。
