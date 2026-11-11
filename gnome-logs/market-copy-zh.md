# GNOME Logs

短描述：GNOME Logs 日志（arm64）

长描述：GNOME Logs 3.34.0 — 用于查看 systemd 日志（journal）中的系统事件记录。官方 Ubuntu 20.04（focal-updates main，较 focal Release 3.34.0-1 更新，仍为 Ubuntu 20.04 依赖）arm64 当前正式包。同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方控制文件无 Recommends、无 Suggests。系统库依赖保持为 Depends，未捆绑。探针：1 个独立包装 ELF（/usr/bin/gnome-logs，aarch64），requiredGlibc 2.17（1 个有版本需求，0 个 null），无 GLIBCXX（0 个有版本需求，1 个 null，null 不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31）满足。ELF 内嵌 /usr/share/locale 与 help:gnome-logs（界面在 GResource 中），官方文件保留在官方路径；/opt/gnome-logs 下仅为符号链接。另有 /usr/bin/kemi-gnome-logs。官方包不含 .mo（Ubuntu 语言包拆分；桌面项 X-Ubuntu-Gettext-Domain=gnome-logs）。官方帮助为真实的 C 语言树，另有官方 help-langpack 符号链接，未发明或捆绑语言包与帮助树。官方应用图标仅为 SVG；未在包内发明 PNG。官方桌面图标为 org.gnome.Logs。官方 D-Bus 服务 Exec 已是绝对路径并保持不变。官方桌面 Exec=gnome-logs 已改为 /usr/bin/gnome-logs。本包提供版本化 Provides: gnome-logs (= 3.34.0-1ubuntu1)。官方来源为 Ubuntu 20.04 focal-updates main gnome-logs 3.34.0-1ubuntu1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnome-logs_3.34.0-1ubuntu1_arm64.deb 重打包为 kemi-gnome-logs；GTK3 图形界面，aarch64 ELF glibc 2.17。合主线：gork.bot协助开发

合主线：gork.bot协助开发
