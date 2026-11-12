# 商城文案（MATE Calculator）

短描述：官方 Ubuntu 20.04 MATE 桌面计算器（金融、逻辑与科学模式）

长描述：MATE Calculator（mate-calc）是官方 Ubuntu 20.04（focal universe）arm64 的图形计算器，支持金融、逻辑与科学模式，并以多精度运算提供较高精度。官方桌面 Name=MATE Calculator、GenericName=Calculator 保持在官方文件中。官方 appdata <name>MATE Calc</name> 位于未捆绑的 mate-calc-common，未打包。商城 app_name 为 MATE Calculator（惯用产品名，较 appdata 简称更完整）。官方 GUI 无 Source 字段，未默认填充。官方 Homepage http://www.mate-desktop.org/ 原样写入（http，未升级为 https）。同源 mate-calc-common 为范围依赖（>= 1.24.0-1, << 1.24.0-1.1~），不是精确版本硬依赖，仍作 Depends，未捆绑。官方相对 Exec 已改写为绝对路径并补上 TryExec。官方文件留在 /usr；/opt/mate-calc/* 与 /usr/bin/kemi-mate-calc 仅为指向官方 /usr/bin/mate-calc（及 mate-calc-cmd）的符号链接。官方 mate-calculator 符号链接保持在官方路径，未发明 kemi-mate-calc-cmd 或 kemi-mate-calculator。

发布说明：首次上架官方 Ubuntu 20.04 mate-calc 1.24.0-1（focal universe，arm64）。同源 mate-calc-common 为范围依赖，未捆绑。官方文件留在 /usr；/opt 与 kemi-mate-calc 仅为符号链接。官方桌面 Name=MATE Calculator 保持；商城 app_name 为 MATE Calculator。官方相对 Exec 已改写为绝对路径并补上 TryExec。128 evidence PNG 由官方 humanity 0.6.15 accessories-calculator 48 SVG 栅格化，仅作 CREATE 图标且不打包，主题未捆绑。探针 2 个 aarch64 ELF，requiredGlibc 2.29。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
