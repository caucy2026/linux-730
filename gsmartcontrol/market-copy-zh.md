# GSmartControl

短描述：官方 Ubuntu 20.04 GSmartControl 磁盘健康工具（focal，arm64）

长描述：GSmartControl 1.1.3-2build1，官方 Ubuntu 20.04（focal universe）Architecture: arm64 软件包的 KEMI 重打包。focal-updates 无更新包。GTK3 SMART 磁盘健康工具，后端为系统 smartctl。官方 /usr/sbin/gsmartcontrol 为已编译的 aarch64 ELF（无 RUNPATH，仅链接系统库）。官方 /usr/bin/gsmartcontrol-root 为 bash 包装脚本，不是 ELF，通过 pkexec 启动 /usr/sbin/gsmartcontrol。官方文件留在官方路径；/opt/gsmartcontrol 下仅为符号链接。另有 /usr/bin/kemi-gsmartcontrol → gsmartcontrol-root。官方 GTK / glibmm / gtkmm 与 smartmontools (>= 5.43) 依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值），requiredGlibcxx 3.4.26（1 个有版本需求，0 个空值，空值不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方 GUI 包不含 .mo，无 Yelp 帮助（保持官方树，不另造语言包）。官方应用图标含 hicolor 16–256 PNG；官方 256×256 用作商城 CREATE --icon（Zim / gitg / gnote / glade 模式），未二次打包。官方应用内 icon_hdd.png / icon_cddvd.png 与官方 pixmap 留在官方树。官方桌面图标为 gsmartcontrol。官方桌面 Name=GSmartControl。官方桌面 Exec="/usr/bin/gsmartcontrol-root" 已是绝对路径并保持不变；已添加 TryExec=/usr/bin/gsmartcontrol-root。官方 PolicyKit exec.path=/usr/sbin/gsmartcontrol 已是绝对路径并保持不变。官方 changelog 为真实文件，已用 cp -L 复制。本包提供版本化 Provides: gsmartcontrol (= 1.1.3-2build1)。官方来源为 Ubuntu 20.04 focal universe gsmartcontrol 1.1.3-2build1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gsmartcontrol 1.1.3-2build1（focal universe Architecture: arm64）。官方 ELF 留在 /usr/sbin；官方包装脚本留在 /usr/bin；/opt 仅为符号链接。官方 GTK 与 smartmontools 依赖未捆绑。官方桌面 Exec 已是绝对路径并保持不变。官方 256×256 hicolor PNG 用于商城图标，未二次打包。探测 1 ELF，glibc 2.17，GLIBCXX 3.4.26。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
