# 商城文案（GNOME System Tools）

短描述：官方 Ubuntu 20.04 GNOME System Tools 跨平台配置工具（用户与组、日期时间、共享文件夹）

长描述：GNOME System Tools（gnome-system-tools）是官方 Ubuntu 20.04（focal universe）arm64 的跨平台系统配置工具集，用于管理用户与组、日期时间和共享文件夹（NFS 与 Samba）。官方三个 applications 桌面 Name（Users and Groups、Time and Date、Shared Folders）保持在官方文件中；Shared Folders 的官方 NoDisplay=true 亦保持。商城 app_name 为 GNOME System Tools（惯用产品名；无官方 appdata <name>）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage https://github.com/LStranger/gnome-system-tools 原样写入。无同源精确版本硬依赖可捆绑；官方不同源范围依赖 liboobs-1-5 (>= 3.0.0) 与 alternatives 仍作 Depends。官方相对 Exec 已改写为绝对路径并补上 TryExec。官方文件留在 /usr；/opt/gnome-system-tools/* 仅为指向官方 /usr/bin 命令的符号链接。官方包没有名为 gnome-system-tools 的命令，因此未发明 /usr/bin/kemi-gnome-system-tools。

发布说明：首次上架官方 Ubuntu 20.04 gnome-system-tools 3.0.0-9ubuntu1（focal universe，arm64）。无同源精确版本硬依赖可捆绑。官方文件留在 /usr；/opt 仅为符号链接。官方桌面 Name 保持；商城 app_name 为 GNOME System Tools。官方相对 Exec 已改写为绝对路径并补上 TryExec。128 evidence PNG 由官方 time-admin.svg 栅格化，仅作 CREATE 图标且不打包。探针 3 个 aarch64 ELF，requiredGlibc 2.29。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
