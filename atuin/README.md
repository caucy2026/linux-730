# atuin (KEMI Linux arm64)

上游：[atuinsh/atuin](https://github.com/atuinsh/atuin) v18.24.5  
产物：`kemi-atuin_18.24.5-1kemi1_arm64.deb`（musl 静态 aarch64，`/usr/bin/atuin`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**145**
- package：`com.kemi.atuin` / `kemi-atuin` / `18.24.5-1kemi1` / version_code **182405**
- bytes：**12763300**
- SHA256：`12f012a576586cf78f97e95ffab4a95b382d06f0495f865558eee06e26992b97`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028010547_0a81b777_kemi-atuin_18_24_5-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-atuin-kemi-deb.sh
```

上游 tar SHA256：`b44b3f264652b847b2e524ec397aa498c13076ed75cf213239ed2b9a0de2f99d`
