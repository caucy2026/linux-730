# 商城文案（Atril Document Viewer）

短描述：官方 Ubuntu 20.04 MATE 文档查看器

长描述：Atril Document Viewer（atril）是官方 Ubuntu 20.04（focal-updates universe，focal-security 同 SHA）arm64 的图形文档查看器，用于打开 PDF、PostScript、DjVu、TIFF、漫画归档与 EPUB 等多页文档。官方桌面 Name=Atril Document Viewer、GenericName=Document Viewer 保持在官方文件中。官方 appdata <name>Atril Document Viewer</name> 位于未捆绑的 atril-common，未打包。商城 app_name 为 Atril Document Viewer（与官方桌面 Name 和官方 appdata 名称一致，较通用 Document Viewer 或项目名 atril 更完整）。官方 GUI 无 Source 字段，未默认填充（未把同源 sibling 的 Source: atril 抄到 kemi）。官方 Homepage https://mate-desktop.org/ 原样写入。同源精确版本硬依赖 libatrildocument3 与 libatrilview3（= 1.24.0-1ubuntu0.2）已捆绑；同源范围依赖 atril-common 仍为 Depends，未捆绑。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/atril/* 与 /usr/bin/kemi-atril 仅为指向官方命令的符号链接，未发明 kemi-atril-previewer、kemi-atril-thumbnailer 或 kemi-atrild。官方 atril-previewer 与 atril-thumbnailer 保留。

发布说明：首次上架官方 Ubuntu 20.04 atril 1.24.0-1ubuntu0.2（focal-updates universe，arm64；focal-security 同 SHA）。同源精确版本硬依赖 libatrildocument3 与 libatrilview3（= 1.24.0-1ubuntu0.2）已捆绑；atril-common 范围依赖未捆绑。官方文件留在 /usr；/opt 与 kemi-atril 仅为符号链接。官方桌面 Name=Atril Document Viewer 保持；商城 app_name 为 Atril Document Viewer。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方应用图标仅在未捆绑 common；128 evidence PNG 由官方 U20 atril-common scalable atril.svg 栅格化，仅作 CREATE 图标且不打包。探针 16 个 aarch64 ELF，requiredGlibc 2.29。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
