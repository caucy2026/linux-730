# Devhelp

短描述：Devhelp API 文档浏览（arm64）

长描述：官方 Ubuntu 20.04（focal-updates universe）devhelp 3.36.2-0ubuntu1（Architecture: arm64）KEMI 重打包，较 focal Release 3.36.1-1 更新，仍为 Ubuntu 20.04 依赖。GTK3 + WebKitGTK 的 GNOME API 文档浏览器。官方 /usr/bin/devhelp 为编译的 aarch64 ELF（内嵌 help:devhelp，NEEDED libdevhelp-3.so.6）。官方文件留在官方路径；/opt/devhelp 下仅为符号链接。另有 /usr/bin/kemi-devhelp。同源 libdevhelp-3-6（>= 3.36.0，非精确版本）与 devhelp-common 保持为 Depends，由 apt 拉取，未捆绑。官方 Recommends（libgtk-3-doc、libglib2.0-doc、libpango1.0-doc）为不同源码包，保持为 Recommends，未捆绑。官方控制文件无 Suggests。官方 Breaks/Replaces devhelp-common (<< 3.21.91-1) 已保留。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值），无 GLIBCXX（0 个有版本需求，1 个 null，空值不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方 gedit 插件为 Python，不计入 ELF。官方 GUI 包不含 .mo、图标、帮助与 schemas（位于官方 devhelp-common，随库由 apt 拉取）。未在 GUI 包内另造语言包、帮助或图标。官方 -common 中应用图标仅为 SVG；128×128 证据 PNG 仅用于商城 CREATE --icon，未打入 deb。官方桌面 Exec=devhelp 已改为 /usr/bin/devhelp；已添加 TryExec。官方 D-Bus Exec=/usr/bin/devhelp --gapplication-service 已是绝对路径并保持不变。官方 emacs 站点脚本 /etc/emacs/site-start.d/50devhelp.el 作为 conffile 保留。官方 py3compile / py3clean / python3 rtupdate 已改指向 kemi-devhelp。官方 GUI changelog.Debian.gz 为指向同源 lib 文档目录的悬空符号链接；已将官方 libdevhelp-3-6 真实 changelog 复制到 kemi 文档目录，未打包该悬空链接。本包提供版本化 Provides: devhelp (= 3.36.2-0ubuntu1)。官方来源为 Ubuntu 20.04 focal-updates universe devhelp 3.36.2-0ubuntu1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 devhelp 3.36.2-0ubuntu1（focal-updates universe arm64）。官方 ELF 留在 /usr；/opt 仅为符号链接。同源库与 -common 未捆绑（非精确版本 Depends）。官方桌面 Exec 改写为 /usr/bin/devhelp。官方应用图标仅在 -common 中为 SVG；128×128 证据 PNG 仅用于商城图标，未打入 deb。探测 1 ELF / glibc 2.17 / 无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
