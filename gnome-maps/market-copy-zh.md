# GNOME Maps

短描述：GNOME Maps 地图（arm64）

长描述：GNOME Maps 3.36.1 — 用于在不同缩放级别查看地图、搜索地点，并在地图上显示当前位置。官方 Ubuntu 20.04（focal-updates universe，较 focal Release 3.36.1-1 更新，仍为 Ubuntu 20.04 依赖）arm64 当前正式包。同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方控制文件无 Recommends、无 Suggests。系统 typelib、geoclue、gjs 与库依赖保持为 Depends，未捆绑。探针：1 个独立包装 ELF（私有库 libgnome-maps.so.0.0.0，aarch64），requiredGlibc 2.17（1 个有版本需求，0 个 null），无 GLIBCXX（0 个有版本需求，1 个 null，null 不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）满足。/usr/bin/gnome-maps 为指向 GJS 包装脚本的符号链接（prefix 写死官方 /usr，libdir 为 /usr/lib/aarch64-linux-gnu）；/opt/gnome-maps 下仅为符号链接。另有 /usr/bin/kemi-gnome-maps。官方包不含 .mo（Ubuntu 语言包拆分；桌面项 X-Ubuntu-Gettext-Domain=gnome-maps），亦无 /usr/share/help，未发明或捆绑语言包与帮助树。官方应用图标仅为 SVG；未在包内发明 PNG。官方桌面图标为 org.gnome.Maps。官方 D-Bus 服务 Exec 已是绝对路径并保持不变。官方桌面 Exec=gapplication 已改为 /usr/bin/gapplication。本包提供版本化 Provides: gnome-maps (= 3.36.1-1ubuntu1)。官方来源为 Ubuntu 20.04 focal-updates universe gnome-maps 3.36.1-1ubuntu1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-maps_3.36.1-1ubuntu1_arm64.deb 重打包为 kemi-gnome-maps；GJS / GTK3 typelib 图形界面，私有 aarch64 库 glibc 2.17。合主线：gork.bot协助开发

合主线：gork.bot协助开发
