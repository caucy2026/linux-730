# Simple Scan

短描述：Simple Scan 文档扫描仪（arm64）

长描述：Simple Scan 3.36.3 — 轻量 GTK3 文档扫描仪（Document Scanner），是 SANE 的图形前端，可连接扫描仪并将照片或文档快速保存为合适格式。官方 Ubuntu 20.04（focal-updates）arm64 当前正式包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/simple-scan + /usr/bin/simple-scan；桌面项、手册、hicolor 图标、GSettings schema、metainfo 和帮助文档保留在 /usr/share。官方桌面图标为 org.gnome.SimpleScan（本包内置 hicolor SVG）。界面以 GResource 编译进二进制（/org/gnome/SimpleScan/*.ui）。本官方包未附带 locale .mo；C 语言帮助已随包，其他语言帮助为官方指向 /usr/share/help-langpack 的符号链接（含 zh_TW，本包无 zh_CN 帮助目录）。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.21.5）、libglib2.0-0 ≥ 2.43.92、libcairo2 ≥ 1.4.10、libgdk-pixbuf2.0-0 ≥ 2.22.0、libsane ≥ 1.0.24、libcolord2、libgusb2、libpackagekit-glib2-18、libwebp6 / libwebpmux3、zlib1g、libc6 ≥ 2.17，以及 gsettings 后端、会话总线和 xdg-utils，均为 Ubuntu 20.04 仓库包；建议安装 yelp 以查看帮助。官方来源为 Ubuntu 20.04 focal-updates main arm64 simple-scan 3.36.3-0ubuntu0.20.04.0（Release 口袋仍为同依赖的 3.36.0-0ubuntu1）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 simple-scan_3.36.3-0ubuntu0.20.04.0_arm64.deb 重打包为 kemi-simple-scan；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
