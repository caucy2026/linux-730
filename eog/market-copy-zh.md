# 商城文案（Eye of GNOME Image Viewer）

短描述：官方 Ubuntu 20.04 GNOME 桌面图像查看器

长描述：Eye of GNOME Image Viewer（eog）是官方 Ubuntu 20.04（focal-updates main）arm64 的图形图像查看器，可浏览和旋转图片。官方桌面 Name=Image Viewer 保持在官方文件中（无 GenericName）。官方 appdata <name>Eye of GNOME</name> 位于官方 GUI 包装树并已打包。商城 app_name 为 Eye of GNOME Image Viewer（惯用英文产品名 / 官方 appdata 名加上功能；官方桌面 Name 为通用 Image Viewer，未把项目名 eog 当作商城名）。官方 GUI 无 Source 字段，未默认填充（未把 sibling eog-dev 的 Source: eog 写入 kemi）。官方 Homepage https://wiki.gnome.org/Apps/EyeOfGnome 原样写入。无 eog-common，无同源精确版本硬依赖可捆绑。eog-dev 已检查但未打包。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/eog/eog 与 /usr/bin/kemi-eog 仅为指向官方 /usr/bin/eog 的符号链接。已上架的 Eye of MATE Image Viewer app456 是不同产品，不是占用，也不是替代。

发布说明：首次上架官方 Ubuntu 20.04 eog 3.36.3-0ubuntu1（focal-updates main，arm64）。无同源精确版本硬依赖可捆绑；eog-dev 未打包。官方文件留在 /usr；/opt 与 kemi-eog 仅为符号链接。官方桌面 Name=Image Viewer 保持；商城 app_name 为 Eye of GNOME Image Viewer。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。128 evidence PNG 由官方包装树内 hicolor scalable org.gnome.eog.svg 栅格化，仅作 CREATE 图标且不打包；官方 SVG 按官方路径打包一次。探针 5 个 aarch64 ELF，requiredGlibc 2.29，requiredGlibcxx 为 None。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
