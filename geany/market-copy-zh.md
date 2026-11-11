# Geany

短描述：Geany 轻量 IDE（arm64）

长描述：Geany 1.36 — 小巧快速的 GTK+ 集成开发环境，支持语法高亮、代码补全与多种语言。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源硬依赖 geany-common（= 1.36-1build1，arch:all）。探针 8 个 ELF：启动器与 6 个包内插件 requiredGlibc 2.17、无 GLIBCXX；libgeany requiredGlibc 2.27、GLIBCXX 3.4.21，适配 Ubuntu 20.04 / KEMI 101。官方启动器保留在 /usr/bin；libgeany 与包内插件保留在官方 /usr/lib 路径；/opt/geany 下仅为符号链接。桌面项、手册、官方 46 个 .mo（含 zh_CN）、geany.glade 等数据、图标与官方 HTML 手册（/usr/share/doc/geany）保留在标准路径。官方桌面图标为 geany（本包随带 hicolor、Tango 图标与 geany.xpm）。异源 geany-plugins 未捆绑（Depends 为 geany 与 geany-abi-18432，非精确版本）；本包 Provides 相应 ABI，以后可装到 kemi-geany 旁边。官方来源为 Ubuntu 20.04 focal universe arm64 geany 1.36-1build1 与 arch:all geany-common；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 geany_1.36-1build1_arm64.deb 与同源 geany-common 重打包为 kemi-geany；探针 8 ELF，libgeany requiredGlibc 2.27、GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
