# Thunar File Manager

短描述：Thunar 文件管理器（arm64）

长描述：Thunar 1.8.14 — Xfce 默认文件管理器，追求快速、易用。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源硬依赖 thunar-data（= 1.8.14-0ubuntu1，arch:all）。探针 3 个 ELF：均为 requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr/share/locale 与 /usr/share/pixmaps/Thunar，保留在 /usr/bin；官方 /usr/bin/Thunar 符号链接、/usr/lib 下助手与面板插件路径保持官方位置；/opt/thunar 下仅为符号链接。桌面项、官方 D-Bus/systemd、polkit、手册、metainfo、图标、关于对话框 PNG、63 个 .mo（含 zh_CN）、sendto 助手、回收站面板插件与 /etc/xdg/Thunar/uca.xml 保留在标准路径。官方桌面图标为 Thunar（本包随带 PNG 及 SVG）。libthunarx-3-0、exo-utils 等为系统 Depends，未捆绑。官方 Recommends（gvfs、thunar-volman、tumbler 等）与 Suggests 插件保持为推荐/建议，未捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 thunar 1.8.14-0ubuntu1 与 arch:all thunar-data；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 thunar_1.8.14-0ubuntu1_arm64.deb 与同源 thunar-data 重打包为 kemi-thunar；探针 3 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
