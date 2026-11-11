# Alacarte

短描述：官方 Ubuntu 20.04 Alacarte 菜单编辑器（focal，all）

长描述：Alacarte 3.36.0-1，官方 Ubuntu 20.04（focal universe）Architecture: all 软件包的 KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 的 GNOME/FreeDesktop.org 菜单编辑器。官方 /usr/bin/alacarte 为 Python 3 包装脚本，不是 ELF。官方文件留在官方路径；/opt/alacarte 下仅为符号链接。另有 /usr/bin/kemi-alacarte → alacarte。官方 typelib / GTK / gnome-menus / Python 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方无 .mo、无 Yelp 帮助、无 appdata（不发明语言包）。官方包含 hicolor 16–256 PNG；商城 CREATE 使用官方 256×256（19892 B），不二次打包。官方桌面图标为 alacarte。官方桌面 Name=Main Menu；商城 app_name=Alacarte。官方桌面 Exec=alacarte 已改写为 /usr/bin/alacarte；已添加 TryExec=/usr/bin/alacarte。官方 changelog 与 NEWS.gz 为真实文件，已用 cp -L 复制。官方 py3compile / py3clean / dpkg -L 以及 python3 rtupdate 已改指向 kemi-alacarte（rtupdate 文件已改名）。官方 Alacarte/config.py 中未使用的 libdir="/usr/lib/x86_64-linux-gnu" 配置残留保持官方原文，未改写。本包提供版本化 Provides: alacarte (= 3.36.0-1)。官方来源为 Ubuntu 20.04 focal universe alacarte 3.36.0-1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 alacarte 3.36.0-1（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 已改写为绝对路径。官方 256×256 PNG 用于商城图标，未二次打包。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
