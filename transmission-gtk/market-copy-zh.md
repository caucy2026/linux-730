# Transmission

短描述：Transmission GTK BitTorrent 客户端（arm64）

长描述：Transmission 2.94 — 轻量 GTK3 BitTorrent 客户端（Transmission GTK 图形界面），界面简洁，后台高效。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包，并已捆绑同版本 arch:all 的 transmission-common；探针 requiredGlibc 2.29（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/transmission-gtk + /usr/bin/transmission-gtk；桌面项、手册、hicolor 图标、pixmap、mime 和 Web 资源保留在 /usr/share 与 /usr/lib/mime。官方桌面图标为 transmission（本包内置 hicolor PNG 与 SVG）。界面以 GResource 编译进二进制。本官方包未附带 locale .mo（编译 locale 路径为 /usr/share/locale；桌面项含 X-Ubuntu-Gettext-Domain=transmission）。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.3.16）、libglib2.0-0 ≥ 2.37.3、libgdk-pixbuf2.0-0 ≥ 2.25.2、libpango-1.0-0 ≥ 1.14.0、libappindicator3-1、libevent-2.1-7、libcurl4、libssl1.1、libminiupnpc17、libnatpmp1、zlib1g、libc6 ≥ 2.29，均为 Ubuntu 20.04 仓库包；建议安装 xdg-utils。官方来源为 Ubuntu 20.04 focal main arm64 transmission-gtk 2.94-2ubuntu3（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 transmission-gtk_2.94-2ubuntu3_arm64.deb 及 transmission-common 重打包为 kemi-transmission-gtk（common 已捆绑）；探针 requiredGlibc 2.29（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
