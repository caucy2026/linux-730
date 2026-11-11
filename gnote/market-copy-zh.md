# Gnote

短描述：Gnote 笔记（arm64）

长描述：官方 Ubuntu 20.04（focal universe）gnote 3.36.0-1（Architecture: arm64）KEMI 重打包。GTK3 C++ 桌面笔记应用（Tomboy 移植），支持 Wiki 风格互链。官方 /usr/bin/gnote 为编译的 aarch64 ELF（内嵌 /usr/share/locale、/usr/share/icons 与 /usr/share/gnote）；官方公共库 libgnote-3.36 与 21 个官方插件留在 /usr/lib/aarch64-linux-gnu；/opt/gnote 下仅为符号链接。另有 /usr/bin/kemi-gnote。同源源码在 focal 仅此一个二进制包，无 -data/-common 可捆绑。官方控制文件无 Recommends、无 Suggests。系统 GTK3 / gtkmm / gspell / libsecret 依赖保持为 Depends，未捆绑。探针：23 个独立包装 ELF，requiredGlibc 2.29（23 个有版本需求：22 个 2.17、1 个 2.29，0 个空值；最大值 2.29，空值不作为最大值），requiredGlibcxx 3.4.21（23 个有版本需求：10 个 3.4、1 个 3.4.15、12 个 3.4.21，0 个空值；最大值 3.4.21，空值不作为最大值），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方包含 52 个 .mo（含 zh_CN / zh_TW / zh_HK）。官方帮助为真实的 C 语言树，另有官方翻译帮助（cs、da、de、el、es、fr、hu、lt、pl、ru、sl、sv、zh_CN），无悬空 help-langpack 链接；官方帮助 PNG 留在官方帮助树中，不是商城图标。官方应用图标含 hicolor 16–256 PNG 及 SVG；官方应用内图标留在 /usr/share/gnote/icons。未在包内另造 PNG。官方桌面图标为 gnote。官方桌面 Name=Gnote（appdata Name=Gnote，含 zh_CN）。官方桌面 Exec=gnote %u 已改为 /usr/bin/gnote %u；已添加 TryExec。官方 D-Bus Exec=/usr/bin/gnote --shell-search 已是绝对路径并保持不变。官方插件 .desktop 为 AddinInfo 元数据（无 Exec）并保持原样。本包提供版本化 Provides: gnote (= 3.36.0-1)。官方 shlibs 已改指向 kemi-gnote；官方 ldconfig trigger 已保留。官方来源为 Ubuntu 20.04 focal universe gnote 3.36.0-1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gnote_3.36.0-1_arm64.deb 重打包为 kemi-gnote；GTK3 C++ 图形界面，23 个 aarch64 ELF，glibc 2.29（22×2.17 + 1×2.29），GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
