# GNOME Clocks

短描述：GNOME Clocks 时钟（arm64）

长描述：GNOME Clocks 3.36.2 — 简单的世界时钟、闹钟、秒表和计时器应用。官方 Ubuntu 20.04（focal-updates universe，新于 focal Release 3.36.0-1）arm64 当前正式包。focal 同源源码仅此一个二进制包，无 -data/-common 可捆绑；官方控制信息无 Recommends / Suggests。探针 1 个 ELF：/usr/bin/gnome-clocks requiredGlibc 2.17、无 GLIBCXX。适配 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）。官方二进制保留在 /usr/bin/gnome-clocks（编译前缀绑定 /usr/share/locale 与 help:gnome-clocks）；/opt/gnome-clocks 下仅为符号链接。桌面项、官方 72 个 .mo（含 zh_CN）、官方 Yelp 帮助、官方 SVG 图标、gsettings schema、D-Bus 与 AppStream 元数据保留在标准路径。官方桌面图标为 org.gnome.clocks（仅官方 SVG，未在包装中发明 PNG）。官方 org.gnome.clocks.service 已使用 /usr/bin/gnome-clocks --gapplication-service。本包提供版本化 Provides: gnome-clocks (= 3.36.2-1~ubuntu20.04.1)。官方来源为 Ubuntu 20.04 focal-updates universe arm64 gnome-clocks 3.36.2-1~ubuntu20.04.1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 focal-updates gnome-clocks_3.36.2-1~ubuntu20.04.1_arm64.deb 重打包为 kemi-gnome-clocks；探针 1 ELF，requiredGlibc 2.17、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
