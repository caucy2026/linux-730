# kemi-kubectx (t223)

合主线：**gork.bot协助开发**。验证≠编译。单 CLI：仅 `kubectx`（`kubens` 另包）。

| 字段 | 值 |
|------|-----|
| package | com.kemi.kubectx |
| deb | kemi-kubectx_0.11.0-1kemi1_arm64.deb |
| app_id | 211 |
| version | 0.11.0-1kemi1 / code 1100 |
| bytes | 3236320 |
| SHA256 | `23f633518303d76cdfe78819bab560ff3067c105f39c32e725070d553ea56953` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794037827676_4d87deb3_kemi-kubectx_0_11_0-1kemi1_arm64.deb |
| binary | linux_arm64 **static** (CGO_ENABLED=0 / NO_NEEDED) |
| install | /usr/bin/kubectx |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-kubectx-kemi-deb.sh
```

Upstream: https://github.com/ahmetb/kubectx/releases/tag/v0.11.0
