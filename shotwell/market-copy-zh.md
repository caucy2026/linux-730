# Shotwell

短描述：Shotwell 照片管理器（arm64）

长描述：Shotwell 0.30.10 — 面向 GNOME 桌面的数字照片管理器，可从磁盘或相机导入照片与视频并整理、编辑与发布。官方 Ubuntu 20.04（focal-updates main，比 focal 的 0.30.8-0ubuntu2 更新且仍兼容 U20）arm64 当前正式包，并捆绑同源精确版本硬依赖 shotwell-common（= 0.30.10-0ubuntu0.1）。探针 8 个 ELF：主程序 requiredGlibc 2.29、无 GLIBCXX；同包库、内置插件与视频缩略图助手 requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方启动器保留在 /usr/bin，库、插件与助手保留在官方 /usr/lib 路径；/opt/shotwell 下仅为符号链接。桌面项、手册、官方 help/C、官方 help-langpack 符号链接、GSettings schema、图标、菜单与 metainfo 保留在标准路径。本包无 gettext .mo，遵循官方语言包拆分，未虚构语言包。官方桌面图标为 shotwell（本包随带 hicolor 图标）。官方 shotwell 无 Recommends。官方来源为 Ubuntu 20.04 focal-updates main arm64 shotwell 0.30.10-0ubuntu0.1 与同源 shotwell-common；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 shotwell_0.30.10-0ubuntu0.1_arm64.deb 与同源精确版本 shotwell-common 重打包为 kemi-shotwell；探针 8 ELF，主程序 requiredGlibc 2.29、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
