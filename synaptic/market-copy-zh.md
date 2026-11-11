# Synaptic

短描述：官方 Ubuntu 20.04 Synaptic 图形包管理器（focal，arm64）

长描述：Synaptic 0.84.6ubuntu5，官方 Ubuntu 20.04（focal universe）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。官方 /usr/sbin/synaptic 为 aarch64 ELF，留在官方路径；官方 /usr/bin/synaptic-pkexec 为 shell 包装脚本，不是 ELF。官方文件留在官方路径；/opt/synaptic 下仅为符号链接。另有 /usr/bin/kemi-synaptic → synaptic-pkexec。官方 Depends 保持为 Depends，未捆绑。官方 Recommends（libgtk3-perl、xdg-utils）与 Suggests 保持原字段，未捆绑。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），requiredGlibcxx 3.4.21（1 个有版本需求，0 个空值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（不发明语言包）。官方非 C 帮助可能是 help-langpack 符号链接，保持官方原文，不发明语言包。官方应用图标为 48×48 pixmap，无官方 256 与 SVG；商城 CREATE 使用该官方 48×48 PNG，不二次打进 deb。官方应用内 / 帮助 PNG 保持官方原文。官方桌面图标为 synaptic。官方桌面 Name=Synaptic Package Manager；商城 app_name=Synaptic。官方桌面 Exec=synaptic-pkexec 已改写为 /usr/bin/synaptic-pkexec；已添加 TryExec=/usr/bin/synaptic-pkexec。官方 PolicyKit exec.path=/usr/sbin/synaptic 已是绝对路径并保持不变。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: synaptic (= 0.84.6ubuntu5)。官方来源为 Ubuntu 20.04 focal universe synaptic 0.84.6ubuntu5（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 synaptic 0.84.6ubuntu5（focal universe arm64）。官方 ELF 留在 /usr/sbin/synaptic；/opt 仅为符号链接。官方 Depends / Recommends / Suggests 未捆绑。官方桌面 Exec 已改写为绝对路径。官方 48×48 pixmap 用于商城图标，未二次打进 deb。探测 1 ELF，glibc 2.17，GLIBCXX 3.4.21。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
