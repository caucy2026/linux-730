# Cheese

短描述：官方 Ubuntu 20.04 Cheese 网络摄像头拍照/录像（focal-updates main，arm64）

长描述：Cheese 3.34.0-1ubuntu1，官方 Ubuntu 20.04（focal-updates main）arm64 软件包的 KEMI 重打包。新于 focal Release 3.34.0-1build1。同源 official arch:all cheese-common 3.34.0-1ubuntu1 已捆绑（GUI 硬依赖为 cheese-common (>= 3.34.0-1ubuntu1)，focal 仅此一个匹配版本）。同源库 libcheese-gtk25 (>= 3.18.0) 与 libcheese8 (>= 3.18.0) 非精确版本依赖，保持为 Depends，不打包。同源 gir / -dev / libcheese-doc 已检查且不打包。官方 /usr/bin/cheese 为 aarch64 ELF，留在官方路径；/opt/cheese 下仅为符号链接。另有 /usr/bin/kemi-cheese → cheese。不同源依赖保持为 Depends。官方 Recommends（gvfs、yelp）保持为 Recommends。官方 Suggests（gnome-video-effects-frei0r）保持为 Suggests。无 Debian 纪元，无波浪号。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（language-pack 拆分，官方 help-langpack 符号链接保留，不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方帮助 PNG 保持官方，不用作商城图标。官方桌面 Name=Cheese；商城 app_name=Cheese。官方 GenericName=Webcam Booth 保留在桌面文件中。官方桌面 Exec 已改写为 /usr/bin/cheese，并添加 TryExec。官方 D-Bus Exec 已是绝对路径并保留。官方 GUI changelog 为指向未捆绑 lib 的悬空符号链接，未打包；已从官方 libcheese8 changelog 用 cp -L 复制到 kemi 文档目录。官方 cheese-common changelog 为真实文件并留在官方路径。本包提供版本化 Provides: cheese / cheese-common（= 3.34.0-1ubuntu1）。官方来源为 Ubuntu 20.04 focal-updates main cheese 3.34.0-1ubuntu1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 cheese 3.34.0-1ubuntu1（focal-updates main arm64）。同源 cheese-common 已捆绑。官方 ELF 留在 /usr；/opt 仅为符号链接。官方桌面 Name=Cheese 保持；商城 app_name=Cheese。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 1 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
