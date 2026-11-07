# kemi-ast-grep (t200)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.ast-grep |
| deb | kemi-ast-grep_0.51.1-1kemi1_arm64.deb |
| app_id | 188 |
| version | 0.51.1-1kemi1 / code 5101 |
| bytes | 5315236 |
| SHA256 | `0d4cf5a1e6e4d102cdebc02255205c1f8199eb1267c3a54bf79bd4322a6dc068` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034393129_91d9c38f_kemi-ast-grep_0_51_1-1kemi1_arm64.deb |
| binary | aarch64-unknown-linux-gnu MAX GLIBC **2.18** |
| install | /usr/bin/ast-grep + /usr/bin/sg |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-ast-grep-kemi-deb.sh
```

Upstream: https://github.com/ast-grep/ast-grep/releases/tag/0.51.1

## Notes

- t200: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
