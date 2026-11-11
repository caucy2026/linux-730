# GPicView

短描述：GPicView 轻量 GTK2 图像查看器（arm64）

长描述：GPicView 0.2.5 — 轻量 GTK2/LXDE 图像查看器，占用内存小，适合快速浏览图片。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.29（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/gpicview + /usr/bin/gpicview；编译写入的数据目录 /usr/share/gpicview/{pixmaps,ui} 保留在标准路径；语言包、图标、桌面项和手册也保留在 /usr/share。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.20.0）、libcairo2、libgdk-pixbuf2.0-0、libglib2.0-0、libjpeg8、libx11-6 和 libc6 ≥ 2.29，均为 Ubuntu 20.04 仓库包。建议依赖 xdg-utils（可选）。Launchpad 已发布 gpicview 0.2.5-3 in focal arm64（universe, Release）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gpicview_0.2.5-3_arm64.deb 重打包为 kemi-gpicview；探针 requiredGlibc 2.29（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
