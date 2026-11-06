# procs（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 procs（dalance/procs）。现代进程查看（`ps` 的替代）。上游 `aarch64-linux` 静态发行物原样重打包。

## 上游

- dalance/procs `v0.14.12` `procs-v0.14.12-aarch64-linux.zip`
- https://github.com/dalance/procs/releases/tag/v0.14.12
- zip：`procs-v0.14.12-aarch64-linux.zip`
- zip SHA256: `74b4f82acc6fe553cbd5af20ba0baac420b42bef9bb0cbb38fef14b8317d9f91`
- 二进制 `procs` SHA256: `bd09e92e5ff1cf32d9695997c4841e3c4e2a2c565f8584a1cc15d998b531fa4c`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.procs`（商场；dpkg 名 `kemi-procs`） |
| app_id | `121` |
| deb | `kemi-procs_0.14.12-1kemi1_arm64.deb` |
| version_name / code | `0.14.12-1kemi1` / `14012` |
| bytes | `1658172` |
| sha256 | `757f6f6f1f583b2b86568e3b05642836b88eac770c22120df0a834fe19448652` |
| 本地指针 | `/workspace/t126-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-procs-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t126 2026-11-06 Asia/Shanghai）

- `procs --version` → `0.14.12`
- list contains `/sbin/init`
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t126-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t126 2026-11-06 Asia/Shanghai）：

- package `com.kemi.procs`
- app_id `121`
- version `0.14.12-1kemi1` / `14012`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793961333731_2eb4bf54_kemi-procs_0_14_12-1kemi1_arm64.deb`
- SHA256 `757f6f6f1f583b2b86568e3b05642836b88eac770c22120df0a834fe19448652`
- 四层 L1–L4 PASS
