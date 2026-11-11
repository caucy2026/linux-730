# qpdfview

短描述：qpdfview 标签式文档阅读器（arm64）

长描述：qpdfview 0.4.18 — 轻量 Qt5 标签式文档阅读器，使用 Poppler 渲染 PDF、CUPS 打印，支持大纲/缩略图、缩放旋转、全文搜索、演示模式和部分注释/表单。官方 Ubuntu 20.04（focal）arm64 Release 包重打包，并捆绑官方 arch:all 翻译包与官方 arm64 DjVu / PostScript 插件；探针 requiredGlibc 2.17（5 ELF：主程序 + pdf/image/djvu/ps 插件），requiredGlibcxx 3.4.9（主程序）/ 3.4（插件），适配 Ubuntu 20.04 / KEMI 101。官方 ELF 保留在 /usr/bin/qpdfview（二进制编译进 /usr/lib/qpdfview 插件目录与 /usr/share/qpdfview 数据前缀）；focal 主包已内置 libqpdfview_pdf.so（不是独立 pdf-poppler 插件包）；/opt/qpdfview/qpdfview 为指向 /usr/bin/qpdfview 的符号链接。帮助、40 个 Qt .qm（含 zh_CN）、31 个帮助 HTML（含 zh_CN / zh_TW）、hicolor 图标、桌面项、手册、metainfo 和 mime 保留在 /usr/share 与 /usr/lib。官方桌面图标为 qpdfview（本包内置 hicolor 可缩放 svg）。运行时依赖系统 Qt 5.12（libqt5core5a ≥ 5.12.2 等）、libpoppler-qt5-1 ≥ 0.34.0、libcups2 ≥ 1.4.0、libsynctex2、libqt5sql5-sqlite、libqt5svg5、hicolor-icon-theme、libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。DjVu / PS 的独有库 libdjvulibre21、libspectre1 为 Recommends。Launchpad HTML 显示 qpdfview 0.4.18-1build1 in focal arm64（universe, Release，发布于 2020-03-23 21:23:14 Asia/Shanghai，Copied from ubuntu focal-proposed arm64）；该 arm64 二进制为 “arm64 build of qpdfview 0.4.18-1build1 in ubuntu focal PROPOSED” 后进入 focal Release。官方 SHA256 与大小已与 ports.ubuntu.com 仓库文件及 focal universe arm64 Packages 索引交叉核对（本轮 Launchpad librarian / +files 返回 503，未取到 librarian URL）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 qpdfview_0.4.18-1build1_arm64.deb 加官方 translations 与 DjVu/PS 插件，重打包为 kemi-qpdfview；探针 requiredGlibc 2.17（5 ELF），requiredGlibcxx 3.4.9。合主线：gork.bot协助开发

合主线：gork.bot协助开发
