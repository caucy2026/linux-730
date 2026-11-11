# Xfce4 Dict

短描述：Xfce4 Dict 词典客户端（arm64）

长描述：Xfce4 Dict 0.8.3 — 轻量 GTK3 词典客户端，支持查询 Dict 服务器（RFC 2229）、在线词典（打开浏览器）以及 aspell/ispell。含独立应用 xfce4-dict 和 Xfce 面板插件。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（2 ELF：主程序 + 面板插件），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/xfce4-dict + /usr/bin/xfce4-dict；面板插件保留在标准 /usr/lib/aarch64-linux-gnu/xfce4/panel/plugins 与 /usr/share/xfce4/panel/plugins 路径；语言包、桌面项、手册和 hicolor 图标保留在 /usr/share。官方桌面图标为 xfce4-dict。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.19.12）、libgdk-pixbuf2.0-0 ≥ 2.25.2、libglib2.0-0 ≥ 2.37.3、libpango-1.0-0 ≥ 1.14.0、libx11-6、libxfce4panel-2.0-4 ≥ 4.13.0、libxfce4ui-2-0 ≥ 4.13.0、libxfce4util7 ≥ 4.9.0、libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。建议安装 aspell 或 ispell。Launchpad 已发布 xfce4-dict 0.8.3-1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 构建后进入 Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xfce4-dict_0.8.3-1_arm64.deb 重打包为 kemi-xfce4-dict；探针 requiredGlibc 2.17（2 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
