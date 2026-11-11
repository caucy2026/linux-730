# GHex

短描述：GHex 十六进制编辑器（arm64）

长描述：GHex 3.18.4 — 轻量 GTK3 十六进制/ASCII 文件编辑器，可同时以十六进制和 ASCII 查看并编辑二进制文件。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/ghex + /usr/bin/ghex；帮助文档、桌面项、手册、hicolor 图标、GSettings schema 和 metainfo 保留在 /usr/share。官方桌面图标为 org.gnome.GHex（本包内置 hicolor 图标）。界面以 GResource 编译进二进制（/org/gnome/ghex/ghex-ui.xml）。本官方包未附带 locale .mo。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.3.16）、libgtkhex-3-0 ≥ 3.0.0、libatk1.0-0 ≥ 1.12.4、libcairo2 ≥ 1.2.4、libpango-1.0-0 ≥ 1.14.0、libpangocairo-1.0-0 ≥ 1.14.0、libglib2.0-0 ≥ 2.37.3、libc6 ≥ 2.17 以及 gsettings 后端，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 ghex 3.18.4-1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu eoan PROPOSED 构建（build 17805238）后复制进入 focal Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 ghex_3.18.4-1_arm64.deb 重打包为 kemi-ghex；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
