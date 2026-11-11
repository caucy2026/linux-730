# GNOME Weather

短描述：GNOME Weather 天气（all）

长描述：GNOME Weather 3.36.1 — 用于查看某座城市或任意地点的当前天气状况，并获取由多种互联网服务提供的最新预报。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）Architecture: all 当前正式包。同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方控制文件无 Recommends、无 Suggests。系统 typelib、geoclue 与 gjs 依赖保持为 Depends，未捆绑。探针：包装内 0 个 ELF（/usr/bin/gnome-weather 为指向 GJS 包装脚本的符号链接，GTK3 typelib 图形界面），无 requiredGlibc / requiredGlibcxx 版本需求，对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）为真空满足。官方 /usr/bin/gnome-weather 指向 /usr/share/org.gnome.Weather/org.gnome.Weather（defs 写死官方 /usr 前缀）；/opt/gnome-weather 下仅为符号链接。另有 /usr/bin/kemi-gnome-weather。官方 66 个 .mo（含 zh_CN / zh_TW / zh_HK）予以保留，未发明或捆绑语言包。官方包无 /usr/share/help，未发明帮助树。官方图标仅为 SVG；未在包内发明 PNG。官方桌面图标为 org.gnome.Weather。官方 D-Bus 服务 Exec 已是绝对路径并保持不变。官方桌面 Exec=gapplication 已改为 /usr/bin/gapplication。本包提供版本化 Provides: gnome-weather (= 3.36.1-1)。官方来源为 Ubuntu 20.04 focal universe gnome-weather 3.36.1-1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-weather_3.36.1-1_all.deb 重打包为 kemi-gnome-weather；GJS / GTK3 typelib 图形界面，包装内 0 个 ELF。合主线：gork.bot协助开发

合主线：gork.bot协助开发
