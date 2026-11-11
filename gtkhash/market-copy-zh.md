# GtkHash

短描述：GtkHash 校验和计算器（arm64）

长描述：GtkHash 1.2 — 轻量 GTK3 校验和/消息摘要计算器，支持 MD5、SHA1、SHA256、SHA512、RIPEMD、TIGER、WHIRLPOOL 等。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/gtkhash + /usr/bin/gtkhash；语言包、桌面项、手册、hicolor/pixmap 图标和 GSettings schema 保留在 /usr/share。官方桌面图标为 gtkhash。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.21.5）、libb2-1 ≥ 0.98.1、libgcrypt20 ≥ 1.8.0、libnettle7、zlib1g、libglib2.0-0 ≥ 2.35.8、libc6 ≥ 2.17 以及 gsettings 后端，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 gtkhash 1.2-1build1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 针对 libnettle7 无改动重建后进入 Release。未捆绑 caja/nautilus/nemo/thunar 文件管理器插件。focal 已无独立 gtkhash-common（数据已并入本包）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gtkhash_1.2-1build1_arm64.deb 重打包为 kemi-gtkhash；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
