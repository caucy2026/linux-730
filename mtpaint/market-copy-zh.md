# mtPaint

短描述：mtPaint 像素画与照片编辑器（arm64）

长描述：mtPaint 3.40 — 轻量 GTK2 绘图程序，面向索引调色板图像、像素画和数字照片处理，可编辑索引色或 24 位 RGB，并支持 JPEG、GIF、TIFF、BMP、XPM、XBM。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/mtpaint + /usr/bin/mtpaint；语言包、图标、桌面项和手册保留在 /usr/share。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.24.0）、libgif7、libtiff5、libjpeg8、libpng16-16、libfreetype6、libpango-1.0-0、libgdk-pixbuf2.0-0、libglib2.0-0、libx11-6、zlib1g、gtklp 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包（gtklp 在 universe）。Launchpad 已发布 mtpaint 3.40-3 in focal arm64（universe, Release）；该 arm64 二进制在 yakkety 构建后原样进入 focal。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 mtpaint_3.40-3_arm64.deb 重打包为 kemi-mtpaint；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
