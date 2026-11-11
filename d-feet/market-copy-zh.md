# D-Feet

短描述：D-Feet D-Bus 调试（all）

长描述：官方 Ubuntu 20.04（focal universe）d-feet 0.3.15-2（Architecture: all）KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 的 D-Bus 对象浏览 / 调试器。官方 /usr/bin/d-feet 为 Python 3 包装脚本，不是 ELF。官方文件留在官方路径（包装脚本内嵌 /usr/share/d-feet）；/opt/d-feet 下仅为符号链接。另有 /usr/bin/kemi-d-feet。官方 typelib / python3-gi 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 26 个 .mo（含 zh_CN）。官方帮助为真实的 C 语言树，另有官方翻译帮助（cs、de、el、es、hu、pl、pt_BR、sv），无悬空链接；部分帮助图为官方指向 C 的符号链接。官方帮助 PNG 留在官方帮助树中，不是商城图标。官方应用图标仅为 SVG（org.gnome.dfeet.svg 及 symbolic）；官方 16×16 hicolor PNG 为应用内图标（method/signal/property 等），留在官方树中，不是商城图标，未二次打包。未在包内另造 PNG。128×128 证据 PNG 仅用于商城 CREATE --icon，未打入 deb。官方桌面图标为 org.gnome.dfeet。官方桌面 Name=D-Feet（含 zh_CN）。官方桌面 Exec=d-feet 已改为 /usr/bin/d-feet；已添加 TryExec。官方 changelog 为真实文件，已用 cp -L 复制。官方 py3compile / py3clean / dpkg -L 已改指向 kemi-d-feet。本包提供版本化 Provides: d-feet (= 0.3.15-2)。官方来源为 Ubuntu 20.04 focal universe d-feet 0.3.15-2（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 d-feet 0.3.15-2（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 改写为 /usr/bin/d-feet。官方应用图标仅为 SVG；128×128 证据 PNG 仅用于商城图标，未打入 deb。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
