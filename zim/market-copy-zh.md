# Zim Desktop Wiki

短描述：Zim Desktop Wiki 桌面维基（all）

长描述：Zim 0.72.0 — 用维基风格维护笔记和笔记本的图形文本编辑器，页面以纯文本保存，并支持链接、附件与插件。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）Architecture: all 当前正式包。focal 同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方 Recommends gir1.2-gtkspell3-3.0（异源 typelib，非精确版本插件依赖）保持为推荐；官方 Suggests（git、graphviz、scrot 等）保持为建议，未捆绑。探针：包装内 0 个 ELF（/usr/bin/zim 为 Python 3 包装脚本，GTK3 typelib 图形界面），无 requiredGlibc / requiredGlibcxx 版本需求，对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）为真空满足。官方脚本保留在 /usr/bin/zim，代码在 /usr/lib/python3/dist-packages/zim，数据在 /usr/share/zim（XDG 默认 /usr/share/）；/opt/zim 下仅为符号链接。桌面项、手册、官方 34 个 .mo（含 zh_CN）、官方 hicolor PNG 与 SVG 图标、官方 /usr/share/zim/manual 帮助保留在标准路径。官方桌面图标为 zim。官方 py3compile/py3clean 脚本已改指向 kemi-zim。本包提供版本化 Provides: zim (= 0.72.0-1)。官方来源为 Ubuntu 20.04 focal universe zim 0.72.0-1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 zim_0.72.0-1_all.deb 重打包为 kemi-zim；Python 3 / GTK3 typelib 图形界面，包装内 0 个 ELF。合主线：gork.bot协助开发

合主线：gork.bot协助开发
