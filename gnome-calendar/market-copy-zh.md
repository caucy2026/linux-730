# GNOME Calendar

短描述：GNOME Calendar 日历（arm64）

长描述：GNOME Calendar 3.36.2 — 面向 GNOME 桌面的简洁日历，用于查看和管理日程。官方 Ubuntu 20.04（focal-updates main，较 focal Release 3.36.1-1 更新，仍为 Ubuntu 20.04 依赖）arm64 当前正式包。同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方 Recommends evolution-data-server（异源，非精确版本插件依赖）保持为推荐，未捆绑。官方无 Suggests。探针：aarch64，1 个 ELF（/usr/bin/gnome-calendar），requiredGlibc 2.17（1 个有版本需求、0 个空值），无 GLIBCXX（0 个有版本需求、1 个空值），满足 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/gnome-calendar（嵌入 /usr/share/locale，界面在 GResource 中）；/opt/gnome-calendar 下仅为符号链接。桌面项、官方 SVG 图标、gsettings schema、D-Bus 服务与 GNOME Shell 搜索提供者保留在标准路径。官方包不含 .mo，也无 /usr/share/help，未发明语言包或帮助树。官方图标仅为 SVG；用于商场 CREATE 的 128×128 PNG 由官方 SVG 栅格化，只放在 evidence/，未打进 deb。官方 D-Bus 服务已使用绝对路径并保留。官方来源为 Ubuntu 20.04 focal-updates main gnome-calendar 3.36.2-0ubuntu1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-calendar_3.36.2-0ubuntu1_arm64.deb 重打包为 kemi-gnome-calendar。合主线：gork.bot协助开发

合主线：gork.bot协助开发
