# Orage

短描述：Orage 日历（arm64）

长描述：Orage 4.12.1 — 轻量 GTK2 桌面日历，以 iCal 格式存储日程，支持提醒、全球时间和时区转换。官方 Ubuntu 20.04（focal）arm64 Release 包 orage_4.12.1-7_arm64.deb 与 arch:all 数据包 orage-data_4.12.1-7_all.deb 一并重打包；探针 requiredGlibc 2.17（4 ELF：orage、globaltime、tz_convert、liborageclock.so），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/orage + /usr/bin/orage、/usr/bin/globaltime、/usr/bin/tz_convert；locale、桌面项、手册、hicolor 图标、HTML 帮助和提醒音保留在 /usr/share 与 /usr/share/orage。官方桌面图标为 xfcalendar / orage_globaltime（本包内置 hicolor 图标，来自 orage-data）。本包含 53 种 locale（含 zh_CN）。面板时钟插件按官方路径附带，但它链接 libxfce4panel-1.0（GTK2），该库未在 focal arm64 发布，因此未将 xfce4-panel 作为硬依赖；独立日历程序不依赖面板。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.16.0）、libgdk-pixbuf2.0-0 ≥ 2.22.0、libglib2.0-0 ≥ 2.35.9、libical3 ≥ 3.0.0、libnotify4 ≥ 0.7.0、libpango-1.0-0 ≥ 1.14.0、libpopt0 ≥ 1.14、libx11-6、libxfce4util7 ≥ 4.9.0、libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 orage 4.12.1-7 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 构建（build 18188688）后复制进入 focal Release；orage-data 为 amd64 构建 18188687 产出的 arch:all 包。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 orage_4.12.1-7_arm64.deb 与 orage-data_4.12.1-7_all.deb 重打包为 kemi-orage；探针 requiredGlibc 2.17（4 ELF），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
