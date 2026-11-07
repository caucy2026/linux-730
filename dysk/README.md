# kemi-dysk (t199)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.dysk |
| deb | kemi-dysk_3.8.2-1kemi1_arm64.deb |
| app_id | 187 |
| version | 3.8.2-1kemi1 / code 30802 |
| bytes | 808052 |
| SHA256 | `f397b982c896d0a0e7132f579b489989aa8e05561c544a2b83dac95690782d96` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794034240466_a74fa405_kemi-dysk_3_8_2-1kemi1_arm64.deb |
| binary | aarch64-unknown-linux-musl **static** (NO_NEEDED) |
| install | /usr/bin/dysk |

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-dysk-kemi-deb.sh
```

Upstream: https://github.com/Canop/dysk/releases/tag/v3.8.2

## Notes

- t199: **xh** policy SKIP — stays toolkit (CLI 禁单包→toolkit)；未 CREATE com.kemi.xh
