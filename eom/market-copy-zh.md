# 商城文案（Eye of MATE Image Viewer）

短描述：官方 Ubuntu 20.04 MATE 桌面图像查看器

长描述：Eye of MATE Image Viewer（eom）是官方 Ubuntu 20.04（focal universe）arm64 的图形图像查看器，可浏览和旋转图片。官方桌面 Name=Eye of MATE Image Viewer 保持在官方文件中（无 GenericName）。官方 appdata <name>Eye of MATE</name> 位于已捆绑的 eom-common 并已打包。商城 app_name 为 Eye of MATE Image Viewer（官方桌面 Name / 惯用英文产品名，未把项目名 eom 当作商城名）。官方 GUI 无 Source 字段，未默认填充（未把 sibling Source: eom 写入 kemi）。官方 Homepage http://www.mate-desktop.org/ 原样写入（未把 http 升级为 https）。同源精确版本硬依赖 eom-common (= 1.24.0-1, Architecture: all) 已捆绑。gir1.2-eom-1.0 为 gir 依赖，已检查但未打包，仍作 Depends。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/eom/eom 与 /usr/bin/kemi-eom 仅为指向官方 /usr/bin/eom 的符号链接。已上架的 Atril / Evince 是不同产品，不是占用，也不是替代。

发布说明：首次上架官方 Ubuntu 20.04 eom 1.24.0-1（focal universe，arm64）。同源精确版本硬依赖 eom-common 已捆绑；gir1.2-eom-1.0 未打包。官方文件留在 /usr；/opt 与 kemi-eom 仅为符号链接。官方桌面 Name=Eye of MATE Image Viewer 保持；商城 app_name 为 Eye of MATE Image Viewer。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。128 evidence PNG 由已捆绑 common 的 hicolor scalable eom.svg 栅格化，仅作 CREATE 图标且不打包；官方 SVG 按官方路径打包一次。探针 4 个 aarch64 ELF，requiredGlibc 2.29，requiredGlibcxx 为 None。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
