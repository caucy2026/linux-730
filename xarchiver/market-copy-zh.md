# Xarchiver

短描述：Xarchiver 轻量 GTK+ 归档管理器（arm64）

长描述：Xarchiver 0.5.4.14 — 轻量 GTK3 归档管理器，可创建、打开、添加、解压和删除 xz、7z、tar、zip、rar、bzip2、gzip、rpm、deb 等常见压缩包。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/xarchiver + /usr/bin/xarchiver；编译写入的帮助文档 /usr/share/doc/xarchiver/index.html 与工具栏图标 /usr/share/pixmaps/xarchiver 保留在标准路径；Thunar 归档插件与 mailcap 辅助也保留在标准插件/MIME 路径；语言包、图标、桌面项和手册保留在 /usr/share。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.0.0）、libgdk-pixbuf2.0-0、libglib2.0-0 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。建议依赖 bzip2、p7zip-full、unzip、xdg-utils、xz-utils（处理常见压缩格式）。Launchpad 已发布 xarchiver 1:0.5.4.14-1 in focal arm64（universe, Release）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xarchiver_0.5.4.14-1_arm64.deb 重打包为 kemi-xarchiver；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
