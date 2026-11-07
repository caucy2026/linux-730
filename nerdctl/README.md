# kemi-nerdctl (t244)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.nerdctl |
| deb | kemi-nerdctl_2.4.2-1kemi1_arm64.deb |
| app_id | 232 |
| version | 2.4.2-1kemi1 / code 20402 |
| bytes | 7594744 |
| SHA256 | `3f8bd89edde27bcb91af78d9eb8bb189b3d2562da7a2832283c258f81cd14bb9` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794040802105_2f219627_kemi-nerdctl_2_4_2-1kemi1_arm64.deb |
| binary | linux-arm64 **static** (NO_NEEDED; single-CLI) |
| install | /usr/bin/nerdctl |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-nerdctl-kemi-deb.sh
```

Upstream: https://github.com/containerd/nerdctl/releases/tag/v2.4.2 (slim tarball)
