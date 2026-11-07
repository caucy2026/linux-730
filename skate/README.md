# kemi-skate (t203)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.skate |
| deb | kemi-skate_1.1.0-1kemi1_arm64.deb |
| app_id | 191 |
| version | 1.1.0-1kemi1 / code 10100 |
| bytes | 3465308 |
| SHA256 | `84dc8f4e5d4d444d2035215b36db03bf6c48c716bc61323e752cd2b39130ce4d` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034850229_9e5aa373_kemi-skate_1_1_0-1kemi1_arm64.deb |
| binary | Linux_arm64 **static** (NO_NEEDED) |
| install | /usr/bin/skate |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-skate-kemi-deb.sh
```

Upstream: https://github.com/charmbracelet/skate/releases/tag/v1.1.0

## Notes

- t203: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
