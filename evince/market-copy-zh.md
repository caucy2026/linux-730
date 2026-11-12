# 商城文案（Evince Document Viewer）

短描述：官方 Ubuntu 20.04 GNOME 桌面文档查看器

长描述：Evince Document Viewer（evince）是官方 Ubuntu 20.04（focal-updates main）arm64 的图形文档查看器，可查看 PDF、PS、EPS、DJVU、DVI、XPS 等文档。官方桌面 Name=Document Viewer 保持在官方文件中（无 GenericName）。官方 appdata <name>Evince</name> 位于官方 GUI 包装树并已打包。商城 app_name 为 Evince Document Viewer（惯用英文产品名；官方桌面 Name 为通用 Document Viewer，未把项目名 evince 当作商城名）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage https://wiki.gnome.org/Apps/Evince 原样写入。同源精确版本硬依赖 libevdocument3-4 与 libevview3-3 (= 3.36.10-0ubuntu1) 已捆绑；同源范围依赖 evince-common (>= 3.36, << 3.37) 仍作 Depends，未捆绑。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/evince/* 与 /usr/bin/kemi-evince 仅为指向官方 /usr/bin/evince（及 previewer/thumbnailer）的符号链接，未发明 kemi-evince-previewer、kemi-evince-thumbnailer 或 kemi-evinced。已上架的 Atril Document Viewer app453 是不同产品，不是占用，也不是替代。

发布说明：首次上架官方 Ubuntu 20.04 evince 3.36.10-0ubuntu1（focal-updates main，arm64）。同源精确版本硬依赖 libevdocument3-4 与 libevview3-3 已捆绑；同源范围依赖 evince-common 未捆绑。官方文件留在 /usr；/opt 与 kemi-evince 仅为符号链接。官方桌面 Name=Document Viewer 保持；商城 app_name 为 Evince Document Viewer。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。128 evidence PNG 由官方包装树内 hicolor scalable org.gnome.Evince.svg 栅格化，仅作 CREATE 图标且不打包；官方 SVG 按官方路径打包一次。探针 14 个 aarch64 ELF，requiredGlibc 2.29。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
