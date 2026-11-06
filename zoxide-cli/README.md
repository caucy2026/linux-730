# zoxide（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 zoxide（ajeetdsouza/zoxide）。更聪明的 `cd`，按使用频率跳转目录。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- ajeetdsouza/zoxide `v0.10.0` `zoxide-0.10.0-aarch64-unknown-linux-musl.tar.gz`
- https://github.com/ajeetdsouza/zoxide/releases/tag/v0.10.0
- tar.gz：`zoxide-0.10.0-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `f1f16c5d6298d63dee467eedea1cdcd8490e43e493bea43acd416dc9033ef641`
- 二进制 `zoxide` SHA256: `1864ef686a652b9db90901c72dbb8bd3da45d98738d12f94b4f85729448f2dde`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.zoxide`（商场；dpkg 名 `kemi-zoxide`） |
| app_id | `118` |
| deb | `kemi-zoxide_0.10.0-1kemi1_arm64.deb` |
| version_name / code | `0.10.0-1kemi1` / `10000` |
| bytes | `410580` |
| sha256 | `e9817f3a5c34f950b999bbd50ab5b2cc85bb445c657870632385b2329818273a` |
| 本地指针 | `/workspace/t123-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-zoxide-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t123 2026-11-06 Asia/Shanghai）

- `zoxide --version` OK
- add / query PASS
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t123-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **DONE**（t123 2026-11-06 Asia/Shanghai）：

- package `com.kemi.zoxide`
- app_id `118`
- version `0.10.0-1kemi1` / `10000`
- CDN `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793959214078_aeb743f6_kemi-zoxide_0_10_0-1kemi1_arm64.deb`
- SHA256 `e9817f3a5c34f950b999bbd50ab5b2cc85bb445c657870632385b2329818273a`
- 四层 L1–L4 PASS
