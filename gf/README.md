# kemi-gf (t302)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.gf |
| deb | kemi-gf_0.0.20200618-1kemi1_arm64.deb |
| app_id | 290 |
| version | 0.0.20200618-1kemi1 / code 20200618 |
| bytes | 873112 |
| SHA256 | `8a8308e4531d0da3166a8563f348a6d1600eeb1b7551c0a1ad91f6c072c5336e` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794048418546_007435d4_kemi-gf_0_0_20200618-1kemi1_arm64.deb |
| binary | linux-arm64 **static**（交叉编译；无 tag，版本取 commit 日期） |
| install | /usr/bin/gf（单 CLI；patterns 不打包） |
| source | tomnomnom/gf@master `dcd4c361` (2020-06-18) |

Patterns: 上游 `examples/` 需自行拷到 `~/.gf`。

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-gf-kemi-deb.sh
```

Upstream: https://github.com/tomnomnom/gf
