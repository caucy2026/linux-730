# difftastic (KEMI Linux arm64)

上游：[Wilfred/difftastic](https://github.com/Wilfred/difftastic) 0.72.0  
产物：`kemi-difftastic_0.72.0-1kemi1_arm64.deb`（aarch64-gnu MAX GLIBC 2.18，`/usr/bin/difft`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**177**
- package：`com.kemi.difftastic` / `kemi-difftastic` / `0.72.0-1kemi1` / version_code **7200**
- bytes：**5722424**
- SHA256：`2b08a70ed8d7c8a07854390b075ef7e84c23e769d193bc78a126c84bf28e0824`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794032537579_226a6e15_kemi-difftastic_0_72_0-1kemi1_arm64.deb
- MAX_GLIBC：2.18（无 aarch64 musl 资产）
- 命令：`difft`

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-difftastic-kemi-deb.sh
```

上游 tar SHA256：`0993a82a6708a24adc6c6b8de366924728ed08f537a5b488940082c8edc79353`
