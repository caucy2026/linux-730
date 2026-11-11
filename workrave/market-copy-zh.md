# Workrave

短描述：Workrave 劳损预防（arm64）

长描述：Workrave 1.10.37 — 帮助预防和恢复重复性劳损（RSI）的休息提醒工具，可定时微休息、休息并限制每日使用时长。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 workrave-data（= 1.10.37-1）。探针 7 个 ELF：全部 requiredGlibc 2.17；仅 /usr/bin/workrave 带 requiredGlibcxx 3.4.21，其余 6 个无 GLIBCXX 版本需求。适配 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/workrave，私有库与面板插件保留在官方 /usr/lib 路径（编译前缀绑定 /usr/share/workrave、/usr/share/locale 与 /usr/share/sounds/workrave）；/opt/workrave 下仅为符号链接。桌面项、手册、官方 37 个 .mo（含 zh_CN）、hicolor 图标（含官方 svg）、音效、拉伸动作图与官方面板/扩展数据保留在标准路径。官方桌面图标为 workrave。官方 Suggests gnome-panel 与 gnome-shell 保持为建议，未捆绑这两个面板程序本身。本包提供版本化 Provides: workrave (= 1.10.37-1) 与 workrave-data (= 1.10.37-1)。官方 workrave-data（Architecture: all）中 XFCE/GNOME/MATE 面板插件路径写死了 /usr/lib/x86_64-linux-gnu，已改写为与官方 arm64 插件一致的 /usr/lib/aarch64-linux-gnu。官方来源为 Ubuntu 20.04 focal universe arm64 workrave 1.10.37-1 与同源 workrave-data；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 workrave_1.10.37-1_arm64.deb 与同源精确版本 workrave-data 重打包为 kemi-workrave；探针 7 ELF，requiredGlibc 2.17、requiredGlibcxx 最高 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
