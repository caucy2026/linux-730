# kemi-trivy (t247)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.trivy |
| deb | kemi-trivy_0.76.2-1kemi1_arm64.deb |
| app_id | 235 |
| version | 0.76.2-1kemi1 / code 7602 |
| bytes | 30118140 |
| SHA256 | `0c032f6917ff1ea96e9ec1c254933e447996b2261b70b346977a13cc8443e5b5` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794041268173_f01feb6c_kemi-trivy_0_76_2-1kemi1_arm64.deb |
| binary | Linux-ARM64 **static** (NO_NEEDED; single-CLI) |
| install | /usr/bin/trivy |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-trivy-kemi-deb.sh
```

Upstream: https://github.com/aquasecurity/trivy/releases/tag/v0.76.2
