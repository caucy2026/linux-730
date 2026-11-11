# Gedit

短描述：Gedit 文本编辑器（arm64）

长描述：Gedit 3.36.2 — GNOME 桌面的官方文本编辑器，支持标签页、语法高亮与插件。官方 Ubuntu 20.04（focal-updates）arm64 当前正式包重打包，并已捆绑同版本 arch:all 的 gedit-common（硬依赖：schema、帮助、插件数据、图标）。探针 9 个 ELF（启动器 + 私有库 libgedit-3.36.so + 7 个插件 .so）：全部 requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101（需 Python 3.8）。官方启动器因编译前缀与 RUNPATH 绑定 /usr/lib/aarch64-linux-gnu/gedit，ELF 保留在 /usr/bin/gedit；私有库、typelib（Gedit-3.0.typelib）与插件保留在该 /usr/lib 路径；GI override 保留在 /usr/lib/python3/dist-packages/gi/overrides/Gedit.py；/opt/gedit/gedit 仅为指向 /usr/bin/gedit 的符号链接。桌面项、D-Bus 服务、手册、GSettings schema、metainfo、图标、插件数据与帮助保留在 /usr/share。官方桌面图标为 org.gnome.gedit（本包随带 SVG）。官方语言包拆分：这两枚 deb 不含 .mo；C 语言帮助为实文件，zh_CN / zh_HK / zh_TW 帮助页为指向 /usr/share/help-langpack/ 的官方符号链接（未捆绑 language-pack）。运行时依赖系统 GTK3、GtkSourceView 4、libtepl-4、libamtk-5、libgspell、libpeas、gir typelib、python3.8、python3-gi、gsettings-desktop-schemas、iso-codes、gsettings 后端与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包；建议安装 yelp 与 zenity。官方来源为 Ubuntu 20.04 focal-updates main arm64 gedit 3.36.2-0ubuntu1（新于 Release 的 3.36.1-1）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gedit_3.36.2-0ubuntu1_arm64.deb 及 gedit-common 重打包为 kemi-gedit（common 已捆绑）；探针 9 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
