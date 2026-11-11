# Gigolo

短描述：Gigolo 远程文件系统前端（arm64）

长描述：Gigolo 0.5.1 — 轻量 GTK3 前端，通过 GIO/GVfs 快速挂载和管理远程文件系统书签。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/gigolo + /usr/bin/gigolo；语言包、桌面项和手册保留在 /usr/share。官方桌面图标为 GTK 库存图标 gtk-network。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.21.5）、libglib2.0-0 ≥ 2.37.3、libx11-6 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 gigolo 0.5.1-1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 构建后进入 Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gigolo_0.5.1-1_arm64.deb 重打包为 kemi-gigolo；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
