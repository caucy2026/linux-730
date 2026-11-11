# Terminator

短描述：官方 Ubuntu 20.04 Terminator 多窗口终端（focal，all）

长描述：Terminator 1.91-4ubuntu1，官方 Ubuntu 20.04（focal universe）Architecture: all 软件包的 KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 多窗口终端模拟器，使用系统 VTE。官方 /usr/bin/terminator 为指向 /usr/share/terminator/terminator 的符号链接，该启动器为 Python 3 包装脚本，不是 ELF。官方 remotinator 同为 Python 包装脚本，不是 ELF。官方文件留在官方路径；/opt/terminator 下仅为符号链接。另有 /usr/bin/kemi-terminator → terminator。官方 typelib / GTK / VTE / D-Bus / Python 依赖保持为 Depends，未捆绑。官方 Recommends（gir1.2-keybinder-3.0, gir1.2-notify-0.7, xdg-utils）保持为 Recommends。官方控制文件无 Suggests。官方 Provides: x-terminal-emulator 已保留。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 81 个 .mo（含 zh_CN / zh_HK / zh_TW），无 Yelp 帮助。官方应用图标含 hicolor 16–48 PNG 以及可缩放 SVG，无官方 256×256。官方 16–48 PNG、HighContrast PNG、动作/状态 PNG 与 48×48 pixmap 留在官方树，不用作商城 256 图标。从官方 SVG 栅格化的 128×128 证据 PNG 仅用于商城 CREATE --icon，未打进 deb。官方桌面图标为 terminator。官方桌面 Name=Terminator。官方桌面 Exec=terminator 已改为 /usr/bin/terminator（含 NewWindow 快捷方式）；TryExec 已改为 /usr/bin/terminator。官方 changelog 为真实文件，已用 cp -L 复制。官方 py3compile / py3clean / dpkg -L 以及针对 /usr/share/terminator 的 python3 rtupdate 已改指向 kemi-terminator。官方 x-terminal-emulator 的 update-alternatives（指向 /usr/bin/terminator）已保留。本包提供版本化 Provides: terminator (= 1.91-4ubuntu1)。官方来源为 Ubuntu 20.04 focal universe terminator 1.91-4ubuntu1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 terminator 1.91-4ubuntu1（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 改写为 /usr/bin/terminator。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
