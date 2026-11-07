# kemi-httprobe (t303)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.httprobe |
| deb | kemi-httprobe_0.2.0-1kemi1_arm64.deb |
| app_id | 291 |
| version | 0.2.0-1kemi1 / code 200 |
| bytes | 1705008 |
| SHA256 | `6e5ae2d5cec616d8e64ce270e851febe7ae253829110ce1259d7eac4efed673a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048545584_b1e0a478_kemi-httprobe_0_2_0-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译 CGO_ENABLED=0；上游无 arm64 release） |
| install | /usr/bin/httprobe |
| source | tomnomnom/httprobe@v0.2 `7e8abdb4` |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-httprobe-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/httprobe/releases/tag/v0.2
