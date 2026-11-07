# kemi-freeze (t202)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.freeze |
| deb | kemi-freeze_0.2.2-1kemi1_arm64.deb |
| app_id | 190 |
| version | 0.2.2-1kemi1 / code 202 |
| bytes | 3739940 |
| SHA256 | `1234ca7b8e71ef0495189b0a09e64d7a3b889dc39bfdff3ef1ceff0c47f523e4` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034743964_5c3401d6_kemi-freeze_0_2_2-1kemi1_arm64.deb |
| binary | Linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/freeze |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-freeze-kemi-deb.sh
```

Upstream: https://github.com/charmbracelet/freeze/releases/tag/v0.2.2

## Notes

- t202: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
