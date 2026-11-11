# GNOME Calculator

短描述：GNOME Calculator 计算器（arm64）

长描述：官方 Ubuntu 20.04（focal main）gnome-calculator 1:3.36.0-1ubuntu1（Architecture: arm64）KEMI 重打包。GTK3 图形计算器，含财务、逻辑与科学模式。官方 /usr/bin/gnome-calculator 为编译的 aarch64 ELF（内嵌 /usr/share/locale 与 help:gnome-calculator）；官方伴侣命令 gcalccmd、搜索提供程序与公共库 libgcalc-2 / libgci-1 留在官方路径；/opt/gnome-calculator 下仅为符号链接。另有 /usr/bin/kemi-gnome-calculator。同源源码在 focal 仅此一个二进制包，无 -data/-common 可捆绑。官方 Recommends（yelp、gvfs，不同源）保持为 Recommends，未捆绑。官方控制文件无 Suggests。官方 Breaks/Replaces gcalctool (<< 6.7) 已保留。Debian 纪元 1: 保留在 dpkg Version，mall version_name 与文件名已省略纪元。探针：5 个独立包装 ELF，requiredGlibc 2.17（5 个有版本需求，0 个空值），无 GLIBCXX（0 个有版本需求，5 个 null，空值不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方包不含 .mo（Ubuntu 语言包拆分；桌面项 X-Ubuntu-Gettext-Domain=gnome-calculator）。官方帮助为真实的 C 语言树，另有官方 help-langpack 符号链接（含 zh_CN / zh_TW / zh_HK），未发明或捆绑语言包。官方应用图标仅为 SVG；未在包内发明 PNG。官方桌面图标为 org.gnome.Calculator。官方桌面 Name=Calculator（appdata Name=GNOME Calculator；zh_CN=GNOME 计算器）。官方桌面 Exec=gnome-calculator 已改为 /usr/bin/gnome-calculator；已添加 TryExec。官方 D-Bus 搜索提供程序 Exec 已是绝对路径并保持不变。本包提供版本化 Provides: gnome-calculator (= 1:3.36.0-1ubuntu1)。官方 shlibs 已改指向 kemi-gnome-calculator（保留纪元）；官方 ldconfig trigger 已保留。官方来源为 Ubuntu 20.04 focal main gnome-calculator 1:3.36.0-1ubuntu1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-calculator_3.36.0-1ubuntu1_arm64.deb 重打包为 kemi-gnome-calculator；GTK3 图形界面，5 个 aarch64 ELF，glibc 2.17（5 有版本、0 空值），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
