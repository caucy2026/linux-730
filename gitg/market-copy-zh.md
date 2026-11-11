# gitg

短描述：gitg Git 仓库浏览器（arm64）

长描述：官方 Ubuntu 20.04（focal universe）gitg 3.32.1-1（Architecture: arm64）KEMI 重打包。GTK3 Git 仓库浏览器：浏览历史、查看差异与文件树。官方 /usr/bin/gitg 为编译的 aarch64 ELF（RUNPATH /usr/lib/gitg）；私有库与插件留在官方路径；/opt/gitg 下仅为符号链接。另有 /usr/bin/kemi-gitg。同源源码在 focal 仅此一个二进制包，无 -data/-common 可捆绑。官方控制文件无 Recommends、无 Suggests。系统 typelib / git / GTK3 / libgit2-glib 依赖保持为 Depends，未捆绑。探针：5 个独立包装 ELF，requiredGlibc 2.17（4 个有版本需求，1 个无 libc 版本需求，空值不作为最大值；无版本需求的是官方插件 libdiff.so），无 GLIBCXX（0 个有版本需求，5 个 null），对 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）满足。官方包不含 .mo（Ubuntu 语言包拆分；桌面项 X-Ubuntu-Gettext-Domain=gitg），亦无 /usr/share/help，未发明或捆绑语言包与帮助树。官方应用图标含 hicolor 16–256 PNG 及 symbolic SVG；未在包内另造 PNG。官方桌面图标为 org.gnome.gitg。官方桌面 Exec=gitg --no-wd %U 已改为 /usr/bin/gitg。本包提供版本化 Provides: gitg (= 3.32.1-1)。官方 shlibs 已改指向 kemi-gitg。官方来源为 Ubuntu 20.04 focal universe gitg 3.32.1-1（Architecture: arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 gitg_3.32.1-1_arm64.deb 重打包为 kemi-gitg；GTK3 图形界面，5 个 aarch64 ELF，glibc 2.17（4 有版本、1 空值），无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
