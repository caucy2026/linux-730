# Onboard

短描述：Onboard 屏幕键盘（arm64）

长描述：Onboard 1.4.1 — 灵活的屏幕键盘（On-screen Keyboard），支持宏、便捷布局编辑和单词联想，适合平板或行动不便的场景。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包，并已捆绑同版本 arch:all 的 onboard-common（硬依赖：布局、主题、locale、图标、帮助）以及官方建议包 onboard-data（29 个语言型号，用于单词联想；官方型号集无 zh_*）。探针 2 个 ELF（CPython 3.8 扩展）：osk requiredGlibc 2.17、无 GLIBCXX；lm requiredGlibc 2.29、GLIBCXX 3.4.21；适配 Ubuntu 20.04 / KEMI 101（需 Python 3.8）。布局 /opt/onboard + /usr/bin/onboard、/usr/bin/onboard-settings；Python 模块与扩展仍在 /usr/lib/python3/dist-packages/Onboard。桌面项、手册、图标、GSettings schema、D-Bus 服务、C 语言帮助、布局/主题/UI 与语言模型保留在 /usr/share。官方桌面图标为 onboard。本包捆绑 98 种 locale（含 zh_CN / zh_HK / zh_TW）。运行时依赖系统 Python 3.8、GTK3 typelib、cairo、hunspell、dconf、libcanberra、X11/Xi/Xtst/xkbfile、udev、libstdc++6、libc6 ≥ 2.29 及 gsettings 后端，均为 Ubuntu 20.04 仓库包；建议安装 gir1.2-appindicator3-0.1、gir1.2-atspi-2.0 与 xdg-utils。官方来源为 Ubuntu 20.04 focal universe arm64 onboard 1.4.1-2ubuntu7（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 onboard_1.4.1-2ubuntu7_arm64.deb 及 onboard-common、onboard-data 重打包为 kemi-onboard（common 与语言模型已捆绑）；探针 2 ELF，requiredGlibc 2.17 / 2.29，lm GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
