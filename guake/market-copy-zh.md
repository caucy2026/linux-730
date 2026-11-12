# 商城文案（Guake）

短描述：官方 Ubuntu 20.04 Guake 下拉式终端（focal universe，Architecture: all）

长描述：Guake 是官方 Ubuntu 20.04（focal universe）Architecture: all 的下拉式终端。官方桌面 Name=Guake Terminal 与偏好设置 Name=Guake Preferences 保持在官方文件中；商城 app_name 为 Guake（与官方 appdata <name>Guake</name> 一致）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage http://guake-project.org 原样写入（http，未升级为 https）。无同源精确版本硬依赖可捆绑。官方相对 Exec/TryExec 已改写为绝对路径。官方文件留在 /usr；/opt/guake/guake 与 /usr/bin/kemi-guake 仅为指向官方 /usr/bin/guake 的符号链接。

发布说明：首次上架官方 Ubuntu 20.04 guake 3.6.3-2（focal universe，Architecture: all）。无同源精确版本硬依赖可捆绑。官方文件留在 /usr；/opt 与 kemi-guake 仅为符号链接。官方桌面 Name=Guake Terminal 保持在官方文件中；商城 app_name 为 Guake。官方相对 Exec/TryExec 已改写为绝对路径。官方 128 PNG 打入官方路径并用作 CREATE 图标。空探针 PASS（0 个 ELF）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
