# GNOME Characters

短描述：官方 Ubuntu 20.04 GNOME Characters 字符映射工具（focal，arm64）

长描述：GNOME Characters 3.34.0-1，官方 Ubuntu 20.04（focal main）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。官方 /usr/bin/gnome-characters 为指向 GJS 包装脚本的符号链接，不是 ELF；官方私有 aarch64 ELF libgc.so 留在官方路径。官方文件留在官方路径；/opt/gnome-characters 下仅为符号链接。另有 /usr/bin/kemi-gnome-characters → gnome-characters。官方 typelib / gjs / GTK / glib / unistring / dconf 依赖保持为 Depends，未捆绑。官方 Recommends fonts-noto-color-emoji 保持 Recommends，未捆绑。官方控制文件无 Suggests。探针：1 个独立包装 ELF（libgc.so），requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方桌面图标为 org.gnome.Characters。官方桌面 Name=Characters；商城 app_name=GNOME Characters。官方桌面 Exec=/usr/bin/gnome-characters 已是绝对路径并保持不变；已添加 TryExec=/usr/bin/gnome-characters。官方 D-Bus Exec 已是绝对路径并保持不变。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: gnome-characters (= 3.34.0-1)。官方来源为 Ubuntu 20.04 focal main gnome-characters 3.34.0-1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-characters 3.34.0-1（focal main arm64）。官方 GJS 包装与 libgc.so 留在 /usr；/opt 仅为符号链接。官方 typelib 与 gjs 依赖未捆绑。官方桌面 Exec 已是绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 1 ELF（libgc.so），glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
