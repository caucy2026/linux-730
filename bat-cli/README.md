# bat（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

官方 bat（sharkdp/bat）。带语法高亮的 cat。上游 `aarch64-unknown-linux-musl` 静态发行物原样重打包。

## 上游

- sharkdp/bat `v0.26.1` `aarch64-unknown-linux-musl`
- https://github.com/sharkdp/bat/releases/tag/v0.26.1
- tar.gz：`bat-v0.26.1-aarch64-unknown-linux-musl.tar.gz`
- tar.gz SHA256: `6369242c584065f195fb20cb36fbd7cb63ae690605bbe89868a7596b596c2c23`
- 二进制 `bat` SHA256: `ba7c30e56a3de25fead14f9d2fa8bdde9dd974a118e367e0de6748c7322a4ae8`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

| 项 | 值 |
|---|---|
| package_name | `com.kemi.bat`（商场；dpkg 名 `kemi-bat`） |
| app_id | （CREATE pending；留空，父任务可回填） |
| deb | `kemi-bat_0.26.1-1kemi1_arm64.deb` |
| version_name / code | `0.26.1-1kemi1` / `0026001` |
| bytes | `2606132` |
| sha256 | `e9f40262807cfada501e0fd32a701f766c825fa8ad335173eb85b83c4a55e842` |
| 本地指针 | `/workspace/t117-20261106/`（box 证据，勿提交） |

## 构建

```bash
./scripts/build-bat-kemi-deb.sh
```

## 真机冒烟（硬门 · 已 PASS · t117 2026-11-06 Asia/Shanghai）

- `bat --version` → `0.26.1`
- `echo hi | bat -p` OK
- **未杀 vibekits**：VK_PIDS unchanged
- 证据：`/workspace/t117-20261106/`（box，勿提交）

## 商场

`os_type=linux` · `linuxpkg` · 分类 `工作` · 独立货架（勿覆盖 Vibekits app90）。CREATE 仅在真机冒烟 PASS 后。

CREATE **pending**（app_id 留空；父任务可回填）：

- package `com.kemi.bat`
- app_id （blank）
- version `0.26.1-1kemi1` / `0026001`
- deb SHA256 `e9f40262807cfada501e0fd32a701f766c825fa8ad335173eb85b83c4a55e842`
- bytes `2606132`
