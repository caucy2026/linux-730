# 商城文案（Engrampa Archive Manager）

短描述：官方 Ubuntu 20.04 MATE 桌面归档管理器

长描述：Engrampa Archive Manager（engrampa）是官方 Ubuntu 20.04（focal universe）arm64 的图形归档管理器，用于创建、查看和展开归档。官方桌面 Name=Engrampa Archive Manager、GenericName=Archive Manager 保持在官方文件中。官方 appdata <name>Engrampa Archive Manager</name> 位于已捆绑的 engrampa-common，并已打包。商城 app_name 为 Engrampa Archive Manager（官方桌面 Name 与官方 appdata 名称一致，较通用 Archive Manager 或项目名 engrampa 更完整）。官方 GUI 无 Source 字段，未默认填充（未把同源 sibling 的 Source: engrampa 抄到 kemi）。官方 Homepage http://www.mate-desktop.org/ 原样写入（http，未升级为 https）。同源精确版本硬依赖 engrampa-common (= 1.24.0-2) 已捆绑；common 的 alternatives 依赖 dconf-gsettings-backend | gsettings-backend 已并入 Depends。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。官方文件留在 /usr；/opt/engrampa/* 与 /usr/bin/kemi-engrampa 仅为指向官方 /usr/bin/engrampa 的符号链接，未发明 kemi-engrampa-server。

发布说明：首次上架官方 Ubuntu 20.04 engrampa 1.24.0-2（focal universe，arm64）。同源精确版本硬依赖 engrampa-common (= 1.24.0-2) 已捆绑。官方文件留在 /usr；/opt 与 kemi-engrampa 仅为符号链接。官方桌面 Name=Engrampa Archive Manager 保持；商城 app_name 为 Engrampa Archive Manager。官方相对 Exec/TryExec 已改写为绝对路径并保留 %U。128 evidence PNG 由官方包装树内 hicolor scalable engrampa.svg 栅格化，仅作 CREATE 图标且不打包。探针 3 个 aarch64 ELF，requiredGlibc 2.17。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
