# 商城文案（File Roller）

短描述：官方 Ubuntu 20.04 GNOME 桌面归档管理器

长描述：File Roller（file-roller）是官方 Ubuntu 20.04（focal-updates/security main）arm64 的图形归档管理器，可创建、查看、修改和提取归档。官方桌面 Name=Archive Manager 保持在官方文件中（无 GenericName）。官方 appdata <name>File Roller</name> 位于官方 GUI 包装树并已打包。商城 app_name 为 File Roller（惯用英文产品名 / 官方 appdata 名；官方桌面 Name 为通用 Archive Manager，未把项目名 file-roller 当作商城名）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage https://wiki.gnome.org/Apps/FileRoller 原样写入。无同源精确版本硬依赖可捆绑，未捆绑其他包。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/file-roller/file-roller 与 /usr/bin/kemi-file-roller 仅为指向官方 /usr/bin/file-roller 的符号链接，未发明 kemi-rpm2cpio 或 kemi-isoinfo.sh。已上架的 Engrampa Archive Manager app452 是不同产品，不是占用，也不是替代。

发布说明：首次上架官方 Ubuntu 20.04 file-roller 3.36.3-0ubuntu1.1（focal-updates/security main，arm64）。无同源精确版本硬依赖可捆绑。官方文件留在 /usr；/opt 与 kemi-file-roller 仅为符号链接。官方桌面 Name=Archive Manager 保持；商城 app_name 为 File Roller。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。128 evidence PNG 由官方包装树内 hicolor scalable org.gnome.ArchiveManager.svg 栅格化，仅作 CREATE 图标且不打包；官方 SVG 按官方路径打包一次。探针 3 个 aarch64 ELF，requiredGlibc 2.17，requiredGlibcxx 为 None。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
