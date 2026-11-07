# kemi-feroxbuster (t282)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.feroxbuster |
| deb | kemi-feroxbuster_2.13.1-1kemi1_arm64.deb |
| app_id | 270 |
| version | 2.13.1-1kemi1 / code 21301 |
| bytes | 3932000 |
| SHA256 | `bf12723d3e790ff177b0fff3a9055aa889a4efc9b1a0f44a38c626c2dbc358d9` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794045772778_69fffed2_kemi-feroxbuster_2_13_1-1kemi1_arm64.deb |
| binary | aarch64-linux **glibc≤2.18** |
| install | /usr/bin/feroxbuster |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-feroxbuster-kemi-deb.sh
```

Upstream: https://github.com/epi052/feroxbuster/releases/tag/v2.13.1
