# Xfce4 Screenshooter

短描述：Xfce4 Screenshooter 轻量 XFCE 截图工具（arm64）

长描述：Xfce4 Screenshooter 1.9.7 — 轻量 GTK3/XFCE 截图工具，可截取全屏、活动窗口或选定区域，也可绑定 Print Screen 键。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（2 ELF：主程序与面板插件），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/xfce4-screenshooter + /usr/bin/xfce4-screenshooter；XFCE 面板插件保留在标准 /usr/lib/aarch64-linux-gnu/xfce4/panel/plugins 与 /usr/share/xfce4/panel/plugins 路径；语言包、图标、桌面项、手册和 AppStream 元数据也保留在 /usr/share。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.21.4）、libexo-2-0、libxfce4ui-2-0、libxfce4util7、libsoup2.4-1、libxml2、libx11-6、libxext6、libxfixes3、libcairo2、libgdk-pixbuf2.0-0、libglib2.0-0 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。建议依赖 libxfce4panel-2.0-4（可选面板插件）。Launchpad 已发布 xfce4-screenshooter 1.9.7-1 in focal arm64（universe, Release）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xfce4-screenshooter_1.9.7-1_arm64.deb 重打包为 kemi-xfce4-screenshooter；探针 requiredGlibc 2.17（2 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
