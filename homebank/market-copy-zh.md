# HomeBank

短描述：HomeBank 家庭记账（arm64）

长描述：HomeBank 5.3.2 — 简单易用的个人记账软件，支持多账户、预算、图表分析、到期提醒，并可导入 OFX/QFX/CSV。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源数据包 homebank-data（硬依赖为 >= 5.3.2-1，focal 仅此版本）。探针 1 个 ELF：/usr/bin/homebank requiredGlibc 2.29、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方二进制保留在 /usr/bin/homebank（编译前缀绑定 /usr/share/homebank）；/opt/homebank 下仅为符号链接。桌面项、手册、官方 55 个 .mo（含 zh_CN）、hicolor 图标、pixmap、数据文件、mime 与官方 HTML 帮助保留在标准路径。官方桌面图标为 homebank。官方软件包说明仍写 GTK2，但 focal 二进制 Depends / DT_NEEDED 实为 GTK3。官方 Recommends librsvg2-common 保持为推荐，未捆绑。本包提供版本化 Provides: homebank (= 5.3.2-1) 与 homebank-data (= 5.3.2-1)。官方来源为 Ubuntu 20.04 focal universe arm64 homebank 5.3.2-1 与同源 homebank-data；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 homebank_5.3.2-1_arm64.deb 与同源 homebank-data 重打包为 kemi-homebank；探针 1 ELF，requiredGlibc 2.29、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
