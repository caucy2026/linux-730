# GNOME Tweaks

短描述：GNOME Tweaks 高级设置（all）

长描述：GNOME Tweaks 3.34.0 — 用于调整 gnome-control-center 中无法配置的高级 GNOME 选项，例如界面与标题栏字体、字体微调与抗锯齿、替代界面主题、窗口管理行为、笔记本合盖行为、文件管理器桌面图标，以及菜单和按钮图标。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）Architecture: all 当前正式包。同源源码另有 gnome-tweak-tool，为过渡空包（Section: oldlibs，Depends: gnome-tweaks，仅含版权与悬空 changelog 链接），未作为本包内容捆绑；本包提供版本化 Provides: gnome-tweaks (= 3.34.0-2ubuntu1)，并保留官方对旧版 gnome-tweak-tool（<= 3.27.4）的 Breaks/Replaces。官方控制文件无 Recommends、无 Suggests。系统 typelib 与 GNOME 组件依赖保持为 Depends，未捆绑。探针：包装内 0 个 ELF（/usr/bin/gnome-tweaks 与 lid-inhibitor 均为 Python 3 脚本，GTK3 typelib 图形界面），无 requiredGlibc / requiredGlibcxx 版本需求，对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）为真空满足。官方脚本保留在 /usr/bin/gnome-tweaks，代码在 /usr/lib/python3/dist-packages/gtweak，数据在 /usr/share/gnome-tweaks（defs.py 写死官方 /usr 前缀）；/opt/gnome-tweaks 下仅为符号链接。另有 /usr/bin/kemi-gnome-tweaks。官方包不含 .mo（Ubuntu 语言包拆分；桌面项 X-Ubuntu-Gettext-Domain=gnome-tweaks），亦无 /usr/share/help，未发明或捆绑语言包与帮助树。官方图标仅为 SVG；未在包内发明 PNG。官方桌面图标为 org.gnome.tweaks。官方 py3compile/py3clean 脚本已改指向 kemi-gnome-tweaks。官方来源为 Ubuntu 20.04 focal universe gnome-tweaks 3.34.0-2ubuntu1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-tweaks_3.34.0-2ubuntu1_all.deb 重打包为 kemi-gnome-tweaks；Python 3 / GTK3 typelib 图形界面，包装内 0 个 ELF。合主线：gork.bot协助开发

合主线：gork.bot协助开发
