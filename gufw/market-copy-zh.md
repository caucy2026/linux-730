# Gufw

短描述：官方 Ubuntu 20.04 Gufw 防火墙配置工具（focal-updates，all）

长描述：Gufw 20.04.1-1ubuntu1，官方 Ubuntu 20.04（focal-updates universe）Architecture: all 软件包的 KEMI 重打包。比 focal Release 20.04.1-1 更新；focal-security / focal-backports 无此包。官方 /usr/bin/gufw 与 /usr/bin/gufw-pkexec 为 bash 包装脚本，不是 ELF。官方文件留在官方路径；/opt/gufw 下仅为符号链接。另有 /usr/bin/kemi-gufw → gufw。官方 typelib / GTK / WebKit / PolicyKit / Python / ufw 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：0 个独立包装 ELF（空探针通过），无 glibc / GLIBCXX 版本需求（0 个有版本需求，0 个空值，不发明最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）空探针满足。官方包含 74 个 .mo（含 zh_CN / zh_TW），无 Yelp 帮助、无 appdata。官方应用图标为 48×48 hicolor PNG 加 scalable SVG（另有官方 gufw.xcf）；无官方 256×256。官方 48×48 PNG 与应用内盾牌 / 教程 PNG 留在官方树，不用作商城 256 图标。从官方 SVG 栅格化的 128×128 证据 PNG 仅用于商城 CREATE --icon，未打进 deb。官方桌面图标为 gufw。官方桌面 Name=Firewall Configuration；商城 app_name=Gufw。官方桌面 Exec=gufw 已改写为 /usr/bin/gufw；已添加 TryExec=/usr/bin/gufw。官方 PolicyKit exec.path=/usr/bin/gufw-pkexec 已是绝对路径并保持不变。官方 256 个 /etc/gufw/app_profiles 配置文件保持官方原文。官方 changelog 为真实文件，已用 cp -L 复制。官方 py3compile / py3clean / dpkg -L 以及 python3 rtupdate 已改指向 kemi-gufw（rtupdate 文件已改名）。本包提供版本化 Provides: gufw (= 20.04.1-1ubuntu1)。官方来源为 Ubuntu 20.04 focal-updates universe gufw 20.04.1-1ubuntu1（Architecture: all）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gufw 20.04.1-1ubuntu1（focal-updates universe Architecture: all）。官方 bash 包装脚本留在 /usr；/opt 仅为符号链接。官方 typelib 与 ufw 依赖未捆绑。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 0 ELF（空探针通过）。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
