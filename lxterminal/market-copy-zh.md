# LXTerminal

短描述：LXTerminal 终端模拟器（arm64）

长描述：LXTerminal 0.3.2 — 轻量 VTE 系 GTK3 终端模拟器，支持多标签，依赖少、桌面无关。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/lxterminal + /usr/bin/lxterminal；编译写入的 /usr/share/lxterminal 数据、hicolor 128x128 图标、语言包、桌面项和手册保留在 /usr/share。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.3.16）、libvte-2.91-0、libgdk-pixbuf2.0-0 ≥ 2.22.0、libpango-1.0-0 ≥ 1.14.0、libglib2.0-0 ≥ 2.28.0 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 lxterminal 0.3.2-1 in focal arm64（universe, Release）；该 arm64 二进制在 cosmic 构建后原样进入 focal。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 lxterminal_0.3.2-1_arm64.deb 重打包为 kemi-lxterminal；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
