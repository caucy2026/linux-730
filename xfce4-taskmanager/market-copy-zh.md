# 商城文案（Xfce Task Manager）

短描述：官方 Ubuntu 20.04 Xfce 桌面进程管理器

长描述：Xfce Task Manager（xfce4-taskmanager）是官方 Ubuntu 20.04（focal universe）arm64 的图形进程管理器，用于查看和结束正在运行的进程。官方桌面 Name=Task Manager、GenericName=Task Manager 保持在官方文件中。官方软件包无 appdata。商城 app_name 为 Xfce Task Manager（惯用产品名，避免仅用通用 Task Manager 或项目名 xfce4-taskmanager）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage https://goodies.xfce.org/projects/applications/xfce4-taskmanager 原样写入。16 索引未发现同源精确版本硬依赖，未捆绑。官方相对 Exec 已改写为绝对路径并补上 TryExec。官方文件留在 /usr；/opt/xfce4-taskmanager/* 与 /usr/bin/kemi-xfce4-taskmanager 仅为指向官方 /usr/bin/xfce4-taskmanager 的符号链接。

发布说明：首次上架官方 Ubuntu 20.04 xfce4-taskmanager 1.2.3-0ubuntu1（focal universe，arm64）。无同源精确版本硬依赖，未捆绑。官方文件留在 /usr；/opt 与 kemi-xfce4-taskmanager 仅为符号链接。官方桌面 Name=Task Manager 保持；商城 app_name 为 Xfce Task Manager。官方相对 Exec 已改写为绝对路径并补上 TryExec。128 evidence PNG 由官方 humanity 0.6.15 utilities-system-monitor 48 SVG 栅格化，仅作 CREATE 图标且不打包，主题未捆绑。官方 hicolor 仅有动作图标 xc_crosshair，不作商城图标。探针 1 个 aarch64 ELF，requiredGlibc 2.17。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
