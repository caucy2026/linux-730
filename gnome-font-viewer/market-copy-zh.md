# GNOME Font Viewer

短描述：官方 Ubuntu 20.04 GNOME Font Viewer 字体预览工具（focal，arm64）

长描述：GNOME Font Viewer 3.34.0-2，官方 Ubuntu 20.04（focal main）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。官方 /usr/bin/gnome-font-viewer 与 /usr/bin/gnome-thumbnail-font 为 aarch64 ELF，留在官方路径。官方文件留在官方路径；/opt/gnome-font-viewer 下仅为符号链接。另有 /usr/bin/kemi-gnome-font-viewer → gnome-font-viewer。官方 libc / cairo / fontconfig / freetype / GTK / pango 等依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：2 个独立包装 ELF，requiredGlibc 2.17（2 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，2 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方桌面图标为 org.gnome.font-viewer。官方桌面 Name=Fonts；商城 app_name=GNOME Font Viewer。官方桌面 Exec=gnome-font-viewer %u 已改写为 /usr/bin/gnome-font-viewer %u；已添加 TryExec=/usr/bin/gnome-font-viewer。官方 D-Bus Exec 已是绝对路径并保持不变。官方 thumbnailer Exec/TryExec 已改写为 /usr/bin/gnome-thumbnail-font。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: gnome-font-viewer (= 3.34.0-2)。官方来源为 Ubuntu 20.04 focal main gnome-font-viewer 3.34.0-2（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-font-viewer 3.34.0-2（focal main arm64）。官方 ELF 留在 /usr；/opt 仅为符号链接。官方依赖未捆绑。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 2 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
