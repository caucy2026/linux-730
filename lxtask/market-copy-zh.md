# LXTask

短描述：LXTask 任务管理器（arm64）

长描述：LXTask 0.1.9 — 轻量 GTK2 进程与任务管理器，源自 xfce4-taskmanager 并去掉 Xfce 依赖，可监视和控制正在运行的进程。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/lxtask + /usr/bin/lxtask；语言包、桌面项和手册保留在 /usr/share。官方桌面图标为主题图标 utilities-system-monitor（官方 deb 不含自带 pixmap）。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.14.0）、libglib2.0-0 ≥ 2.14.0 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 lxtask 0.1.9-1 in focal arm64（universe, Release）；该 arm64 二进制在 eoan 构建后原样进入 focal。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 lxtask_0.1.9-1_arm64.deb 重打包为 kemi-lxtask；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
