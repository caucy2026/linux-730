# Catfish

短描述：Catfish 轻量 GTK+ 文件搜索工具

长描述：Catfish 1.4.13 — 轻量 GTK3 文件搜索工具，可通过命令行选项配置搜索路径、精确匹配、隐藏文件和全文检索。官方 Ubuntu 20.04（focal）arch=all Release 包重打包；无原生 ELF（Python + GTK3 typelib），适配 Ubuntu 20.04 Python 3.8 / KEMI 101，无 PEP 585 类型注解。布局 /opt/catfish + /usr/bin/catfish；界面数据保留在编译写入的 /usr/share/catfish/；语言包、图标、桌面项、AppStream 和手册保留在 /usr/share。运行时依赖系统 python3（focal 3.8.2）、python3-gi-cairo、python3-dbus、python3-pexpect，以及 gir1.2-gtk-3.0、gir1.2-gdkpixbuf-2.0、gir1.2-glib-2.0、gir1.2-pango-1.0，均为 Ubuntu 20.04 仓库包。建议依赖 mlocate 或 locate。官方启动器要求 GTK 3.10（focal 为 3.24）。Launchpad 已发布 catfish 1.4.13-1 in focal arm64（universe, Release，arch=all）。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 catfish_1.4.13-1_all.deb 重打包为 kemi-catfish；arch=all，0 ELF，Python 3.8 兼容。合主线：gork.bot协助开发

合主线：gork.bot协助开发
