# curlie (KEMI Linux arm64)

上游：[rs/curlie](https://github.com/rs/curlie) v1.8.2  
产物：`kemi-curlie_1.8.2-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/curlie`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**154**
- package：`com.kemi.curlie` / `kemi-curlie` / `1.8.2-1kemi1` / version_code **10802**
- bytes：**752528**
- SHA256：`41904f2a43a260f0cb1ca2413bcc6789f4b1e0e952e4cc6704bf8bd90ea0130e`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794029207791_9641d80f_kemi-curlie_1_8_2-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-curlie-kemi-deb.sh
```

上游 tar SHA256：`570d505ad08e51ffe98e2ee39ee969cb340e846bc17a10ed2e4ba7a5e9d64c1a`
