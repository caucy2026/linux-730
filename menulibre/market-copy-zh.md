# MenuLibre

短描述：官方 Ubuntu 20.04 MenuLibre 菜单编辑器（focal，all）

长描述：MenuLibre 2.2.1-1，官方 Ubuntu 20.04（focal universe）Architecture: all 软件包的 KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 的 FreeDesktop.org 菜单编辑器。官方 /usr/bin/menulibre 与 /usr/bin/menulibre-menu-validate 为 Python 3 包装脚本，不是 ELF。官方文件留在官方路径；/opt/menulibre 下仅为符号链接。另有 /usr/bin/kemi-menulibre → menulibre。官方 typelib / GTK / gnome-menus / Python 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 42 个 .mo（含 zh_CN / zh_HK / zh_TW），无 Yelp 帮助、无 appdata。官方应用图标仅为 SVG（hicolor 16–64 与 scalable）；无官方 256×256。官方 48×48 pixmap 留在官方树，不用作商城 256 图标。从官方 SVG 栅格化的 128×128 证据 PNG 仅用于商城 CREATE --icon，未打进 deb。官方桌面图标为 menulibre。官方桌面 Name=Menu Editor；商城 app_name=MenuLibre。官方桌面 Exec=/usr/bin/menulibre 已是绝对路径并保持不变；已添加 TryExec=/usr/bin/menulibre。官方 changelog 为真实文件，已用 cp -L 复制。官方 NEWS.gz 为指向 changelog.gz 的悬空符号链接，未打包。官方 py3compile / py3clean / dpkg -L 已改指向 kemi-menulibre。本包提供版本化 Provides: menulibre (= 2.2.1-1)。官方来源为 Ubuntu 20.04 focal universe menulibre 2.2.1-1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 menulibre 2.2.1-1（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 已是绝对路径并保持不变。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
