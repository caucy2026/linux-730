# GNOME Usage

短描述：官方 Ubuntu 20.04 GNOME Usage 系统资源监视工具（focal，arm64）

长描述：GNOME Usage 3.32.0-1，官方 Ubuntu 20.04（focal universe）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。同源源包在 focal 仅有这一二进制包，无 -common / 精确版本库可捆绑。官方 /usr/bin/gnome-usage 为 aarch64 ELF，留在官方路径。官方文件留在官方路径；/opt/gnome-usage 下仅为符号链接。另有 /usr/bin/kemi-gnome-usage → gnome-usage。官方 dazzle / gtop / GTK / glib / cairo / pango / libc6 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方含 26 个 .mo（含 zh_TW，无 zh_CN，不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方桌面图标为 org.gnome.Usage。官方桌面 Name=Usage；商城 app_name=GNOME Usage。官方桌面 Exec=gnome-usage 已改写为 /usr/bin/gnome-usage；已添加 TryExec=/usr/bin/gnome-usage。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: gnome-usage (= 3.32.0-1)。官方来源为 Ubuntu 20.04 focal universe gnome-usage 3.32.0-1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-usage 3.32.0-1（focal universe arm64）。官方 ELF 留在 /usr；/opt 仅为符号链接。官方依赖未捆绑。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 1 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
