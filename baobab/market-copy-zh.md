# Baobab

短描述：Baobab 磁盘占用分析器（arm64）

长描述：Baobab 3.34.0 — 轻量 GTK3 磁盘占用分析器（Disk Usage Analyzer），可扫描整个文件系统或指定目录，并以树状图显示各文件夹占用。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/baobab + /usr/bin/baobab；桌面项、手册、hicolor 图标、GSettings schema、metainfo、D-Bus 服务和帮助文档保留在 /usr/share。官方桌面图标为 org.gnome.baobab（本包内置 hicolor SVG）。界面以 GResource 编译进二进制（/org/gnome/baobab/ui、baobab.css）。本官方包未附带 locale .mo；C 语言帮助已随包，其他语言帮助为官方指向 /usr/share/help-langpack 的符号链接（不在本包内）。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.19.12）、libglib2.0-0 ≥ 2.43.92、libcairo2 ≥ 1.2.4、libpango-1.0-0 ≥ 1.14.0、libc6 ≥ 2.17 以及 gsettings 后端，均为 Ubuntu 20.04 仓库包；建议安装 yelp 以查看帮助。Launchpad 已发布 baobab 3.34.0-1 in focal arm64（main, Release）；该 arm64 二进制在 ubuntu eoan PROPOSED 构建（build 17770047）后进入 focal Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 baobab_3.34.0-1_arm64.deb 重打包为 kemi-baobab；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
