# Ristretto

短描述：Ristretto 轻量 XFCE 图像查看器（arm64）

长描述：Ristretto 0.10.0 — 轻量 GTK3/XFCE 图像查看器，适合快速浏览图片。官方 Ubuntu 20.04（focal）arm64 updates 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/ristretto + /usr/bin/ristretto；语言包、图标、桌面项、手册和 AppStream 元数据保留在标准 /usr/share 路径。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.21.5）、libcairo2、libexif12、libgdk-pixbuf2.0-0、libglib2.0-0、libmagic1、libpango-1.0-0、libpangocairo-1.0-0、libx11-6、libxfce4ui-2-0、libxfce4util7、libxfconf-0-3 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。建议依赖 tumbler（缩略图，可选）。Launchpad 已发布 ristretto 0.10.0-1ubuntu0.1 in focal arm64（universe, updates）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 ristretto_0.10.0-1ubuntu0.1_arm64.deb 重打包为 kemi-ristretto；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
