# Pidgin

短描述：Pidgin 即时通讯（arm64）

长描述：Pidgin 2.13.0 — 图形化、模块化的多协议即时通讯客户端，支持 AIM、IRC、Jabber/XMPP/Google Talk 等。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源数据包 pidgin-data（硬依赖为 >= 1:2.13.0 且 << 1:2.13.0-z，focal 仅此版本）。探针 24 个打包 ELF：主程序与多数插件 requiredGlibc 2.17、无 GLIBCXX；vvconfig.so requiredGlibc 2.29、无 GLIBCXX；iconaway.so 无 libc version-need，适配 Ubuntu 20.04 / KEMI 101。官方二进制保留在 /usr/bin/pidgin，GTK 插件保留在 /usr/lib/pidgin/（编译前缀绑定 /usr）；/opt/pidgin 下仅为符号链接。桌面项、手册、appdata、消息指示器、官方 94 个 .mo（含 zh_CN）、hicolor 图标、pixmaps、音效与 /etc/purple/prefs.xml 保留在标准路径。官方桌面图标为 pidgin。同源 libpurple0（Depends 为 >= 2.13.0，非精确版本）留作系统依赖，未捆绑（探针 only：最大 requiredGlibc 2.29、无 GLIBCXX）。官方 Recommends（gstreamer 插件与 pidgin-libnotify）保持为推荐；pidgin-libnotify 不在 focal arm64/all 索引中，未虚构或捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 pidgin 1:2.13.0-2.2ubuntu4 与同源 pidgin-data；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 pidgin_2.13.0-2.2ubuntu4_arm64.deb 与同源 pidgin-data 重打包为 kemi-pidgin；探针 24 ELF，vvconfig.so requiredGlibc 2.29、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
