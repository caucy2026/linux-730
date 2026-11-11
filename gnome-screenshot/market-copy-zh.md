# GNOME Screenshot

短描述：官方 Ubuntu 20.04 GNOME Screenshot 截图工具（focal，arm64）

长描述：GNOME Screenshot 3.36.0-1ubuntu1，官方 Ubuntu 20.04（focal main）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。官方 /usr/bin/gnome-screenshot 为 aarch64 ELF，留在官方路径；/opt/gnome-screenshot 下仅为符号链接。另有 /usr/bin/kemi-gnome-screenshot → gnome-screenshot。官方 libc / GTK / cairo / canberra / X11 / dconf 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：1 个独立包装 ELF，requiredGlibc 2.29（1 个有版本需求，0 个空值，不从空值发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方无 .mo、无 Yelp 帮助（不发明语言包）。官方应用图标仅为 SVG（hicolor scalable 与 symbolic）；无官方 256×256。从官方 scalable SVG 栅格化的 128×128 证据 PNG 仅用于商城 CREATE --icon，未打进 deb。官方桌面图标为 org.gnome.Screenshot。官方桌面 Name=Screenshot；商城 app_name=GNOME Screenshot。官方桌面 Exec=gnome-screenshot（含 action Exec）已改写为 /usr/bin/gnome-screenshot；已添加 TryExec=/usr/bin/gnome-screenshot。官方 D-Bus Exec 已是绝对路径并保持不变。官方 gschema 保持官方原文。官方 changelog 与 NEWS.gz 为真实文件，已用 cp -L 复制。官方无维护者脚本；已添加 icon-cache、desktop-database 与 glib-compile-schemas 钩子。本包提供版本化 Provides: gnome-screenshot (= 3.36.0-1ubuntu1)。官方来源为 Ubuntu 20.04 focal main gnome-screenshot 3.36.0-1ubuntu1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-screenshot 3.36.0-1ubuntu1（focal main arm64）。官方 ELF 留在 /usr；/opt 仅为符号链接。官方库依赖未捆绑。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 1 ELF，glibc 2.29，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
