# kemi-qsv (t194)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.qsv |
| deb | kemi-qsv_28.0.0-1kemi1_arm64.deb |
| app_id | 182 |
| version | 28.0.0-1kemi1 / code 280000 |
| bytes | 8535024 |
| SHA256 | `323f71b2d0b0b123e9aeae0d0a0009f61ae014f77168d184dab86f787626db02` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794033462654_47da5904_kemi-qsv_28_0_0-1kemi1_arm64.deb |
| binary | aarch64-unknown-linux-musl **static** (NO_NEEDED) |
| install | /usr/bin/qsv (qsvlite omitted) |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-qsv-kemi-deb.sh
```

Upstream: https://github.com/dathere/qsv/releases/tag/28.0.0

## Notes

- t194 first pick **xan** SKIP: aarch64 gnu MAX GLIBC_2.39 (>2.31); no aarch64 musl.
- Fallback **qsv** musl static PASS.
