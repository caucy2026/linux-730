# GNOME Nettool

短描述：官方 Ubuntu 20.04 GNOME Nettool 网络信息工具（focal universe，arm64）

长描述：GNOME Nettool 3.8.1-3，官方 Ubuntu 20.04（focal universe）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。同源源码在 focal 各口袋仅此一个二进制包，无 -data/-common 或精确版本库可捆绑。官方 /usr/bin/gnome-nettool 为 aarch64 ELF，留在官方路径；/opt/gnome-nettool 下仅为符号链接。另有 /usr/bin/kemi-gnome-nettool → gnome-nettool。不同源依赖（GTK / glib / cairo / pango / gdk-pixbuf / gtop、libc6 (>= 2.17)、dconf-gsettings-backend | gsettings-backend、dnsutils、finger、iputils-ping | ping、iputils-tracepath、net-tools、nmap、whois）保持为 Depends。官方控制文件无 Recommends、无 Suggests。无 Debian 纪元，无波浪号。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方带 89 个 .mo（含 zh_CN / zh_HK / zh_TW），全部保留，不发明语言包。官方 hicolor 应用图标为 16/22/24/32 PNG 与 scalable SVG，无 hicolor 256；官方 pixmap /usr/share/gnome-nettool/pixmaps/gnome-nettool.png 已为 256×256，用作商城 CREATE --icon，仅按官方路径打入 deb，不二次打包，不发明 128 栅格。官方应用内 pixmap 与帮助 PNG 保持官方，不作为发明的商城图标。官方桌面 Name=Network Tools；商城 app_name=GNOME Nettool（官方软件包说明与 README 使用的常用上游名称；历史项目名 GNOME Network Tools 不用作商城 app_name）。官方桌面 Exec 已改写为 /usr/bin/gnome-nettool，并添加 TryExec。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: gnome-nettool (= 3.8.1-3)。官方来源为 Ubuntu 20.04 focal universe gnome-nettool 3.8.1-3（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-nettool 3.8.1-3（focal universe arm64）。无同源捆绑。官方 ELF 留在 /usr；/opt 仅为符号链接。官方桌面 Name=Network Tools 保持；商城 app_name=GNOME Nettool。官方桌面 Exec 已改写为绝对路径。官方 256×256 pixmap 用作商城图标并仅按官方路径打包。探测 1 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
