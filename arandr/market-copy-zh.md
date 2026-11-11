# ARandR

短描述：官方 Ubuntu 20.04 ARandR 屏幕布局工具（focal，all）

长描述：ARandR 0.1.10-1.1，官方 Ubuntu 20.04（focal universe）Architecture: all 软件包的 KEMI 重打包。focal-updates 无更新包。Python 3 + GTK3 typelib 的 XRandR 可视化前端。官方 /usr/bin/arandr 与 /usr/bin/unxrandr 为 Python 3 包装脚本，不是 ELF。官方文件留在官方路径；/opt/arandr 下仅为符号链接。另有 /usr/bin/kemi-arandr → arandr。官方 typelib / GTK / Python / x11-xserver-utils 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 38 个 .mo（含 zh_CN / zh_Hant），无 Yelp 帮助、无 appdata。官方软件包不含应用图标文件（无 hicolor、无 pixmap、无 SVG）。官方桌面 Icon=display（主题图标）保持不变。官方 About 对话框使用 logo_icon_name=video-display。从该官方图标名对应的主题 SVG 栅格化的 128×128 证据 PNG 仅用于商城 CREATE --icon，未打进 deb，也不是发明的打包图标。官方桌面 Name=ARandR；商城 app_name=ARandR。官方桌面 Exec=arandr 已改写为 /usr/bin/arandr；已添加 TryExec=/usr/bin/arandr。官方 changelog、NEWS.gz 与 README.gz 为真实文件，已用 cp -L 复制。官方 screenlayout/data/gpl-3.txt 为指向 /usr/share/common-licenses/GPL-3 的符号链接，保持官方原文。官方 py3compile / py3clean / dpkg -L 已改指向 kemi-arandr。本包提供版本化 Provides: arandr (= 0.1.10-1.1)。官方来源为 Ubuntu 20.04 focal universe arandr 0.1.10-1.1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 arandr 0.1.10-1.1（focal universe Architecture: all）。官方 Python 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 依赖未捆绑。官方桌面 Exec 已改写为绝对路径。官方软件包不含应用图标；商城图标为主题 video-display 的 128×128 证据 PNG，未打进 deb。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
