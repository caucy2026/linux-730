# FileZilla

短描述：FileZilla FTP 客户端（arm64）

长描述：FileZilla 3.46.3 — 功能完整的图形化 FTP/FTPS/SFTP 客户端，支持站点管理、传输队列与超过 40 种语言。官方 Ubuntu 20.04（focal-updates universe，新于 Release 的 3.46.3-1build1 且仍兼容 U20；含 focal-security Terrapin/CVE-2023-48795 修复）arm64 当前正式包，并捆绑同源硬依赖 filezilla-common（= 3.46.3-1ubuntu0.1，arch:all）。探针 3 个 ELF：filezilla requiredGlibc 2.28、GLIBCXX 3.4.21；SFTP 助手 fzputtygen 与 fzsftp requiredGlibc 2.28、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方启动器与助手保留在 /usr/bin；/opt/filezilla 下仅为符号链接。桌面项、手册、官方 58 个 .mo（含 zh_CN）、XRC 界面与主题资源、图标、metainfo 与示例保留在标准路径。官方桌面图标为 filezilla（本包随带 hicolor 图标与 pixmaps）。异源 libfilezilla0（Depends 为 >= 0.19.3，非精确版本）及 wxWidgets/GTK3 等未捆绑，保留为系统 Depends。官方 Recommends xdg-utils 保持为推荐，未捆绑。官方来源为 Ubuntu 20.04 focal-updates universe arm64 filezilla 3.46.3-1ubuntu0.1 与 arch:all filezilla-common；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 filezilla_3.46.3-1ubuntu0.1_arm64.deb 与同源 filezilla-common 重打包为 kemi-filezilla；探针 3 ELF，filezilla requiredGlibc 2.28、GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
