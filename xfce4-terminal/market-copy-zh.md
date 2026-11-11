# Xfce Terminal

短描述：Xfce Terminal 终端模拟器（arm64）

长描述：Xfce Terminal 0.8.9.1 — 轻量 X11 终端模拟器，为 Xfce 桌面设计，也可用于其它环境。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包重打包。无同源 common/data 包。探针 1 个 ELF：requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr/share/locale 与 /usr/share/xfce4/terminal，保留在 /usr/bin；/opt/xfce4-terminal 下仅为符号链接。桌面项、手册、官方 57 个 .mo（含 zh_CN）、terminal-preferences.ui、配色方案与 gnome-control-center 默认应用列表保留在标准路径。官方桌面图标为 utilities-terminal（主题图标，本包不随带图标，未虚构图标）。Debian 包装器保留在 /usr/bin/xfce4-terminal.wrapper，并改写为绝对路径调用 /usr/bin/xfce4-terminal。运行时依赖系统 GTK3、VTE、libxfce4ui、exo-utils 与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方 Recommends 会话总线保持为 Recommends，未捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 xfce4-terminal 0.8.9.1-1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xfce4-terminal_0.8.9.1-1_arm64.deb（focal universe）重打包为 kemi-xfce4-terminal；探针 1 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
