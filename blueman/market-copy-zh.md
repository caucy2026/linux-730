# Blueman

短描述：Blueman 蓝牙管理器（arm64）

长描述：Blueman 2.1.2 — GTK+ 图形化蓝牙管理器，使用 BlueZ D-Bus 后端，提供适配器设置、设备配对、文件发送与托盘小程序。官方 Ubuntu 20.04（focal-updates universe，新于 Release 的 2.1.2-1 且仍兼容 U20；含 LP #1877524 与先前 focal-security CVE-2020-15238 / polkit 修复）arm64 当前正式包。无同源 common/data 包。探针 1 个 ELF：Python 3.8 aarch64 扩展 _blueman.cpython-38-aarch64-linux-gnu.so requiredGlibc 2.17、无 GLIBCXX；启动器为官方 Python 3 脚本（Depends：python3 ≥ 3.8~ 且 << 3.9，适配 U20），官方树无 PEP 585 构造。官方启动器保留在 /usr/bin，扩展与助手保留在官方 /usr/lib 路径；/opt/blueman 下仅为符号链接。桌面项、手册、官方 56 个 .mo（含 zh_CN）、UI、图标、D-Bus、systemd、polkit 与 conffiles 保留在标准路径。官方桌面图标为 blueman / blueman-device（本包随带 hicolor 图标与 pixmaps）。异源 libbluetooth3、typelib、bluez、Python/GTK 运行时未捆绑，保留为系统 Depends。官方 Recommends policykit-1 与 pulseaudio-module-bluetooth 保持为推荐，未捆绑。官方来源为 Ubuntu 20.04 focal-updates universe arm64 blueman 2.1.2-1ubuntu0.3；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 blueman_2.1.2-1ubuntu0.3_arm64.deb 重打包为 kemi-blueman；探针 1 ELF（cpython-38 aarch64 扩展）requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
