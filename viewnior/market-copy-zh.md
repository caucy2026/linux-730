# Viewnior

短描述：Viewnior 轻量 GTK2 图像查看器（arm64）

长描述：Viewnior 1.6 — 轻量 GTK2 图像查看器，支持全屏、幻灯片、旋转/翻转/裁剪、动画和导航窗口。官方 Ubuntu 20.04（focal）arm64 deb 重打包；探针 requiredGlibc 2.17（1 ELF）、requiredGlibcxx 3.4.21，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/viewnior + /usr/bin/viewnior；界面与 pixmap 保留在编译路径 /usr/share/viewnior。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.20.0）、libexiv2-27、libgdk-pixbuf2.0-0、libglib2.0-0、libstdc++6、libgcc-s1 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 viewnior 1.6-1build2 in focal arm64（universe）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 viewnior_1.6-1build2_arm64.deb 重打包为 kemi-viewnior；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
