# GNOME System Monitor

短描述：GNOME 系统监视器（arm64）

长描述：GNOME System Monitor 3.36.1 — GNOME 官方进程查看与系统资源监视器（CPU、内存、网络与进程管理）。官方 Ubuntu 20.04（focal-updates，新于 Release 3.36.0）arm64 当前正式包重打包。商场已有 LXTask（app337），但桌面/工具链不同。探针 3 个 ELF：主程序 requiredGlibc 2.29、GLIBCXX 3.4.21；pkexec 助手 gsm-kill / gsm-renice requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale、/usr/share/gnome-system-monitor/gsm.gresource、/usr/libexec/gnome-system-monitor），保留在 /usr/bin 与 /usr/libexec；/opt/gnome-system-monitor 下仅为符号链接。桌面项、polkit 策略、gschema、gresource、手册、metainfo、官方帮助树与图标保留在标准路径。官方桌面图标为 org.gnome.SystemMonitor（本包随带 SVG）。官方语言包拆分：本 deb 不含 .mo；C 帮助为实文件，其他帮助语言为官方 help-langpack 符号链接，未捆绑 language-pack。运行时依赖系统 GTK3、gtkmm、glibmm、libgtop、librsvg、libsigc++、libsystemd、libstdc++6 与 libc6 ≥ 2.29，均为 Ubuntu 20.04 仓库包。官方 Recommends gvfs 保留为推荐依赖、未捆绑。官方来源为 Ubuntu 20.04 focal-updates main arm64 gnome-system-monitor 3.36.1-0ubuntu0.20.04.1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gnome-system-monitor_3.36.1-0ubuntu0.20.04.1_arm64.deb（focal-updates）重打包为 kemi-gnome-system-monitor；探针 3 ELF，requiredGlibc 2.29 / 2.17，GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
