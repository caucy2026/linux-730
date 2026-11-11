# Pavucontrol

短描述：Pavucontrol 音量控制（arm64）

长描述：Pavucontrol 4.0 — 轻量 GTK3 PulseAudio 音量控制（混音器），可分别调节硬件设备和各播放流音量，并在不中断播放的情况下将播放流重定向到其他输出设备。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），requiredGlibcxx 3.4.21（低于 101 的 GLIBCXX 3.4.28），适配 Ubuntu 20.04 / KEMI 101。布局 /opt/pavucontrol + /usr/bin/pavucontrol；语言包、桌面项、手册和编译期内置的 glade 界面保留在 /usr/share（/usr/share/pavucontrol/pavucontrol.glade）。官方桌面图标为 multimedia-volume-control（主题图标，本包未内置）。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.0.0）、GTKMM3（libgtkmm-3.0-1v5 ≥ 3.24.0）、libatkmm-1.6-1v5 ≥ 2.24.0、libglibmm-2.4-1v5 ≥ 2.54.0、libsigc++-2.0-0v5 ≥ 2.2.0、libcanberra-gtk3-0、libcanberra0、libpulse0 ≥ 4.0、libpulse-mainloop-glib0、libgcc-s1、libstdc++6 ≥ 5.2、libglib2.0-0 ≥ 2.16.0、libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 pavucontrol 4.0-1build1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 为 libgcc-s1 包名变更做 no-change rebuild 后进入 Release。建议安装 pulseaudio。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 pavucontrol_4.0-1build1_arm64.deb 重打包为 kemi-pavucontrol；探针 requiredGlibc 2.17（1 ELF），requiredGlibcxx 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
