# kemi-interactsh-client (t293)

合主线：**gork.bot协助开发**。验证≠编译。

| 字段 | 值 |
|------|-----|
| package | com.kemi.interactsh-client |
| deb | kemi-interactsh-client_1.4.1-1kemi1_arm64.deb |
| app_id | 281 |
| version | 1.4.1-1kemi1 / code 10401 |
| bytes | 5952788 |
| SHA256 | `ee80682e8332d14a41b192e8600f5b30e7fa6d7e1026b2b3de5714b24aa36899` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794047213316_2a51bf02_kemi-interactsh-client_1_4_1-1kemi1_arm6.deb |
| binary | linux-arm64 **static** (NO_NEEDED) |
| install | /usr/bin/interactsh-client |

注：CDN key 因对象名长度被截断为 `..._arm6.deb`，内容 SHA/bytes 与本地 deb 一致，L4 PASS。

## Build

```bash
OUT=./debs DL=./dl ./scripts/build-interactsh-client-kemi-deb.sh
```

Upstream: https://github.com/projectdiscovery/interactsh/releases/tag/v1.4.1 （client only；未打包 server）
