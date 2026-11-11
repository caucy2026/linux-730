# BleachBit

短描述：BleachBit 系统清理（all）

长描述：官方 Ubuntu 20.04（focal universe）bleachbit 3.9.0-1（Architecture: all）KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 的系统垃圾清理工具。官方 /usr/bin/bleachbit 为指向 /usr/share/bleachbit/bleachbit.py 的符号链接，该启动器为 Python 3 包装脚本，不是 ELF。官方文件留在官方路径（包装脚本内嵌 /usr/share/ 与 /usr/share/bleachbit）；/opt/bleachbit 下仅为符号链接。另有 /usr/bin/kemi-bleachbit。官方 typelib / GTK / PolicyKit / Python 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 63 个 .mo（含 zh_CN / zh_TW），无 Yelp 帮助。官方应用图标为 /usr/share/pixmaps/bleachbit.png（256×256 PNG，另有官方 .xpm）；无 hicolor 应用图标树。未在包内另造 PNG。官方 256×256 pixmap 用作商城 CREATE --icon（Zim / gitg / gnote 模式），未二次打包。官方桌面图标为 bleachbit。官方桌面 Name=BleachBit（注释含 zh_CN）。官方桌面 Exec=bleachbit 已改为 /usr/bin/bleachbit；TryExec 已改为 /usr/bin/bleachbit。官方 root 桌面 Exec=pkexec bleachbit 已改为 pkexec /usr/bin/bleachbit；官方 TryExec=pkexec 保持不变。官方 PolicyKit exec.path=/usr/bin/bleachbit 已是绝对路径并保持不变。官方 changelog 为真实文件，已用 cp -L 复制。官方 py3compile / py3clean / dpkg -L 以及针对 /usr/share/bleachbit 的 python3 rtupdate 已改指向 kemi-bleachbit。本包提供版本化 Provides: bleachbit (= 3.9.0-1)。官方来源为 Ubuntu 20.04 focal universe bleachbit 3.9.0-1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 bleachbit 3.9.0-1（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 改写为 /usr/bin/bleachbit；官方 root 桌面 Exec=pkexec /usr/bin/bleachbit。官方 256×256 pixmap 用于商城图标，未二次打包。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
