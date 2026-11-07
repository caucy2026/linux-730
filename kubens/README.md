# kemi-kubens (t224)

合主线：**gork.bot协助开发**。验证≠编译。单 CLI：仅 `kubens`（`kubectx` 另包）。

| 字段 | 值 |
|------|-----|
| package | com.kemi.kubens |
| deb | kemi-kubens_0.11.0-1kemi1_arm64.deb |
| app_id | 212 |
| version | 0.11.0-1kemi1 / code 1100 |
| bytes | 4666452 |
| SHA256 | `cc4c9883b2333238e23fc0f27b9b5152b4ff87614d66d1c41df534a122309a5f` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794037968805_216b1b28_kemi-kubens_0_11_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/kubens |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-kubens-kemi-deb.sh
```

Upstream: https://github.com/ahmetb/kubectx/releases/tag/v0.11.0 (asset kubens_v0.11.0_linux_arm64.tar.gz)
