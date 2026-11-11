# Xpad

短描述：Xpad 便笺应用（arm64）

长描述：Xpad 5.4.0 — 轻量 GTK3 便笺/便签（post-it）应用，每个便笺是独立窗口，可自由定制外观。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 保留在 /usr/bin/xpad（二进制内含 binreloc 与编译进的 /usr/share/xpad/help、/usr/share/locale、/usr/share/icons 前缀）；/opt/xpad/xpad 为指向 /usr/bin/xpad 的符号链接。帮助、locale、hicolor 图标、桌面项、手册和 metainfo 保留在 /usr/share。官方桌面图标为 xpad（本包内置 hicolor 可缩放 svg）。官方 locale 含 zh_CN / zh_TW。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.22）、GtkSourceView 3（libgtksourceview-3.0-1 ≥ 3.22）、libglib2.0-0 ≥ 2.56、libpango-1.0-0 ≥ 1.14.0、libsm6、libice6 ≥ 1:1.0.0、libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 xpad 5.4.0-1 in focal arm64（universe, Release，Focal 于 2019-10-18 发布）；该 arm64 二进制在 ubuntu eoan PROPOSED 构建（build 17381069）后进入 focal Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xpad_5.4.0-1_arm64.deb 重打包为 kemi-xpad；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
