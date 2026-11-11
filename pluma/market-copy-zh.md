# Pluma

短描述：Pluma 文本编辑器（arm64）

长描述：Pluma 1.24.0 — MATE 桌面的官方文本编辑器，支持标签页、语法高亮与插件。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包，并已捆绑同版本 arch:all 的 pluma-common（硬依赖：locale、帮助、UI、schema）以及同版本 gir1.2-pluma-1.0（同源 typelib）。探针 10 个 ELF（主程序 + 9 个插件 .so）：全部 requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr，保留在 /usr/bin/pluma；插件与 typelib 保留在 /usr/lib 标准路径；/opt/pluma/pluma 仅为指向 /usr/bin/pluma 的符号链接。桌面项、手册、GSettings schema、metainfo、UI、帮助与 119 种 locale（含 zh_CN / zh_TW）保留在 /usr/share。官方桌面图标为 accessories-text-editor（主题图标，本包不随带）。运行时依赖系统 GTK3、GtkSourceView 3、libpeas、gir1.2-peas-1.0、iso-codes、mate-desktop-common、python3、enchant、cairo、pango、X11、gsettings 后端与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包；建议安装 zenity。官方来源为 Ubuntu 20.04 focal universe arm64 pluma 1.24.0-1（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 pluma_1.24.0-1_arm64.deb 及 pluma-common、gir1.2-pluma-1.0 重打包为 kemi-pluma（common 与 typelib 已捆绑）；探针 10 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
