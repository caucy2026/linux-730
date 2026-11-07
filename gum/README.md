# gum (KEMI Linux arm64)

上游：[charmbracelet/gum](https://github.com/charmbracelet/gum) v2.0.2  
产物：`kemi-gum_2.0.2-1kemi1_arm64.deb`（静态 aarch64，`/usr/bin/gum`）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

## 商场指纹（CREATE 后钉死）

- app_id：**149**
- package：`com.kemi.gum` / `kemi-gum` / `2.0.2-1kemi1` / version_code **20002**
- bytes：**3233360**
- SHA256：`0ea6d79e17097ee27677221eb054a0c5c54d6b311c5864386ab09f694472ea50`
- CDN：https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794028482522_31db419f_kemi-gum_2_0_2-1kemi1_arm64.deb

## 构建

```bash
OUT=./debs DL=./dl ./scripts/build-gum-kemi-deb.sh
```

上游 tar SHA256：`8ebf8b54ec1e8c81f2bb58b59ff9b70998186a4d11375f0cf357b80e0ccfa1d5`
