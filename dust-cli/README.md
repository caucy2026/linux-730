# dust（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 dust（bootandy/dust）。比 `du` 更直观的磁盘占用查看。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- bootandy/dust `v1.2.7` `dust-v1.2.7-aarch64-unknown-linux-musl.tar.gz`
- https://github.com/bootandy/dust/releases/tag/v1.2.7
- tar.gz：`dust-v1.2.7-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `4c8ebaf224179bfd42db45d8a50fd5304bbd89532eda94db684d309c7b734ed6`
- 二进制 `dust` SHA256: `22b441d64b3c3368456ddd4cdb727faa055029c4a4dc43e7b848497558b31c00`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.dust`（商场；dpkg 名 `kemi-dust`） |
| app_id | `120` |
| deb | `kemi-dust_1.2.7-1kemi1_arm64.deb` |
| version_name / code | `1.2.7-1kemi1` / `10207` |
| bytes | `797396` |
| sha256 | `f15ac77beed48ac24ce3ee398ad2201b32530f7474d2650c15af76d1fce94969` |
| 本地指针 | `/workspace/t125-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-dust-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t125 2026-11-06 Asia/Shanghai）

- `dust --version` → `Dust 1.2.7`
- `dust -n 5 dir` PASS
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t125-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t125 2026-11-06 Asia/Shanghai）：

- package `com.kemi.dust`
- app_id `120`
- version `1.2.7-1kemi1` / `10207`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793960683047_6c56ee7e_kemi-dust_1_2_7-1kemi1_arm64.deb`
- SHA256 `f15ac77beed48ac24ce3ee398ad2201b32530f7474d2650c15af76d1fce94969`
- 四层 L1–L4 PASS
