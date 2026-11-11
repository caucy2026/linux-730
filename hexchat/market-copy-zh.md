# HexChat

短描述：HexChat IRC 客户端（arm64）

长描述：HexChat 2.14.3 — 轻量 GTK2 IRC 客户端（基于 X-Chat 2），支持多服务器/频道窗口、SASL 等认证、可定制通知，以及插件 API。官方 Ubuntu 20.04（focal-updates）arm64 当前正式包重打包，并已捆绑同版本 arch:all 的 hexchat-common；探针 requiredGlibc 2.28（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/hexchat + /usr/bin/hexchat；桌面项、手册、hicolor 图标、metainfo、locale 和 D-Bus 服务保留在 /usr/share。官方桌面图标为 hexchat（本包内置 hicolor PNG 与 SVG）。界面以 GResource 编译进二进制。本包捆绑 53 种 locale（含 zh_CN / zh_TW）。官方插件包（hexchat-perl / hexchat-plugins / hexchat-python3）仍为建议依赖，未捆绑。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.24.0）、libglib2.0-0 ≥ 2.51.0、libgdk-pixbuf2.0-0 ≥ 2.25.2、libpango-1.0-0 ≥ 1.44.3、libnotify4、libssl1.1、libproxy1v5、libcanberra0、libdbus-glib-1-2、libx11-6、libc6 ≥ 2.28，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal-updates universe arm64 hexchat 2.14.3-3ubuntu0.20.04.2（Release 口袋仍为 2.14.3-3）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 hexchat_2.14.3-3ubuntu0.20.04.2_arm64.deb 及 hexchat-common 重打包为 kemi-hexchat（common 已捆绑）；探针 requiredGlibc 2.28（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
