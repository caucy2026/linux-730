# Glade

短描述：Glade 界面设计（arm64）

长描述：官方 Ubuntu 20.04（focal universe）glade 3.22.2-1（Architecture: arm64）KEMI 重打包。focal-updates 无更新包。GTK3 图形界面设计器（RAD，界面以 XML 保存）。官方 /usr/bin/glade 与 /usr/bin/glade-previewer 为编译的 aarch64 ELF（NEEDED libgladeui-2.so.6）。官方文件留在官方路径；/opt/glade 下仅为符号链接。另有 /usr/bin/kemi-glade。同源 libgladeui-2-6（>= 3.22.0，非精确版本）与 libgladeui-common 保持为 Depends，由 apt 拉取，未捆绑。官方 Recommends（libgtk-3-dev、devhelp）为不同源码包，保持为 Recommends，未捆绑。官方控制文件无 Suggests。探针：2 个独立包装 ELF，requiredGlibc 2.17（2 个有版本需求，0 个空值），无 GLIBCXX（0 个有版本需求，2 个 null，空值不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方 GUI 包不含 .mo（语言包拆分，保留官方树，不另造语言包）。官方帮助有真实的 C 语言树，另有官方 help-langpack 符号链接（含 zh_CN；无语言包时悬空，保留官方，不另造）；官方帮助 PNG 留在官方帮助树中，不是商城图标。官方应用图标含 hicolor 16–256 PNG 及 symbolic SVG；未在包内另造 PNG。官方 256×256 glade.png 用作商城 CREATE --icon（Zim / gitg / gnote 模式），未二次打包。官方桌面图标为 glade。官方桌面 Name=Glade。官方桌面 Exec=glade %F 已改为 /usr/bin/glade %F；已添加 TryExec。官方 GUI changelog.Debian.gz 为指向同源 lib 文档目录的悬空符号链接；已将官方 libgladeui-2-6 真实 changelog 复制到 kemi 文档目录，未打包该悬空链接。本包提供版本化 Provides: glade (= 3.22.2-1)。官方来源为 Ubuntu 20.04 focal universe glade 3.22.2-1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 glade 3.22.2-1（focal universe arm64）。官方 ELF 留在 /usr；/opt 仅为符号链接。同源库与 libgladeui-common 未捆绑（非精确版本 Depends）。官方桌面 Exec 改写为 /usr/bin/glade。官方 hicolor 16–256 PNG 保留；官方 256×256 用于商城图标，未二次打包。探测 2 ELF / glibc 2.17 / 无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
